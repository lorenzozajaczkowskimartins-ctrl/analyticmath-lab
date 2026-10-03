module M10BLinearAlgebraTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra

# Bounded M7 numeric contracts: generic matrix construction/exact symbolic
# algebra are distinct from the explicitly Float64, heuristic LAPACK boundary.
@testset "M10B mechanical scalar contracts" begin
    for T in (Float32, Float64, BigFloat, Rational{Int})
        masses = T[2, 3]
        M = cartesian_mass_matrix(masses, 2)
        @test eltype(M) == T
        @test diag(M) == T[2, 2, 3, 3]
        masses[1] = T(9)
        @test M[1,1] == T(2)
        K = T[4 0; 0 12]
        r = normal_modes(K, cartesian_mass_matrix(T[2,3], 1))
        @test r.evidence.status == :heuristic
        @test r.metadata.arithmetic == :Float64
        @test eltype(r.eigenvalues) == Float64
        @test r.eigenvalues ≈ [2.,4.]
        @test r.mode_vectors' * Float64.(r.mass_matrix) * r.mode_vectors ≈ Matrix{Float64}(I,2,2)
        @test r.reconstruction ≈ Float64.(K)
    end
    @variables q v
    lag = LagrangianSystem((3//7)*v^2/2-(5//11)*q^2/2;
        coordinates=(q,), velocities=(v,))
    l = linearize_mechanics(lag, (0//1,))
    @test l.evidence.status == :established
    @test only(l.mass_matrix) == 3//7
    @test only(l.stiffness_matrix) == 5//11
    @test only(l.damping_matrix) == 0
    @test normal_modes(l).metadata.matrix_evidence.mass.method == :exact_input
    @test only(normal_modes(l).eigenvalues) ≈ Float64((5//11)/(3//7))

    setprecision(BigFloat, 256) do
        delta = BigFloat(2)^(-100)
        # Generic helper must not round this away just because LAPACK later does.
        M = cartesian_mass_matrix([1+delta],1)
        @test only(M)-1 == delta
        @test eltype(M) == BigFloat
        # The explicit Float64 boundary is allowed ordinary rounding; this is
        # not a demand for an arbitrary-precision eigensolver.
        r = normal_modes(reshape(BigFloat[2],1,1),M)
        @test r.metadata.arithmetic == :Float64
        @test r.evidence.status == :heuristic
        @test only(r.mass_matrix) == 1+delta
        # Rounding erases the only positive mass pivot: never certify SPD.
        collapsed = BigFloat[1 1; 1 1+delta]
        @test normal_modes(Matrix{BigFloat}(I,2,2),collapsed).evidence.status == :unknown
    end
end

@testset "M10B small singular and ill-conditioned masses" begin
    K = Matrix{Float64}(I,2,2)
    for m in (0., -1., eps(Float64)/4)
        r = normal_modes(K,Diagonal([1.,m]))
        @test r.evidence.status == :unknown
        @test r.eigenvalues === nothing
    end
    @test normal_modes(K,Diagonal([1.,1e-8])).evidence.status == :heuristic
    for scale in (1e-200, 1e200)
        r = normal_modes(reshape([scale],1,1),reshape([scale],1,1);atol=0,rtol=0)
        @test r.evidence.status == :heuristic
        @test only(r.eigenvalues) ≈ 1.
    end
    for bad in (NaN, Inf, -Inf)
        @test normal_modes(reshape([bad],1,1),ones(1,1)).evidence.status == :unknown
        @test normal_modes(ones(1,1),reshape([bad],1,1)).evidence.status == :unknown
        @test_throws ArgumentError cartesian_mass_matrix([bad],1)
    end
    for m in (0., -1.)
        @test_throws ArgumentError cartesian_mass_matrix([m],1)
    end
    @test_throws ArgumentError cartesian_mass_matrix(Float64[],1)
    @test_throws DimensionMismatch normal_modes(zeros(0,0),zeros(0,0))
    @test_throws DimensionMismatch normal_modes(ones(1,2),ones(1,2))
end

@testset "M10B inclusive spectral thresholds and anchored groups" begin
    t = 2.0^-20
    r = normal_modes(Diagonal([-2t,-t,0.,t,2t]),Diagonal(ones(5));atol=t,rtol=0)
    @test r.eigenvalues == [-2t,-t,0.,t,2t]
    @test r.classifications == [:unstable,:zero,:zero,:zero,:oscillatory]
    @test r.zero_modes == [2,3,4]
    @test ismissing(r.frequencies[1])
    @test r.frequencies[2:4] == zeros(3)
    @test r.metadata.spectral_threshold == t
    # Adjacent distances <= t must not transitively merge a wider cluster.
    g = normal_modes(Diagonal([1.,1+t,1+2t]),Diagonal(ones(3));atol=t,rtol=0)
    @test g.degeneracies == [[1,2]]
    relative = normal_modes(Diagonal([-1.,100.]),Diagonal(ones(2));atol=0,rtol=0.01)
    @test relative.metadata.spectral_threshold == 1.
    @test relative.classifications == [:zero,:oscillatory]
end

@testset "M10B fail closed at destructive numeric boundaries" begin
    setprecision(BigFloat,256) do
        for bad in (BigFloat(2)^2000, BigFloat(2)^(-2000))
            r = normal_modes(reshape([bad],1,1),ones(1,1))
            @test r.evidence.status == :unknown
            @test r.eigenvalues === nothing
        end
        # RED candidate: converting a positive caller tolerance to zero silently
        # changes threshold semantics. Reject rather than claim exact tolerance.
        @test_throws ArgumentError normal_modes(ones(1,1),ones(1,1);atol=BigFloat(2)^(-2000),rtol=0)
    end
    # RED candidate: nonzero K/M is below Float64 range, not an exact zero mode.
    tiny = normal_modes(reshape([1e-200],1,1),reshape([1e200],1,1);atol=0,rtol=0)
    @test tiny.evidence.status == :unknown
    @test tiny.eigenvalues === nothing
    huge = normal_modes(reshape([1e200],1,1),reshape([1e-200],1,1);atol=0,rtol=0)
    @test huge.evidence.status == :unknown
end
end # module
