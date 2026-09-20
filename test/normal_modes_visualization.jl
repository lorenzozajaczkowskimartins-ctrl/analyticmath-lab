module NormalModesVisualizationTests
using Test, AnalyticMathLab
import CairoMakie, Makie
@testset "Mode component plots preserve mathematical results" begin
    @test isdefined(AnalyticMathLab,:modeplot)
    if isdefined(AnalyticMathLab,:modeplot)
        r=normal_modes([2 -1;-1 2],[1 0;0 1])
        before=deepcopy(r)
        fig=modeplot(r)
        @test fig isa Makie.Figure
        @test r.mode_vectors == before.mode_vectors
        @test r.weighted_vectors == before.weighted_vectors
        @test r.eigenvalues == before.eigenvalues
        @test sprint(show,r.metadata) == sprint(show,before.metadata)
        ax=only(filter(c->c isa Makie.Axis,fig.content))
        @test occursin("coordinate",lowercase(ax.xlabel[]))
        @test occursin("mass",lowercase(ax.ylabel[]))
        @test modeplot(r;modes=[2],representation=:mass_weighted) isa Makie.Figure
        @test_throws ArgumentError modeplot(r;modes=[0])
        @test_throws ArgumentError modeplot(r;representation=:cartesian)
        @test_throws ArgumentError modeplot(normal_modes([1;;],[0;;]))
        @test modeplot(normal_modes([1 0;0 1],[1 0;0 1])) isa Makie.Figure
    end
end
end
