module TrajectoryComparisonVisualizationTests
using Test, AnalyticMathLab, Unitful
import Makie
@testset "M8C stored comparison views" begin
    @test isdefined(AnalyticMathLab,:comparisonplot)
    if isdefined(AnalyticMathLab,:comparisonplot)
        sa=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"J";name=:total_energy,interval=1u"s")
        sb=ObservableSeries(sa.values .+ 1u"J";name=:total_energy,interval=1u"s")
        a=ComparisonInput(correlated_mean(sa;window=1,maxlag=3);series=sa,label="A")
        b=ComparisonInput(correlated_mean(sb;window=1,maxlag=3);series=sb,label="B")
        c=compare(a,b;independence=:independent)
        before=copy(sa.values)
        @test comparisonplot(c) isa Makie.Figure
        @test differenceplot(c) isa Makie.Figure
        ac=ComparisonInput(a.result.value.correlation;series=sa,label="A")
        bc=ComparisonInput(b.result.value.correlation;series=sb,label="B")
        @test comparisonplot(compare(ac,bc)) isa Makie.Figure
        @test differenceplot(compare(ac,bc)) isa Makie.Figure
        short=ComparisonInput(autocorrelation(sb;maxlag=2);series=sb)
        @test comparisonplot(compare(ac,short)) isa Makie.Figure
        @test differenceplot(compare(ac,short)) isa Makie.Figure
        @test sa.values==before
        @test compare(a,b).uncertainty.value===nothing
    end
end
end
