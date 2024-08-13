using datfm
using Clustering: dbscan, DbscanResult

# Clustering param.
global radius = 1
global γ = 0.8 # radius reduction rate

function DetectComm(NashSet, idx)
    uSet = ExtractMyU(NashSet, idx)
    cluster = dbscan(uSet, radius)
    return cluster
end

abstract type VoteType end
struct ApprovalVote_Float <: VoteType end
struct ApprovalVote_Int <: VoteType end
struct ApprovalVote_Int_Cont <: VoteType end
struct ApprovalVote_Cluster <: VoteType end

function LetsVote(c::ApprovalVote_Float, costList, scoreBoard, idx)
    localCost = costList[idx,:]
    nNash = length(localCost)
    for i = 1:nNash
        scoreBoard[i] = scoreBoard[i] - localCost[i]
    end
    return scoreBoard
end

function LetsVote(c::ApprovalVote_Int, costList, scoreBoard, idx)
    localCost = costList[idx,:]
    nNash = length(localCost)
    bestIdx = findmin(localCost)[2]
    scoreBoard[bestIdx] = scoreBoard[bestIdx] + 1
    return scoreBoard
end

function LetsVote(c::ApprovalVote_Int_Cont, costList, scoreBoard, idx)
    localCost = costList[idx,:]
    nNash = length(localCost)
    permList = sortperm(localCost)
    for i = 1:nNash
        scoreBoard[i] = scoreBoard[i] - permList[i]
    end
    return scoreBoard
end

function LetsVote(c::ApprovalVote_Cluster, gameInfo, costList, NashSet, scoreBoard, idx)
    cluster = DetectComm(NashSet, idx)
    clusterList = cluster.clusters
    nCluster = length(clusterList)
    localCost = costList[idx,:]
    clusterScore = Vector{Float64}(undef, nCluster)
    ψ = gameInfo.ψ
    for i = 1:nCluster
        localCluster = clusterList[i]
        core = localCluster.core_indices
        clusterScore[i] = mean(localCost[core])
    end
    bestIdx = findmin(clusterScore)[2]
    scoreBoard[clusterList[bestIdx].core_indices] = scoreBoard[clusterList[bestIdx].core_indices] .+ 1# * ψ[idx]
    return scoreBoard
end

function RunVote(gameInfo, NashSet)
    n = gameInfo.n
    nNash = length(NashSet)
    clusterInfo = Vector{DbscanResult}(undef, n)
    scoreBoard = zeros(nNash)

    costList = GetCostList(gameInfo, NashSet)

    while true
        for i = 1:n
            # scoreBoard = LetsVote(ApprovalVote_Float(), costList, scoreBoard, i)
            # scoreBoard = LetsVote(ApprovalVote_Int(), costList, scoreBoard, i)
            # scoreBoard = LetsVote(ApprovalVote_Int_Cont(), costList, scoreBoard, i)
            scoreBoard = LetsVote(ApprovalVote_Cluster(), gameInfo, costList, NashSet, scoreBoard, i)
        end
        println(map(x -> round(x, digits=2), scoreBoard))
        global bestScore = findmax(scoreBoard)[1]
        global bestIdx = findmax(scoreBoard)[2]
        bestIdxs = findall(x -> x==bestScore, scoreBoard)
        println(bestIdxs)

        if length(bestIdxs) == 1
            break
        end
        global radius = radius * γ
        NashSet = NashSet[bestIdxs]
        nNash = length(NashSet)
        scoreBoard = zeros(nNash)
    end


    (; score = scoreBoard, bestScore, bestIdx)
end