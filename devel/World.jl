using datfm
using MAT

abstract type PrefSelectionStrategy end
struct Selfish <: PrefSelectionStrategy end
struct SystemOptimal <: PrefSelectionStrategy end
struct Voting <: PrefSelectionStrategy end
struct Auction <: PrefSelectionStrategy end

function ChoosePreference(c::SystemOptimal, nashList, gameInfo, privateInfo, disc) # Selection method
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
    return choiceList
end

function ChoosePreference(c::Selfish, nashList, gameInfo, privateInfo, disc)
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

function ChoosePreference(c::Voting, nashSet, gameInfo, privateInfo, disc)
    n = gameInfo.n
    NashNum = length(nashSet)
    out = RunVote(gameInfo, nashSet, privateInfo)
    bestIdx = out.bestIdx
    count = out.count
    choiceList = fill(bestIdx,n)
    cumDist = zeros(NashNum)
    return (;choiceList, count)
end

function ChoosePreference(c::Auction, nashSet, gameInfo, privateInfo, disc)
    n = gameInfo.n
    NashNum = length(nashSet)
    out = RunDiscAuction(gameInfo, nashSet, privateInfo, disc)
    bestIdx = out.bestIdx
    count = out.count
    priceVec = out.priceVec
    costVec = out.costVec
    choiceList = fill(bestIdx,n)
    cumDist = zeros(NashNum)
    return (;choiceList, count, priceVec, costVec)
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
    disc = 10)
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
        GenPrivatePref(gameInfo, seed)
        privateInfo = GetPrivatePref()
    else
        privateInfo = ones(n)
    end
    tempOut = ChoosePreference(prefSelectionStrategy, NashSet, gameInfo, privateInfo, disc)
    global choiceList = tempOut.choiceList
    count = tempOut.count
    if prefSelectionStrategy == Auction()
        priceVec = tempOut.priceVec
        fairness_private = EvalGini(gameInfo, priceVec)
        costVec = tempOut.costVec
        fairness_public = EvalGini(gameInfo, costVec)
    end

    global sysOpt = ChoosePreference(SystemOptimal(), NashSet, gameInfo, privateInfo, disc)
    sysOpt = sysOpt[1]

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

    currentScore = EvalSystemScore(gameInfo, NashSet, choiceList[1])
    optScore = EvalSystemScore(gameInfo, NashSet, sysOpt)

    # println(optScore)
    # println(currentScore)
    optGap = (currentScore-optScore)/optScore
    if prefSelectionStrategy == Auction() || prefSelectionStrategy == Voting()
        if prefSelectionStrategy == Voting()
            return (;optGap, count)
        else
            return (;optGap, count, fairness_private, fairness_public)
        end
    else
        return (;optGap)
    end
end

# Iterative gaming
# function RunSim(n, termStep, seed)
#     dt = 1 #ADS-B update rate
#     simT = 80
#     maxDv = 1 * dt

#     simStep = simT/dt

#     # Initial setting
#     gameInfo = SetGame(n, seed)
#     out = SearchAllNash(gameInfo)
#     global NashSet = out.primalsList
#     global NashNum = length(NashSet)
#     e = deepcopy(gameInfo.eInit)
#     eInit = deepcopy(e)
#     eHistory = Vector{Any}(undef,0)
#     eHistory = vcat(eHistory, [eInit])

#     v = zeros(n)
#     global cumDist = zeros(NashNum)
#     choiceList = ChoosePreference(NashSet, gameInfo)

#     # Run scenario
#     for t in 1:simStep
#         # Select their preference
#         # choiceList = ChoosePreference(NashSet, gameInfo)

#         # Action for dt
#         for i in 1:n
#             e[i], v[i] = EvolveDynamics(e[i], v[i], eInit[i] + NashSet[choiceList[i]][i], maxDv, dt)
#         end
#         etemp = deepcopy(e)
#         eHistory = vcat(eHistory,[etemp])

#         # Infer (overall)
#         overallDistList = Vector{Any}(undef,0)
#         for j in 1:NashNum
#             overallDistList = vcat(overallDistList, measureOverallDist(e, NashSet[j]))
#         end
#         cumDist = cumDist + overallDistList

#         # Infer (individual)
#         # distList = Vector{Any}(undef,0)
#         # for i in 1:n # for individual player
#         #     indDistList = Vector{Any}(undef,0) # dist to an equi j of player i
#         #     for j in 1:NashNum # for each equil.
#         #         indDistList = vcat(indDistList, measureDist(e, NashSet[j], i))
#         #     end
#         #     distList = vcat(distList, [indDistList])
#         # end
        
#         # Update decision
#         if t % termStep == 0
#             println(choiceList)
#             println("Update")
#             choiceList = fill(findmin(cumDist)[2], n)
#             # for i = 1:n
#             #     choiceList[i] = Roulette(cumDist)
#             # end
#             # choiceList = fill(Roulette(cumDist), n)
#             cumDist = zeros(NashNum)

#             # Calculate Nash equilibrium
#             gameInfo = UpdateGame(gameInfo, e)
#             out = SearchAllNash(gameInfo)
#             global NashSet = out.primalsList
#             global NashNum = length(NashSet)
#         end

#         # println(round.(e,digits=2))
#         # println(round.(distList,digits=2))
#         # println(sortperm(distList))
#         # println("Individual Preference: $(ChoosePreference(NashSet, gameInfo))")
#         # println("System Preference: $(sortperm(SystemPreference(NashSet, gameInfo)))")
#         # println("========")
#         println("Step $(convert(Int64,t))")
#     end
#     # println(sortperm(SystemPreference(NashSet, gameInfo)))
#     println(eHistory)
#     matwrite("Analysis/eHistory_iterative2.mat",Dict(
#         "eHistory" => eHistory
#     ); version="v7.4")
# end