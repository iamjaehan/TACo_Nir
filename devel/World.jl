using datfm
using MAT

abstract type PrefSelectionStrategy end
struct Selfish <: PrefSelectionStrategy end
struct SystemOptimal <: PrefSelectionStrategy end
struct Voting <: PrefSelectionStrategy end
struct Auction <: PrefSelectionStrategy end
struct RandomDemo <: PrefSelectionStrategy end

function ChoosePreference(c::SystemOptimal, nashList, gameInfo, privateInfo, disc, interrupt) # Selection method
    n = gameInfo.n
    ψ = gameInfo.ψ
    listLen = length(nashList)
    choiceList = Vector{Any}(undef,0)
    for i in 1:n
        candidateList = Vector{Any}(undef,0)
        for j in 1:listLen
            candidateList = vcat(candidateList, CalcJ(nashList[j][i],ψ,i))
        end
        choiceList = vcat(choiceList,findmin(SystemPreference(nashList, gameInfo))[2])
    end
    return (;choiceList)
end

function ChoosePreference(c::Selfish, nashList, gameInfo, privateInfo, disc, interrupt)
    n = gameInfo.n
    ψ = gameInfo.ψ
    listLen = length(nashList)
    choiceList = Vector{Any}(undef,0)
    for i in 1:n
        candidateList = Vector{Any}(undef,0)
        for j in 1:listLen
            candidateList = vcat(candidateList, CalcJ(nashList[j][i],ψ,i))
        end
        choiceList = vcat(choiceList, findmin(candidateList)[2])      
    end
    return choiceList
end

function ChoosePreference(c::Voting, nashSet, gameInfo, privateInfo, disc, interrupt)
    n = gameInfo.n
    NashNum = length(nashSet)
    out = RunVote(gameInfo, nashSet)
    bestIdx = out.bestIdx
    count = out.count
    choiceList = fill(bestIdx,n)
    return (;choiceList, count)
end

function ChoosePreference(c::Auction, nashSet, gameInfo, privateInfo, disc, interrupt)
    n = gameInfo.n
    NashNum = length(nashSet)
    out = RunDiscAuction(gameInfo, nashSet, privateInfo, disc, interrupt)
    bestIdx = out.bestIdx
    count = out.count
    priceVec = out.priceVec
    costVec = out.costVec
    choiceList = fill(bestIdx,n)
    return (;choiceList, count, priceVec, costVec)
end

function ChoosePreference(c::RandomDemo, nashSet, gameInfo, privateInfo, disc, interrupt)
    n = gameInfo.n
    NashNum = length(nashSet)
    out = RunRD(gameInfo, nashSet)
    bestIdx = out.choice
    averageCost = out.averageCost
    averageFairness = out.averageFairness
    choiceList = fill(bestIdx,n)
    return (;choiceList, averageCost, averageFairness)
end

function SystemPreference(nashList, gameInfo)
    n = gameInfo.n
    ψ = gameInfo.ψ
    listLen = length(nashList)

    systemScoreList = Vector{Any}(undef,0)
    for i = 1:listLen
        # systemScore = 0
        # for j = 1:n
        #     systemScore = systemScore + CalcJ(nashList[i][j],ψ,j)
        # end
        systemScore = EvalSystemScore(gameInfo, nashList, i)
        systemScoreList = vcat(systemScoreList, systemScore)
    end
    return systemScoreList
end

function RunScenario(n)
    out = SearchAllNash(n)
    choiceList = ChoosePreference(Voting(), out.primalsList, out.gameInfo)
    return choiceList
end

