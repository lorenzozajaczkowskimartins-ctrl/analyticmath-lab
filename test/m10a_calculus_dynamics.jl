module M10ACalculusDynamicsTests
using Test, AnalyticMathLab, Symbolics, Random, LinearAlgebra
import ForwardDiff

# Independent numeric closures, never AML's generated callable, supply AD/FD oracles.
# Smooth bounded samples: AD/analytic 2e-11; central first FD 2e-7 (h=1e-5);
# value-only second FD 2e-6 (h=2e-4), allowing cancellation and O(h²).
fd1(f, x; h=1e-5) = (f(x+h)-f(x-h))/(2h)
function fdgradient(f, x; h=1e-5)
    E = Matrix{Float64}(I, length(x), length(x))
    [(f(x+h*E[:,i])-f(x-h*E[:,i]))/(2h) for i in eachindex(x)]
end
function fdhessian(f, x; h=2e-4)
    E = Matrix{Float64}(I, length(x), length(x))
    [(f(x+h*E[:,i]+h*E[:,j])-f(x+h*E[:,i]-h*E[:,j])-
      f(x-h*E[:,i]+h*E[:,j])+f(x-h*E[:,i]-h*E[:,j]))/(4h^2)
     for i in eachindex(x), j in eachindex(x)]
end
matches(a, b; atol=2e-11, rtol=2e-11) =
    all(isfinite, a) && all(isfinite, b) && isapprox(a,b;atol,rtol)

@variables x y
@testset "M10A M1–M2 independent scalar calculus" begin
    rng = MersenneTwister(10401)
    f(s) = s^4 + sin(s) + exp(s)/3
    df(s) = 4s^3 + cos(s) + exp(s)/3
    ddf(s) = 12s^2 - sin(s) + exp(s)/3
    report = analyze(x^4 + sin(x) + exp(x)/3, x)
    for s in 2rand(rng,8).-1
        @test evaluate(report,s) ≈ f(s) atol=2e-12 rtol=2e-12
        @test evaluate(report,s;order=1) ≈ df(s) atol=2e-11 rtol=2e-11
        @test evaluate(report,s;order=1) ≈ ForwardDiff.derivative(f,s) atol=2e-11
        @test evaluate(report,s;order=1) ≈ fd1(f,s) atol=2e-7
        @test evaluate(report,s;order=2) ≈ ddf(s) atol=2e-11
        @test evaluate(report,s;order=2) ≈ ForwardDiff.derivative(df,s) atol=2e-11
        @test evaluate(report,s;order=2) ≈ fd1(df,s) atol=2e-7
        comparison = compare_derivatives(report,s)
        @test comparison.values.symbolic ≈ df(s) atol=2e-11
        @test comparison.values.automatic ≈ df(s) atol=2e-11
        @test comparison.values.central ≈ df(s) atol=2e-7
    end
    # For x^3 at x=1 the forward error is 3h+h², central error is h².
    # These are external algebraic references, not differences from stored reference.
    for method in (:forward,:central)
        c = derivative_convergence(analyze(x^3,x),1.0;
            method,hmin=1e-3,hmax=1e-1,samples=9)
        expected = method == :central ? c.steps.^2 : 3c.steps+c.steps.^2
        @test c.reference == 3
        @test c.approximations ≈ 3 .+ expected atol=2e-12 rtol=2e-12
        @test c.absolute_errors ≈ expected atol=2e-12 rtol=2e-12
        @test c.relative_errors ≈ expected./3 atol=2e-12 rtol=2e-12
        @test c.observed_order !== nothing
        if c.observed_order !== nothing
            @test abs(c.observed_order-(method == :central ? 2 : 1)) < 0.04
        end
        @test c.best_step == last(c.steps)
    end
end

