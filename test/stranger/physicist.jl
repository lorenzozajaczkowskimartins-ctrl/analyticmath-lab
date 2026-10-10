using AnalyticMathLab
using Test, Symbolics, LinearAlgebra, Unitful
@testset "Stranger physicist mechanics and stored observables" begin
    @variables q v
    system=LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,))
    report=analyze(system)
    modes=normal_modes(linearize_mechanics(report,[0.]))
    @test modes.frequencies≈[1.]
    path=trajectory(dynamics(report),[1.,0.],(0.,0.25))
    @test path.diagnostics.success && path.diagnostics.completed
    position=observable_series(path;component=1)
    @test position.sampling.times==path.solution.t
    @test position.values≈cos.(path.solution.t) atol=1e-7
    @test occursin("unknown",position.units)
    physical=observable_series(path;observable=(u,t)->u[1]*u"m",name=:position)
    @test statistical_summary(physical).value.mean≈sum(position.values)/length(position.values)*u"m"
    @test_throws ArgumentError observable_series(path;component=:absent)
    @test_throws ArgumentError observable_series(path)
    @test_throws DimensionMismatch linearize_mechanics(report,[0.,0.])
    @test_throws ArgumentError LagrangianSystem(v^2;coordinates=(q,q),velocities=(v,v))
end
println("STRANGER_PASS physicist")
