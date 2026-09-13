module RealAnalysisCoreTests
using Test, Symbolics, Roots
abstract type AbstractAnalysis end
const corepath = joinpath(@__DIR__, "..", "src", "real_analysis.jl")
@testset "real study implementation exists" begin
    @test isfile(corepath)
end
isfile(corepath) && include(corepath)
@variables x
study(e; original=e) = _real_analysis(e, x, Symbolics.expand_derivatives(Differential(x)(e)), Symbolics.expand_derivatives(Differential(x)(Differential(x)(e))); original)
@testset "overflow-safe exponent bounds" begin
    s = _real_analysis(x,x,nothing,nothing; original=:(x^(-9223372036854775808)))
    @test s.asymptotes.status == :unknown
    @test domain_contains(s.domain,0) === false
end
@testset "algebraic resource exhaustion is unknown" begin
    # This modest nested expression was safe to run before the guard, but
    # already exceeds the supported total degree (not just each exponent).
    s = _real_analysis(x,x,nothing,nothing; original=:((x^32)^32))
    @test s.asymptotes.status == :unknown
    @test s.roots.status == :unknown
    for original in (:(((2^32)^32)^8), :(x/x^32))
        bounded = _real_analysis(x,x,nothing,nothing; original)
        @test bounded.asymptotes.status == :unknown
    end
    domain_only = _real_analysis(x,x,nothing,nothing; original=:(sin(x)/((x^32)^32)))
    @test domain_only.domain.status == :unknown
    deep = :x
    for _ in 1:100; deep = Expr(:call,:+,deep,1); end
    @test _real_analysis(x,x,nothing,nothing;original=deep).domain.status == :unknown
    # All exits carry explicit resource evidence, including later derivative
    # intermediates and domain-only parsing; the next study gets a fresh budget.
    for original in (:((x^32)^32), :(((2^32)^32)^8), :(x/x^32),
                     :(sin(x)/((x^32)^32)), deep,
                     Expr(:call,:+,fill(:x,600)...),
                     Expr(:call,:*,big(1)<<5000,:x))
        limited = _real_analysis(x,x,nothing,nothing;original,interval=(-1,1))
        @test limited.domain.method == :resource_budget
        @test limited.roots.status == :unknown
        @test limited.asymptotes.method == :resource_budget
        @test !isempty(limited.roots.notes)
    end
    @test study(x^2).symmetry.value == :even
    # Exercise shared guards directly to isolate derivative/parity-style
    # products and the cumulative work gate from initial parsing.
    r = _ra_parse(:(1/(x^32+1)),:x)
    @test_throws _RABudgetExceeded _ra_derivative(_ra_derivative(r))
    @test_throws _RABudgetExceeded _ra_mul(_RAQ[1;zeros(Int,64)],_RAQ[1,1])
    @test_throws _RABudgetExceeded task_local_storage(_RA_BUDGET_KEY,Ref(1)) do
        _ra_add(_RAQ[1,1],_RAQ[1,1])
    end
    @test !haskey(task_local_storage(),_RA_BUDGET_KEY)
