using datfm

global increment = 1
# global nextBidderProtocol = LeastFavorNextBidder() # LeastFavorNextBidder, OrderTypeNextBidder
global nextBidderProtocol = OrderTypeNextBidder()

abstract type NextBidderProtocol end
struct OrderTypeNextBidder <: NextBidderProtocol end
struct LeastFavorNextBidder <: NextBidderProtocol end

function WhoIsNext(c::OrderTypeNextBidder, n, counter)
    return (counter-1)%n + 1
end

function WhoIsNext(c::LeastFavorNextBidder, n, counter)
    return rand(1:n)
end

function GetBestBid(priceList)
    # return findmin(priceList)[2]
    return partialsortperm(priceList,1:topN,rev=false)
end

function UpdateOfferList(n, offerList, plIdx, bidIdx, privateInfo)
    # offerList[:,bidIdx] = offerList[:,bidIdx] .+ discount
    # return offerList
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        for j = 1:n
            offerList[j,localBid] = offerList[j,localBid] .+ discount/i*privateInfo[j]
        end
        offerList[plIdx,localBid] = offerList[plIdx,localBid] .- discount/i*privateInfo[plIdx]
    end
    return offerList
end

function UpdatePayList(payList, plIdx, bidIdx, privateInfo)
    # payList[plIdx,bidIdx] = payList[plIdx,bidIdx] + discount
    # return payList
    n = size(payList)[1]
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        payList[plIdx,localBid] = payList[plIdx,localBid] + discount/i*(n-1)*privateInfo[plIdx]
    end
    return payList
end

function RunDiscAuction(gameInfo, NashList, privateInfo, disc)
    n = gameInfo.n
    nNash = length(NashList)
    assignList = zeros(n)
    costList = GetCostList(gameInfo, NashList)
    offerList = zeros(n,nNash) # Choice [i] discounted by ~
    payList = zeros(n,nNash) # Paid by whom[i] for the choice [j]
    global priceList = deepcopy(costList)
    global discount = disc
    
    count = 0
    while true
        count = count + 1
        # global discount = discount * increment^(count-1)
        global discount = discount * increment
        prevAssignList = deepcopy(assignList)
        # println("Iteration #$(count)")

        # Choose bidder
        bidder = WhoIsNext(nextBidderProtocol, n, count)
        # Choose the best choice
        bestBidIdx = GetBestBid(priceList[bidder,:])
        # Update offerList
        offerList = UpdateOfferList(n, offerList, bidder, bestBidIdx, privateInfo)
        # Update payList
        payList = UpdatePayList(payList, bidder, bestBidIdx, privateInfo)
        # Update priceList
        global priceList = costList + payList - offerList
        # Assign
        assignList[bidder] = bestBidIdx[1]
        # println(map(x->Int64(x),assignList))

        if iszero(assignList.-assignList[1]) || count > 10000
            if count > 10000
                println("[Warning] Convergence Failure [Auction]")
            end
            break
        end
    end

    bestIdx = Int64(assignList[1])
    priceVec = priceList[:,bestIdx]
    costVec = costList[:,bestIdx]
    return (; bestIdx, count, priceVec, costVec)
end