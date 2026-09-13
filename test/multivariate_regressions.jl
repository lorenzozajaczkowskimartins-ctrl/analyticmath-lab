using Test, AnalyticMathLab, Symbolics
import LinearAlgebra
@variables rx ry
@testset "Original-domain membership and derivative gates" begin
    pole = analyze(@real_function(1/(rx^2+ry^2)), (rx,ry))
    @test domain_contains(pole.domain, (2^32,0)) === true
    partial = analyze(@real_function(tan(rx)/(ry-1)), (rx,ry))
    @test domain_contains(partial.domain, (0,1)) === false
    @test domain_contains(partial.domain, (0,2)) === nothing
    @test domain_contains(partial.domain, (NaN,2)) === false
    unknown = analyze(@real_function(rx^ry), (rx,ry))
    @test domain_contains(unknown.domain, (Inf,2)) === false
    cusp = analyze(@real_function(0*sqrt(rx)+rx^2+ry^2), (rx,ry))
    @test_throws DomainError directional_derivative(cusp,(0,0),(1,0))
    @test_throws DomainError gradient(cusp,(0,0))
    @test_throws DomainError hessian(cusp,(0,0))
    @test isnan(AnalyticMathLab._mv_safe_value(unknown,(2,3)))
    canceled_unknown = analyze(@real_function(tan(rx)/tan(rx)+rx^2+ry^2),(rx,ry))
    @test isnan(AnalyticMathLab._mv_safe_value(canceled_unknown,(0,0)))
    hole = analyze(@real_function((rx^2+ry^2)^2/(rx^2+ry^2)), (rx,ry))
    @test isempty(hole.stationary_points.value)
    @test domain_contains(hole.domain,(0,0)) === false
    @test AnalyticMathLab._mv_stationary_xyz(hole,(-1,1),(-1,1)) == (Float64[],Float64[],Float64[])
end
@testset "Scalar field evidence and resource regressions" begin
    unknown = analyze(@real_function(tan(rx)/tan(rx) + rx^2 + ry^2), (rx,ry))
    @test unknown.stationary_points.status == :unknown
    @test isempty(unknown.stationary_points.value)
    # Original boundary is defined but not an open smooth neighborhood.
    boundary = analyze(@real_function(sqrt(rx)/sqrt(rx) + rx^2 + ry^2), (rx,ry))
    @test isempty(boundary.stationary_points.value)
    flatdomain = analyze(@real_function(0*sqrt(rx) + rx^2 + ry^2), (rx,ry))
    @test isempty(flatdomain.stationary_points.value)
    @test flatdomain.stationary_points.status != :established
    @test AnalyticMathLab._mv_symbolic_classification([1e-30 0.0; 0.0 1.0]) === nothing
    @test_throws ArgumentError analyze(rx^2, (1,ry))
    budget = analyze((big(2)^1024)*rx^4 + ry^4, (rx,ry))
    @test budget.stationary_points.method == :resource_budget
    @test isdefined(AnalyticMathLab, :_mv_product_size)
    if isdefined(AnalyticMathLab, :_mv_product_size)
        @test_throws ArgumentError AnalyticMathLab._mv_product_size(fill(25,18), 50000)
        @test_throws ArgumentError AnalyticMathLab._mv_product_size(fill(3,20), 4096)
    end
    # More variables must fail before allocating a large symbolic Hessian.
    vars = Symbolics.variable.([Symbol("r$i") for i in 1:33])
    @test_throws ArgumentError analyze(0, Tuple(vars))
    @test_throws DomainError levelset(analyze(rx^2+ry^2,(rx,ry)), Inf)
    q=analyze(rx^2+ry^2,(rx,ry))
    @test directional_derivative(q,(1,1),(1e308,1e308)) ≈ 2sqrt(2)
    @test all(isconcretetype, fieldtypes(typeof(q)))
end
@testset "Surface interior singularities" begin
    pole = analyze(@real_function(1/((rx-1//5)^2+(ry-1//5)^2)), (rx,ry))
    xs,ys,z = AnalyticMathLab._mv_grid(pole,(0,1),(0,1),4)
    @test any(isnan,z[1:2,1:2])
end
