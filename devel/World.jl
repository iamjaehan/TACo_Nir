using datfm
using MAT

function ChoosePreference(nashList, gameInfo) # Selection method
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

function SystemPreference(nashList, gameInfo)
    n = gameInfo.n
    ψ = gameInfo.ψ
    listLen = length(nashList)

    systemScoreList = Vector{Any}(undef,0)
    for i = 1:listLen
        systemScore = 0
        for j = 1:n
            systemScore = systemScore + CalcJ(nashList[i][j],ψ,j)
        end
        systemScoreList = vcat(systemScoreList, systemScore)
    end
    return systemScoreList
end

function RunScenario(n)
    out = SearchAllNash(n)
    choiceList = ChoosePreference(out.primalsList, out.gameInfo)
    return choiceList
end

function EvolveDynamics(e, ref, maxDv, dt)
    # updateRate = 0.2
    # return e + updateRate*(ref - e)*dt
    
    error = ref - e
    if error != 0
        out = e + min(maxDv,abs(error)) * error / abs(error)
    else
        out =  e
    end
    return out
end

# function RunSim(n)
#     dt = 1 #ADS-B update rate
#     simT = 120
#     maxDv = 1 * dt

#     simStep = simT/dt

#     gameInfo = SetGame(n)
#     # println("GameInfo: n = $(n), ψ = $(gameInfo.ψ)")
#     # println("===============")
#     out = SearchAllNash(gameInfo)
#     NashSet = out.primalsList
#     NashNum = length(NashSet)
#     gameInfo = out.gameInfo

#     e = gameInfo.e
#     eInit = deepcopy(e)
#     eHistory = Vector{Any}(undef,0)
#     etemp = deepcopy(eInit)
#     eHistory = vcat(eHistory, [etemp])

#     # Run scenario
#     for t in 1:simStep
#         # Select their preference
#         choiceList = ChoosePreference(NashSet, gameInfo)

#         # Action for dt
#         for i in 1:n
#             e[i] = EvolveDynamics(e[i], NashSet[choiceList[i]][i], maxDv, dt)
#         end
#         etemp = deepcopy(e)
#         eHistory = vcat(eHistory,[etemp])

#         # Infer
#         distList = Vector{Any}(undef,0)
#         for j in 1:NashNum
#             distList = vcat(distList, measureDist(e, NashSet[j]))
#         end
#         # println(round.(e,digits=2))
#         # println(round.(distList,digits=2))
#         # println(sortperm(distList))
#         # println("============")
#     end
#     # println("Individual Preference: $(ChoosePreference(NashSet, gameInfo))")
#     # println(sortperm(SystemPreference(NashSet, gameInfo)))
#     # println("System Preference: $(SystemPreference(NashSet, gameInfo))")
#     # println(eHistory)
    
#     matwrite("Analysis/eHistory_single.mat",Dict(
#         "eHistory" => eHistory
#     ); version="v7.4")
# end

function RunSim(n)
    dt = 1 #ADS-B update rate
    simT = 120
    maxDv = 1 * dt

    simStep = simT/dt

    # Initial setting
    gameInfo = SetGame(n)
    e = gameInfo.e
    eInit = deepcopy(e)
    eHistory = Vector{Any}(undef,0)
    eHistory = vcat(eHistory, [eInit])

    # Run scenario
    for t in 1:simStep
        # Calculate Nash equilibrium
        gameInfo = UpdateGame(gameInfo, e)
        out = SearchAllNash(gameInfo)
        NashSet = out.primalsList
        NashNum = length(NashSet)
        
        # Select their preference
        choiceList = ChoosePreference(NashSet, gameInfo)

        # Action for dt
        for i in 1:n
            e[i] = EvolveDynamics(e[i], NashSet[choiceList[i]][i], maxDv, dt)
        end
        etemp = deepcopy(e)
        eHistory = vcat(eHistory,[etemp])

        # Infer
        distList = Vector{Any}(undef,0)
        for j in 1:NashNum
            distList = vcat(distList, measureDist(e, NashSet[j]))
        end
        
        # println(round.(e,digits=2))
        # println(round.(distList,digits=2))
        # println(sortperm(distList))
        # println("Individual Preference: $(ChoosePreference(NashSet, gameInfo))")
        # println("System Preference: $(sortperm(SystemPreference(NashSet, gameInfo)))")
        # println("========")
        println("Step $(t)")
    end
    # println(sortperm(SystemPreference(NashSet, gameInfo)))
    println(eHistory)
    matwrite("Analysis/eHistory_iterative.mat",Dict(
        "eHistory" => eHistory
    ); version="v7.4")
end