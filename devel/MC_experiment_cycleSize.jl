using datfm
using MAT
using ProgressBars

include("World.jl")
include("0_GameSetup.jl")

iterNum = 10
n = 4
testCaseNum = 1
Record = Array{Any,2}(undef,testCaseNum,iterNum)
OptGap = deepcopy(Record)
Fairness = deepcopy(Record)
Count = deepcopy(Record)
global cycleSizeTrackList = Vector{Any}(undef,iterNum)
outList = Array{Any}(undef,testCaseNum,iterNum)

# for i = 1:iterNum
for i in 1:iterNum
    # seed = 17095
    global seed = rand(1:100000)
    global topN = 1
    global increment = 1
    global decrement = 0.8

    outList[1,i] = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    cycleSizeTrackList[i] = outList[1,i].cycleSizeTrack
end

matwrite("Analysis/[0]_Experiment_cycleSize.mat",Dict(
    "cycleSizeTrackList" => cycleSizeTrackList
); version="v7.4")