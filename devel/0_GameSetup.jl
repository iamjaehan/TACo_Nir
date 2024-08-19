# 2830898829&Courtesy&&&USR&45321&5_1_2021&1000&PATH&GEN&31_12_2025&0_0_0&6000&0_0

using datfm
using BlockArrays
using Combinatorics
using Statistics
using Random

include("Auction.jl")
include("World.jl")
include("Vote.jl")
include("DiscountAuction.jl")
include("PrivateInfo.jl")

function GenSeqSeed(n)
    if n>=10
        println("[Warning] n too big. n! is a dangerous thing.")
    end
    return collect(permutations(collect(1:n)))
end

function GetCombination(n)
    return collect(combinations(collect(1:n),2))
end

function GetPermPair(n)
    return collect(permutations(collect(1:n,2)))
end

function SetGame(n, seed)
    rng = rand(MersenneTwister(seed),2)
    rng1 = MersenneTwister(convert(Int64,ceil(rng[1]*1000)))
    rng2 = MersenneTwister(convert(Int64,ceil(rng[2]*1000)))
    # println("Seed: $(seed)")

    D = 5 # Separation distance
    L = 12 # Dispersed range 
    e = rand(rng1,n)*L # Initial ETA for the players
    eInit = deepcopy(e)
    ψ = rand(rng2,n)*10

    conflictNum = 0
    seqList = GenSeqSeed(n)
    pairList = GetCombination(n)
    for pairs in pairList
        if abs(e[pairs[1]]-e[pairs[2]]) < D
            conflictNum = conflictNum + 1
        end
    end

    (; D, L, n, e, ψ, seqList, conflictNum, eInit)
end

function UpdateGame(gameInfo, e)
    (; gameInfo.D, gameInfo.L, gameInfo.n, e, gameInfo.ψ, gameInfo.seqList, gameInfo.conflictNum)
end

function GetConstraint(x,e,n,D,seq,ii) # for player ii
    constraintSet = Vector{Any}(undef,0)
    pairList = GetCombination(n)
    for pairs in pairList
        if seq[pairs[1]] <= seq[pairs[2]] #1 is ahead
            constraintSet = vcat(constraintSet, [e[pairs[1]] + x[pairs[1]]] - [e[pairs[2]] + x[pairs[2]]] - [D])
        else
            constraintSet = vcat(constraintSet, -[e[pairs[1]] + x[pairs[1]]] + [e[pairs[2]] + x[pairs[2]]] - [D])
        end
    end
    return constraintSet[ii]
end

function EvalEffort(x,ψ)
    return ψ*x'*x
end

function EvalFairness(x, ψ, ii)
    return 0
end

function CalcJ(x, ψ, ii)
    return EvalEffort(x, ψ[ii]) + EvalFairness(x, ψ, ii)
end

# Define functions
function generateAseq(i,ai,m,n)
    primeChoice = "1:$m"
    stringUnit = ""
    for j in 1:n
        if j == i
            stringUnit = stringUnit*"$ai"*","
        else
            stringUnit = stringUnit*primeChoice*","
        end
    end
    stringUnit = chop(stringUnit)
    stringSum = "vec(collect(Iterators.product("*stringUnit*")))"
    aSet = eval(Meta.parse(stringSum))
    return aSet
end

function measureOverallDist(N1,N2)
    x = N1-N2
    return sqrt(x'*x)
end

function measureDist(N1,N2,i)
    x = N1[i] - N2[i]
    return sqrt(x'*x)
end

function EvolveDynamics(e, v, ref, maxDv, dt)
    # updateRate = 0.2
    # return e + updateRate*(ref - e)*dt

    m = 10
    c = 2
    k = 0.2
    error = (ref - e)
    dd = (-c*v + k*error)/m
    v = v + dd*dt
    # println("[Dyn] Damping ratio: $(round(c/(2*sqrt(m*k)),digits=2))")
    return e + v*dt, v
    
    # error = ref - e
    # if error != 0
    #     out = e + min(maxDv,abs(error)) * error / abs(error)
    # else
    #     out =  e
    # end
    # return out
end

function Roulette(x)
    x = x./sum(x) # Normalize
    x_cum = cumsum(x) .- x[1]
    fix = rand(1)[1]
    for i in 1:length(x)
        if fix >= x_cum[i]
            return i
        end
    end
    return nothing
end

function ExtractMyU(NashSet,idx)
    nNash = length(NashSet)
    myU = randn(1, nNash)
    for i = 1:nNash
        myU[i] = NashSet[i][idx]
    end
    return myU
end

function GetCostList(gameInfo, NashList)
    n = gameInfo.n
    ψ = gameInfo.ψ
    nNash = length(NashList)
    costList = Array{Float64,2}(undef, n, nNash)
    for i = 1:n
        for j = 1:nNash
            costList[i,j] = CalcJ(NashList[j][i],ψ,i)
        end
    end
    return costList
end

function EvalSystemScore(gameInfo, NashList, idx)
    n = gameInfo.n
    ψ = gameInfo.ψ
    systemScore = 0
    for i = 1:n
        systemScore = systemScore + sqrt(CalcJ(NashList[idx][i],ψ,i))
    end
    return systemScore
end