@testset "M10A M4–M5 ordered gradient, Hessian, rectangular Jacobian" begin
    rng = MersenneTwister(10405)
    # Numeric order is (y,x), deliberately different from spelling/creation order.
    f(z) = z[2]^3 + 2z[2]*z[1]^2 + sin(z[2]+2z[1])
    g(z) = [4z[2]*z[1]+2cos(z[2]+2z[1]),
            3z[2]^2+2z[1]^2+cos(z[2]+2z[1])]
    H(z) = [4z[2]-4sin(z[2]+2z[1]) 4z[1]-2sin(z[2]+2z[1]);
            4z[1]-2sin(z[2]+2z[1]) 6z[2]-sin(z[2]+2z[1])]
    scalar = analyze(x^3+2x*y^2+sin(x+2y),(y,x))
    standard = analyze(x^3+2x*y^2+sin(x+2y),(x,y))
    F(z) = [z[2]*z[1]+sin(z[1]), z[2]^2-3z[1], exp(z[2])+z[1]^3]
    J(z) = [z[2]+cos(z[1]) z[1]; -3 2z[2]; 3z[1]^2 exp(z[2])]
    vector = analyze([x*y+sin(y),x^2-3y,exp(x)+y^3],(y,x))
    @test scalar.variables == (y,x)
    @test vector.variables == (y,x)
    for _ in 1:8
        z = 2rand(rng,2).-1
        d = randn(rng,2); d /= norm(d)
        @test matches(gradient(scalar,z),g(z))
        @test matches(gradient(scalar,z),ForwardDiff.gradient(f,z))
        @test matches(gradient(scalar,z),fdgradient(f,z);atol=2e-7)
        actual = hessian(scalar,z)
        @test matches(actual,H(z))
        @test matches(actual,ForwardDiff.hessian(f,z))
        @test matches(actual,fdhessian(f,z);atol=2e-6)
        @test matches(actual,transpose(actual))
        @test matches(actual,hessian(standard,reverse(z))[[2,1],[2,1]])
        @test directional_derivative(scalar,z,d) ≈ dot(g(z),d) atol=2e-11
        @test matches(jacobian(vector,z),J(z))
        @test matches(jacobian(vector,z),ForwardDiff.jacobian(F,z))
        @test matches(jacobian(vector,z)*d,(F(z+1e-5d)-F(z-1e-5d))/(2e-5);atol=2e-7)
    end
    # Audit-predicate negative controls: no arbitrary report-constructor validation claim.
    z = [0.3,-0.7]
    @test !matches(-g(z),g(z))
    @test !matches(H(z)[[2,1],[2,1]],H(z))
    @test !matches(J(z)[:,[2,1]],J(z))
end

@testset "M10A M3–M6 original-domain exclusions survive cancellation" begin
    scalar = analyze(@real_function((x^2-1)/(x-1)),x)
    @test domain_contains(scalar.real_analysis.domain,1) === false
    @test domain_contains(scalar.real_analysis.domain,2) === true
    # Legacy univariate evaluate deliberately does not enforce real_analysis.domain.
    field = analyze(@real_function((x-y)/(x-y)+x^2+2y^2),(y,x))
    vector = analyze(@real_function([(x-y)/(x-y)+x,y]),(y,x))
    for r in (field,vector)
        @test domain_contains(r.domain,(1,1)) === false
        @test domain_contains(r.domain,(1,2)) === true
        @test_throws DomainError evaluate(r,(1,1))
    end
    @test_throws DomainError gradient(field,(1,1))
    @test_throws DomainError hessian(field,(1,1))
    @test_throws DomainError jacobian(vector,(1,1))
    logarithm = analyze(@real_function(log(x-y)),(x,y))
    @test domain_contains(logarithm.domain,(1,1)) === false
    @test domain_contains(logarithm.domain,(0,1)) === false
    @test gradient(logarithm,(2,1)) ≈ [1,-1]
    hole = analyze(AutonomousSystem(@real_function([x/x]),(x,)))
    @test_throws DomainError trajectory(hole,[0.0],(0.0,0.2))
end

# Verify reference equation and IC *before* comparing any numerical trajectory.
function reference_valid(ref, rhs, initial, times; atol=2e-11)
    matches(ref(first(times)),initial;atol) && all(times) do t
        derivative = ForwardDiff.jacobian(z->ref(z[1]),[t])[:,1]
        matches(derivative,rhs(ref(t),t);atol)
    end
end
@testset "M10A M6 analytic reference equation and IC audits" begin
    decay(t) = [exp(-t^2)]
    harmonic(t) = [0.7cos(2t)-0.2sin(2t),-1.4sin(2t)-0.4cos(2t)]
    logistic(t) = [1/(1+3exp(-t))]
    cases = (
        (FirstOrderODE((u,t)->[-1.3u[1]],1),t->[exp(-1.3t)],(u,t)->[-1.3u[1]],[1.0],1.5),
        (FirstOrderODE((u,t)->[-2t*u[1]],1),decay,(u,t)->[-2t*u[1]],[1.0],1.5),
        (analyze(AutonomousSystem([y,-4x],(x,y))),harmonic,(u,t)->[u[2],-4u[1]],[0.7,-0.4],2.0),
        (analyze(AutonomousSystem([x*(1-x)],(x,))),logistic,(u,t)->[u[1]*(1-u[1])],[0.25],2.0))
    for (problem,ref,rhs,initial,stop) in cases
        times = collect(range(0.0,stop;length=13))
        @test reference_valid(ref,rhs,initial,times)
        @test !reference_valid(ref,(u,t)->-rhs(u,t),initial,times)
        @test !reference_valid(ref,rhs,initial.+0.1,times)
        path = trajectory(problem,initial,(0.0,stop);abstol=1e-11,reltol=1e-11)
        @test path.diagnostics.success && path.diagnostics.completed
        @test path.diagnostics.final_time == stop
        # Dense off-step samples; 2e-8 is a comparison allowance, not a global bound.
        for t in times
            @test matches(path.solution(t),ref(t);atol=2e-8,rtol=2e-8)
        end
    end
end
end # module
