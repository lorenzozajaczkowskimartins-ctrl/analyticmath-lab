module M10CChunkingTests
using Test, AnalyticMathLab
@testset "M10C bounded sampled diagnostics" begin
    x=fill(3.,100_000); y=fill(1.,100_000)
    sampled_summary(x)
    @test (@allocated sampled_summary(x)) < 100_000
    @test sampled_summary(Iterators.Stateful([3.,4.])).sampled_l2 ≈ 5.
    @test sampled_summary((v for v in Iterators.Stateful([3.,4.]))).sampled_l2 ≈ 5.
    calls=Ref(0)
    generated=((calls[]+=1; Float64(calls[])) for _ in 1:4)
    @test sampled_summary(generated).sampled_l2 ≈ sqrt(30.)
    @test calls[]==4
    for T in (Float32,Float64,BigFloat,Rational{Int})
        p=T[3,4,5]; r=T[1,2,3]
        full=field_errors(p,r)
        bounded=field_errors(p,r;summary_only=true)
        @test bounded.absolute === nothing
        @test bounded.summary == full.summary
        @test bounded.relative_sampled_l2 == full.relative_sampled_l2
    end
    field_errors(x,y;summary_only=true)
    @test (@allocated field_errors(x,y;summary_only=true)) < 100_000
    @test_throws ArgumentError field_errors([floatmax(Float64)],[-floatmax(Float64)];summary_only=true)
end
@testset "M10C residual summary without retained values" begin
    points=PINNPoints([0.1 0.3 0.7;0.2 0.4 0.6])
    f=q->q[1]^2+q[2]
    full=heat_residual(f,points;alpha=0.2)
    bounded=heat_residual(f,points;alpha=0.2,summary_only=true)
    @test bounded.values === nothing
    @test bounded.summary == full.summary
    @test bounded.summary.rms ≈ 0.6
end
end
