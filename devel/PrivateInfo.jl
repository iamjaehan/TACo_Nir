using datfm

function GenPrivatePref(gameInfo, seed)
    n = gameInfo.n
    global privatePref = rand(n)*0.4 + 0.8
end

function GetPrivatePref()
    return privatePref
end