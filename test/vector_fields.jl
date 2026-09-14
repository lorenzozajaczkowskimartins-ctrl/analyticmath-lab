module VectorFieldTests
using Test, AnalyticMathLab, Symbolics
import Makie
@variables x y z
@testset "Vector dispatch and rectangular Jacobian" begin
    @test applicable(analyze, [-y,x], (x,y))
    if applicable(analyze, [-y,x], (x,y))
        r = analyze([-y,x], (x,y))
        @test r isa VectorFieldAnalysis
        @test (r.input_dimension,r.output_dimension) == (2,2)
        @test jacobian(r) == [0 -1; 1 0]
        @test jacobian(r,(1.0,2.0)) == [0 -1;1 0]
        @test evaluate(r,(1.0,2.0)) == [-2,1]
        @test_throws DimensionMismatch evaluate(r,(1,))
        @test_throws DomainError evaluate(r,(Inf,0))
        q = analyze([x+y,x-y,x^2], (x,y))
        @test size(jacobian(q)) == (3,2)
        @test jacobian(q,(2,3)) == [1 1;1 -1;4 0]
        @test evaluate(q,(2,3)) == [5,-1,4]
        @test analyze(x^2,x) isa FunctionAnalysis
        @test analyze(x^2+y^2,(x,y)) isa ScalarFieldAnalysis
        @test ismissing(Makie.current_backend())
        @test all(m -> nameof(m) ∉ (:CairoMakie,:GLMakie), values(Base.loaded_modules))
    end
@testset "Vector component original domains" begin
    r = analyze(@real_function([(x^2-1)/(x-1),y]), (x,y))
    @test domain_contains(r.domain,(1,0)) === false
    @test_throws DomainError evaluate(r,(1,0))
    q = analyze([sqrt(1-x^2-y^2),log(x-y)], (x,y))
    @test domain_contains(q.domain,(0.5,0)) === true
    @test domain_contains(q.domain,(2,0)) === false
    @test domain_contains(q.domain,(0,0)) === false
    p = analyze([x,y], (x,y); original_expression=[:(mystery(x)), :(1/y)])
    @test domain_contains(p.domain,(1,0)) === false
    @test domain_contains(p.domain,(1,1)) === nothing
    boundary = analyze(@real_function([sqrt(x)^2,y]), (x,y))
    @test_throws DomainError jacobian(boundary,(0,0))
end
end
end
