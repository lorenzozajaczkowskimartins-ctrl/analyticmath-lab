module ModeContractTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra
const AML=AnalyticMathLab
@variables x y v w
@testset "Review regressions: singular mass, underflow and excluded equilibrium" begin
    singular=normal_modes([1 0;0 1],[1 3;3 9])
    @test singular.evidence.status == :unknown
    @test singular.eigenvalues === nothing
    underflow=normal_modes([-big"1e-400";;],[big"1e-300";;];atol=0,rtol=0)
    @test underflow.evidence.status == :unknown
    @test underflow.eigenvalues === nothing
    tiny=normal_modes([nextfloat(0.0);;],[1e-308;;];atol=0,rtol=0)
    @test tiny.classifications == [:oscillatory]
    @test only(tiny.eigenvalues) ≈ nextfloat(0.0)/1e-308
    excluded=LagrangianSystem(v^2/2-sqrt(x);coordinates=(x,),velocities=(v,))
    @test linearize_mechanics(excluded,(-1,)).evidence.status == :unknown
    @test normal_modes(excluded,(-1,)).evidence.status == :unknown
end
@testset "Mode provenance and reconstruction contract" begin
    r = normal_modes([2 -1;-1 2],Matrix{Int}(I,2,2))
    @test hasproperty(r.metadata,:matrix_evidence)
    if hasproperty(r.metadata,:matrix_evidence)
        @test r.metadata.matrix_evidence.mass.method == :exact_input
        @test r.metadata.matrix_evidence.stiffness.method == :exact_input
        @test normal_modes([1.0;;],[1.0;;]).metadata.matrix_evidence.mass.method == :numerical_input
        @test r.metadata.reconstruction_convention == :a_equals_mass_inverse_sqrt_times_e
        @test r.metadata.zero_mode_categories == Dict{Int,Symbol}()
    end
end
@testset "Coupled patterns and multidimensional M6 consistency" begin
    L=(2v^2+2w^2-4x^2-4y^2-2*(y-x)^2)/2
    coupled=analyze(LagrangianSystem(L;coordinates=(x,y),velocities=(v,w)))
    l=linearize_mechanics(coupled,(0,0))
    r=normal_modes(l)
    @test l.mass_matrix == [2 0;0 2]
    @test l.stiffness_matrix == [6 -2;-2 6]
    @test r.eigenvalues ≈ [2,4]
    @test r.frequencies ≈ [sqrt(2),2]
    @test r.mode_vectors[1,1] ≈ r.mode_vectors[2,1]
    @test r.mode_vectors[1,2] ≈ -r.mode_vectors[2,2]
    @test rank(r.mode_vectors)==2
    damped=analyze(LagrangianSystem(L;coordinates=(x,y),velocities=(v,w),rayleigh=(2v^2+2v*w+3w^2)/2))
    dl=linearize_mechanics(damped,(0,0))
    @test dl.damping_matrix == [2 1;1 3]
    d=dynamics(damped)
    @test d.variables == (x,y,v,w)
    block=[zeros(2,2) Matrix{Float64}(I,2,2); -Float64.(dl.mass_matrix)\Float64.(dl.stiffness_matrix) -Float64.(dl.mass_matrix)\Float64.(dl.damping_matrix)]
    @test jacobian(d.analysis,(0,0,0,0)) ≈ block
end
@testset "Unequal masses and explicit Cartesian pair reconstruction" begin
    U=analyze(3*((y-x)-2)^2/2,(x,y))
    M=cartesian_mass_matrix([2,5],1)
    K=AML.hessian(U,(0,2))
    layout=(particle_count=2,spatial_dimension=1,ordering=:particle_major)
    r=normal_modes(K,M;equilibrium=(0,2),metadata=(coordinate_layout=layout,))
    @test diag(M)==[2,5]
    @test r.classifications==[:zero,:oscillatory]
    @test r.eigenvalues ≈ [0,21/10] atol=1e-12
    @test r.frequencies ≈ [0,sqrt(21/10)]
    @test r.mode_vectors[1,1] ≈ r.mode_vectors[2,1]
    @test r.mode_vectors[1,2]*r.mode_vectors[2,2] < 0
    @test dot([2,5],r.mode_vectors[:,2]) ≈ 0 atol=1e-12
    @test r.mass_inverse_sqrt*r.weighted_vectors ≈ r.mode_vectors
    @test r.mass_sqrt*r.mode_vectors ≈ r.weighted_vectors
    @test r.mode_vectors'*M*r.mode_vectors ≈ I
    @test r.dynamical_matrix*r.weighted_vectors ≈ r.weighted_vectors*Diagonal(r.eigenvalues) atol=1e-12
    @test r.reconstruction ≈ K
    @test r.metadata.coordinate_layout == layout
    # Physical components recover from weighted coordinates without geometry guessing.
    @test reshape(r.mass_inverse_sqrt*r.weighted_vectors[:,2],1,2)[:] ≈ r.mode_vectors[:,2]
    M3=cartesian_mass_matrix([1,2,4],1)
    K3=[2 -2 0;-2 5 -3;0 -3 3]
    r3=normal_modes(K3,M3;equilibrium=zeros(3))
    @test length(r3.zero_modes)==1
    @test r3.eigenvalues ≈ sort(real.(eigvals(K3,Matrix(M3)))) atol=1e-12
    @test K3*r3.mode_vectors ≈ M3*r3.mode_vectors*Diagonal(r3.eigenvalues) atol=1e-12
    @test r3.mass_inverse_sqrt*r3.weighted_vectors ≈ r3.mode_vectors
end
end
