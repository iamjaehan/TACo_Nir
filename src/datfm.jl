module datfm

using Symbolics: Symbolics, @variables
using ParametricMCPs: ParametricMCPs, ParametricMCP
using BlockArrays: BlockArray, Block, mortar, blocks
using LinearAlgebra: norm_sqr
using Statistics: mean
using Clustering: dbscan
using StatsBase
using ProgressBars

include("parametric_game.jl")
export ParametricOptimizationProblem, solve, total_dim
include("parametric_optimization_problem.jl")
export ParametricGame
include("../devel/SearchNash.jl")
export SearchNash, SearchAllNash
include("../devel/0_GameSetup.jl")
export SetGame, GetCostList, EvalGini
include("../devel/DiscountAuction.jl")
export RunDiscAuction
include("../devel/Vote.jl")
export RunVote
include("../devel/RandomDemocracy.jl")
export RunRD
include("../devel/World.jl")
export Voting, SystemOptimal, RandomDemo, SystemFair, Selfish, Auction, RunSim
include("../devel/PrivateInfo.jl")
export GenFakePrivatePref, GenPrivatePref, GetPrivatePref


include("../example/TACo.jl")
export RunTACo


include("../example/RankedTACo.jl")
export RunRankedTACo
include("../devel/RankedDiscountAuction.jl")
export RunRankedDiscAuction

end # module datfm
