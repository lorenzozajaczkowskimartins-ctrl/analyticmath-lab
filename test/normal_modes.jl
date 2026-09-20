module NormalModesTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra
const AML = AnalyticMathLab
@variables q v q2 v2 m k g ell t

@testset "Local Euler–Lagrange mechanical linearization" begin
    @test isdefined(AML, :linearize_mechanics)
    if isdefined(AML, :linearize_mechanics)
        harmonic = analyze(LagrangianSystem(m*v^2/2-k*q^2/2;
            coordinates=(q,),velocities=(v,),nonzero=(m,)))
        r = AML.linearize_mechanics(harmonic,(0,);parameters=Dict(m=>2,k=>8))
        @test r isa AML.MechanicalLinearization
        @test r isa AbstractAnalysis
        @test r.evidence.status == :established
        @test r.mass_matrix == [2;;]
        @test r.damping_matrix == [0;;]
        @test r.stiffness_matrix == [8;;]
        @test r.equilibrium == (0,)
        @test r.equilibrium_evidence.value === true
        @test r.domain_evidence.value === true
        @test AML.linearize_mechanics(harmonic,(1,);parameters=Dict(m=>2,k=>8)).evidence.status == :unknown
        @test_throws DimensionMismatch AML.linearize_mechanics(harmonic,(0,0))
    end
end

@testset "Generic SPD mass normal modes" begin
    @test isdefined(AML, :normal_modes)
    if isdefined(AML, :normal_modes)
        M = [2.0 0.5; 0.5 1.0]
        K = [3.0 -1.0; -1.0 2.0]
        r = AML.normal_modes(K,M;equilibrium=(0,0),metadata=(label="full mass",))
        @test r isa AML.NormalModeAnalysis
        @test r isa AbstractAnalysis
        @test r.evidence.status == :heuristic
        @test r.eigenvalues ≈ eigvals(K,M)
        @test r.frequencies.^2 ≈ r.eigenvalues
        @test K*r.mode_vectors ≈ M*r.mode_vectors*Diagonal(r.eigenvalues)
        @test r.mode_vectors'*M*r.mode_vectors ≈ I
        @test r.weighted_vectors'*r.weighted_vectors ≈ I
        @test r.mass_sqrt*r.mass_sqrt ≈ M
        @test r.mass_inverse_sqrt*M*r.mass_inverse_sqrt ≈ I
        @test r.dynamical_matrix ≈ r.mass_inverse_sqrt*K*r.mass_inverse_sqrt
        @test r.reconstruction ≈ K
        @test r.normalization == :mass_orthonormal
        @test r.representation == :coordinate_displacements
        @test r.metadata.user.label == "full mass"
        @test r.classifications == [:oscillatory,:oscillatory]
        for bad in ([1 0;0 0], [1 0;0 -1], [1 1;0 1])
            @test AML.normal_modes(K,bad).evidence.status == :unknown
        end
        @test AML.normal_modes([1 1;0 1],M).evidence.status == :unknown
        @test_throws DimensionMismatch AML.normal_modes(K,[1;;])
        @test_throws ArgumentError AML.normal_modes(K,M;atol=-1)
    end
end

@testset "Mechanical modes, pendulum and M6 agreement" begin
    harmonic = analyze(LagrangianSystem((2v^2-8q^2)/2;coordinates=(q,),velocities=(v,)))
    @test hasmethod(AML.normal_modes,Tuple{typeof(harmonic),Tuple{Int}})
    if hasmethod(AML.normal_modes,Tuple{typeof(harmonic),Tuple{Int}})
        h = AML.normal_modes(harmonic,(0,))
        @test h.frequencies ≈ [2]
        @test h.source isa AML.MechanicalLinearization
        @test AML.normal_modes(h.source).eigenvalues ≈ [4]
        coupled = LagrangianSystem((v^2+v2^2-q^2-q2^2-(q2-q)^2)/2;
            coordinates=(q,q2),velocities=(v,v2))
        c = AML.normal_modes(coupled,(0,0))
        @test c.eigenvalues ≈ [1,3]
        pendulum = analyze(LagrangianSystem(m*ell^2*v^2/2-m*g*ell*(1-cos(q));
            coordinates=(q,),velocities=(v,),nonzero=(m,ell)))
        formal = AML.linearize_mechanics(pendulum,(0,))
        @test iszero(Symbolics.simplify(formal.stiffness_matrix[1]/formal.mass_matrix[1]-g/ell))
        @test formal.evidence.status == :unknown
        @test AML.normal_modes(formal).evidence.status == :unknown
        pend = AML.normal_modes(pendulum,(0,);parameters=Dict(m=>3,g=>10,ell=>2))
        @test pend.eigenvalues ≈ [5]
        @test pend.frequencies ≈ [sqrt(5)]
        damped = analyze(LagrangianSystem((2v^2-8q^2)/2;
            coordinates=(q,),velocities=(v,),rayleigh=3v^2/2))
        l = AML.linearize_mechanics(damped,(0,))
        @test l.damping_matrix == [3;;]
        J = jacobian(dynamics(damped).analysis,(0,0))
        @test J ≈ [0 1; -4 -1.5]
        @test J[2:2,1:1] ≈ -Float64.(l.mass_matrix)\Float64.(l.stiffness_matrix)
        @test J[2:2,2:2] ≈ -Float64.(l.mass_matrix)\Float64.(l.damping_matrix)
        @test AML.normal_modes(l).evidence.status == :unknown
        @test AML.normal_modes(harmonic,(1,)).evidence.status == :unknown
        hole = LagrangianSystem(@real_function(v^2/2-q^2/2+q/q);coordinates=(q,),velocities=(v,))
        edge = LagrangianSystem(@real_function(v^2/2-q^2/2+sqrt(q)^2);coordinates=(q,),velocities=(v,))
        unsupported = LagrangianSystem(RealExpression((v^2-q^2)/2,:(v^2/2-q^2/2+tan(q)));
            coordinates=(q,),velocities=(v,))
        for s in (hole,edge,unsupported)
            @test AML.linearize_mechanics(s,(0,)).domain_evidence.status == :unknown
            @test AML.normal_modes(s,(0,)).evidence.status == :unknown
        end
        pole = LagrangianSystem(v^2/2-1/q;coordinates=(q,),velocities=(v,))
        @test AML.linearize_mechanics(pole,(0,)).evidence.status == :unknown
        @test AML.normal_modes(pole,(0,)).evidence.status == :unknown
        forced = LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),time=t)
        @test AML.linearize_mechanics(forced,(0,)).evidence.status == :unknown
    end
