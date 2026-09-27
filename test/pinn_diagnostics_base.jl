module PINNDiagnosticsBaseTests
using Test, AnalyticMathLab
import Makie
@testset "M9B sampled metrics and point provenance" begin
    s=sampled_summary([-3.,4.])
    @test s.count==2
    @test s.rms≈sqrt(12.5)
    @test s.mean_absolute==3.5
    @test s.max_absolute==4.
    @test s.sampled_l2≈5.
    @test s.normalization==:unweighted_samples
    @test sampled_summary([NaN,1.]).rms===nothing
    @test sampled_summary([Inf]).finite_count==0
    @test sampled_summary(Float64[]).count==0
    @test sampled_summary([0.,0.]).sampled_l2==0.
    @test isfinite(sampled_summary([1e300,-1e300]).rms)
    p=PINNPoints([1. 2.];generation=:explicit,provenance=(units="m",))
    @test p.provenance.units=="m"
    @test p.generation==:explicit
    @test_throws ArgumentError PINNPoints(zeros(1,0))
    @test_throws ArgumentError PINNPoints([NaN;;])
    @test ismissing(Makie.current_backend())
    @test Base.get_extension(AnalyticMathLab,:AnalyticMathLabPINNExt)===nothing
end
end
