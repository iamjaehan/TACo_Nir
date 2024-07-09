using datfm

function ChoosePreference(nashList, gameInfo)
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

function RunScenario(n)
    out = SearchAllNash(n)
    choiceList = ChoosePreference(out.primalsList, out.gameInfo)
    return choiceList
end