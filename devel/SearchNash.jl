using datfm
using BlockArrays: Block

function PrepNash(gameInfo,seqIdx)
    n = gameInfo.n
    e = gameInfo.e
    D = gameInfo.D
    ψ = gameInfo.ψ
    seq = gameInfo.seqList[seqIdx]
    combNum = length(GetCombination(n))

    # Constraint as a shared constraint
    fs = [(x,θ) -> CalcJ(x,ψ,ii) for ii in 1:n]
    gs = [(x,θ) -> [0] for ii in 1:n]
    hs = [(x,θ) -> [0] for ii in 1:n]
    g̃ = (x,θ) -> [0]
    h̃ = [(x,θ) -> GetConstraint(x,e,n,D,seq,ii) for ii in 1:combNum] # Need a vector here

    global problem = ParametricGame(
        objectives = fs,
        equality_constraints = gs,
        inequality_constraints = hs,
        shared_equality_constraint = g̃,
        shared_inequality_constraint = h̃,
        parameter_dimension = 1,
        primal_dimensions = fill(1, n),
        equality_dimensions = fill(1, n),
        inequality_dimensions = fill(1, n), # Included if we have control range constraint
        shared_equality_dimension = 1,
        shared_inequality_dimension = combNum, # Included if we have control output contraint
    )

    return (; problem, n)
end

function SolveNash(problem,n)
    # Randomize seed?
    if false
        # PNE guess - Smart duals
        initial_guess = zeros(total_dim(problem))
        rndIdx = Vector{Int64}(undef,n)
        equalityMultiplier = zeros(n)
        for i in 1:n
            rndIdx[i] = argmax(rand(m))
        end
        for i in 1:n
            initial_guess[rndIdx[i]+(i-1)*m] = 1
            initial_guess[rndIdx[i]+(i-1)*m + n*m+n] = 0
        end
        for i in 1:n
            primalSum = zeros(m)
            for j in 1:n
                primalSum .+= C[Block(i,j)] * initial_guess[(j-1)*m+1:j*m]
            end
            equalityMultiplier[i] = primalSum[rndIdx[i]]
            initial_guess[n*m+n + (i-1)*m+1 : n*m+n + i*m] = primalSum - ones(m)*equalityMultiplier[i]
        end
        initial_guess[n*m+1:n*m+n] = equalityMultiplier
    else
        initial_guess = zeros(total_dim(problem))
    end

    # Solve!
    solverTime = @elapsed (; primals, variables, status, info) = solve(problem, [0], initial_guess = initial_guess)
    primals_out = Vector{Any}(undef,0)

    for i in 1:length(primals)
        primals_out = vcat(primals_out,primals[i][1])
    end

    primals = primals_out

    (; primals, varsize = size(primals_out), solverTime, status)
end

function SearchNash(gameInfo, seqIdx)
    (; problem, n) = PrepNash(gameInfo, seqIdx) # Add seq index
    (; primals, varsize, solverTime, status) = SolveNash(problem, n)
    
    (; primals)
end

function SearchAllNash(n)
    global gameInfo = SetGame(n)
    println("GameInfo: n = $(n), ψ = $(gameInfo.ψ)")
    println("===============")
    primalsList = Vector{Any}(undef,0)
    seqList = gameInfo.seqList
    seqNum = length(seqList)
    for i in 1:seqNum
        out = SearchNash(gameInfo,i)
        primals = out.primals
        primalsList = vcat(primalsList, [primals])
        println("Searched $(i) out of $(seqNum) equilibria.")
    end
    (; primalsList, gameInfo)
end