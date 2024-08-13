using datfm

global discount = 10;
global nextBidderProtocol = LeastFavorNextBidder() # LeastFavorNextBidder, OrderTypeNextBidder
# global nextBidderProtocol = OrderTypeNextBidder()

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
    # (; bestMargin = findmin(priceList)[1], bestBidIdx = findmin(priceList)[2])
    return findmin(priceList)[2]
end

function UpdateOfferList(offerList, plIdx, bidIdx)
    offerList[:,bidIdx] = offerList[:,bidIdx] .+ discount
    return offerList
end

function UpdatePayList(payList, plIdx, bidIdx)
    payList[plIdx,bidIdx] = payList[plIdx,bidIdx] + discount
    return payList
end

function RunDiscAuction(gameInfo, NashList)
    n = gameInfo.n
    nNash = length(NashList)
    assignList = zeros(n)
    costList = GetCostList(gameInfo, NashList)
    offerList = zeros(n,nNash) # Choice [i] discounted by ~
    payList = zeros(n,nNash) # Paid by whom[i] for the choice [j]
    priceList = costList
    
    count = 0
    while true
        count = count + 1
        prevAssignList = deepcopy(assignList)
        println("Iteration #$(count)")

        # Choose bidder
        bidder = WhoIsNext(nextBidderProtocol, n, count)
        # Choose the best choice
        bestBidIdx = GetBestBid(priceList[bidder,:])
        # Update offerList
        offerList = UpdateOfferList(offerList, bidder, bestBidIdx)
        # Update payList
        payList = UpdatePayList(payList, bidder, bestBidIdx)
        # Update priceList
        priceList = costList + payList - offerList
        # Assign
        assignList[bidder] = bestBidIdx
        println(map(x->Int64(x),assignList))

        if iszero(assignList.-assignList[1]) || count > 100
            break
        end
    end

    bestIdx = Int64(assignList[1])
    return (; bestIdx)
end