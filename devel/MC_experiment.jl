using datfm
using MAT
using ProgressBars

include("World.jl")
include("0_GameSetup.jl")

iterNum = 1000
n = 4
testCaseNum = 1
Record = Array{Any,2}(undef,testCaseNum,iterNum)
OptGap = deepcopy(Record)
Fairness = deepcopy(Record)
Count = deepcopy(Record)

outList = Array{Any}(undef,testCaseNum,iterNum)

# for i = 1:iterNum
for i in ProgressBar(1:iterNum)
    # seed = 17095
    global seed = rand(1:100000)
    global topN = 1
    global increment = 1

    # outList[1,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=1, interrupt=Inf)
    # outList[2,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # outList[3,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=100, interrupt=Inf)
    # outList[4,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=60)
    # outList[5,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=30)
    # outList[8,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=n+1)
    # global increment = 1.05
    # outList[6,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global increment = 1.1
    # outList[7,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global increment = 1
    # outList[9,i] = RunSim(n, 0, seed, Voting(), matWrite=false, disc=10, interrupt=Inf)
    # outList[10,i] = RunSim(n, 0, seed, SystemOptimal(), matWrite=false, disc=10, interrupt=Inf)
    # outList[11,i] = RunSim(n, 0, seed, SystemFair(), matWrite=false, disc=10, interrupt=Inf)
    # outList[12,i] = RunSim(n, 0, seed, RandomDemo(), matWrite=false, disc=10, interrupt=Inf)

    global discVar = 0.02
    outList[1,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global discVar = 0.02
    # outList[2,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global discVar = 0.05
    # outList[3,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global discVar = 0.02
    # outList[4,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=60)
    # outList[5,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=30)
    # outList[6,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=n+1)
    # outList[7,i] = RunSim(n, 0, seed, Voting(), matWrite=false, disc=10, interrupt=Inf)
    # outList[8,i] = RunSim(n, 0, seed, SystemOptimal(), matWrite=false, disc=10, interrupt=Inf)
    # outList[9,i] = RunSim(n, 0, seed, SystemFair(), matWrite=false, disc=10, interrupt=Inf)
    # outList[10,i] = RunSim(n, 0, seed, RandomDemo(), matWrite=false, disc=10, interrupt=Inf)

    for j = 1:testCaseNum
        OptGap[j,i] = outList[j,i].optGap
        Count[j,i] = outList[j,i].count
        Fairness[j,i] = outList[j,i].fairness
    end

    # println("Iter $(i) out of $(iterNum) done!")
end

matwrite("Analysis/[0]_Experiment_noiseTest.mat",Dict(
    "OptGap" => OptGap,
    "Count" => Count,
    "Fairness" => Fairness
); version="v7.4")