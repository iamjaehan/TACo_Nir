using datfm

function GetBestMargin(costList, priceList)
    margin = costList - priceList
    firstMargin = findmax(margin)[1]
    firstBidIdx = findmax(margin)[2]
    (; firstMargin, firstBidIdx)
end

function CalcBidIncrease(costList, priceList, firstMargin, firstBidIdx)
    margin = costList - priceList
    margin[firstBidIdx] = minimum(margin)
    return firstMargin - maximum(margin)
end

function UpdateChoiceTakenList(assignList, nNash)
    l = length(assignList)
    choiceTakenList = falses(nNash)
    for i = 1:l
        if assignList[i] != 0
            assignIdx = Int64(assignList[i])
            choiceTakenList[assignIdx] = true
        end
    end
    return choiceTakenList
end

abstract type NextBidderProtocol end
struct OrderTypeNextBidder <: NextBidderProtocol end
struct LeastFavorNextBidder <: NextBidderProtocol end

function WhoIsNext(c::OrderTypeNextBidder, n, counter)
    return (counter-1)%n + 1
end

function WhoIsNext(c::LeastFavorNextBidder, n, counter)
    return rand(1:n)
end

function RunAuction(gameInfo, NashList)
    n = gameInfo.n
    nNash = length(NashList)
    assignList = zeros(n)
    choiceTakenList = falses(nNash)
    priceList = zeros(nNash)
    costList = GetCostList(gameInfo, NashList)
    nextBidderProtocol = LeastFavorNextBidder() # LeastFavorNextBidder, OrderTypeNextBidder
    nextBidderProtocol = OrderTypeNextBidder()
    
    count = 0
    while true
        count = count + 1
        prevAssignList = deepcopy(assignList)
        bidder = WhoIsNext(nextBidderProtocol, n, count)
        j = GetBestMargin(costList[bidder,:], priceList)
        firstMargin = j.firstMargin
        firstBidIdx = j.firstBidIdx
        b = CalcBidIncrease(costList[bidder,:], priceList, firstMargin, firstBidIdx)
        
        if choiceTakenList[firstBidIdx] == true
            # println(firstBidIdx)
            # println(assignList)
            # println(choiceTakenList)
            whoTookIt = findall(x->x==firstBidIdx, assignList)[1]
            assignList[whoTookIt] = 0
        end
        assignList[bidder] = firstBidIdx
        choiceTakenList = UpdateChoiceTakenList(assignList, nNash)
        priceList[firstBidIdx] = priceList[firstBidIdx] + b

        # println(prevAssignList)
        # println(assignList)
        # println("ooo")

        if prevAssignList == assignList && isempty(findall(x->x==0, assignList))
            break
        end
    end

    return assignList
end