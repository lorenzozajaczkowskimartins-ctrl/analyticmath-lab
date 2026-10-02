module SurrogateDiagnosticsTests
using Test, AnalyticMathLab
const A=AnalyticMathLab
@testset "M9D independent heat residual semantics" begin
    @test isdefined(A,:heat_residual)
    if isdefined(A,:heat_residual)
        pts=PINNPoints([0.17 0.43 0.79;0.13 0.27 0.37];generation=:independent_grid)
        f=q->sin(pi*q[1])*exp(-0.1*pi^2*q[2])
        r=heat_residual(f,pts;alpha=0.1)
        @test r.summary.max_absolute<1e-12
        @test r.derivative==:ForwardDiff_coordinate_gradient_hessian
        @test r.evidence.status==:unknown
        bad=heat_residual(q->f(q)+0.1q[1]^2,pts;alpha=0.1)
        @test bad.values≈fill(-0.02,3)
        @test_throws ArgumentError heat_residual(f,pts;alpha=-1.)
        @test_throws DimensionMismatch heat_residual(f,PINNPoints(zeros(3,2));alpha=0.1)
    end
end
@testset "M9D descriptive query timings" begin
    @test isdefined(A,:benchmark_queries)
    if isdefined(A,:benchmark_queries)
        r=benchmark_queries(()->ones(4),()->fill(1.,4);training_seconds=2.,repetitions=5,context=(benchmark=:fixture,))
        @test length(r.reference_seconds)==5
        @test length(r.inference_seconds)==5
        @test r.training_seconds==2
        @test r.reference_median>=0 && r.inference_median>=0
        @test r.compilation==:first_timed_calls_may_include_compilation
        @test r.break_even_queries===nothing || r.break_even_queries>0
        @test_throws ArgumentError benchmark_queries(()->1,()->1;training_seconds=-1.)
    end
end
end
