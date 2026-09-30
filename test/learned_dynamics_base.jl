using Test, AnalyticMathLab
const LD = AnalyticMathLab
@testset "Learned dynamics base contracts" begin
    @test isdefined(LD, :HamiltonianNN)
    if isdefined(LD, :HamiltonianNN)
        @test_throws ArgumentError LD.UDEProblem(FirstOrderODE((u,t)->u, 2), nothing, nothing, nothing; correction_indices=(1,1))
        @test_throws ArgumentError LD.DerivativeData(zeros(2,0), zeros(2,0))
        @test_throws DimensionMismatch LD.DerivativeData(zeros(2,3), zeros(1,3))
        @test_throws ArgumentError LD.TrajectoryData([0.,0.], zeros(2,2))
        @test_throws ArgumentError LD.TrajectoryData([0.,1.], [0. NaN; 1. 2.])
        @test LD.DerivativeData(ones(2,3),zeros(2,3)).states == ones(2,3)
    end
end
