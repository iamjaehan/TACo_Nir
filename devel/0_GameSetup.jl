# 2830898829&Courtesy&&&USR&45321&5_1_2021&1000&PATH&GEN&31_12_2025&0_0_0&6000&0_0

using datfm
using BlockArrays
using Combinatorics
using Statistics

function GenSeqSeed(n)
    if n>=10
        println("[Warning] n too big. n! is a dangerous thing.")
    end
    return collect(permutations(collect(1:n)))
end

function GetCombination(n)
    return collect(combinations(n))
end

function SetGame(n, wm, wp)
    D = 10
    L = 30
    e = rand(n)*30 # Initial ETA for the players
    seqList = GenSeqSeed(n)
end

function EvalJ(u)
end

# Define functions
# function generateAseq(i,ai,m,n)
#     primeChoice = "1:$m"
#     stringUnit = ""
#     for j in 1:n
#         if j == i
#             stringUnit = stringUnit*"$ai"*","
#         else
#             stringUnit = stringUnit*primeChoice*","
#         end
#     end
#     stringUnit = chop(stringUnit)
#     stringSum = "vec(collect(Iterators.product("*stringUnit*")))"
#     aSet = eval(Meta.parse(stringSum))
#     return aSet
# end

function CalcPhi(i,ai,_ai,x,m,n,C)
    aSeq = generateAseq(i,ai,m,n) # (i,ai)
    _aSeq = generateAseq(i,_ai,m,n) # (i,_ai)
    l = length(aSeq)
    phi = 0
    for j in 1:l
        zValue = x[CartesianIndex(aSeq[j])]
        aSeqV = [k for k in _aSeq[j]]
        for ii in 1:n
            aSeqV[ii] = aSeqV[ii] + m*(ii-1)
        end
        cValue = sum(C[m*(i-1)+ai,aSeqV])
        phi += zValue * cValue
    end
    return phi
end

function CalcJ(x, C, m, n)
    x = reshape(x,ntuple(i->m,n))
    aSeq = generateAseq(0,0,m,n) #Generates all the possible actions
    l = length(aSeq)
    J = 0
    for i in 1:l
        zValue = x[CartesianIndex(aSeq[i])]
        aSeqV = [k for k in aSeq[i]]
        for ii in 1:n
            aSeqV[ii] = aSeqV[ii] + m*(ii-1)
        end
        cValue = sum(C[aSeqV,aSeqV])
        J += zValue * cValue
    end
    return J
end

function CalcIndividualJ(x,idx,C,m,n)
    x = reshape(x,ntuple(i->m,n))
    aSeq = generateAseq(0,0,m,n) #Generates all the possible actions
    l = length(aSeq)
    J = 0
    for i in 1:l
        zValue = x[CartesianIndex(aSeq[i])]
        aSeqV = [k for k in aSeq[i]]
        for ii in 1:n
            aSeqV[ii] = aSeqV[ii] + m*(ii-1)
        end
        cValue = sum(C[aSeqV[idx],aSeqV])
        J += zValue * cValue
    end
    return J
end

function CalcH(x,m,n,C)
    x_f = reshape(x,ntuple(i->m,n))
    out = Vector{Any}(undef,m^n+m^2*n)
    out[1:length(x)] = x
    c = length(x)
    for i in 1:n
        for ai in 1:m
            for _ai in 1:m
                c += 1
                out[c] = CalcPhi(i,ai,ai,x_f,m,n,C) - CalcPhi(i,ai,_ai,x_f,m,n,C)
            end
        end
    end
    return out
end

function SwitchIndtoJoint(primals,m,n)
    aSeq = generateAseq(0,0,m,n)
    l = length(aSeq)
    jointPrimal = zeros(m^n,1)
    jointPrimal = reshape(jointPrimal,ntuple(i->m,n))
    for i in 1:l
        localIndex = CartesianIndex(aSeq[i])
        jointProb = 1
        for j in 1:length(localIndex)
            jointProb *= primals[j][localIndex[j]]
        end
        jointPrimal[localIndex] = jointProb
    end
    return reshape(jointPrimal,m^n)
end

function CalcJNash(C,primals,m,n)
    jointPrimal = SwitchIndtoJoint(primals,m,n)
    J = CalcJ(jointPrimal,C,m,n)
    return J
end

function CalcJNashSet(λ,nashSet,C, m, n)
    # jointProb = sum(nashSet.*λ,dims=1)[1]
    jointProb = nashSet*λ
    return CalcJ(jointProb, C, m ,n)
end

function SmoothMax(x)
    N = 10
    E = exp.(x*N)
    return ( x'*E ) / sum(E)
end

function CalcEFJ(xi, l, n, Δ)
    v = xi[l+1:end-1]
    J = -n*Δ + ones(n)'*v
    return J
end

function T1Const(xi,C,m,n,l)
    x = xi[1:l]
    c = Vector{Any}(undef,n)
    for i in 1:n
        c[i] = CalcIndividualJ(x, i, C, m ,n)
    end
    w = xi[end]
    return w .- c
end

function T2Const(xi,C,m,n,l,Δ)
    x = xi[1:l]
    c = Vector{Any}(undef,n)
    for i in 1:n
        c[i] = CalcIndividualJ(x, i, C, m ,n)
    end
    v = xi[l+1:end-1]
    return v - c .- Δ
end

function T3Const(xi,l)
    v = xi[l+1:end-1]
    w = xi[end]
    return v .- w
end

function CorrPacker(x,C,m,n,l,Δ)
    out = [CalcH(x[1:l], m, n, C);
    T1Const(x,C,m,n,l);
    T2Const(x,C,m,n,l,Δ);
    T3Const(x,l)]
    return out
end

function T1ConstN(xi,jointScore,C,m,n)
    c = jointScore
    w = xi[end]
    return w .- c
end

function T2ConstN(xi,jointScore,C,m,n,l,Δ)
    c = jointScore
    v = xi[l+1:end-1]
    return v - c .- Δ
end

function NashPacker(x,scoreSet,C,m,n,l,Δ)
    λ = x[1:l]
    jointScore = scoreSet'*λ
    out = [x[1:l];
    T1ConstN(x,jointScore,C,m,n);
    T2ConstN(x,jointScore,C,m,n,l,Δ);
    T3Const(x,l)]
    return out
end

function EvalFairness(primals,C,m,n,Δ)
    c = Vector{Any}(undef,n)
    for i in 1:n
        c[i] = CalcIndividualJ(primals, i, C, m, n)
    end
    return abs(maximum(c)-minimum(c))/Δ
end

function EvalGini(primals,C,m,n,Δ)
    c = Vector{Any}(undef,n)
    for i in 1:n
        c[i] = CalcIndividualJ(primals, i, C, m, n)
    end
    us = 0
    for i in 1:n-1
        for j in i+1:n
            us += abs(c[i]-c[j])
        end
    end
    return us/(2*mean(c)*n^2)
end

function EvalMaxCostDiff(primals, C, m, n)
    c = Vector{Any}(undef,n)
    for i in 1:n
        c[i] = CalcIndividualJ(primals, i, C, m, n)
    end
    return abs(maximum(c)-minimum(c))/Δ
end

function EvalAverageDelay(primals, C, m, n)
    return CalcJ(primals, C, m, n)/n
end