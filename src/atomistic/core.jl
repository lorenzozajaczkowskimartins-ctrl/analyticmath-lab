"""Borrowed particle-major analysis data: `positions[i][axis]`, never a simulation system.

Arrays are read-only by convention; use `copy_data=true` for an owned snapshot.
Malformed numerical values can be retained for `mdcheck`. A boundary is a named
record with `kind=:open`, `:orthorhombic` and `lengths`, or `:unsupported`.
A backend may supply `distance(a,b)` implementing its own boundary semantics.
Unitless values have unknown physical units unless provenance specifies them.
"""
struct AtomisticSnapshot{P,V,M,S,B,T,R,E,F,D} <: AbstractAnalysis
    positions::P
    velocities::V
    masses::M
    species::S
    dimension::Int
    boundary::B
    time::T
    provenance::R
    potential_energy::E
    forces::F
    distance::D
end
function AtomisticSnapshot(positions;velocities=nothing,masses=nothing,species=nothing,
        dimension=isempty(positions) ? 0 : length(first(positions)),boundary=(kind=:open,),
        time=nothing,provenance=(source=:generic,units=:unknown),potential_energy=nothing,
        forces=nothing,distance=nothing,copy_data=false)
    dimension isa Integer && dimension>=0 || throw(ArgumentError("dimension must be a nonnegative integer"))
    data=copy_data ? deepcopy((positions,velocities,masses,species,boundary,forces)) :
        (positions,velocities,masses,species,boundary,forces)
    AtomisticSnapshot(data[1],data[2],data[3],data[4],Int(dimension),data[5],time,
        provenance,potential_energy,data[6],distance)
end
atomistic_snapshot(s::AtomisticSnapshot;kwargs...) = isempty(kwargs) ? s :
    throw(ArgumentError("snapshot conversion has no additional options"))

"""Lazy, read-only frame access. `getframe(i)` supplies one snapshot on demand.

No coordinate history is collected. `times=nothing` means unknown, not assumed
uniform timesteps. Provenance should record storage stride and any selection.
A view reflects mutations of its backing logger/data; freeze upstream explicitly.
"""
struct AtomisticTrajectoryView{F,T,P} <: AbstractAnalysis
    frame_count::Int
    getframe::F
    times::T
    provenance::P
end
function AtomisticTrajectoryView(n::Integer,getframe;times=nothing,provenance=(source=:generic,))
    n>=0 || throw(ArgumentError("frame count must be nonnegative"))
    times === nothing || length(times)==n || throw(DimensionMismatch("frame times must match frame count"))
    AtomisticTrajectoryView(Int(n),getframe,times,provenance)
end
Base.length(t::AtomisticTrajectoryView)=t.frame_count
function Base.getindex(t::AtomisticTrajectoryView,i::Integer)
    1<=i<=length(t) || throw(BoundsError(t,i))
    atomistic_snapshot(t.getframe(i))
end
function atomistic_trajectory end

_at_unknown(note;method=:unavailable)=PropertyResult(nothing,:unknown,method,[note])
_at_observed(x;method=:snapshot_arithmetic,notes=String[])=PropertyResult(x,:heuristic,method,notes)
_at_unit(x)=x isa Unitful.AbstractQuantity ? string(Unitful.unit(x)) : "unknown (unitless values)"
_at_number(x)=x isa Unitful.AbstractQuantity ? Unitful.ustrip(x) : x
_at_finite(x)=x isa Number && isreal(x) && isfinite(x)
_at_shape(a,n,d)=a isa AbstractVector && length(a)==n && all(v->v isa Union{Tuple,AbstractVector} && length(v)==d,a)
_at_positions_ok(s)=s.dimension>0 && _at_shape(s.positions,length(s.positions),s.dimension) &&
    all(v->all(_at_finite,v),s.positions)
_at_masses_ok(s)=s.masses isa AbstractVector && length(s.masses)==length(s.positions) &&
    all(x->_at_finite(x) && x>zero(x),s.masses)
_at_velocities_ok(s)=_at_shape(s.velocities,length(s.positions),s.dimension) && all(v->all(_at_finite,v),s.velocities)
_at_kind(s)=get(s.boundary,:kind,:unsupported)
function _at_box_ok(s)
    lengths=get(s.boundary,:lengths,nothing)
    _at_kind(s)==:orthorhombic && lengths !== nothing && length(lengths)==s.dimension &&
        all(x->_at_finite(x) && x>zero(x),lengths)
end
function _at_distance(s,a,b)
    s.distance !== nothing && return s.distance(a,b)
    delta=collect(b).-collect(a)
    if _at_kind(s)==:orthorhombic
        L=s.boundary.lengths
        delta=[delta[k]-round(delta[k]/L[k])*L[k] for k in eachindex(delta)]
    end
    LinearAlgebra.norm(delta)
end
function _at_selection(s,species)
    species===nothing && return (collect(eachindex(s.positions)),collect(eachindex(s.positions)),true)
    species isa Tuple && length(species)==2 || throw(ArgumentError("species must be nothing or an (A,B) tuple"))
    s.species === nothing && return nothing
    length(s.species)==length(s.positions) || return nothing
    (findall(==(species[1]),s.species),findall(==(species[2]),s.species),species[1]==species[2])
end
"""Stored unordered distances (same species), or A→B pairs (distinct species).

O(N²) work/storage, bounded by `max_pairs`. Periodic orthorhombic separation uses
minimum image; unsupported geometry never silently falls back to open distance.
"""
function pair_distances(s::AtomisticSnapshot;species=nothing,max_pairs=1_000_000)
    _at_positions_ok(s) || return _at_unknown("Finite, consistently shaped positions are required.")
    (_at_kind(s)==:open || _at_box_ok(s)) || return _at_unknown("Unsupported boundary geometry.")
    selection=_at_selection(s,species)
    selection===nothing && return _at_unknown("Species metadata unavailable or inconsistent.")
    A,B,same=selection
    pairs_count=same ? big(length(A))*(length(A)-1)÷2 : big(length(A))*length(B)
    max_pairs isa Integer && max_pairs>=0 || throw(ArgumentError("max_pairs must be nonnegative"))
    pairs_count<=max_pairs || return _at_unknown("Pair storage budget exceeded; use streaming RDF for distributions.")
    pairs=Tuple{Int,Int}[]; distances=Any[]
    for i in A,j in B
        (same && j<=i) && continue
        d=_at_distance(s,s.positions[i],s.positions[j])
        _at_finite(d) && d>=zero(d) || return _at_unknown("Invalid computed distance.")
        push!(pairs,(i,j)); push!(distances,d)
    end
    _at_observed((pairs=pairs,distances=distances,minimum=isempty(distances) ? nothing : minimum(distances),
        maximum=isempty(distances) ? nothing : maximum(distances),species=species,boundary=s.boundary,
        units=isempty(distances) ? "unknown" : _at_unit(first(distances)));method=:pair_enumeration)
end
pair_distances(x;kwargs...)=pair_distances(atomistic_snapshot(x);kwargs...)
