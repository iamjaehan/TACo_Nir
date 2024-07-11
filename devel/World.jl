using datfm

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
        return e + min(maxDv,abs(error)) * error / abs(error)
    else
        return e
    end
end

function RunSim(n)
    dt = 1 #ADS-B update rate
    simT = 30
    maxDv = 1 * dt

    simStep = simT/dt
    out = SearchAllNash(n)
    NashSet = out.primalsList
    NashNum = length(NashSet)
    gameInfo = out.gameInfo
    eInit = gameInfo.e
    e = eInit
    eHistory = Vector{Any}(undef,0)
    eHistory = vcat(eHistory, eInit)

    # Run scenario
    for t in 1:simStep
        # Select their preference
        choiceList = ChoosePreference(NashSet, gameInfo)

        # Action for dt
        for i in 1:n
            e[i] = EvolveDynamics(e[i], NashSet[choiceList[i]][i], maxDv, dt)
        end
        eHistory = vcat(eHistory,e)

        # Infer
        distList = Vector{Any}(undef,0)
        for j in 1:NashNum
            distList = vcat(distList, measureDist(e, NashSet[j]))
        end
        # println(round.(distList,digits=2))
        println(sortperm(distList))
    end

    println("Individual Preference: $(ChoosePreference(NashSet, gameInfo))")
    println(sortperm(SystemPreference(NashSet, gameInfo)))
    println("System Preference: $(SystemPreference(NashSet, gameInfo))")
end