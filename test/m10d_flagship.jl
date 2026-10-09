module M10DFlagshipTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra
const example_path = joinpath(@__DIR__, "..", "examples", "integration", "one_system_many_methods.jl")
@testset "M10D4 canonical oscillator definition" begin
    @test isfile(example_path)
    if isfile(example_path)
        include(example_path)
        s = OneSystemManyMethods.canonical_system()
        @test s.parameters == (m=1, k=1, κ=1)
        @test s.coordinates == (:q1, :q2)
        @test s.state_order == (:q1, :q2, :v1, :v2)
        @test s.units == :dimensionless
        @test s.equilibrium == (0, 0)
        @test s.equilibrium_positions == (0, 1)
        @test s.amplitudes == (0.20, 0.10)
        @test OneSystemManyMethods.exact_state(s, 0)[3:4] == zeros(2)
        @test OneSystemManyMethods.exact_state(s, 0)[1:2] ≈ [0.3, 0.1]/sqrt(2)
    end
end
const W = OneSystemManyMethods
const A = AnalyticMathLab
@testset "M10D4 mechanics to sampled physical investigation" begin
    @test isdefined(W, :investigate)
    if isdefined(W, :investigate)
        # Keep the heterogeneous workflow result out of whole-testset inference.
        r = Base.invokelatest(W.investigate)
        s = r.system
        @test r.field.variables == r.lagrangian.coordinates
        @test A.gradient(r.field, s.equilibrium) == [0, 0]
        @test A.hessian(r.field, s.equilibrium) == [2 -1; -1 2]
        @test r.linearization.mass_matrix == [1 0; 0 1]
        @test r.linearization.stiffness_matrix == [2 -1; -1 2]
        @test r.linearization.damping_matrix == zeros(2, 2)
        @test r.linearization.equilibrium_evidence.value === true
        @test r.linearization.domain_evidence.value === true
        @test r.linearization.evidence.method == :local_euler_lagrange_derivatives
        @test :linearization in A.scientific_metadata(r.linearization).approximation
        @test r.linearization.source === r.lagrangian
        q = collect(r.lagrangian.coordinates)
        v = collect(r.lagrangian.velocities)
        a = collect(r.lagrangian.acceleration_symbols)
        zeroexpr(x) = iszero(Symbolics.simplify(Symbolics.expand(x)))
        @test all(zeroexpr, euler_lagrange(r.lagrangian) - (a + [2 -1; -1 2]*q))
        @test all(zeroexpr, generalized_momenta(r.lagrangian)-v)
        @test zeroexpr(energy_function(r.lagrangian)-W.energy(s, vcat(q,v)))
        @test r.legendre.status == :established
        @test isequal(r.hamiltonian.phase_variables, (q..., r.momenta...))
        @test zeroexpr(energy_function(r.hamiltonian) -
            (sum(p^2 for p in r.momenta)/2+W.potential_energy(s,q)))
        @test all(zeroexpr, hamilton_equations(r.hamiltonian)-vcat(collect(r.momenta),-[2 -1;-1 2]*q))
        @test r.lagrangian.energy_conservation.status == :established
        @test r.modes.eigenvalues ≈ [1, 3]
        @test r.modes.frequencies ≈ [1, sqrt(3)]
        Φ = r.modes.mode_vectors
        @test [2 -1;-1 2]*Φ ≈ Φ*Diagonal(r.modes.eigenvalues) atol=1e-13
        @test Φ'*r.modes.mass_matrix*Φ ≈ I atol=1e-13
        @test abs.(Φ'*W.mode_directions(s)) ≈ Matrix{Float64}(I,2,2) atol=1e-13
        @test W.mode_directions(s)'*r.path.solution.u[1][1:2] ≈ collect(s.amplitudes)
        @test r.modes.source === r.linearization
        @test r.modes.evidence.status == :heuristic
        @test r.path.diagnostics.success && r.path.diagnostics.completed
        @test r.path.solution.t == s.times
        @test Tuple(Symbol.(r.path.labels)) == s.state_order
        @test r.conversion.source === r.lagrangian
        @test A.scientific_metadata(r.path).tolerances.value == s.controls
        @test maximum(abs, hcat(r.path.solution.u...)-r.exact) < 2e-8
        @test r.metrics.trajectory_error < 2e-8
        @test r.metrics.energy_drift < 2e-9
        @test r.metrics.energy_oracle_error < 2e-9
        @test r.metrics.hamiltonian_energy_error < 1e-13
        @test r.metrics.hamiltonian_flow_error < 1e-13
        @test r.drift.value.times == s.times
        @test r.drift.status == :heuristic
        @test r.drift.value.values ≈ r.series.energy.values atol=1e-13
        for name in (:q1, :q2, :energy, :symmetric_mode)
            series = getproperty(r.series, name)
            stats = getproperty(r.statistics, name)
            values = series.values
            μ = sum(values)/length(values)
            @test series.sampling.times == s.times
            @test series.provenance.source === r.path
            @test series.provenance.context.units == :dimensionless
            @test series.provenance.resampling == :none
            @test stats.value.mean ≈ μ atol=1e-15
            @test stats.value.variance ≈ sum((values.-μ).^2)/(length(values)-1) atol=1e-15
            @test stats.value.standard_error === nothing
            @test stats.status == :heuristic
            @test A.scientific_origin(stats).availability == :unknown
            @test fieldnames(typeof(stats)) == (:value, :status, :method, :notes)
            @test :numerical_integration in A.scientific_metadata(series).approximation
            @test Base.summarysize(A.scientific_origin(series)) < 4096
        end
        @test r.series.q1.values == [u[1] for u in r.path.solution.u]
        @test r.series.q2.values == [u[2] for u in r.path.solution.u]
        @test r.series.q1.values ≈ vec(r.exact[1,:]) atol=2e-8
        @test r.series.q2.values ≈ vec(r.exact[2,:]) atol=2e-8
        @test r.running.value.means ≈ [sum(r.series.q1.values[1:i])/i for i in eachindex(s.times)] atol=1e-15
        @test r.statistics.energy.value.variance < 1e-18
        @test r.series.symmetric_mode.values ≈ s.amplitudes[1]*cos.(s.times) atol=2e-8
        for (i, snapshot, distance) in zip(r.atomistic.indices, r.atomistic.snapshots, r.atomistic.distances)
            u = r.path.solution.u[i]
            @test snapshot.positions == [[u[1],0,0],[1+u[2],0,0]]
            @test snapshot.masses == [1,1]
            @test snapshot.provenance.particle_ids == s.particle_ids
            @test snapshot.provenance.units == :dimensionless
            @test snapshot.time == s.times[i]
            @test distance.value.pairs == [(1,2)]
            @test only(distance.value.distances) ≈ abs(1+u[2]-u[1]) atol=1e-14
            @test only(distance.value.distances) ≈ abs(1+r.exact[2,i]-r.exact[1,i]) atol=2e-8
            @test snapshot.provenance.source.token == objectid(r.path)
            @test isempty(A.scientific_origin(snapshot).parents)
        end
        @test !applicable(atomistic_trajectory, r.path)
        @test minimum(1 .+ r.exact[2,:] .- r.exact[1,:]) > 0
        d = r.dataset
        @test d.input_names == (:symmetric_amplitude,)
        @test d.coordinate_names == (:t,)
        @test only(d.samples).input == [s.amplitudes[1]]
        @test only(d.samples).coordinates == reshape(s.times,1,:)
        @test only(d.samples).values == r.series.q1.values
        @test only(d.samples).split == :training
        @test d.reference.kind == :numerical
        @test d.reference.error == :unknown
        @test d.reference.tolerances == s.controls
        @test d.units == (inputs=("dimensionless",),coordinates=("dimensionless",),output="dimensionless")
        @test d.provenance.source.token == objectid(r.path)
        @test !hasproperty(d.provenance.source, :solution)
        @test r.trace.series[1].source_type == :ObservableSeries
        @test [x.operation for x in r.trace.series][1:4] ==
            [:stored_observable_selection, :numerical_integration, :mechanics_to_dynamics, :symbolic_mechanics]
        @test r.trace.summary.availability == :unknown
        @test all(length(t)<=8 for t in (r.trace.series,r.trace.dataset,r.trace.modes))
        twin = observable_series(r.path; component=:q1, context=(independent_selection=true,))
        @test statistical_summary(twin).value == r.statistics.q1.value
        @test hash(statistical_summary(twin).value) == hash(r.statistics.q1.value)
        @test A.scientific_origin(twin).token != A.scientific_origin(r.series.q1).token
        @test all(c.compatibility == :explicit_same_quantity_and_conventions for c in r.comparisons)
        @test all(c.agreement for c in r.comparisons)
        @test_throws ArgumentError W.compare_quantity(:bad, [1.], [1.],
            W.quantity_contract(s,:q1,[0.],:numerical),
            W.quantity_contract(s,:q2,[0.],:analytical); tolerance=1e-8)
        contract = W.quantity_contract(s,:q1,[0.],:analytical)
        for change in ((units=:unknown,), (parameters=(m=2,k=1,κ=1),),
                       (coordinates=(:q2,:q1),), (samples=[1.],), (reference=:unknown,))
            @test_throws ArgumentError W.compare_quantity(:bad,[1.],[1.],contract,merge(contract,change);tolerance=1e-8)
        end
        code = read(example_path, String)
        @test !occursin("Base.include", code)
        @test !occursin(r"include\(.*src/", code)
        @test !occursin(r"(?:AML|AnalyticMathLab)\._", code)
        @test ismissing(A.Makie.current_backend())
        println("FLAGSHIP_METRICS ", r.metrics)
        println("FLAGSHIP_STATISTICS ", map(x->x.value, r.statistics))
        println("FLAGSHIP_PROVENANCE ", r.trace)
    end
end
end