# Single game
function RunSim(n, termStep, seed, prefSelectionStrategy::PrefSelectionStrategy; matWrite=true, usePrivateInfo=true,
    disc = 10, interrupt = Inf)
    dt = 1 #ADS-B update rate
    simT = 80
    maxDv = 1 * dt

    simStep = simT/dt

    global gameInfo = SetGame(n, seed)
    # println("GameInfo: n = $(n), ψ = $(gameInfo.ψ)")
    # println("===============")
    ψ = gameInfo.ψ

    out = SearchAllNash(gameInfo)
    global NashSet = out.primalsList
    NashNum = length(NashSet)
    gameInfo = out.gameInfo

    e = deepcopy(gameInfo.eInit)
    eInit = deepcopy(e)
    eHistory = Vector{Any}(undef,0)
    etemp = deepcopy(eInit)
    eHistory = vcat(eHistory, [etemp])
    v = zeros(n)

    global cumDist = zeros(NashNum)
    # Select their preference
    if usePrivateInfo
        GenPrivatePref(gameInfo, seed, disc)
    else
        GenFakePrivatePref(gameInfo, seed, disc)
    end
    privateInfo = GetPrivatePref()
    tempOut = ChoosePreference(prefSelectionStrategy, NashSet, gameInfo, privateInfo, disc, interrupt)
    global choiceList = tempOut.choiceList
    if prefSelectionStrategy == Auction()
        priceVec = tempOut.priceVec
        fairness_private = EvalGini(gameInfo, priceVec)
        costVec = tempOut.costVec
        fairness_public = EvalGini(gameInfo, costVec)
        count = tempOut.count
    elseif prefSelectionStrategy == Voting()
        count = tempOut.count
    elseif prefSelectionStrategy == RandomDemo()
        averageCost = tempOut.averageCost
        averageFairness = tempOut.averageFairness
    end

    global sysOpt = ChoosePreference(SystemOptimal(), NashSet, gameInfo, privateInfo, disc, interrupt)
    sysOpt = sysOpt.choiceList[1]

    # Run scenario
    for t in 1:simStep
        # Action for dt
        for i in 1:n
            e[i], v[i] = EvolveDynamics(e[i], v[i], eInit[i] + NashSet[choiceList[i]][i], maxDv, dt)
        end
        etemp = deepcopy(e)
        eHistory = vcat(eHistory,[etemp])

        # # Infer (overall)
        overallDistList = Vector{Any}(undef,0)
        for j in 1:NashNum
            overallDistList = vcat(overallDistList, measureOverallDist(e, NashSet[j]))
        end
        cumDist = cumDist + overallDistList

        # # Infer (individual)
        # distList = Vector{Any}(undef,0)
        # for i in 1:n # for individual player
        #     indDistList = Vector{Any}(undef,0) # dist to an equi j of player i
        #     for j in 1:NashNum # for each equil.
        #         indDistList = vcat(indDistList, measureDist(e, NashSet[j], i))
        #     end
        #     distList = vcat(distList, [indDistList])
        # end
        
        # # Update decision
        # if t % termStep == 0
        #     println(choiceList)
        #     println("Update")
        #     global choiceList = fill(findmin(cumDist)[2], n)
        #     for i = 1:n
        #         choiceList[i] = Roulette(map(x->1/x, cumDist))
        #     end
        #     # choiceList = fill(Roulette(1./cumDist), n)
        #     println(choiceList)
        #     cumDist = zeros(NashNum)
        # end

        # println(round.(e,digits=2))
        # println(round.(distList,digits=2))
        # println(sortperm(overallDistList))
        # println(round.(overallDistList,digits=2))
        # println(map(x -> round.(x./sum(x),digits=2), distList))
    end
    # println(systemOptIdx)
    # println("============")
    
    if matWrite
        matwrite("Analysis/eHistory_similarity.mat",Dict(
            "eHistory" => eHistory,
            "psi" => ψ
        ); version="v7.4")
    end

    if prefSelectionStrategy != RandomDemo()
        currentScore = EvalSystemScore(gameInfo, NashSet, choiceList[1])
    else
        currentScore = averageCost
    end
    optScore = EvalSystemScore(gameInfo, NashSet, sysOpt)

    # println(optScore)
    # println(currentScore)
    optGap = (currentScore-optScore)/optScore
    if prefSelectionStrategy == Auction() || prefSelectionStrategy == Voting()
        if prefSelectionStrategy == Voting()
            costList = GetCostList(gameInfo, NashSet)
            fairness = EvalGini(gameInfo, costList[:,choiceList[1]])
            return (;optGap, count, fairness)
        else
            return (;optGap, count, fairness = fairness_private, fairness_public)
        end
    elseif prefSelectionStrategy == RandomDemo()
        return (;optGap, count = 1, averageCost, fairness = averageFairness)
    else
        costList = GetCostList(gameInfo, NashSet)
        fairness = EvalGini(gameInfo, costList[:,sysOpt])
        return (;optGap, count = 1, fairness)
    end
end
