module M10BAtomisticTests
using Test, AnalyticMathLab, LinearAlgebra, Unitful

@testset "M10B stored coordinate arithmetic and scalar types" begin
    for T in (Float32, Float64, BigFloat)
        s = AtomisticSnapshot([T[0,0],T[3,4]];masses=T[2,3],
            velocities=[T[1,0],T[0,2]])
        d = only(pair_distances(s).value.distances)
        @test d isa T
        @test d == T(5)
        o = mdcheck(s).observations
        @test o.total_mass.value isa T
        @test o.total_mass.value == T(5)
        @test o.kinetic_energy.value == T(7)
        @test o.total_momentum.value == T[2,6]
        su = AtomisticSnapshot([T[0,0]u"m",T[3,4]u"m"];
            masses=T[2,3]u"kg",velocities=[T[1,0]u"m/s",T[0,2]u"m/s"])
        du = only(pair_distances(su).value.distances)
        @test ustrip(du) isa T
        @test du == T(5)u"m"
        ou = mdcheck(su).observations
        @test ustrip(ou.total_mass.value) isa T
        @test ou.kinetic_energy.value == T(7)u"J"
        # Unitful bridge strips explicit scales, then deliberately uses LAPACK.
        oneparticle = AtomisticSnapshot([T[0]u"m"];masses=T[2]u"kg")
        modes = normal_modes(oneparticle;hessian=reshape(T[8]u"kg/s^2",1,1))
        @test modes.evidence.status == :heuristic
        @test eltype(modes.eigenvalues) == Float64
        @test modes.metadata.arithmetic == :Float64
        @test modes.metadata.units == :explicit_scales
        # Units can restore BigFloat storage, not precision lost in LAPACK.
        @test uconvert(u"s^-1",only(modes.metadata.angular_frequencies)) ≈ 2u"s^-1" rtol=8eps(Float64)
    end
    setprecision(BigFloat,256) do
        base = BigFloat(2)^60
        exactcoords = [[base,BigFloat(0)],[base+1,BigFloat(0)]]
        high = AtomisticSnapshot(exactcoords)
        low = AtomisticSnapshot([Float64.(p) for p in exactcoords])
        @test only(pair_distances(high).value.distances) == BigFloat(1)
        @test only(pair_distances(low).value.distances) == 0.
        @test isempty(mdcheck(high).observations.exact_overlaps.value)
        @test mdcheck(low).observations.exact_overlaps.value == [(1,2)]
        # The Float64 overlap describes stored coordinates, not the pre-rounded
        # geometry. No implementation can recover that missing displacement.
    end
end

@testset "M10B extreme distances and invalid snapshots" begin
    for T in (Float32,Float64)
        for scale in (floatmax(T)/T(4),floatmin(T)*T(4))
            s = AtomisticSnapshot([T[0,0],T[scale,scale]])
            r = pair_distances(s)
            @test r.status == :heuristic
            @test only(r.value.distances) ≈ sqrt(T(2))*scale
        end
    end
    # True separation overflows the stored scalar type: unknown, not Inf data.
    overflow = AtomisticSnapshot([[-floatmax(Float64)],[floatmax(Float64)]])
    @test pair_distances(overflow).status == :unknown
    for bad in (NaN,Inf,-Inf)
        s = AtomisticSnapshot([[0.],[bad]];masses=[1.,1.])
        @test pair_distances(s).status == :unknown
        @test !mdcheck(s).checks.finite_positions
        @test normal_modes(s;hessian=Matrix{Float64}(I,2,2)).evidence.status == :unknown
    end
    for badmass in (0.,-1.,NaN,Inf)
        s = AtomisticSnapshot([[0.]];masses=[badmass])
        @test mdcheck(s).observations.total_mass.status == :unknown
        @test normal_modes(s;hessian=ones(1,1)).evidence.status == :unknown
    end
    empty_default = AtomisticSnapshot(Vector{Float64}[])
    @test pair_distances(empty_default).status == :unknown # dimension unavailable
    empty_known = AtomisticSnapshot(Vector{Float64}[];dimension=2,masses=Float64[])
    @test isempty(pair_distances(empty_known).value.distances)
    @test coordination(empty_known;cutoff=1.).status == :unknown
    @test normal_modes(empty_known;hessian=zeros(0,0)).evidence.status == :unknown
    singleton = AtomisticSnapshot([[0.,0.]];masses=[1.])
    pairs = pair_distances(singleton).value
    @test isempty(pairs.pairs) && isempty(pairs.distances)
    @test pairs.minimum === nothing && pairs.maximum === nothing
    @test coordination(singleton;cutoff=0.).value.counts == [0]
