using datfm
using MAT

include("World.jl")

iterNum = 500;
n = 4;
# seed = 17095

testTypeNum = 2

Record = Array{Any,2}(undef,2,iterNum)
for i = 1:iterNum
    seed = rand(1:10000)
    out1 = RunSim(n,1,seed,Auction(),matWrite=false)
    out2 = RunSim(n,1,seed,Voting(),matWrite=false)
    Record[1,i] = out1
    Record[2,i] = out2
    println("Iter $(i) out of $(iterNum) done!")
end

matwrite("Analysis/MC.mat",Dict(
    "Record" => Record
); version="v7.4")

# say(what) = run(`osascript -e "say \"$(what)\""`, wait=false)
# say("Beep"^10)