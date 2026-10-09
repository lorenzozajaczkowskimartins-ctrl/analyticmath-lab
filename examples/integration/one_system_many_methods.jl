"""
One system, many methods: a dimensionless coupled harmonic oscillator.
Run from the repository root:
    julia --project=. examples/integration/one_system_many_methods.jl
Optional learning: see one_system_learning.jl and the accompanying report.
No plotting backend is activated here. All source arrays are read-only by convention.
"""
module OneSystemManyMethods
using AnalyticMathLab, Symbolics, LinearAlgebra
const AML = AnalyticMathLab

"""The authoritative model and interpretation, not a new library data type."""
function canonical_system()
    (family=:coupled_harmonic_oscillator,
     parameters=(m=1, k=1, κ=1), coordinates=(:q1, :q2),
     state_order=(:q1, :q2, :v1, :v2), phase_order=(:q1, :q2, :p1, :p2),
     units=:dimensionless, equilibrium=(0, 0), equilibrium_positions=(0, 1),
     particle_ids=(:left, :right), amplitudes=(0.20, 0.10),
     initial_modal_velocities=(0.0, 0.0),
     times=collect(0.0:0.03125:10.0), controls=(abstol=1e-8, reltol=1e-8),
     reference=(kind=:analytical, description="Independent symmetric/antisymmetric modal superposition"))
end

mode_directions(s) = [1.0 1.0; 1.0 -1.0]/sqrt(2.0)
squared_frequencies(s) = [s.parameters.k, s.parameters.k+2s.parameters.κ]/s.parameters.m
stiffness(s) = [s.parameters.k+s.parameters.κ -s.parameters.κ;
               -s.parameters.κ s.parameters.k+s.parameters.κ]
potential_energy(s, q) = s.parameters.k*(q[1]^2+q[2]^2)/2 + s.parameters.κ*(q[2]-q[1])^2/2
kinetic_energy(s, v) = s.parameters.m*(v[1]^2+v[2]^2)/2
energy(s, u) = kinetic_energy(s, u[3:4])+potential_energy(s, u[1:2])

"""Independent oracle: no AML eigenvectors or integrated states enter this formula."""
function exact_state(s, t; amplitude=s.amplitudes[1])
    a = [amplitude, s.amplitudes[2]]
    ω = sqrt.(squared_frequencies(s))
    Φ = mode_directions(s)
    w = collect(s.initial_modal_velocities)
    vcat(Φ*(a.*cos.(ω*t)+w./ω.*sin.(ω*t)),
         Φ*(-a.*ω.*sin.(ω*t)+w.*cos.(ω*t)))
end

"""Explicit comparison contract; reference quality differs, physical meaning must not."""
function quantity_contract(s, quantity, samples, reference; amplitude=s.amplitudes[1])
    (model=s.family, parameters=s.parameters, coordinates=s.coordinates,
     state_order=s.state_order, initial_amplitudes=(amplitude,s.amplitudes[2]),
     initial_modal_velocities=s.initial_modal_velocities, units=s.units,
     quantity=quantity, samples=samples, reference=reference)
end

function compare_quantity(stage, actual, reference, left, right; tolerance)
    for key in keys(left)
        key == :reference && continue
        isequal(getproperty(left,key),getproperty(right,key)) ||
            throw(ArgumentError("$stage: incompatible $key; no automatic conversion"))
    end
    allowed = (:analytical, :symbolic, :numerical, :sampled, :learned)
    left.reference in allowed && right.reference in allowed ||
        throw(ArgumentError("$stage: reference quality must be explicit"))
    left.units == :dimensionless || throw(ArgumentError("This investigation declares dimensionless quantities"))
    size(actual) == size(reference) || throw(DimensionMismatch("$stage: sample shape mismatch"))
    error = maximum(abs, actual-reference)
    (stage=stage, quantity=left.quantity, compatibility=:explicit_same_quantity_and_conventions,
     error=error, tolerance=tolerance, agreement=error<=tolerance,
     units=left.units, actual_quality=left.reference, reference_quality=right.reference)
end

"""Display only the detached public descriptor, never walk native source objects."""
function origin_trace(result)
    origin = AML.scientific_origin(result)
    hasproperty(origin,:parents) || return origin
    rows = NamedTuple[]
    while true
        push!(rows,(source_type=Symbol(origin.type),operation=origin.operation,
                    token=origin.token,truncated=origin.truncated))
        isempty(origin.parents) && break
        origin = only(origin.parents)
    end
    rows
end

