using datfm
include("World.jl")

function RunRD(gameInfo, nashList)
    nNash = length(nashList)
    n = gameInfo.n
    accuScore = 0
    accuFair = 0
    costList = GetCostList(gameInfo, nashList)
    choiceList = ChoosePreference(Selfish(), nashList, gameInfo, 0, 0, 0)
    for i = 1:n
        accuScore = accuScore + EvalSystemScore(gameInfo, nashList, choiceList[i])
        accuFair = accuFair + EvalGini(gameInfo, costList[:,choiceList[i]])
    end
    averageCost = accuScore/n
    averageFairness = accuFair/n
    choice = rand(1:n)
    return (; choice, averageCost, averageFairness)
end