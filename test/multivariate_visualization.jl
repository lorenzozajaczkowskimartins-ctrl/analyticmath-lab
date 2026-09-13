using Test, AnalyticMathLab, Symbolics
import Makie

@variables vx vy
@testset "Multivariate backend independence" begin
    @test all(m -> nameof(m) != :CairoMakie, values(Base.loaded_modules))
    report = analyze(vx^2 + vy^2, (vx,vy))
    @test surface(report; xrange=(-2,2), yrange=(-2,2), samples=21) isa Makie.Figure
    @test contour(report; xrange=(-2,2), yrange=(-2,2), samples=21) isa Makie.Figure
    @test gradientplot(report; xrange=(-2,2), yrange=(-2,2), samples=7) isa Makie.Figure
    @test gradientplot(report; samples=7, arrowscale=0.1) isa Makie.Figure
    @test_throws ArgumentError gradientplot(report; arrowscale=Inf)
    @test_throws ArgumentError gradientplot(report; arrowscale=0)
    @test plot(report; xrange=(-2,2), yrange=(-2,2), samples=21,
               tangent_at=(1,1)) isa Makie.Figure
    before = copy(report.stationary_points.value)
    surface(report; xrange=(-2,2), yrange=(-2,2), samples=9)
    @test report.stationary_points.value == before
    pole = analyze(@real_function(1/(vx^2+vy^2-1)), (vx,vy))
    gx,gy,z = AnalyticMathLab._mv_grid(pole, (-1.5,1.5), (-1.5,1.5), 8)
    @test any(isnan,z)
    crossing_cells = [(i,j) for i in 1:7, j in 1:7 if
        minimum((x^2+y^2-1 for x in gx[i:i+1], y in gy[j:j+1])) < 0 <
        maximum((x^2+y^2-1 for x in gx[i:i+1], y in gy[j:j+1]))]
    @test !isempty(crossing_cells)
    @test all(any(isnan,z[i:i+1,j:j+1]) for (i,j) in crossing_cells)
    @test all(m -> nameof(m) != :CairoMakie, values(Base.loaded_modules))
    @test_throws ArgumentError surface(report; xrange=(1,-1))
    @test_throws ArgumentError contour(report; samples=1)
    @test_throws ArgumentError gradientplot(report; samples=101)
    @test_throws ArgumentError surface(analyze(vx^2, (vx,vy, Symbolics.variable(:vz))))

    pole = analyze(@real_function(1/(vx^2+vy^2-1)), (vx,vy))
    xs, ys, zs = AnalyticMathLab._mv_grid(pole, (-2,2), (-2,2), 20)
    @test any(isnan, zs)
    @test all(isnan(zs[i,j]) for i in eachindex(xs), j in eachindex(ys)
              if (xs[i]^2+ys[j]^2-1) == 0)
end
