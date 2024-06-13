module datfm

using Symbolics: Symbolics, @variables
using ParametricMCPs: ParametricMCPs, ParametricMCP
using BlockArrays: BlockArray, Block, mortar, blocks
using LinearAlgebra: norm_sqr
using Statistics: mean

include("parametric_game.jl")
export ParametricOptimizationProblem, solve, total_dim
include("parametric_optimization_problem.jl")
export ParametricGame

end # module datfm
