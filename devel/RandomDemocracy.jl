using datfm

function RunRD(gameInfo, nashList)
    nNash = length(nashList)
    n = gameInfo.n
    accuScore = 0
    accuFair = 0
    costList = GetCostList(gameInfo, nashList)
    for i = 1:nNash
        accuScore = accuScore + EvalSystemScore(gameInfo, nashList, i)
        accuFair = accuFair + EvalGini(gameInfo, costList[:,i])
    end
    averageCost = accuScore/n
    averageFairness = accuFair/n
    choice = rand(1:n)
    return (; choice, averageCost, averageFairness)
end