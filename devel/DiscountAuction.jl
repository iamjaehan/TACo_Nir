using datfm

global increment = 1
# global nextBidderProtocol = LeastFavorNextBidder() # LeastFavorNextBidder, OrderTypeNextBidder
global nextBidderProtocol = OrderTypeNextBidder()
termLimit = 10000

abstract type NextBidderProtocol end
struct OrderTypeNextBidder <: NextBidderProtocol end
struct LeastFavorNextBidder <: NextBidderProtocol end

## Debugging history
global offerHist = Vector{Any}(undef,termLimit)
global payHist = Vector{Any}(undef,termLimit)
global costHist = Vector{Any}(undef,termLimit)
global priceHist = Vector{Any}(undef,termLimit)

function WhoIsNext(c::OrderTypeNextBidder, n, counter)
    return (counter-1)%n + 1
end

function WhoIsNext(c::LeastFavorNextBidder, n, counter)
    return rand(1:n)
end

function GetBestBid(priceList, ioUnitList, unitLimit)
    tempPriceList = deepcopy(priceList)
    count = 0
    for i = 1:length(priceList)
        if ioUnitList[i] + discount > unitLimit
            count = count + 1
            tempPriceList[i] = tempPriceList[i] + M
            # println("[Warning] Partial overbidding")
        end
    end
    if count == length(priceList)
        # println("[Warning] Overbidding!")
    end
    return partialsortperm(tempPriceList,1:topN,rev=false)
end

function UpdateOfferList(n, offerList, plIdx, bidIdx, privatePref)
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        for j = 1:n
            offerList[j,localBid] = offerList[j,localBid] .+ discount/i*privatePref[j]
        end
        offerList[plIdx,localBid] = offerList[plIdx,localBid] .- discount/i*privatePref[plIdx]
    end
    return offerList
end

function UpdatePayList(payList, plIdx, bidIdx, privatePref)
    n = size(payList)[1]
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        payList[plIdx,localBid] = payList[plIdx,localBid] + discount/i*n*privatePref[plIdx]
    end
    return payList
end

function UpdateOfferUnitList(n, offerUnitList, plIdx, bidIdx, privatePref)
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        for j = 1:n
            offerUnitList[j,localBid] = offerUnitList[j,localBid] .+ discount/i
        end
        offerUnitList[plIdx,localBid] = offerUnitList[plIdx,localBid] .- discount/i
    end
    return offerUnitList
end

function UpdatePayUnitList(payUnitList, plIdx, bidIdx, privatePref)
    n = size(payUnitList)[1]
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        payUnitList[plIdx,localBid] = payUnitList[plIdx,localBid] + discount/i*(n-1)
    end
    return payUnitList
end

function RunDiscAuction(gameInfo, NashList, privateInfo, disc, interrupt)
    n = gameInfo.n
    privatePref = privateInfo.privatePref
    privateUnitLimit = privateInfo.privateUnitLimit
    nNash = length(NashList)
    assignList = zeros(n)
    costList = GetCostList(gameInfo, NashList)
    offerList = zeros(n,nNash) # Choice [i] discounted by ~
    offerUnitList = zeros(n,nNash)
    payList = zeros(n,nNash) # Paid by whom[i] for the choice [j]
    payUnitList = zeros(n,nNash)
    global priceList = deepcopy(costList)
    global ioUnitList = deepcopy(costList)
    global discount = disc
    global M = 100 * maximum(costList)
    isInterrupted = false

    global offerHist[1] = deepcopy(offerList)
    global payHist[1] = deepcopy(payList)
    global costHist[1] = deepcopy(costList)
    global priceHist[1] = deepcopy(priceList)
    
    count = 1
    while true
        count = count + 1
        global discount = discount * increment^(count-1)
        # global discount = discount + increment
        prevAssignList = deepcopy(assignList)
        # println("Iteration #$(count)")

        # Choose bidder
        bidder = WhoIsNext(nextBidderProtocol, n, count)
        # Choose the best choice
        bestBidIdx = GetBestBid(priceList[bidder,:], ioUnitList[bidder,:], privateUnitLimit[bidder])
        # Update offerList
        offerList = UpdateOfferList(n, offerList, bidder, bestBidIdx, privatePref)
        offerUnitList = UpdateOfferUnitList(n, offerUnitList, bidder, bestBidIdx, privatePref)
        # Update payList
        payList = UpdatePayList(payList, bidder, bestBidIdx, privatePref)
        payUnitList = UpdatePayUnitList(payUnitList, bidder, bestBidIdx, privatePref)
        # Update priceList
        global priceList = costList + payList - offerList
        # global ioUnitList = payUnitList - offerUnitList
        global ioUnitList = payUnitList
        # Assign
        assignList[bidder] = bestBidIdx[1]
        # println(map(x->Int64(x),assignList))

        global offerHist[count] = deepcopy(offerUnitList)
        global payHist[count] = deepcopy(payUnitList)
        global priceHist[count] = deepcopy(priceList)

        if iszero(assignList.-assignList[1]) || count == termLimit || count >= interrupt
            if count == interrupt
                isInterrupted = true
            end
            if count == termLimit
                println("[Warning] Convergence Failure [Auction]")
            end
            break
        end
    end

    # payHist = payHist[1:count]

    if isInterrupted
        bestIdx = Int64(mode(assignList))
    else
        bestIdx = Int64(assignList[1])
    end
    priceVec = priceList[:,bestIdx]
    costVec = costList[:,bestIdx]
    return (; bestIdx, count, priceVec, costVec)
end