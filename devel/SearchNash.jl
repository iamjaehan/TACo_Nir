using datfm
using BlockArrays: Block

function PrepNash(gameInfo,seqIdx)
    n = gameInfo.n

    # Construct variables
    # global fs = [(x, θ) -> x[Block(ii)]'*C[m*(ii-1)+1:m*ii,:]*x for ii in 1:n]
    # gs = [(x, θ) -> [sum(x[Block(ii)]) - 1] for ii in 1:n]
    # hs = [(x, θ) -> x[Block(ii)] for ii in 1:n]
    # g̃ = (x, θ) -> [0]
    # h̃ = (x, θ) -> [0]

    # Constraint as a shared constraint
    fs = [(x,θ) -> x[Block(ii)]]
    gs = (x,θ) -> [0]
    hs = (x,θ) -> [0]
    g̃ = (x,θ) -> [0]
    h̃ = [(x,θ) -> [(x,θ) -> GetConstraint(x,gameInfo.e,n,seq[seqIdx],ii)] for ii in 1:gameInfo.conflictNum] # Need a vector here

    println(n)
    println(h̃)
    println("=====")
    println(fs)
    println("******")
    println(gameInfo.conflictNum)
    println(gameInfo)

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
        shared_inequality_dimension = gameInfo.conflictNum, # Included if we have control output contraint
    )

    return (; problem, C, m, n)
end

function SolveNash(problem,C,m,n,isRndGuess)
    # Randomize seed?
    if isRndGuess
        # initial_guess = rand(total_dim(problem))
        # PNE guess
        # initial_guess = zeros(total_dim(problem))
        # initial_guess[n*m+n+1:end-2] .= rand(1)*50
        # rndIdx = Vector{Int64}(undef,n)
        # for i in 1:n
        #     rndIdx[i] = argmax(rand(m))
        # end
        # for i in 1:n
        #     initial_guess[rndIdx[i]+(i-1)*m] = 1
        #     initial_guess[rndIdx[i]+(i-1)*m + n*m+n] = 0
        # end
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
        # MNE guess
        # initial_guess = zeros(total_dim(problem))
        # for i = 1:n
        #     localGuess = rand(m)
        #     localGuess = localGuess/sum(localGuess)
        #     initial_guess[1+(i-1)*m:i*m] = localGuess
        # end
    else
        initial_guess = zeros(total_dim(problem))
    end

    # Solve!
    solverTime = @elapsed (; primals, variables, status, info) = solve(problem, [0], initial_guess = initial_guess)

    (; primals, score = CalcJNash(C,primals,m,n), varsize = size(primals)[1]*m, solverTime, status)
end

function SearchNash(r,n,λ,isRndGuess,Δ)
    gameInfo = SetGame(n)
    (; problem, C, m, n) = PrepNash(gameInfo,1) # Add seq index
    (; primals, score, varsize, solverTime, status) = SolveNash(problem, C, m, n, isRndGuess)
    
    (; primals)
end 