using datfm
using MAT
using ProgressBars

include("World.jl")
include("0_GameSetup.jl")

iterNum = 5
n = 4
testCaseNum = 11
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

    global decrement = 0.3
    outList[1,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    global decrement = 0.5
    outList[2,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    global decrement = 0.9
    outList[3,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    global decrement = 0.99
    outList[4,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    global decrement = 0.9
    outList[5,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=60)
    outList[6,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=30)
    outList[7,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=n+1)
    outList[8,i] = RunSim(n, 0, seed, Voting(), matWrite=false, disc=10, interrupt=Inf)
    outList[9,i] = RunSim(n, 0, seed, SystemOptimal(), matWrite=false, disc=10, interrupt=Inf)
    outList[10,i] = RunSim(n, 0, seed, SystemFair(), matWrite=false, disc=10, interrupt=Inf)
    outList[11,i] = RunSim(n, 0, seed, RandomDemo(), matWrite=false, disc=10, interrupt=Inf)

    for j = 1:testCaseNum
        OptGap[j,i] = outList[j,i].optGap
        Count[j,i] = outList[j,i].count
        Fairness[j,i] = outList[j,i].fairness
    end
end

matwrite("Analysis/[0]_Experiment_epsilon.mat",Dict(
    "OptGap" => OptGap,
    "Count" => Count,
    "Fairness" => Fairness
); version="v7.4")