using datfm
using MAT

include("World.jl")
include("0_GameSetup.jl")

iterNum = 3
n = 3
testCaseNum = 6

Record = Array{Any,2}(undef,testCaseNum,iterNum)
OptGap = deepcopy(Record)
Fairness = deepcopy(Record)
Count = deepcopy(Record)

for i = 1:iterNum
    # seed = 17095
    seed = rand(1:1000)
    global topN = 1

    out1 = RunSim(n, 0, seed, Auction(), matWrite=false, disc=1, interrupt=Inf)
    out2 = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=Inf)
    out3 = RunSim(n, 0, seed, Auction(), matWrite=false, disc=100, interrupt=Inf)
    out4 = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=300)
    out5 = RunSim(n, 0, seed, Auction(), matWrite=false, disc=10, interrupt=100)
    out6 = RunSim(n, 0, seed, Voting(), matWrite=false, disc=10, interrupt=Inf)
    out7 = RunSim(n, 0, seed, SystemOptimal(), matWrite=false, disc=10, interrupt=Inf)
    out8 = RunSim(n, 0, seed, RandomDemo(), matWrite=false, disc=10, interrupt=Inf)

    println("Iter $(i) out of $(iterNum) done!")
end
