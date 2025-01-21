function RunTACo(;n=4, seed=rand(1:10000), d=10, interrupt = Inf, γ=0.9)
    # Set game
    global gameInfo = SetGame(n, seed)

    # Generate choices (Nash equilibria in this scenario)
    searchNash = SearchAllNash(gameInfo)
    global nashSet = searchNash.primalsList

    # Generate private valuation (b)
    GenPrivatePref(gameInfo, seed, d)
    privateInfo = GetPrivatePref()

    # Run TACo
    global out = RunDiscAuction(gameInfo, nashSet, privateInfo, d, interrupt, γ)
    
    # Printable result
    global costList = GetCostList(gameInfo, nashSet)
    global agreedChoice = out.bestIdx
    global totalRounds = out.count
    global priceVec = out.priceVec
    
    # Display result
    println("Raw Output: $(out)")
    println("Cost List: $(costList)")
    println("Final Choice: $(agreedChoice)")
    println("Number of Rounds: $(totalRounds)")
    println("Profit Vector: $(priceVec)")
end