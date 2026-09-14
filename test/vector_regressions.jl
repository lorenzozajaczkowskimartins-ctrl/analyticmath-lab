module VectorRegressionTests
using Test, AnalyticMathLab, Symbolics
import Makie
@variables x y z w
@testset "Vector input, arithmetic and evidence boundaries" begin
    @test analyze((-y,x),(x,y)) isa VectorFieldAnalysis
    @test_throws ArgumentError analyze([], (x,y))
    @test_throws ArgumentError analyze([x,"y"],(x,y))
    @test_throws ArgumentError analyze([x,z],(x,y))
    @test_throws ArgumentError analyze([x,y],(x,x))
    @test_throws ArgumentError analyze([x,y],(x,y);original_expression=[x])
    @test_throws ArgumentError analyze([x,y],(x,y);residual_rtol=-1)
    @test_throws ArgumentError analyze([x,y],(x,y);residual_rtol=1e308,residual_scale=1e308)
    r = analyze([x^2,y^2],(x,y))
    for p in ((0.5f0,0.25f0),(0.5,0.25),(1//2,1//4),(big"0.5",big"0.25"))
        @test evaluate(r,p) == collect(p).^2
        @test eltype(evaluate(r,p)) == typeof(p[1])
    end
    @test (@inferred evaluate(r,(0.5,0.25))) == [0.25,0.0625]
    J = jacobian(r); J[1,1] = 123
    @test !isequal(J,jacobian(r))
    c = analyze([2x,2y],(x,y))
    p = potential(c); push!(p.notes,"changed")
    @test "changed" ∉ c.potential.notes
    @test all(isconcretetype,fieldtypes(typeof(c)))
    four = analyze([x,y,z,w],(x,y,z,w))
    @test divergence(four).value == 4
    @test curl(four).status == :unknown
    @test four.conservative.value === true
    # Unsupported source and nonsmooth cancellation never become smoothness proofs.
    a = analyze([x,y],(x,y);original_expression=[:(mystery(x)),:(y)])
    @test a.domain.status == :unknown
    @test a.field_zeros.status == :unknown
    @test a.conservative.status == :unknown
    @test_throws DomainError jacobian(a,(1,1))
    @test isempty(first(AnalyticMathLab._vf_arrows(a,(-1,1),(-1,1),3,1)))
    b = analyze(@real_function([abs(x)^2,y]),(x,y))
    @test_throws DomainError linearization(b,(0,1))
    @test b.conservative.status == :unknown
    # No promotion of a constant-zero system into an empty exact zero set.
    zero = analyze([0,0],(x,y))
    @test zero.field_zeros.status == :unknown
    emptysearch = analyze([sin(x)+2,y],(x,y);bounds=((-1,1),(-1,1)),grid=3)
    @test emptysearch.field_zeros.status == :heuristic
    @test isempty(emptysearch.field_zeros.value)
    hole = analyze(@real_function([(x^2+y^2)/(x^2+y^2),y]),(x,y))
    @test domain_contains(hole.domain,(0,0)) === false
    @test_throws DomainError evaluate(hole,(0,0))
    named = [x,y]
    opaque = analyze(@real_function(named),(x,y))
    @test opaque.domain.status == :unknown
    @test ismissing(Makie.current_backend())
end
@testset "Vector views call only stored field values" begin
    r = analyze([-y,x],(x,y))
    calls = Ref(0)
    field = map(r.numerical.field) do f
        (args...) -> (calls[] += 1; f(args...))
    end
    numerical = (field=field,jacobian=r.numerical.jacobian)
    fields = ntuple(i -> fieldnames(typeof(r))[i] == :numerical ? numerical : getfield(r,i),fieldcount(typeof(r)))
    instrumented = VectorFieldAnalysis(fields...)
    before = calls[]
    sprint(show,MIME"text/plain"(),instrumented)
    @test calls[] == before
    points,_ = AnalyticMathLab._vf_arrows(instrumented,(-1,1),(-1,1),3,1)
    @test calls[] == 2*length(points)
    @test length(points) == 9
end
end
