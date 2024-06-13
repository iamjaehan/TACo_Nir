using correlated
using Test: @testset, @test
using BlockArrays: Block
using PATHSolver: PATHSolver

print("==========================\n")
print("**************************\n")
@testset "OptimizationTests" begin
    f(x, θ) = sum(x)
    g(x, θ) = [sum(x .^ 2) - 1]
    h(x, θ) = -x

    problem = ParametricOptimizationProblem(;
        objective = f,
        equality_constraint = g,
        inequality_constraint = h,
        parameter_dimension = 1,
        primal_dimension = 2,
        equality_dimension = 1,
        inequality_dimension = 2,
    )

    (; primals, variables, status, info) = solve(problem, [0])
    print(primals, "\n", variables, "\n", status, "\n")
    @test all(isequal.(status, PATHSolver.MCP_Solved))
end

print("**************************\n")
@testset "GameTests" begin
    N = 3
    fs = [(x, θ) -> sum(x[Block(ii)]) for ii in 1:N]
    gs = [(x, θ) -> [sum(x[Block(ii)] .^ 2) - 1] for ii in 1:N]
    hs = [(x, θ) -> -x[Block(ii)] for ii in 1:N]
    g̃ = (x, θ) -> [0]
    h̃ = (x, θ) -> [0]

    problem = ParametricGame(
        objectives = fs,
        equality_constraints = gs,
        inequality_constraints = hs,
        shared_equality_constraint = g̃,
        shared_inequality_constraint = h̃,
        parameter_dimension = 1,
        primal_dimensions = fill(2, N),
        equality_dimensions = fill(1, N),
        inequality_dimensions = fill(2, N),
        shared_equality_dimension = 1,
        shared_inequality_dimension = 1,
    )

    (; primals, variables, status, info) = solve(problem, [0])
    print(primals, "\n", status, "\n")
    @test all(isequal.(status, PATHSolver.MCP_Solved))
end