"""The numerical dataset selects q1; fixed model constants are explicit context."""
function simulation_schema(s; amplitude=s.amplitudes[1], id=:canonical)
    family = (model=s.family,parameters=s.parameters,coordinates=s.coordinates,
              state_order=s.state_order,units=s.units,antisymmetric_amplitude=s.amplitudes[2],
              initial_modal_velocities=s.initial_modal_velocities,
              equilibrium_positions=s.equilibrium_positions)
    (family=family, id=id, input=[amplitude], input_names=(:symmetric_amplitude,),
     coordinate_names=(:t,), domain=(inputs=[0.15 0.25],coordinates=[first(s.times) last(s.times)]),
     selection=(component=:q1,), split=:training,
     reference=(kind=:numerical,description="AML mechanics trajectory; not analytical truth",error=:unknown),
     units=(inputs=("dimensionless",),coordinates=("dimensionless",),output="dimensionless"),
     grid=(sampling=:stored,resampling=:none),rng=(kind=:deterministic,),
     context=(model=s.family,parameters=s.parameters,coordinates=s.coordinates,
              state_order=s.state_order,amplitudes=(amplitude,s.amplitudes[2]),units=s.units))
end

"""No interpolant: refuse if the native adaptive solver inserts additional saved points.
The small binary interval forces accepted stops and is below the accepted step size
for this bounded model/control combination. This is checked, not a general saveat promise.
"""
function integrate(s, conversion; amplitude=s.amplitudes[1])
    step = s.times[2]-s.times[1]
    path = trajectory(conversion,exact_state(s,first(s.times);amplitude),
        (first(s.times),last(s.times));s.controls...,saveat=step,dt=step)
    path.diagnostics.success && path.diagnostics.completed || error("Incomplete integration")
    path.solution.t == s.times || error("Saved grid differs; interpolation/resampling is not authorized")
    Tuple(Symbol.(path.labels)) == s.state_order || error("Unexpected mechanical state ordering")
    path
end

