"""Concrete snapshot observations, never a certificate of simulation validity."""
struct AtomisticSystemAnalysis{S,C,O} <: AbstractAnalysis
    source::S
    checks::C
    observations::O
    notes::Vector{String}
end
function _at_safe(f,note)
    try
        value=f()
        finite=value isa AbstractArray ? all(_at_finite,value) : _at_finite(value)
        finite ? _at_observed(value) : _at_unknown("Nonfinite result: "*note)
    catch err
        err isa Union{DimensionMismatch,Unitful.DimensionError,MethodError,DomainError,OverflowError} || rethrow()
        _at_unknown("Incompatible data or units: "*note)
    end
end
"""Inspect an instantaneous configuration; optional backend energies/forces are
requested only by the adapter, not recomputed by a second force engine.

Pair enumeration is bounded by `max_pairs`. `close_distance` and `force_threshold`
are explicit user thresholds, not universal model-validity criteria. Periodic
centroids use the supplied coordinate images, not an inferred unwrapped molecule.
"""
function mdcheck(s::AtomisticSnapshot;close_distance=nothing,force_threshold=nothing,max_pairs=1_000_000)
    n,d=length(s.positions),s.dimension
    shape=_at_shape(s.positions,n,d)
    finite_pos=shape && all(v->all(_at_finite,v),s.positions)
    mass_count=s.masses isa AbstractVector && length(s.masses)==n
    finite_mass=mass_count && all(_at_finite,s.masses)
    positive_mass=finite_mass && all(m->m>zero(m),s.masses)
    velocity_shape=_at_shape(s.velocities,n,d)
    checks=(particle_count=n,dimension=d,coordinate_shape=shape,finite_positions=finite_pos,
        mass_count=mass_count,finite_masses=finite_mass,positive_masses=positive_mass,
        velocity_shape=s.velocities===nothing ? missing : velocity_shape,
        finite_velocities=s.velocities===nothing ? missing : velocity_shape && all(v->all(_at_finite,v),s.velocities),
        species_count=s.species===nothing ? missing : length(s.species)==n,
        boundary=s.boundary)
    available=positive_mass && n>0 && d>0
    total=available ? _at_safe(()->sum(s.masses),"total mass") : _at_unknown("Positive finite masses required.")
    center=available && finite_pos ? _at_safe(()->sum(s.masses[i].*collect(s.positions[i]) for i in 1:n)/sum(s.masses),"center of mass") :
        _at_unknown("Finite positions and positive masses required.")
    if center.value !== nothing && _at_kind(s)!=:open
        center=PropertyResult(center.value,:heuristic,:supplied_image_centroid,
            ["Arithmetic centroid of supplied coordinate images; wrapping-dependent, not a periodic unwrapped center of mass."])
    end
    moving=available && _at_velocities_ok(s)
    momentum=moving ? _at_safe(()->sum(s.masses[i].*collect(s.velocities[i]) for i in 1:n),"momentum") : _at_unknown("Velocities or positive masses unavailable.")
    cmvelocity=momentum.value!==nothing && total.value!==nothing ? _at_safe(()->momentum.value/total.value,"center-of-mass velocity") : _at_unknown("Momentum unavailable.")
    kinetic=moving ? _at_safe(()->sum(s.masses[i]*sum(abs2,s.velocities[i])/2 for i in 1:n),"kinetic energy") : _at_unknown("Velocities or positive masses unavailable.")
    potential=s.potential_energy isa PropertyResult ? s.potential_energy : s.potential_energy===nothing ?
        _at_unknown("Potential energy unavailable; no force engine invoked.") : _at_safe(()->s.potential_energy,"potential energy")
    energy=kinetic.value!==nothing && potential.value!==nothing ? _at_safe(()->kinetic.value+potential.value,"total mechanical energy") : _at_unknown("Compatible kinetic and potential energies required.")
    distances=try pair_distances(s;max_pairs=max_pairs) catch err
        err isa Union{Unitful.DimensionError,DimensionMismatch,MethodError,DomainError} || rethrow()
        _at_unknown("Incompatible distance units or shape.")
    end
    overlaps=distances.value===nothing ? _at_unknown("Pair distances unavailable.") :
        _at_observed(distances.value.pairs[findall(iszero,distances.value.distances)];method=:exact_stored_coordinate_overlap)
    if close_distance!==nothing
        _at_finite(close_distance) && close_distance>zero(close_distance) || throw(ArgumentError("close_distance must be finite and positive"))
    end
    close=distances.value===nothing || close_distance===nothing ? _at_unknown("No close-pair threshold or distances supplied.") :
        _at_observed(distances.value.pairs[findall(x->x<close_distance,distances.value.distances)];method=:user_distance_threshold)
    maximum_force=_at_shape(s.forces,n,d) && n>0 && all(v->all(_at_finite,v),s.forces) ?
        _at_safe(()->maximum(LinearAlgebra.norm(v) for v in s.forces),"force magnitude") : _at_unknown("Finite backend forces unavailable.")
    if force_threshold!==nothing
        _at_finite(force_threshold) && force_threshold>zero(force_threshold) || throw(ArgumentError("force_threshold must be finite and positive"))
    end
    large_force=force_threshold===nothing || maximum_force.value===nothing ? _at_unknown("No force threshold or forces supplied.") :
        _at_observed(maximum_force.value>force_threshold;method=:user_force_threshold)
    observations=(total_mass=total,center_of_mass=center,total_momentum=momentum,center_of_mass_velocity=cmvelocity,
        kinetic_energy=kinetic,potential_energy=potential,total_energy=energy,pair_distances=distances,
        exact_overlaps=overlaps,close_pairs=close,maximum_force=maximum_force,large_force=large_force,
        timestep_stability=_at_unknown("Timestep stability not assessed."))
    AtomisticSystemAnalysis(s,checks,observations,["Snapshot observations are not a claim of physical correctness, equilibrium or simulation validity.",
        "Pair distances are O(N²), with bounded stored pair count; arrays are borrowed read-only."])