end

@testset "M10B snapshot underflow must not certify zero energy" begin
    # RED candidate: squaring first loses velocity before a large mass rescales
    # it to a representable positive energy. Correct value OR explicit unknown
    # is acceptable; silently reporting a heuristic zero is not.
    s = AtomisticSnapshot([[0.]];masses=[1e200],velocities=[[1e-200]])
    result = mdcheck(s).observations.kinetic_energy
    oracle = setprecision(BigFloat,256) do
        BigFloat(1e200)*BigFloat(1e-200)^2/2
    end
    @test oracle > 0
    @test result.status == :unknown ||
        (result.value !== nothing && isapprox(result.value,Float64(oracle);rtol=1e-12,atol=0))
    particle=inspect_particle(s,1).kinetic_energy
    @test particle.status==:unknown || isapprox(particle.value,Float64(oracle);rtol=1e-12,atol=0)
    # An overflowing sum is already guarded by the observation boundary.
    huge = AtomisticSnapshot([[0.],[1.]];masses=fill(floatmax(Float64),2))
    @test mdcheck(huge).observations.total_mass.status == :unknown
end

@testset "M10B LJ exact scale certificate versus numerical display" begin
    # No root search, integration, large geometry, or optional MD backend.
    for T in (Float32,Float64,BigFloat)
        p = lennard_jones_analysis(;epsilon=T(2),sigma=T(1))
        @test p.evidence.minimum.status == :established
        @test p.evidence.minimum.value.epsilon isa T
        @test only(p.equilibria.value).x isa Float64
        @test only(p.equilibria.value).curvature isa Float64
        @test only(p.equilibria.value).value == -T(2)
        @test evaluate(p,T(1)) == 0
        @test p.numerical.force(T(1)) ≈ T(48)
        for bad in (0.,-1.,NaN,Inf,-Inf)
            @test_throws DomainError evaluate(p,bad)
        end
    end
    for bad in (0.,-1.,NaN,Inf,-Inf)
        @test_throws ArgumentError lennard_jones_analysis(;epsilon=bad)
        @test_throws ArgumentError lennard_jones_analysis(;sigma=bad)
    end
    # Units on the potential API are metadata, unlike snapshot quantities.
    @test_throws ArgumentError lennard_jones_analysis(;epsilon=1u"J")
    @test_throws ArgumentError lennard_jones_analysis(;sigma=1u"m")
    setprecision(BigFloat,256) do
        for outside in (BigFloat(2)^2000,BigFloat(2)^(-2000))
            @test_throws ArgumentError lennard_jones_analysis(;epsilon=outside)
            @test_throws ArgumentError lennard_jones_analysis(;sigma=outside)
        end
        p = lennard_jones_analysis()
        # Generic generated evaluation can use BigFloat even though candidate
        # search/display is Float64. Do not impose Float32 return preservation:
        # exact Rational{BigInt} coefficients may legitimately promote scalars.
        for r in (BigFloat(2)^(-100),BigFloat(2)^100)
            oracle = 4*((inv(r))^12-(inv(r))^6)
            actual = evaluate(p,r)
            @test actual isa BigFloat
            @test isfinite(actual) && !iszero(actual)
            @test actual ≈ oracle rtol=BigFloat(2)^(-200) atol=0
        end
    end
    # Finite scales whose displayed curvature truly over/underflows are refused,
    # not returned as a certified minimum with zero or infinite curvature.
    @test_throws ArgumentError lennard_jones_analysis(;epsilon=1.,sigma=1e-200)
    @test_throws ArgumentError lennard_jones_analysis(;epsilon=1.,sigma=1e200)
end
end # module
