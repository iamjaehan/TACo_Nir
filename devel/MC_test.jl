using datfm
using MAT

include("World.jl")

iterNum = 100;
n = 4;

Record = Array{Any,2}(undef,3,iterNum)
Count = Array{Any,2}(undef,3,iterNum)
for i = 1:iterNum
    # seed = 17095
    seed = rand(1:1000)
    # out1 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 0.1)
    # out2 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 1)
    # # out3 = RunSim(n,1,seed,Auction(),matWrite=false,usePrivateInfo=false)
    # out3 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 10)
    # out4 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 100)
    # out5 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 1000)
    # Record[1,i] = out1.optGap
    # Record[2,i] = out2.optGap
    # Record[3,i] = out3.optGap
    # Record[4,i] = out4.optGap
    # Record[5,i] = out5.optGap
    # Count[1,i] = out1.count
    # Count[2,i] = out2.count
    # Count[3,i] = out3.count
    # Count[4,i] = out4.count
    # Count[5,i] = out5.count
    global topN = 1
    out1 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 1)
    global topN = 3
    out2 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 1)
    global topN = 5
    out3 = RunSim(n,1,seed,Auction(),matWrite=false, disc = 1)
    Record[1,i] = out1.optGap
    Record[2,i] = out2.optGap
    Record[3,i] = out3.optGap
    Count[1,i] = out1.count
    Count[2,i] = out2.count
    Count[3,i] = out3.count
    println("Iter $(i) out of $(iterNum) done!")
end

matwrite("Analysis/MC_faster_iteration.mat",Dict(
    "Record" => Record,
    "Count" => Count
); version="v7.4")

# say(what) = run(`osascript -e "say \"$(what)\""`, wait=false)
# say("Beep"^10)