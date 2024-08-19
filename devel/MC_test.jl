using datfm
using MAT

include("World.jl")

iterNum = 10;
n = 5;

Record = Array{Any,2}(undef,3,iterNum)
Count = Array{Any,2}(undef,3,iterNum)
for i = 1:iterNum
    # seed = 17095
    seed = rand(1:10000)
    out1 = RunSim(n,1,seed,Auction(),matWrite=false)
    out2 = RunSim(n,1,seed,Voting(),matWrite=false)
    out3 = RunSim(n,1,seed,Auction(),matWrite=false,usePrivateInfo=false)
    Record[1,i] = out1.optGap
    Record[2,i] = out2.optGap
    Record[3,i] = out3.optGap
    Count[1,i] = out1.count
    Count[2,i] = out2.count
    Count[3,i] = out3.count
    println("Iter $(i) out of $(iterNum) done!")
end

matwrite("Analysis/MC_5p.mat",Dict(
    "Record" => Record,
    "Count" => Count
); version="v7.4")

# say(what) = run(`osascript -e "say \"$(what)\""`, wait=false)
# say("Beep"^10)