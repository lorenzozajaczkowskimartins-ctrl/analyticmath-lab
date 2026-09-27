module PINNBaseTests
using Test, AnalyticMathLab
const A=AnalyticMathLab
@testset "M9A optional bridge surface" begin
    for name in (:PINNProblem,:PINNTrainingResult,:PINNHistory,:pinn_network,:pinn_problem,:train,:predict,:pinn_inspect,:lossplot)
        @test isdefined(A,name)
    end
    @test Base.get_extension(A,:AnalyticMathLabPINNExt) === nothing
    @test all(m->!(nameof(m) in (:Lux,:NeuralPDE,:ModelingToolkit,:Optimization,:OptimizationOptimisers)),values(Base.loaded_modules))
    @test ismissing(A.Makie.current_backend())
    if isdefined(A,:pinn_network)
        @test_throws ArgumentError A.pinn_network(1,1)
        @test_throws ArgumentError A.pinn_problem(nothing)
        h=A.PINNHistory(;stride=2,capacity=3)
        @test isempty(h.entries)
        @test h.stride==2 && h.capacity==3 && !h.truncated
        @test_throws ArgumentError A.PINNHistory(;stride=0)
        @test_throws ArgumentError A.PINNHistory(;capacity=-1)
        @test A.PINNProblem <: AbstractAnalysis
        @test A.PINNTrainingResult <: AbstractAnalysis
    end
end
end
