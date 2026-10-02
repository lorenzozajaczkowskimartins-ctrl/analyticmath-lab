module M10AMechanicsTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra, ForwardDiff
@variables q1 q2 v1 v2 p1 p2 m k

numeric(expr, vars, point) = Float64(Symbolics.value(Symbolics.substitute(expr,Dict(zip(vars,point));fold=Val(true))))
vector_at(expr, vars, point) = [numeric(e,vars,point) for e in expr]
# Scaled direct residual, independent of AML's stored diagnostic metadata.
eigenpair_ok(K,M,a,lambda) = norm(K*a-lambda*M*a) <= 1e-11*(norm(K)*norm(a)+abs(lambda)*norm(M*a)+1)

@testset "M10A force, canonical signs and ordered phase space" begin
    V = q1^4/4 + 3q1*q2 + 2q2^2
    potential(z) = z[2]^4/4 + 3z[2]*z[1] + 2z[1]^2
    force = force_from_potential(analyze(V,(q2,q1)))
    for z in ([0.3,-0.7],[1.2,0.4])
        oracle = [-3z[2]-4z[1],-z[2]^3-3z[1]]
        actual = vector_at(force,(q2,q1),z)
        @test actual ≈ oracle atol=1e-12
        @test actual ≈ -ForwardDiff.gradient(potential,z) atol=1e-12
        @test !isapprox(-actual,oracle;atol=1e-12)
    end
    h = analyze(HamiltonianSystem((q1^2+2q2^2+3p1^2+4p2^2)/2+q1*p2/4;
        coordinates=(q1,q2),momenta=(p1,p2)))
    J = [0 0 1 0; 0 0 0 1; -1 0 0 0; 0 -1 0 0]
    @test h.phase_variables == (q1,q2,p1,p2)
    @test h.symplectic_matrix == J
    @test J' == -J && J*J == -Matrix{Int}(I,4,4)
    z = [0.3,-0.7,1.1,0.8]
    expected = [3z[3],4z[4]+z[1]/4,-z[1]-z[4]/4,-2z[2]]
    actual = evaluate(dynamics(h).analysis,z)
    @test actual ≈ expected atol=1e-12
    @test !isapprox(-actual,expected;atol=1e-12)
    @test !isapprox(evaluate(dynamics(h).analysis,z[[1,3,2,4]]),expected;atol=1e-12)
end

@testset "M10A regular Legendre equivalence and EL oscillator" begin
    oscillator = analyze(LagrangianSystem(m*v1^2/2-k*q1^2/2;
        coordinates=(q1,),velocities=(v1,),nonzero=(m,)))
    @test iszero(Symbolics.simplify(only(oscillator.accelerations.value)+k*q1/m))
    bound = dynamics(oscillator;parameters=Dict(k=>8,m=>2))
    @test evaluate(bound.analysis,[0.7,-0.4]) ≈ [-0.4,-2.8]
    @test bound.variables == (q1,v1)
    # Full, non-diagonal SPD kinetic form makes p != v and exposes ordering errors.
    M = [2. 1.;1. 3.]; K = [4. -1.;-1. 5.]
    L = (2v1^2+2v1*v2+3v2^2-4q1^2+2q1*q2-5q2^2)/2
    lag = analyze(LagrangianSystem(L;coordinates=(q1,q2),velocities=(v1,v2)))
    transformed = legendre_transform(lag;momenta=(p1,p2))
    @test transformed.status == :established
    dl, dh = dynamics(lag), dynamics(transformed.value)
    for z in ([0.2,-0.4,0.7,0.3],[-0.8,0.1,-0.2,1.])
        q,v = z[1:2],z[3:4]; p = M*v
        fl,fh = evaluate(dl.analysis,z),evaluate(dh.analysis,vcat(q,p))
        @test fl ≈ vcat(v,-(M\(K*q))) atol=1e-12
        @test fh ≈ vcat(M\p,-K*q) atol=1e-12
        @test fh ≈ vcat(fl[1:2],M*fl[3:4]) atol=1e-12
        @test dh.energy_value(q...,p...) ≈ (dot(p,M\p)+dot(q,K*q))/2 atol=1e-12
    end
end

@testset "M10A nontrivial equilibrium M C K and local nonlinear limit" begin
    # Coordinates are explicitly (q2,q1); equilibrium is (1,-2).
    a,b = q2-1,q1+2
    L = (2v2^2+2v2*v1+3v1^2-4a^2+2a*b-5b^2)/2
    R = (v2^2+2v2*v1+2v1^2)/2
    lag = LagrangianSystem(L;coordinates=(q2,q1),velocities=(v2,v1),rayleigh=R)
    linear = linearize_mechanics(lag,(1,-2))
    M = [2. 1.;1. 3.]; C = [1. 1.;1. 2.]; K = [4. -1.;-1. 5.]
    @test linear.evidence.status == :established
    @test linear.metadata.coordinates == (q2,q1)
    @test linear.mass_matrix == M
    @test linear.damping_matrix == C
    @test linear.stiffness_matrix == K
    @test linearize_mechanics(lag,(0,0)).evidence.status == :unknown
    d = dynamics(lag)
    z = [1.3,-2.4,0.2,0.7]
    @test evaluate(d.analysis,z) ≈ vcat(z[3:4],-(M\(C*z[3:4]+K*(z[1:2]-[1,-2])))) atol=1e-12
    @test normal_modes(linear).evidence.status == :unknown # damping is not an undamped eigenproblem
    pend = dynamics(LagrangianSystem(v1^2/2+cos(q1);coordinates=(q1,),velocities=(v1,)))
    for amplitude in (0.04,0.02)
        field = evaluate(pend.analysis,[amplitude,0.])
        @test abs(field[2]+amplitude) <= amplitude^3/6
        path = trajectory(pend,[amplitude,0.],(0.,1.);abstol=1e-12,reltol=1e-12)
        @test path.diagnostics.success && path.diagnostics.completed
        @test norm(path.solution(1.)-[amplitude*cos(1.),-amplitude*sin(1.)]) < amplitude^3/3
    end
end

@testset "M10A direct generalized eigenpairs and spectral semantics" begin
    M = [2. 0.5;0.5 1.]; K = [3. -1.;-1. 2.]
    r = normal_modes(K,M)
    for (i,lambda) in enumerate(r.eigenvalues)
        @test eigenpair_ok(K,M,r.mode_vectors[:,i],lambda)
        @test !eigenpair_ok(K,M,r.mode_vectors[:,i],lambda+0.5)
    end
    @test r.mode_vectors'*M*r.mode_vectors ≈ Matrix{Float64}(I,2,2) atol=1e-12
    # Independent quadratic determinant roots: det(K-lambda*M)=7lambda²/4-8lambda+5.
    @test r.eigenvalues ≈ [(8-sqrt(29))/3.5,(8+sqrt(29))/3.5] atol=1e-12
    signed = normal_modes(Diagonal([-4.,0.,9.]),Diagonal(ones(3)))
    @test signed.eigenvalues ≈ [-4.,0.,9.]
    @test signed.classifications == [:unstable,:zero,:oscillatory]
    @test ismissing(signed.frequencies[1])
    @test signed.zero_modes == [2]
    degenerate = normal_modes(3M,M)
    @test degenerate.degeneracies == [[1,2]]
    # Subspaces, not unique vectors/signs, are meaningful for repeated eigenvalues.
    Q = degenerate.mode_vectors
    @test Q*Q'*M ≈ Matrix{Float64}(I,2,2) atol=1e-12
    @test all(eigenpair_ok(3M,M,Q[:,i],3.) for i in 1:2)
end
end
