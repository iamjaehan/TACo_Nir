using datfm
using MAT

include("World.jl")
include("0_GameSetup.jl")

iterNum = 100
n = 4
testCaseNum = 4

Record = Array{Any,2}(undef,testCaseNum,iterNum)
OptGap = deepcopy(Record)
Fairness = deepcopy(Record)
Count = deepcopy(Record)

for i = 1:itermNum
end
