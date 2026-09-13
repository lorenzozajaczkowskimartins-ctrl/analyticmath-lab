using Test, AnalyticMathLab, Symbolics

@variables mx my mz mp

@testset "Multivariate scalar analysis" begin
    q = analyze(mx^2 + 2my^2 - mx*my, (mx, my))
    @test q isa ScalarFieldAnalysis
    @test q.dimension == 2
    @test q.variables == (mx, my)
    @test all(iszero, Symbolics.simplify.(gradient(q) .- [2mx-my, 4my-mx]))
    @test all(iszero, Symbolics.simplify.(hessian(q) .- [2 -1; -1 4]))
    @test evaluate(q, (2, 3)) == 16
    @test gradient(q, [2, 3]) == [1, 10]
    @test hessian(q, (2, 3)) == [2 -1; -1 4]
    @test_throws DimensionMismatch evaluate(q, [1])
    @test_throws DomainError evaluate(q, [1, Inf])
    @test_throws ArgumentError analyze(mx + my, (mx, mx))
    @test_throws ArgumentError analyze(mx + mp, (mx, my))
    @test_throws ArgumentError analyze(mx, (mx + 1, my))

    p = only(q.stationary_points.value)
    @test p.point == [0//1, 0//1]
    @test p.residual_norm <= p.residual_threshold
    @test p.classification == :minimum_candidate
    @test q.stationary_points.status == :established

    quartic = analyze(mx^4 + my^4 - 2mx^2 - 2my^2, [mx, my])
    @test quartic.stationary_points.status == :established
    @test length(quartic.stationary_points.value) == 9
    @test count(p -> p.classification == :minimum_candidate, quartic.stationary_points.value) == 4
    @test count(p -> p.classification == :maximum_candidate, quartic.stationary_points.value) == 1
    @test count(p -> p.classification == :saddle_candidate, quartic.stationary_points.value) == 4

    saddle = analyze(mx^2 - my^2, (mx, my))
    @test only(saddle.stationary_points.value).classification == :saddle_candidate
    flat = analyze(mx^4 + my^4, (mx, my))
    @test only(flat.stationary_points.value).classification == :inconclusive
    @test analyze(sin(mx) + cos(my), (mx, my)).stationary_points.status == :unknown
    heuristic = analyze(sin(mx) + cos(my), (mx, my); bounds=((-4,4),(-4,4)), grid=5)
    @test heuristic.stationary_points.status == :heuristic
    @test all(isfinite(p.residual_norm) for p in heuristic.stationary_points.value)

    @test directional_derivative(q, (2,3), (3,4)) ≈ 43/5
    @test_throws DomainError directional_derivative(q, (0,0), (0,0))
    lin = linearization(q, (1,2))
    @test lin.base_point == [1,2]
    @test lin.value == 7
    @test lin.coefficients == [0,7]
    @test iszero(Symbolics.simplify(lin.expression - (7 + 7*(my-2))))
    ls = levelset(q, 3)
    @test ls isa Symbolics.Equation
    @test isequal(Symbolics.Num(ls.rhs), Symbolics.Num(3))

    nd = analyze(mx^2 + my^2 + mz^2, (mx,my,mz))
    @test nd.dimension == 3
    @test gradient(nd, (1,2,3)) == [2,4,6]
end

@testset "Multivariate original domains" begin
    pole = analyze(@real_function(1/(mx^2+my^2-1)), (mx,my))
    @test domain_contains(pole.domain, (1,0)) === false
    @test domain_contains(pole.domain, (0,0)) === true
    disk = analyze(@real_function(sqrt(1-mx^2-my^2)), (mx,my))
    @test domain_contains(disk.domain, (0,0)) === true
    @test domain_contains(disk.domain, (2,0)) === false
    logarithm = analyze(@real_function(log(mx-my)), (mx,my))
    @test domain_contains(logarithm.domain, (2,1)) === true
    @test domain_contains(logarithm.domain, (1,2)) === false
    canceled = analyze(@real_function((mx^2+my^2-1)/(mx^2+my^2-1)), (mx,my))
    @test domain_contains(canceled.domain, (1,0)) === false
    unknown = analyze(@real_function(mx^my), (mx,my))
    @test unknown.domain.status == :unknown
    @test domain_contains(unknown.domain, (2,3)) === nothing
    @test_throws DomainError evaluate(pole, (1,0))
    @test occursin("Scalar Field Analysis", sprint(show, MIME"text/plain"(), pole))
    @test !occursin("RuntimeGeneratedFunction", sprint(show, MIME"text/plain"(), pole))
end
