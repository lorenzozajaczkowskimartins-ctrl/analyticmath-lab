module DynamicalSystemTests
using Test, AnalyticMathLab, Symbolics
import Makie
const AML = AnalyticMathLab
@variables x y z
@testset "Autonomous structural API" begin
    @test isdefined(AML, :AutonomousSystem)
    if isdefined(AML, :AutonomousSystem)
        f = analyze([-y,x], (x,y))
        s = AML.AutonomousSystem(f)
        r = analyze(s)
        @test r isa AML.DynamicalSystemAnalysis
        @test r.system === s && r.field === f && s.field === f
        @test r.variables == (x,y) && r.dimension == 2 && r.domain === f.domain
        @test length(AML.equilibria(r).value) == 1
        @test AML.equilibria(r).status == :established
        @test_throws DimensionMismatch AML.AutonomousSystem(analyze([x,y,x+y],(x,y)))
        @test evaluate(r,(1,2)) == [-2,1]
        @test AML.jacobian(r) == AML.jacobian(f)
        @test isequal(AML.linearization(r,(0,0)), AML.linearization(f,(0,0)))
        @test ismissing(Makie.current_backend())
    end
@testset "Numerical evidence and implicit nullclines" begin
    r = analyze(AML.AutonomousSystem([exp(x)-2],(x,);bounds=((-2,2),)))
    @test r.equilibria.status == :heuristic
    @test !isempty(r.equilibria.value)
    @test all(l -> l.stability.status == :heuristic && l.stability.value == :unstable,AML.stability(r))
    @test all(l -> any(contains("approximate"),l.stability.notes),AML.stability(r))
    n = analyze(AML.AutonomousSystem([-y,x],(x,y)))
    @test AML.nullclines(n).status == :established
    if AML.nullclines(n).value !== nothing
        @test length(AML.nullclines(n).value) == 2
        @test all(c -> c.domain === n.domain,n.nullclines.value)
        @test isequal(AML.nullclines(n).value[1].equation, -y ~ 0)
    end
    @test occursin("DynamicalSystemAnalysis",sprint(show,MIME"text/plain"(),n))
    @test occursin("equilibria",sprint(show,MIME"text/plain"(),n))
end
@testset "Domain, degeneracy, copies, and diagnostics" begin
    hole = analyze(AML.AutonomousSystem(@real_function([(x^2-1)/(x-1)-2,y]),(x,y)))
    @test domain_contains(hole.domain,(1,0)) === false
    @test isempty(hole.equilibria.value)
    @test domain_contains(only(filter(c -> c.component == 1,AML.nullclines(hole).value)).domain,(1,0)) === false
    corner = analyze(AML.AutonomousSystem(@real_function([sqrt(x)^2,y]),(x,y)))
    @test only(AML.stability(corner)).stability.status == :unknown
    @test only(AML.stability(corner)).stability.method == :smoothness_gate
    # These exact points are independently verified to isolate the local theorem
    # from the intentionally limited complete field-zero solver.
    for (F,expected) in (([-y+x^3,x],:inconclusive),([x,y^3],:unstable))
        f = analyze(F,(x,y))
        z0 = AML._vf_zero_candidate(f,[0//1,0//1],1e-8;exact=true)
        @test z0 !== nothing
        l = AML._ds_local(f,z0,:established,1e-10,1e-8)
        @test l.stability.value == expected
        @test l.stability.status == (expected == :inconclusive ? :unknown : :established)
    end
    r = analyze(AML.AutonomousSystem([-x+y,-y+z,-z],(x,y,z)))
    @test only(AML.stability(r)).stability.status == :heuristic
    @test r.nullclines.status == :unknown
    q = analyze(AML.AutonomousSystem([-x],(x,)))
    copied = AML.equilibria(q); copied.value[1].point[1] = 9
    push!(copied.notes,"changed")
    @test q.equilibria.value[1].point == [0]
    @test "changed" ∉ q.equilibria.notes
    localcopy = AML.stability(q); localcopy[1].matrix[1,1] = 123
    @test q.equilibria.value[1].local_analysis.matrix[1,1] == -1
    @test_throws ArgumentError analyze(q.system;classification_atol=-1)
    @test_throws ArgumentError analyze(q.system;classification_rtol=Inf)
    @test_throws ArgumentError AML.AutonomousSystem([x],(x,x))
    @test_throws ArgumentError AML.AutonomousSystem([z],(x,))
    # Huge finite exact entries must not acquire false signs through Float64.
    huge = big(10)^400
    f = analyze([huge*x],(x,))
    l = AML._ds_local(f,only(f.field_zeros.value),:established,1e-10,1e-8)
    @test l.stability.status == :unknown
    @test l.stability.method == :unrepresentable_spectrum
    overflow_field = analyze([exp(x)-2],(x,))
    diagnostic_point = AML.FieldZero([1000.0],[0.0],0.0,1e-8)
    diagnostic = AML._ds_local(overflow_field,diagnostic_point,:heuristic,1e-10,1e-8)
    @test diagnostic.stability.status == :unknown
    @test diagnostic.stability.method == :unrepresentable_jacobian
    @test ismissing(Makie.current_backend())
    @test all(m -> nameof(m) ∉ (:CairoMakie,:GLMakie),values(Base.loaded_modules))
end
@testset "Exact local stability" begin
    for (F,vars,expected) in (([-y,x],(x,y),:center),
            ([y,-x-(1//2)*y],(x,y),:locally_asymptotically_stable),
            ([x,-y],(x,y),:saddle), ([-x],(x,),:locally_asymptotically_stable))
        r = analyze(AML.AutonomousSystem(F,vars))
        local_result = only(AML.stability(r))
        @test local_result.stability.value == expected
        @test local_result.stability.status == :established
        @test size(local_result.matrix) == (length(vars),length(vars))
        @test length(local_result.eigenvalues) == length(vars)
    end
    r = analyze(AML.AutonomousSystem([x*(1-x)],(x,)))
    @test Set(e.local_analysis.stability.value for e in r.equilibria.value) == Set([:unstable,:locally_asymptotically_stable])
    @test all(e -> e.local_analysis.stability.status == :established,r.equilibria.value)
    for F in ([x^3],[-x^3])
        q = analyze(AML.AutonomousSystem(F,(x,)))
        @test only(AML.stability(q)).stability.value == :inconclusive
        @test only(AML.stability(q)).stability.status == :unknown
    end
end
end
end
