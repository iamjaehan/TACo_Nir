using datfm
using MAT
using ProgressBars
using StatsBase

# include("World.jl")
# include("0_GameSetup.jl")

iterNum = 100
n = 4
testCaseNum = 11
Record = Array{Any,2}(undef,testCaseNum,iterNum)
OptGap = deepcopy(Record)
Fairness = deepcopy(Record)
Count = deepcopy(Record)
outList = Array{Any}(undef,testCaseNum,iterNum)
global cycleSizeTrackList = Vector{Any}(undef,iterNum)
global activeTrackList = Vector{Any}(undef,iterNum)

global seedList = sample(1:100000,iterNum,replace=false)

# for i = 1:iterNum
for i in ProgressBar(1:iterNum)
    # seed = 17095
    global seed = seedList[i]
    # global seed = i
    global topN = 1
    global increment = 1

    # global decrement = 0.9
    outList[1,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=1, interrupt=Inf)
    # global decrement = 0.9
    outList[2,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=50, interrupt=Inf)
    # global decrement = 0.9
    outList[3,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    # global decrement = 0.9
    outList[4,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=100, interrupt=Inf)
    # global decrement = 0.9
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
    cycleSizeTrackList[i] = outList[3,i].cycleSizeTrack
    activeTrackList[i] = outList[3,i].activeTrack
end

matwrite("Analysis/[0]_Experiment_epsilon_3.mat",Dict(
    "OptGap" => OptGap,
    "Count" => Count,
    "Fairness" => Fairness,
    "cycleSizeTrackList" => cycleSizeTrackList,
    "activeTrack" => activeTrackList
); version="v7.4")