end

@testset "Cartesian masses, degeneracy and three-particle modes" begin
    @test isdefined(AML,:cartesian_mass_matrix)
    if isdefined(AML,:cartesian_mass_matrix)
        for masses in ([1,2,3],Rational{Int}[1//2,2//3,3//4],Float32[1,2,3],BigFloat[1,2,3])
            M = AML.cartesian_mass_matrix(masses,2)
            @test M isa Diagonal
            @test eltype(M) == eltype(masses)
            @test diag(M) == repeat(masses;inner=2)
            @test masses == unique(diag(M))
        end
        @test_throws ArgumentError AML.cartesian_mass_matrix([1,0],2)
        @test_throws ArgumentError AML.cartesian_mass_matrix([1,-1],2)
        @test_throws ArgumentError AML.cartesian_mass_matrix([1,Inf],2)
        @test_throws ArgumentError AML.cartesian_mass_matrix([m],2)
        @test_throws ArgumentError AML.cartesian_mass_matrix(Int[],2)
        @test_throws ArgumentError AML.cartesian_mass_matrix([1,2],0)
        @test_throws ArgumentError AML.cartesian_mass_matrix([1,2],1.5)
        M = AML.cartesian_mass_matrix([1,2,3],2)
        K = kron([1 -1 0;-1 2 -1;0 -1 1],Matrix{Int}(I,2,2))
        r = AML.normal_modes(K,M;equilibrium=zeros(6),metadata=(coordinate_layout=(particles=3,dimension=2),))
        @test r.evidence.status == :heuristic
        @test length(r.zero_modes) == 2
        @test length(r.degeneracies) == 3
        @test all(length(x)==2 for x in r.degeneracies)
        @test r.metadata.coordinate_layout == (particles=3,dimension=2)
        @test K*r.mode_vectors ≈ M*r.mode_vectors*Diagonal(r.eigenvalues) atol=1e-12
        @test r.reconstruction ≈ K atol=1e-12
        @test r.mode_vectors'*M*r.mode_vectors ≈ I
        @test r.eigenvalues ≈ sort(real.(eigvals(Matrix(K),Matrix(M)))) atol=1e-12
        @test r.mass_sqrt*r.mode_vectors ≈ r.weighted_vectors
        signed = AML.normal_modes(Diagonal([-4,0,9]),Diagonal([1,1,1]))
        @test signed.eigenvalues ≈ [-4,0,9]
        @test signed.classifications == [:unstable,:zero,:oscillatory]
        @test ismissing(signed.frequencies[1])
        @test signed.frequencies[2:end] == [0,3]
        @test signed.zero_modes == [2]
        @test isempty(signed.degeneracies)
        near = AML.normal_modes(Diagonal([-1e-12,1.0,1.0+1e-11]),Diagonal(ones(3)))
        @test near.eigenvalues[1] < 0
        @test near.classifications == [:zero,:oscillatory,:oscillatory]
        @test near.degeneracies == [[2,3]]
        strict = AML.normal_modes(Diagonal([-1e-12,1.0,1.0+1e-11]),Diagonal(ones(3));atol=0,rtol=0)
        @test strict.classifications[1] == :unstable
        @test isempty(strict.degeneracies)
        for (Kbad,Mbad) in (([NaN;;],[1;;]),([1;;],[Inf;;]),([k;;],[m;;]))
            @test AML.normal_modes(Kbad,Mbad).evidence.status == :unknown
        end
    end
end
end