end
@testset "polynomial exact study" begin
    s = study(x^2)
    @test s isa AbstractAnalysis
    @test s.domain.status == :established
    @test s.roots.value == [0//1]
    @test s.roots.status == :established
    @test [p.sign for p in s.sign.value] == [1, 1]
    @test [p.direction for p in s.monotonicity.value] == [:decreasing, :increasing]
    @test only(s.extrema.value).classification == :minimum
    @test isempty(s.inflections.value)
    @test s.symmetry.value == :even
end
@testset "original rational domain and limits" begin
    s=study((x^2-1)/(x-1))
    @test domain_contains(s.domain,1) === false
    @test s.roots.value == [-1//1]
    @test only(s.continuity.value.discontinuities).classification == :removable
    @test any(l->l.at==1 && l.kind==:finite && l.value==2,s.limits.value)
    @test isempty(s.asymptotes.value.vertical)
    @test all(l->l.slope==1 && l.intercept==1,s.asymptotes.value.slant)
    p=study(1/x)
    @test p.intercepts.value.y === nothing
    @test p.symmetry.value == :odd
    @test p.asymptotes.value.vertical == [0//1]
    @test any(l->l.at==0 && l.side==:left && l.kind==:negative_infinity,p.limits.value)
    @test isempty(p.inflections.value)
    @test isempty(p.extrema.value)
    c=study(x^3)
    @test only(c.inflections.value).x == 0
    @test isempty(c.extrema.value)
    @test isempty(study(x^4).inflections.value)
    h=study(x;original=:(x^2/x))
    @test h.symmetry.value == :odd
    @test isempty(h.roots.value)
end
@testset "radicals and logarithms" begin
    s=study(sqrt(x-2))
    @test domain_contains(s.domain,2) === true
    @test domain_contains(s.domain,1) === false
    @test s.roots.value == [2//1]
    @test only(s.monotonicity.value).direction == :increasing
    @test only(s.concavity.value).direction == :concave
    @test only(s.extrema.value).x == 2
    l=study(log(x-1))
    @test domain_contains(l.domain,1) === false
    @test l.roots.value == [2//1]
    @test l.asymptotes.value.vertical == [1//1]
    @test only(l.concavity.value).direction == :concave
    q=study(log(x^2))
    @test q.roots.value == [-1//1,1//1]
    @test q.symmetry.value == :even
    @test isempty(q.inflections.value)
    a=study(sqrt(x^2))
    @test a.symmetry.value == :even
    @test only(a.extrema.value).classification == :minimum
    @test isempty(a.inflections.value)
    @test [p.direction for p in a.monotonicity.value] == [:decreasing,:increasing]
    @test length(a.asymptotes.value.slant)==2
    nested=study(log(sqrt(x-2)))
    @test nested.domain.status == :unknown # unsupported composed inequality, never guessed
end
@testset "degenerate domains and square-root constants" begin
    isolated=study(x;original=:(sqrt(-x^2)))
    @test domain_contains(isolated.domain,0) === true
    @test domain_contains(isolated.domain,1) === false
    @test isolated.roots.value == [0//1]
    @test isempty(isolated.monotonicity.value)
    @test isempty(isolated.concavity.value)
    @test all(l->l.kind==:does_not_exist,isolated.limits.value)
    @test study(x;original=:(sqrt(4))).symmetry.value == :even
    empty=study(x;original=:(1/0))
    @test empty.roots.status == :established
    @test isempty(empty.roots.value)
    @test empty.sign.status == :established
    @test isempty(empty.sign.value)
    @test isempty(empty.limits.value)
    unsupported_empty=study(x;original=:(exp(x)/0))
    @test unsupported_empty.domain.status == :established
    @test unsupported_empty.roots.status == :established
    @test unsupported_empty.roots.value == []
    @test unsupported_empty.symmetry.value == :both
    @test unsupported_empty.intercepts.value == (x=[],y=nothing)
end
@testset "derivative singularities and domain-restricted parity" begin
    isolated=study(sqrt(-x^2))
    @test isolated.symmetry.value == :both # The function is zero on {0}.
    @test isempty(isolated.extrema.value)
    mixed=study(x;original=:(sqrt(x^2*(x-1))))
    @test domain_contains(mixed.domain,0) === true
    @test domain_contains(mixed.domain,1//2) === false
    @test mixed.roots.value == [0//1,1//1]
    @test all(p->p.interval.left>=1,mixed.monotonicity.value)
    cusp=study(sqrt(x^2))
    @test all(p->p.interval.left!=p.interval.right,cusp.concavity.value)
    @test all(p->p.direction==:affine,cusp.concavity.value)
    @test length(cusp.concavity.value)==2 # Do not join across a nondifferentiable cusp.
    @test isempty(cusp.inflections.value)
    pole=study(1/x^2)
    @test isempty(pole.extrema.value)
    @test isempty(pole.inflections.value)
    @test all(p->p.direction==:convex,pole.concavity.value)
end
@testset "bounded roots remain heuristic" begin
    bounded(e;original=e,interval=(-2,2)) = _real_analysis(e,x,nothing,nothing;original,interval)
    s=bounded(x^2-2)
    @test s.roots.status == :heuristic
    @test s.roots.method == :bounded_root_search
    @test s.roots.value ≈ [-sqrt(2),sqrt(2)]
    @test s.sign.status == :unknown
    @test bounded(exp(x)).roots.status == :heuristic
    @test isempty(bounded(exp(x)).roots.value)
    @test !isempty(bounded(exp(x)).roots.notes)
    @test bounded(sin(x)+x).roots.value ≈ [0.0]
    @test bounded(x;original=:(sin(x)+x)).roots.value ≈ [0.0]
    @test bounded(x;original=:(exp(x))).roots.value == Float64[]
    @test bounded(1/(x^2-2)).roots.status == :unknown
    @test bounded(x^2-2;interval=(-Inf,Inf)).roots.status == :unknown
    hole=bounded((x^2-2)/(x-1))
    @test hole.roots.status == :heuristic
    @test hole.roots.value ≈ [-sqrt(2),sqrt(2)]
    @test all(t->domain_contains(hole.domain,t),hole.roots.value)
end
@testset "concrete expression and periodic payload storage" begin
    s=study(x^2)
    @test fieldtype(typeof(s),:original_expression) == typeof(s.original_expression)
    @test fieldtype(typeof(s),:simplified_expression) == typeof(s.simplified_expression)
    p=PeriodicPointSet(0,:π)
    @test fieldtype(typeof(p),:offset) == Int
    @test fieldtype(typeof(p),:period) == Symbol
    i=PeriodicIntervalSet(0,:π,:(2*π),false,false)
    @test fieldtype(typeof(i),:left) == Int
    @test fieldtype(typeof(i),:right) == Symbol
    @test fieldtype(typeof(i),:period) == Expr
end
@testset "periodic analytic identities" begin
    s=study(sin(x))
    @test s.roots.status == :established
    @test s.roots.value isa PeriodicPointSet
    @test s.roots.value.offset == 0
    @test s.roots.value.period == :π
    @test s.symmetry.value == :odd
    @test [p.sign for p in s.sign.value] == [1,-1]
    @test [p.direction for p in s.monotonicity.value] == [:increasing,:decreasing]
    @test [p.value for p in s.extrema.value] == [1,-1]
    @test only(s.inflections.value).value == 0
    @test all(l->l.kind==:does_not_exist,s.limits.value)
    @test isempty(s.asymptotes.value.vertical)
end
@testset "certified boundaries and conservative fallbacks" begin
    r=study((x^2-4)/(x^2-1))
    @test r.roots.value == [-2//1,2//1]
    @test r.asymptotes.value.vertical == [-1//1,1//1]
    @test all(p->p.value==1,r.asymptotes.value.horizontal)
    @test r.concavity.status == :established
    @test isempty(r.inflections.value)
    @test only(r.extrema.value).classification == :minimum
    @test [p.sign for p in r.sign.value] == [1,-1,1,-1,1]
    unknown=study(x^2-2)
    @test unknown.roots.status == :unknown
    @test unknown.sign.status == :unknown
    @test unknown.continuity.status == :established
    @test study(1/(x^2-2)).domain.status == :unknown
    @test domain_contains(study(1/(x^2-2)).domain,0) === nothing
    @test study(exp(x)).roots.status == :unknown
    zero=study(0*x)
    @test zero.roots.value isa RealDomain
    @test zero.symmetry.value == :both
    @test isempty(zero.extrema.value)
    @test isempty(study(x;original=:(1/0)).domain.components)
    @test study(x;original=:(run(`never-execute`))).domain.status == :unknown
    @test study(x;original=:(x^(-1))).asymptotes.value.vertical == [0//1]
    @test isequal(study((x^2-1)/(x-1)).simplified_expression,Symbolics.simplify((x^2-1)/(x-1)))
    @test study(x;original=:(log(x/x))).symmetry.value == :both
    @test study(x;original=:(sqrt(0*x))).symmetry.value == :both
    @test study(x;original=:(0/(x-1))).symmetry.value == :neither
    # Exact sign certificates agree with evaluations on every certified cell.
    for e in (x^2,x^3,x^4,1/x,(x^2-4)/(x^2-1))
        s=study(e)
        for cell in s.sign.value
            t=_ra_sample(cell.interval.left,cell.interval.right)
            val=Symbolics.value(Symbolics.substitute(e,Dict(x=>t)))
            @test sign(val)==cell.sign
            @test t isa Rational{BigInt}
        end
    end
end
end
