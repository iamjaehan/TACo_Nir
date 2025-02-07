# Global Variables
global increment = 1
global topN = 1
termLimit = 10000
global ϵ = .1

abstract type NextBidderProtocol end
struct OrderTypeNextBidder <: NextBidderProtocol end
struct LeastFavorNextBidder <: NextBidderProtocol end

# Global Protocol Setting
global nextBidderProtocol = OrderTypeNextBidder()

function RankedWhoIsNext(c::OrderTypeNextBidder, n, counter)
    return (counter - 2) % n + 1
end

function RankedWhoIsNext(c::LeastFavorNextBidder, n, counter)
    return rand(1:n)
end

function RankedGetBestBid(priceList, ioUnitList, unitLimit)
    return partialsortperm(priceList, 1:topN, rev=true)
end

function RankedSortBidList(priceList, ioUnitList, unitLimit)
    return sort(priceList)
end

function RankedUpdateOfferList(n, offerList, plIdx, sortedBids, privatePref, priceList)
    for price in priceList
        index = findfirst(==(price), priceList)
        ranked_index = findfirst(==(price), sortedBids)

        for j = 1:n
            offerList[j, index] += (discount * (ranked_index)) * privatePref[j]
        end
    end
    return offerList
end

function RankedUpdateOfferUnitList(n, offerUnitList, plIdx, sortedBids, privatePref, priceList)
    for price in priceList
        index = findfirst(==(price), priceList)
        ranked_index = findfirst(==(price), sortedBids)

        for j = 1:n
            offerUnitList[j, index] += discount * (ranked_index)
        end
    end
    #println("OFFER UNIT LIST", offerUnitList)
    return offerUnitList
end

function RankedUpdatePayUnitList(payUnitList, plIdx, sortedBids, privatePref, priceList)
    for price in priceList
        index = findfirst(==(price), priceList)
        ranked_index = findfirst(==(price), sortedBids)

        payUnitList[plIdx, index] += discount * n * (ranked_index)
    end
    #println("PAY UNIT LIST", payUnitList)
    return payUnitList
end

function RankedUpdatePayList(payList, plIdx, sortedBids, privatePref, priceList)
    for price in priceList
        index = findfirst(==(price), priceList)
        ranked_index = findfirst(==(price), sortedBids)

        payList[plIdx, index] += discount * n * (ranked_index) * privatePref[plIdx]
    end
    return payList
end

function RunRankedDiscAuction(gameInfo, NashList, privateInfo, disc, interrupt, decrement)
    global n = gameInfo.n
    privatePref =  privateInfo.privatePref
    privateUnitLimit = privateInfo.privateUnitLimit
    nNash = length(NashList)
    assignList = zeros(n)
    costList =  GetCostList(gameInfo, NashList)
    offerList = zeros(n, nNash)
    offerUnitList = zeros(n, nNash)
    payList = zeros(n, nNash)
    payUnitList = zeros(n, nNash)
    global priceList = deepcopy(costList)
    global ioUnitList = deepcopy(costList)
    global discount = disc
    global M = 100 * maximum(costList)
    global tupleList = Vector{Any}(undef, 0)
    isInterrupted = false

    global cycleSizeTrack = Vector{Any}(undef, termLimit)
    global activeTrack = Vector{Any}(undef, termLimit)

    count = 1
    cycleCount = 0
    while true
        count += 1
        global discount *= increment

        bidder = RankedWhoIsNext(nextBidderProtocol, n, count)
        bidderProfitTuple = (bidder, round.(priceList, digits=100))
        #println("BIDDER PROFIT TUPLE", bidderProfitTuple)
        #println("PRICE LIST", priceList)

        if IsCycleDetected(tupleList, bidderProfitTuple)
            cycleCount += 1
            global cycleTuple = GetCycleInfo(tupleList, bidderProfitTuple)
            global discount *= decrement
            tupleList = Vector{Any}(undef, 0)
            global activeChoice = GetActiveChoices(cycleTuple)
            global maxPriceDiff = GetPriceDiff(activeChoice, cycleTuple, n)
            global cycleSizeTrack[cycleCount] = maxPriceDiff
            global activeTrack[cycleCount] = length(activeChoice)

            if IsEpsilonTermination(maxPriceDiff, ϵ)
                isInterrupted = true
                break
            end
        end

        tupleList = vcat(tupleList, bidderProfitTuple)
        bestBidIdx = RankedGetBestBid(priceList[bidder, :], ioUnitList[bidder, :], privateUnitLimit[bidder])
        sortedBids = RankedSortBidList(priceList[bidder, :], ioUnitList[bidder, :], privateUnitLimit[bidder])

        offerList = RankedUpdateOfferList(n, offerList, bidder, sortedBids, privatePref, priceList[bidder, :])
        offerUnitList = RankedUpdateOfferUnitList(n, offerUnitList, bidder, sortedBids, privatePref, priceList[bidder, :])
        payList = RankedUpdatePayList(payList, bidder, sortedBids, privatePref, priceList[bidder, :])
        payUnitList = RankedUpdatePayUnitList(payUnitList, bidder, sortedBids, privatePref, priceList[bidder, :])

        global priceList = offerList - payList - costList 

        
        #println("Price list", priceList)
        #println("Cost list", costList)
        #println("Pay list", payList)
        #println("offer list", offerList)


        global ioUnitList = payUnitList

        #print("SHOWBESTBID IDX", bestBidIdx)
        assignList[bidder] = bestBidIdx[1]

        if count == termLimit || count >= interrupt
            if count == interrupt
                isInterrupted = true
            end
            if count == termLimit
                println("[Warning] Convergence Failure [Auction]  disc: $(discount)")
            end
            break
        end
    end

    global cycleSizeTrack = cycleSizeTrack[1:cycleCount]
    global activeTrack = activeTrack[1:cycleCount]

    if isInterrupted
        bestIdx = Int64(mode(assignList))
    else
        bestIdx = Int64(assignList[1])
    end
    #print("PRICE LIST", priceList)
    priceVec = priceList[:, bestIdx]
    costVec = costList[:, bestIdx]
    return (; bestIdx, count, priceVec, costVec, cycleSizeTrack, activeTrack)
end
