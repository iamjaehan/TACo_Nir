using datfm
using Random

function GenPrivatePref(gameInfo, seed, disc)
    n = gameInfo.n
    global privatePref = rand(MersenneTwister(seed),n)*0.4 .+ 0.8
    global privateUnitLimit = rand(MersenneTwister(seed),1000:2000,n)
end

function GenFakePrivatePref(gameInfo, seed, disc)
    n = gameInfo.n
    global privatePref = rand(MersenneTwister(seed),n)*0.4 .+ 0.8
    global privateUnitLimit = ones(n)
end

function GetPrivatePref()
    (;privatePref, privateUnitLimit)
end