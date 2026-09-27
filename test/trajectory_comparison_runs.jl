module TrajectoryComparisonRunTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
@testset "M8C stored report composition and isolation" begin
    @test isdefined(A,:compare_runs)
    if isdefined(A,:compare_runs)
        calls=Ref(0)
        t=AtomisticTrajectoryView(8,i->(calls[]+=1;error("No frame access permitted"));times=(0:7)u"s")
        sa=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"J";name=:total_energy,times=t.times,provenance=(ensemble=:NVE,run="A"))
        sb=ObservableSeries(sa.values .+ 1u"J";name=:total_energy,times=t.times,provenance=(ensemble=:NVE,run="B"))
        a=analyze(t;series=(energy=sa,),correlations=(:energy,),window=1,maxlag=3)
        b=analyze(t;series=(energy=sb,))
        c=compare_runs(a,b;labels=("A","B"),components=(:summaries,:correlations,:vacf))
        @test c isa MDTrajectoryComparison
        @test c.a===a && c.b===b
        @test c.labels==("A","B")
        @test c.components[:summaries][:energy].difference.value≈1u"J"
        @test c.components[:summaries][:energy].metadata.a.identity==:total_energy
        @test c.components[:correlations][:energy].compatibility.status==:unknown
        @test c.components[:correlations][:energy].difference.value===nothing
        @test c.components[:vacf].compatibility.status==:unknown
        @test calls[]==0
        @test !haskey(c.components,:msd)
        @test diagnose(c).value===c.components
        @test compare(a,b;components=(:summaries,)).components[:summaries][:energy].difference.value≈1u"J"
        @test_throws ArgumentError compare_runs(a,b;components=(:bogus,))
        @test Base.get_extension(A,:AnalyticMathLabMollyExt)===nothing
        @test all(m->!(nameof(m) in (:Molly,:CairoMakie,:GLMakie)),values(Base.loaded_modules))
        @test ismissing(A.Makie.current_backend())
        empty=analyze(t)
        missing=compare_runs(a,empty;components=(:summaries,))
        @test missing.components[:summaries][:energy].difference.value===nothing
        @test missing.components[:summaries][:energy].compatibility.status==:unknown
    end
end
end
