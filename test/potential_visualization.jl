module PotentialVisualizationTests
using Test, AnalyticMathLab, Symbolics
import Makie
@testset "Potential views reuse stored analysis" begin
    @variables r
    p=AnalyticMathLab.analyze_potential((r-2)^2,r)
    @test isdefined(AnalyticMathLab,:potentialplot)
    if isdefined(AnalyticMathLab,:potentialplot)
        before=deepcopy(p.equilibria.value)
        fig=AnalyticMathLab.potentialplot(p;rmin=0.5,rmax=4.,samples=41)
        @test fig isa Makie.Figure
        @test count(x->x isa Makie.Axis,fig.content)==2
        @test p.equilibria.value==before
        @test_throws ArgumentError AnalyticMathLab.potentialplot(p;rmin=0.,rmax=3.)
        @test_throws ArgumentError AnalyticMathLab.potentialplot(p;rmin=1.,rmax=3.,samples=1)
        @test AnalyticMathLab.plot(p;rmin=0.5,rmax=4.) isa Makie.Figure
        @test isdefined(AnalyticMathLab,:forceplot)
        if isdefined(AnalyticMathLab,:forceplot)
            forcefig=AnalyticMathLab.forceplot(p;rmin=0.5,rmax=4.,samples=41)
            @test forcefig isa Makie.Figure
            @test count(x->x isa Makie.Axis,forcefig.content)==1
            @test_throws ArgumentError AnalyticMathLab.forceplot(p;rmin=0.,rmax=4.)
        end
    end
end
end