function investigate()
    s = canonical_system()
    @variables q1 q2 v1 v2 p1 p2
    q, v, p = (q1,q2), (v1,v2), (p1,p2)
    Tuple(Symbol.(string.(q))) == s.coordinates || error("Coordinate declaration mismatch")
    V, T = potential_energy(s,q), kinetic_energy(s,v)
    field = analyze(V,q)
    lagrangian = analyze(LagrangianSystem(T-V;coordinates=q,velocities=v))
    linearization = linearize_mechanics(lagrangian,s.equilibrium)
    legendre = legendre_transform(lagrangian;momenta=p)
    legendre.status == :established || error("Legendre transform unsupported")
    hamiltonian = legendre.value
    modes = normal_modes(linearization)
    conversion = dynamics(lagrangian)
    path = integrate(s,conversion)
    exact = hcat((exact_state(s,t) for t in s.times)...)
    context = (model=s.family,parameters=s.parameters,units=s.units,
               coordinates=s.coordinates,state_order=s.state_order,amplitudes=s.amplitudes,
               time_units=:dimensionless,scope=:stored_samples)
    series = (q1=observable_series(path;component=:q1,context),
              q2=observable_series(path;component=:q2,context),
              energy=observable_series(path;observable=(u,t)->energy(s,u),name=:energy,context),
              symmetric_mode=observable_series(path;observable=(u,t)->dot(mode_directions(s)[:,1],u[1:2]),
                                               name=:symmetric_mode,context))
    statistics = map(statistical_summary,series)
    running = running_statistics(series.q1)
    drift = energy_drift(conversion,path)

    # Explicit anchored-particle interpretation: not an ODE-to-particle adapter.
    indices = [1,81,161,241,321]
    snapshots = map(indices) do i
        u = path.solution.u[i]
        AtomisticSnapshot([[s.equilibrium_positions[j]+u[j],0,0] for j in 1:2];
            velocities=[[u[j+2],0,0] for j in 1:2],masses=fill(s.parameters.m,2),
            species=fill(:oscillator_mass,2),time=s.times[i],boundary=(kind=:open,),
            provenance=(source=AML.scientific_origin(path),operation=:explicit_longitudinal_mapping,
                particle_ids=s.particle_ids,units=s.units,equilibrium_positions=s.equilibrium_positions,
                state_order=s.state_order,frame_index=i))
    end
    distances = [pair_distances(snapshot;max_pairs=1) for snapshot in snapshots]
    atomistic = (;indices,snapshots,distances)
    schema = simulation_schema(s)
    dataset = ScientificDataset(path;schema,source_retention=:descriptor)

    # Evaluate the public symbolic Hamilton equations at representative numerical
    # states. p=m*v is a conversion, not an unannounced state reinterpretation.
    hvalues, flowerrors = Float64[], Float64[]
    scalar(expr,bindings) = Float64(Symbolics.value(Symbolics.substitute(expr,bindings)))
    for i in indices
        u = path.solution.u[i]
        bindings = Dict(vcat(collect(q),collect(p)) .=> vcat(u[1:2],s.parameters.m*u[3:4]))
        push!(hvalues,scalar(energy_function(hamiltonian),bindings))
        expected = vcat(u[3:4],-stiffness(s)*u[1:2])
        push!(flowerrors,maximum(abs,scalar.(hamilton_equations(hamiltonian),Ref(bindings))-expected))
    end
    E0 = sum(s.parameters.m*squared_frequencies(s).*collect(s.amplitudes).^2)/2
    metrics = (trajectory_error=maximum(abs,hcat(path.solution.u...)-exact),
        energy_drift=maximum(abs,series.energy.values.-first(series.energy.values)),
        energy_oracle_error=maximum(abs,series.energy.values.-E0),
        hamiltonian_energy_error=maximum(abs,hvalues-series.energy.values[indices]),
        hamiltonian_flow_error=maximum(flowerrors),
        mode_residual=maximum(abs,stiffness(s)*modes.mode_vectors-
            modes.mass_matrix*modes.mode_vectors*Diagonal(modes.eigenvalues)),
        orthogonality_error=maximum(abs,modes.mode_vectors'*modes.mass_matrix*modes.mode_vectors-I),
        frequencies=modes.frequencies,energy=E0,saved_points=length(s.times))
    comparisons = NamedTuple[]
    function compare(stage,quantity,actual,reference,samples,quality;tolerance=1e-13,reference_quality=:analytical)
        push!(comparisons,compare_quantity(stage,actual,reference,
            quantity_contract(s,quantity,samples,quality),
            quantity_contract(s,quantity,samples,reference_quality);tolerance))
    end
    compare(:equilibrium,:q,collect(linearization.equilibrium),collect(s.equilibrium),:equilibrium,:symbolic)
    compare(:gradient,:gradient_V,AML.gradient(field,s.equilibrium),zeros(2),:equilibrium,:symbolic)
    compare(:hessian,:stiffness,AML.hessian(field,s.equilibrium),stiffness(s),:equilibrium,:symbolic)
    compare(:linearization,:stiffness,linearization.stiffness_matrix,stiffness(s),:equilibrium,:symbolic)
    compare(:modes,:angular_frequency,modes.frequencies,sqrt.(squared_frequencies(s)),(:symmetric,:antisymmetric),:numerical)
    compare(:trajectory,:q_and_v,hcat(path.solution.u...),exact,s.times,:numerical;tolerance=2e-8)
    compare(:energy,:energy,series.energy.values,fill(E0,length(s.times)),s.times,:numerical;tolerance=2e-9)
    compare(:mechanical_energy,:energy,drift.value.values,series.energy.values,s.times,:numerical;reference_quality=:numerical)
    compare(:hamiltonian_energy,:energy,hvalues,fill(E0,length(indices)),s.times[indices],:numerical;tolerance=2e-9)
    compare(:observable,:q1,series.q1.values,vec(exact[1,:]),s.times,:numerical;tolerance=2e-8)
    compare(:atomistic,:pair_distance,[only(d.value.distances) for d in distances],
        abs.(s.equilibrium_positions[2]-s.equilibrium_positions[1].+exact[2,indices].-exact[1,indices]),
        s.times[indices],:numerical;tolerance=2e-8)
    compare(:dataset,:q1,only(dataset.samples).values,series.q1.values,s.times,:numerical;
        tolerance=0,reference_quality=:numerical)
    all(c.agreement for c in comparisons) || error("Cross-method inconsistency")
    trace = (series=origin_trace(series.q1),summary=origin_trace(statistics.q1),
             dataset=origin_trace(dataset),modes=origin_trace(modes))
    (;system=s,field,lagrangian,linearization,legendre,hamiltonian,momenta=p,modes,
      conversion,path,exact,series,statistics,running,drift,atomistic,schema,dataset,metrics,comparisons,trace)
end

function main()
    r = investigate()
    println("Coupled oscillator; all quantities explicitly dimensionless")
    println("Parameters: ",r.system.parameters,"; order: ",r.system.state_order)
    println("Independent analytical oracle versus AML: ",r.metrics)
    foreach(println,r.comparisons)
    println("Sampled statistics (not continuum averages): ",map(x->x.value,r.statistics))
    println("Legitimate recorded ancestry: ",r.trace)
    println("Statistical leaf ancestry is unavailable; keep its source series explicitly.")
    println("Analytical oracle: same physical model, NOT descended from the trajectory.")
    r
end

end # module

if abspath(PROGRAM_FILE) == @__FILE__
    OneSystemManyMethods.main()
end