end
mdcheck(x;kwargs...)=mdcheck(atomistic_snapshot(x);kwargs...)

"""Inspect one particle; returns borrowed position/velocity plus local distances.
`cutoff` is explicit; no physical atomic radius or automatic bonding is inferred.
"""
function inspect_particle(s::AtomisticSnapshot,i::Integer;cutoff=nothing)
    1<=i<=length(s.positions) || throw(BoundsError(s.positions,i))
    m=s.masses===nothing || length(s.masses)<i ? nothing : s.masses[i]
    v=s.velocities===nothing || length(s.velocities)<i ? nothing : s.velocities[i]
    speed=v===nothing ? _at_unknown("Velocity unavailable.") : _at_safe(()->LinearAlgebra.norm(v),"speed")
    kinetic=m===nothing || speed.value===nothing ? _at_unknown("Mass/velocity unavailable.") : _at_safe(()->m*speed.value^2/2,"particle kinetic energy")
    local_distances=_at_positions_ok(s) && (_at_kind(s)==:open || _at_box_ok(s)) ?
        _at_observed([(index=j,distance=_at_distance(s,s.positions[i],s.positions[j])) for j in eachindex(s.positions) if j!=i];method=:selected_particle_distances) : _at_unknown("Unsupported positions or boundary.")
    if local_distances.value!==nothing && !all(x->_at_finite(x.distance) && x.distance>=zero(x.distance),local_distances.value)
        local_distances=_at_unknown("Invalid computed distance.")
    end
    cutoff===nothing || (_at_finite(cutoff) && cutoff>zero(cutoff)) || throw(ArgumentError("cutoff must be finite and positive"))
    neighbors=cutoff===nothing || local_distances.value===nothing ? _at_unknown("No cutoff or distances supplied.") :
        _at_observed(count(x->x.distance<=cutoff,local_distances.value);method=:explicit_cutoff)
    (index=i,species=s.species===nothing || length(s.species)<i ? nothing : s.species[i],mass=m,position=s.positions[i],velocity=v,
        speed=speed,kinetic_energy=kinetic,local_distances=local_distances,coordination=neighbors,provenance=s.provenance)
end
inspect_particle(x,i;kwargs...)=inspect_particle(atomistic_snapshot(x),i;kwargs...)
