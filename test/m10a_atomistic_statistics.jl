module M10AAtomisticStatisticsTests
using Test, AnalyticMathLab, LinearAlgebra, ForwardDiff, Unitful
const A = AnalyticMathLab

# Independent finite fixtures, not a simulation-validity or performance suite.
# Include directly; deliberately does not load Molly or alter the root runner.
@testset "M10A M8 correctness audit" begin
    @testset "Geometry: symmetry, zero, images, populations and dimensions" begin
        for d in (2, 3)
            p = [zeros(d), [3., 4., zeros(d-2)...], [0., 4., zeros(d-2)...]]
            s = AtomisticSnapshot(p; species=[:A, :A, :B])
            pairs = pair_distances(s).value
            @test pairs.pairs == [(1,2), (1,3), (2,3)]
            @test pairs.distances ≈ [5., 4., 3.]
            for i in 1:3, j in 1:3
                # Private primitive intentionally probed for self distance, which
                # the public unordered enumeration correctly never includes.
                @test A._at_distance(s, p[i], p[j]) ≈ norm(p[j]-p[i])
                @test A._at_distance(s, p[i], p[j]) == A._at_distance(s, p[j], p[i])
                i == j && @test iszero(A._at_distance(s, p[i], p[j]))
            end
            @test pair_distances(s; species=(:A,:A)).value.pairs == [(1,2)]
            ab = pair_distances(s; species=(:A,:B)).value
            ba = pair_distances(s; species=(:B,:A)).value
            @test ab.pairs == [(1,3), (2,3)]
            @test ba.pairs == [(3,1), (3,2)]
            @test ab.distances == ba.distances
            @test coordination(s; cutoff=4.).value.counts == [1,1,2]
            @test coordination(s; cutoff=4., species=(:A,:B)).value.counts == [1,1]
            @test pair_distances(s; max_pairs=2).status == :unknown

            # 29 wraps to -1 in a box of length 10; not a single-wrap shortcut.
            q = [zeros(d), [29., 4., zeros(d-2)...]]
            periodic = AtomisticSnapshot(q; boundary=(kind=:orthorhombic,lengths=fill(10.,d)))
            @test pair_distances(periodic).value.distances ≈ [sqrt(17.)]
            @test A._at_distance(periodic,q[1],q[2]) == A._at_distance(periodic,q[2],q[1])
            rdf = radial_distribution(periodic; edges=[0.,4.,5.])
            shells = d == 2 ? [16π,9π] : [256π/3,244π/3]
            @test rdf.counts == [0,1]
            @test rdf.pair_populations == [1]
            @test rdf.expected_counts ≈ shells ./ 10^d
            @test rdf.rdf.value ≈ [0., 10^d/shells[2]]
            @test rdf.rdf.status == :heuristic
        end
        duplicate = AtomisticSnapshot([[0.,0.],[0.,0.]])
        @test pair_distances(duplicate).value.distances == [0.]
        @test coordination(duplicate; cutoff=0.).value.counts == [1,1]
        @test pair_distances(AtomisticSnapshot([[0.,0.],[1.]];dimension=2)).status == :unknown
        @test pair_distances(AtomisticSnapshot([[0.,0.]];boundary=(kind=:unsupported,))).status == :unknown
        line = AtomisticSnapshot([[0.],[1.]];boundary=(kind=:orthorhombic,lengths=[10.]))
        @test radial_distribution(line;edges=[0.,2.]).rdf.status == :unknown
        su = AtomisticSnapshot([[0.,0.]u"m",[300.,400.]u"cm"])
        @test only(pair_distances(su).value.distances) ≈ 5u"m"
    end

    @testset "LJ independent formula, AD and radial sign" begin
        epsilon, sigma = 2., 1.5
        U(r) = 4epsilon*((sigma/r)^12-(sigma/r)^6)
        F(r) = 24epsilon/r*(2*(sigma/r)^12-(sigma/r)^6)
        p = lennard_jones_analysis(;epsilon,sigma)
        for r in (1.4, 1.5, 2., 3.)
            @test evaluate(p,r) ≈ U(r) rtol=1e-11 atol=1e-12
            @test p.numerical.force(r) ≈ F(r) rtol=1e-11 atol=1e-12
            @test p.numerical.force(r) ≈ -ForwardDiff.derivative(U,r) rtol=1e-11 atol=1e-12
            @test evaluate(p,r;order=2) ≈ ForwardDiff.derivative(x->ForwardDiff.derivative(U,x),r) rtol=1e-10
        end
        rmin = 2^(1/6)*sigma
        @test p.numerical.force(1.4) > 0
        @test p.numerical.force(2.) < 0
        @test p.numerical.force(rmin) ≈ 0 atol=1e-10
        @test evaluate(p,rmin) ≈ -epsilon atol=1e-12
        @test evaluate(p,rmin;order=2) ≈ 72epsilon/rmin^2
        @test U(rmin-0.01) > U(rmin) < U(rmin+0.01)
        point = only(p.equilibria.value)
        @test point.x ≈ rmin
        @test point.classification == :minimum
        @test point.curvature ≈ 72epsilon/rmin^2
        @test p.evidence.minimum.status == :established
        @test_throws DomainError evaluate(p,0.)
    end

    @testset "Unconstrained Cartesian mode bridge" begin
        s = AtomisticSnapshot([[1.,2.],[4.,6.]];masses=[2.,3.])
        # U = (3/2)*|delta q2-delta q1|^2: two translations and
        # two relative modes, lambda = 3*(1/2+1/3) = 5/2.
        K = [3. 0 -3 0; 0 3 0 -3; -3 0 3 0; 0 -3 0 3]
        M = Diagonal([2.,2.,3.,3.])
        r = normal_modes(s;hessian=K)
        @test r.equilibrium == (1.,2.,4.,6.)
        @test r.mass_matrix ≈ M
        @test r.metadata.coordinate_ordering == :particle_major_cartesian
        @test r.metadata.coordinate_layout == (particles=2,dimension=2)
        @test r.metadata.equilibrium_status == :not_verified
        @test r.eigenvalues ≈ [0.,0.,2.5,2.5] atol=1e-12
        @test length(r.zero_modes) == 2
        @test r.mode_vectors' * M * r.mode_vectors ≈ Matrix{Float64}(I,4,4) atol=1e-12
        @test norm(K*r.mode_vectors-M*r.mode_vectors*Diagonal(r.eigenvalues)) < 1e-11
        translations = [1. 0; 0 1; 1 0; 0 1]
        Z = r.mode_vectors[:,r.zero_modes]
        @test Z*(Z'*M*translations) ≈ translations atol=1e-12
        @test normal_modes(s).evidence.status == :unknown
        @test_throws DimensionMismatch normal_modes(s;hessian=zeros(3,3))
    end

    @testset "Hand moments, covariance denominators, IAT, ESS and blocks" begin
        s = ObservableSeries([1.,2.,3.,4.];interval=2.,name=:energy)
        m = statistical_summary(s)
        @test m.value.mean == 5/2
        @test m.value.variance ≈ 5/3
        @test m.value.standard_error === nothing
        @test m.status == :heuristic
        running = running_statistics(s).value
        @test running.means ≈ [1.,1.5,2.,2.5]
        @test running.variances[1] === nothing
        @test running.variances[2:end] ≈ [1/2,1.,5/3]
        ac = autocorrelation(s;maxlag=3)
        au = autocorrelation(s;maxlag=3,normalization=:unbiased)
        @test ac.counts == [4,3,2,1]
        @test collect(ac.lag_times) == [0.,2.,4.,6.]
        @test ac.autocovariance ≈ [5/4,5/16,-3/8,-9/16]
        @test au.autocovariance ≈ [5/4,5/12,-3/4,-9/4]
        @test ac.autocorrelation ≈ [1.,1/4,-3/10,-9/20]
        @test au.autocorrelation ≈ [1.,1/3,-3/5,-9/5]
        tau = integrated_autocorrelation_time(ac)
        @test tau.value.window == 1
        @test tau.value.tau == 3/4
        @test tau.value.physical_tau == 3/2
        cm = correlated_mean(s;maxlag=3)
        @test cm.value.effective_samples ≈ 8/3
        @test cm.value.standard_error ≈ sqrt(5/8)
        @test cm.status == :heuristic
        clamped = integrated_autocorrelation_time(ac;window=3).value
        @test clamped.raw_tau ≈ 0. atol=1e-14
        @test clamped.tau == 1/2
        @test clamped.clamped
        @test integrated_autocorrelation_time(autocorrelation(s;maxlag=1)).status == :unknown
        constant = autocorrelation(ObservableSeries(fill(2.,4);index_time=true);maxlag=3)
        @test constant.autocovariance == zeros(4)
        @test constant.autocorrelation === nothing
        @test correlated_mean(ObservableSeries(fill(2.,4);index_time=true)).status == :unknown
        blocks = block_average(ObservableSeries([1.,2.,3.,4.,99.]);block_sizes=[2,3])
        @test blocks.block_counts == [2,1]
        @test blocks.discarded == [1,2]
        @test blocks.block_means == [[1.5,3.5],[2.]]
        @test blocks.variances == [2.,nothing]
        @test blocks.standard_errors == [1.,nothing]
        @test statistical_summary(ObservableSeries([1.,missing,3.])).status == :unknown
    end

    @testset "Time honesty and transport arithmetic" begin
        meta = (stride=5,dt=0.1,fixed_particles=:caller_asserted)
        frame(i) = AtomisticSnapshot([[Float64(i-1),0.],[0.,2.0*(i-1)]];
            velocities=[[Float64(i),0.],[0.,2.0*i]])
        t = AtomisticTrajectoryView(3,frame;times=[10.,10.5,11.],provenance=meta)
        unknown = AtomisticTrajectoryView(3,frame;provenance=meta)
        irregular = AtomisticTrajectoryView(3,frame;times=[0.,0.5,1.5],provenance=meta)
        @test sampling_info(t).interval == 0.5
        @test sampling_info(t).interval != meta.dt
        @test sampling_info(unknown).interval === nothing
        @test sampling_info(unknown).regularity == :unknown
        @test sampling_info(irregular).regularity == :irregular
        for times in (nothing,[0.,0.5,1.5])
            @test autocorrelation(ObservableSeries([1.,2.,3.];times);maxlag=2).evidence.status == :unknown
        end
        @test_throws ArgumentError sampling_info(3;times=[0.,1.,1.])
        @test_throws ArgumentError sampling_info(3;times=[0.,2.,1.])
        @test_throws ArgumentError sampling_info(3;times=[0.,0.5,1.],interval=0.1)
        @test_throws ArgumentError sampling_info(3;interval=1.,index_time=true)
        msd = mean_squared_displacement(t)
        @test msd.values.value ≈ [0.,2.5,10.]
        @test msd.times == [0.,0.5,1.]
        @test msd.dimensions == 2
        @test msd.particle_count == 2
        @test msd.origin_count == 1
        @test mean_squared_displacement(irregular).values.value ≈ [0.,2.5,10.]
        @test mean_squared_displacement(unknown).values.status == :unknown
        @test mean_squared_displacement(t;coordinates=:wrapped).values.status == :unknown
        @test diffusion_estimate(msd).status == :unknown
        vacf = velocity_autocorrelation(t;maxlag=2,normalize=true)
        @test vacf.raw.value ≈ [35/3,10.,15/2]
        @test vacf.normalized.value ≈ [1.,6/7,9/14]
        @test vacf.origin_counts == [3,2,1]
        @test vacf.lag_times == [0.,0.5,1.]
        @test velocity_autocorrelation(irregular).raw.status == :unknown
        @test velocity_autocorrelation(unknown).raw.status == :unknown
        @test_throws ArgumentError analyze(t;series=(energy=ObservableSeries([1.,2.,3.];times=[0.,0.5,1.]),))
    end

    @testset "Mechanical observations and conditional conservation" begin
        s = AtomisticSnapshot([[0.,0.],[4.,0.]]u"m";masses=[2.,1.]u"kg",
            velocities=[[1.,2.],[-2.,0.]]u"m/s",potential_energy=-3u"J")
        o = mdcheck(s).observations
        @test o.total_mass.value == 3u"kg"
        @test o.center_of_mass.value ≈ [4/3,0.]u"m"
        @test o.total_momentum.value == [0.,4.]u"kg*m/s"
        @test o.center_of_mass_velocity.value ≈ [0.,4/3]u"m/s"
        @test o.kinetic_energy.value == 7u"J"
        @test o.total_energy.value == 4u"J"
        t = AtomisticTrajectoryView(2,i->s;times=[0.,1.]u"s")
        @test collect(observable_series(t,:total_energy).values) == [4,4]u"J"
        @test collect(observable_series(t,:total_momentum;component=2).values) == [4,4]u"kg*m/s"
        @test all(ismissing,observable_series(t,:temperature).values)
        @test all(ismissing,observable_series(t,:temperature;dof=4).values)
        temperature = observable_series(t,:temperature;dof=4,boltzmann=2u"J/K")
        @test collect(temperature.values) == [7/4,7/4]u"K"
        @test temperature.provenance.temperature_convention == :caller_dof_and_boltzmann
        for name in (:total_energy,:kinetic_energy,:potential_energy), ensemble in (:NVE,:NVT,:unknown)
            series = ObservableSeries([2.,4.,6.];name,interval=2.,provenance=(ensemble=ensemble,))
            d = energy_diagnostics(series)
            @test d.value.deviations == [0.,2.,4.]
            @test d.value.maximum_absolute == 4.
            @test d.value.maximum_relative == 2.
            @test d.value.rms ≈ sqrt(20/3)
            @test d.value.linear_slope.value ≈ 1.
            @test d.value.conservation_expected == (name==:total_energy && ensemble==:NVE)
            @test d.value.interpretation == :descriptive_deviations
            @test d.status == :heuristic
        end
        # False expectation is compatible even with exactly constant observations;
        # it is not an established nonconservation certificate.
        constant = energy_diagnostics(ObservableSeries([2.,2.];name=:kinetic_energy,provenance=(ensemble=:NVE,)))
        @test !constant.value.conservation_expected
        @test constant.value.maximum_absolute == 0.
        @test constant.value.linear_slope.status == :unknown
        mom = momentum_diagnostics(ObservableSeries([[1.,0.],[4.,4.]];name=:total_momentum))
        @test mom.value.maximum_absolute == 5.
        @test mom.value.rms ≈ sqrt(25/2)
        @test !mom.value.conservation_expected
    end

    @testset "Stored B-A, independent uncertainty, refusal gates" begin
        sa = ObservableSeries([1.,2.,3.,4.];name=:energy,index_time=true)
        sb = ObservableSeries([3.,4.,5.,6.];name=:energy,index_time=true)
        ra, rb = correlated_mean(sa;maxlag=3), correlated_mean(sb;maxlag=3)
        a, b = ComparisonInput(ra;series=sa,label="A"), ComparisonInput(rb;series=sb,label="B")
        c = compare(a,b;unitless=true)
        @test c.compatibility.status == :compatible
        @test c.difference.value == 2.
        @test compare(b,a;unitless=true).difference.value == -2.
        @test c.uncertainty.status == :unknown
        @test compare(a,b;unitless=true,independence=:independent).uncertainty.value ≈ sqrt(5/4)
        @test compare(a,a;unitless=true,independence=:independent).uncertainty.status == :unknown
        @test compare(a,b).difference.value === nothing
        otherwindow = ComparisonInput(correlated_mean(sb;maxlag=3,window=0);series=sb)
        cw = compare(a,otherwindow;unitless=true,independence=:independent)
        @test cw.difference.value == 2.
        @test cw.uncertainty.status == :unknown

        joules = ObservableSeries([1.,2.,3.,4.]u"J";name=:energy)
        metres = ObservableSeries([1.,2.,3.,4.]u"m";name=:energy)
        units = compare(ComparisonInput(statistical_summary(joules);series=joules),
            ComparisonInput(statistical_summary(metres);series=metres))
        @test units.compatibility.checks[:units].value === false
        @test units.difference.value === nothing
        ac = autocorrelation(sa;maxlag=3)
        left = ComparisonInput(ac;series=sa)
        unbiased = compare(left,ComparisonInput(autocorrelation(sb;maxlag=3,normalization=:unbiased);series=sb);unitless=true)
        @test unbiased.compatibility.checks[:estimator].value === false
        @test unbiased.difference.value === nothing
        short = compare(left,ComparisonInput(autocorrelation(sb;maxlag=2);series=sb);unitless=true)
        @test short.compatibility.checks[:shape].value === false
        @test short.compatibility.checks[:grid].value === false
        @test short.difference.value === nothing
        explicit = ObservableSeries([3.,4.,5.,6.];name=:energy,interval=1.)
        clocks = compare(left,ComparisonInput(autocorrelation(explicit;maxlag=3);series=explicit);unitless=true,unitless_time=true)
        @test clocks.compatibility.checks[:time].value === false
        @test clocks.difference.value === nothing
        slow = ObservableSeries([3.,4.,5.,6.];name=:energy,interval=2.)
        grids = compare(ComparisonInput(autocorrelation(explicit;maxlag=3);series=explicit),
            ComparisonInput(autocorrelation(slow;maxlag=3);series=slow);unitless=true,unitless_time=true)
        @test grids.compatibility.checks[:grid].value === false
        @test grids.difference.value === nothing
        path = AtomisticTrajectoryView(3,i->AtomisticSnapshot([[Float64(i),0.]]);
            times=[0.,1.,2.]u"s",provenance=(fixed_particles=:caller_asserted,))
        ma = mean_squared_displacement(path)
        mu = mean_squared_displacement(path;coordinates=:unwrapped)
        coordinates = compare(ComparisonInput(ma;selection=:same),ComparisonInput(mu;selection=:same);unitless=true)
        @test coordinates.compatibility.checks[:semantics].value === false
        @test coordinates.difference.value === nothing
    end
end
end # module
