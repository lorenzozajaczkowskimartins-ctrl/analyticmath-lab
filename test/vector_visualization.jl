module VectorVisualizationTests
using Test, AnalyticMathLab, Symbolics
import Makie
@variables x y
snapshot(r) = (r.components,r.original_components,r.jacobian_expression,
    map(d -> (d.expression,d.relation),r.domain.restrictions))
@testset "Vector views use stored callables and original domains" begin
    @test isdefined(AnalyticMathLab,:vectorplot)
    if isdefined(AnalyticMathLab,:vectorplot)
        r = analyze(@real_function([-y/(x^2+y^2),x/(x^2+y^2)]),(x,y))
        before = deepcopy(snapshot(r))
        points,vectors = AnalyticMathLab._vf_arrows(r,(-1,1),(-1,1),3,0.25)
        backend = Makie.current_backend()
        @test length(points) == 8
        @test all(p -> domain_contains(r.domain,Tuple(p)) === true,points)
        @test all(p -> !all(iszero,p),points)
        for (p,v) in zip(points,vectors)
            @test collect(v) ≈ 0.25 .* evaluate(r,Tuple(p))
        end
        @test_throws ArgumentError vectorplot(r;arrowscale=0)
        @test_throws ArgumentError vectorplot(r;samples=51)
        @test_throws ArgumentError vectorplot(r;xrange=(2,1))
        @test_throws ArgumentError vectorplot(analyze([x,y,x+y],(x,y)))
        text = sprint(show,MIME"text/plain"(),r)
        @test occursin("Vector Field Analysis",text)
        @test occursin("unknown",text)
        @test !occursin("RuntimeGeneratedFunction",text)
        @test isequal(Makie.current_backend(),backend)
        @test isequal(before,snapshot(r))
        @eval import CairoMakie
        fig = vectorplot(r;xrange=(-1,1),yrange=(-1,1),samples=3,arrowscale=0.25)
        @test fig isa Makie.Figure
        axis = only(filter(c -> c isa Makie.Axis,fig.content))
        @test length(only(axis.scene.plots)[1][]) == 8
        @test plot(analyze([-y,x],(x,y));samples=3) isa Makie.Figure
        mktempdir() do dir
            @test isequal(before,snapshot(r))
            path = joinpath(dir,"vector.png")
            CairoMakie.save(path,fig)
            @test filesize(path) > 1000
        end
    end
end
end
