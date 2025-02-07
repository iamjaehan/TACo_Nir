using datfm
global increment = 1
global topN = 1
termLimit = 10000
global ϵ = .1

abstract type NextBidderProtocol end
struct OrderTypeNextBidder <: NextBidderProtocol end
struct LeastFavorNextBidder <: NextBidderProtocol end

# global nextBidderProtocol = LeastFavorNextBidder() # LeastFavorNextBidder, OrderTypeNextBidder
global nextBidderProtocol = OrderTypeNextBidder()

function WhoIsNext(c::OrderTypeNextBidder, n, counter)
    return (counter-2)%n + 1
end

function WhoIsNext(c::LeastFavorNextBidder, n, counter)
    return rand(1:n)
end

function GetBestBid(priceList, ioUnitList, unitLimit)
    return partialsortperm(priceList,1:topN,rev=false)
end

function UpdateOfferList(n, offerList, plIdx, bidIdx, privatePref)
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        for j = 1:n
            offerList[j,localBid] = offerList[j,localBid] .+ discount/i*privatePref[j]
        end
        # offerList[plIdx,localBid] = offerList[plIdx,localBid] .- discount/i*privatePref[plIdx]
    end
    return offerList
end

function UpdatePayList(payList, plIdx, bidIdx, privatePref)
    n = size(payList)[1]
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        payList[plIdx,localBid] = payList[plIdx,localBid] + discount/i*(n)*privatePref[plIdx]
    end
    return payList
end

function UpdateOfferUnitList(n, offerUnitList, plIdx, bidIdx, privatePref)
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        for j = 1:n
            offerUnitList[j,localBid] = offerUnitList[j,localBid] .+ discount/i
        end
        # offerUnitList[plIdx,localBid] = offerUnitList[plIdx,localBid] .- discount/i
    end
    #println("OFFER UNIT LIST", offerUnitList)

    return offerUnitList
end

function UpdatePayUnitList(payUnitList, plIdx, bidIdx, privatePref)
    n = size(payUnitList)[1]
    for i = 1:length(bidIdx)
        localBid = bidIdx[i]
        payUnitList[plIdx,localBid] = payUnitList[plIdx,localBid] + discount/i*(n)
    end
    #println("Pay UNIT LIST", payUnitList)
    return payUnitList
    
end

function RunDiscAuction(gameInfo, NashList, privateInfo, disc, interrupt, decrement)
    n = gameInfo.n
    #privatePref = privateInfo.privatePref
    privatePref = [.8, 1.2]#privateInfo.privatePref
    #print("PRIVATE PREF", privatePref)
    privateUnitLimit = privateInfo.privateUnitLimit
    nNash = length(NashList)
    assignList = zeros(n)
    costList = [10 7; 4 9]#GetCostList(gameInfo, NashList)
    offerList = zeros(n,nNash) # Choice [i] discounted by ~
    offerUnitList = zeros(n,nNash)
    payList = zeros(n,nNash) # Paid by whom[i] for the choice [j]
    payUnitList = zeros(n,nNash)
    global priceList = deepcopy(costList)
    global ioUnitList = deepcopy(costList)
    global discount = disc
    global M = 100 * maximum(costList)
    global tupleList = Vector{Any}(undef,0)
    isInterrupted = false

    #이건 저장?
    global cycleSizeTrack = Vector{Any}(undef,termLimit)
    global activeTrack = Vector{Any}(undef,termLimit)
    
    count = 1
    cycleCount = 0
    while true
        count = count + 1
        # global discount = discount * increment^(count%n+1-2)
        # global discount = discount * (rand()*discVar+1-discVar/2)
        global discount = discount * increment
        # prevAssignList = deepcopy(assignList)
        # println("Iteration #$(count)")

        # Choose bidder
        bidder = WhoIsNext(nextBidderProtocol, n, count)    
        # Detect Cycle
        bidderProfitTuple = (bidder,round.(priceList,digits=10))

        #rintln("PRICE LIST", priceList)

        # if count == 99 || count == 115 || count == 131 || count == 147
        #     testTuple = (bidder,round.(priceList,digits=3))
        #     println(testTuple)
        #     if count != 99
        #         println(prevTuple == testTuple)
        #     end
        #     global prevTuple = testTuple
        # end
        
        if IsCycleDetected(tupleList, bidderProfitTuple)
            # println("Cycle Detected! @ count: $(count)")
            cycleCount = cycleCount + 1
            global cycleTuple = GetCycleInfo(tupleList, bidderProfitTuple)
            global discount = discount * decrement
            tupleList = Vector{Any}(undef,0)            
            global activeChoice = GetActiveChoices(cycleTuple)
            global maxPriceDiff = GetPriceDiff(activeChoice, cycleTuple, n)            
            global cycleSizeTrack[cycleCount] = maxPriceDiff
            global activeTrack[cycleCount] = length(activeChoice)
            # Check termination condition
            if IsEpsilonTermination(maxPriceDiff,ϵ)
                # println("Epsilon Termination Satisfied @ maxDiff: $(maxPriceDiff) < ϵ: $(ϵ)")
                isInterrupted = true
                break
            end
        end
        # Remember the bidder-profit tuple
        tupleList = vcat(tupleList,bidderProfitTuple)
        # Choose the best choice
        bestBidIdx = GetBestBid(priceList[bidder,:], ioUnitList[bidder,:], privateUnitLimit[bidder])
        # Update offerList
        offerList = UpdateOfferList(n, offerList, bidder, bestBidIdx, privatePref)
        offerUnitList = UpdateOfferUnitList(n, offerUnitList, bidder, bestBidIdx, privatePref)
        # Update payList
        payList = UpdatePayList(payList, bidder, bestBidIdx, privatePref)
        payUnitList = UpdatePayUnitList(payUnitList, bidder, bestBidIdx, privatePref)
        # Update priceList
        global priceList = offerList - payList - costList
        # global ioUnitList = payUnitList - offerUnitList
        global ioUnitList = payUnitList
        # Assign
        assignList[bidder] = bestBidIdx[1]
        # global choiceHist[count-1] = deepcopy(assignList)

        # Check Abnormal Termination Condition
        if count == termLimit || count >= interrupt
            if count == interrupt
                isInterrupted = true
            end
            if count == termLimit
                println("[Warning] Convergence Failure [Auction] seed:,: disc: $(discount)")
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
    priceVec = priceList[:,bestIdx]
    costVec = costList[:,bestIdx]
    return (; bestIdx, count, priceVec, costVec, cycleSizeTrack, activeTrack)
end