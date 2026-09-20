"""Streaming radial distribution with finite-N ideal-gas normalization.

`rdf` is a PropertyResult: sampled distributions are heuristic evidence, not a
claim of equilibrium. Same/all pairs use N(N-1)/2 and cross-species pairs NA*NB.
Expected shell counts are summed per frame before division, including changing
populations and volumes. Bins are [lo,hi), with the last right edge included.
Only periodic orthorhombic 2D/3D geometry is normalized. Memory is O(bins + frames
+ particles), never O(frames*particles²). Units of radii are retained; g is unitless.
"""
struct RadialDistributionAnalysis <: AbstractAnalysis
    rdf::PropertyResult
    counts::Vector{Int}
    edges
    centers
    expected_counts
    frame_count::Int
    particle_populations
    pair_populations
    species
    units
    boundary_assumptions
    method::Symbol
    notes::Vector{String}
end

"""Count neighbors at distance ≤ cutoff per selected central A particle.

Self pairs are excluded. Same-species unordered pairs increment both particles;
distinct A→B pairs increment A only. Open geometry is allowed for this direct
count (no homogeneous-density normalization is performed).
"""
function coordination(s::AtomisticSnapshot;cutoff,species=nothing)
    _at_finite(cutoff) && cutoff>=zero(cutoff) || return _at_unknown("A finite nonnegative cutoff is required.")
    _at_positions_ok(s) || return _at_unknown("Finite, consistently shaped positions required.")
    (_at_kind(s)==:open || _at_box_ok(s)) || return _at_unknown("Unsupported boundary geometry.")
    sel=_at_selection(s,species)
    sel===nothing && return _at_unknown("Species metadata unavailable or inconsistent.")
    A,B,same=sel
    isempty(A) && return _at_unknown("No central particles selected.")
    counts=zeros(Int,length(A)); index=Dict(a=>k for (k,a) in enumerate(A))
    for (k,i) in enumerate(A),j in B
        same && j<=i && continue
        d=_at_distance(s,s.positions[i],s.positions[j])
        _at_finite(d) && d>=zero(d) || return _at_unknown("Invalid computed pair distance.")
        if d<=cutoff
            counts[k]+=1
            same && (counts[index[j]]+=1)
        end
    end
    _at_observed((mean=sum(counts)/length(A),counts=counts,central_indices=A,
        cutoff=cutoff,species=species,boundary=s.boundary,units="dimensionless");
        method=:neighbor_count,notes=["Direct finite-snapshot neighbor counts; cutoff inclusive."])
end

function radial_distribution(s::AtomisticSnapshot;edges,species=nothing,frames=1:1)
    radial_distribution(AtomisticTrajectoryView(1,i->s);edges,species,frames)
end

function radial_distribution(t::AtomisticTrajectoryView;edges,species=nothing,frames=1:length(t))
    e=collect(edges)
    length(e)>=2 && all(_at_finite,e) && first(e)>=zero(first(e)) &&
        all(i->e[i]<e[i+1],1:length(e)-1) || throw(ArgumentError("edges must be finite, nonnegative and strictly increasing"))
    counts=zeros(Int,length(e)-1); expected=zeros(length(counts))
    populations=NamedTuple[]; pairs=BigInt[]; nf=0; dimension=nothing
    notes=["Finite-N normalization; expected counts summed over selected frames."]
    assumptions=(geometry=:periodic_orthorhombic,dimensions=(2,3),range=:half_shortest_box,
        bins=:left_closed_last_right_closed)
    result(p)=RadialDistributionAnalysis(p,counts,e,(e[1:end-1].+e[2:end])./2,
        expected,nf,populations,pairs,species,(radius=_at_unit(first(e)),rdf="dimensionless"),
        assumptions,:streaming_pair_histogram,copy(notes))
    unknown(msg)=result(_at_unknown(msg;method=:streaming_pair_histogram))
    for f in frames
        f isa Integer && 1<=f<=length(t) || throw(ArgumentError("frame indices must be in trajectory range"))
        s=t[f]
        _at_positions_ok(s) || return unknown("Finite, consistently shaped positions required.")
        s.dimension in (2,3) && _at_box_ok(s) || return unknown("RDF requires periodic orthorhombic 2D/3D geometry.")
        dimension===nothing || dimension==s.dimension || return unknown("Cannot pool RDF frames with different spatial dimensions.")
        dimension=s.dimension
        last(e)<=minimum(s.boundary.lengths)/2 || return unknown("RDF range exceeds half the shortest box length.")
        sel=_at_selection(s,species)
        sel===nothing && return unknown("Species metadata unavailable or inconsistent.")
        A,B,same=sel
        np=same ? big(length(A))*(length(A)-1)÷2 : big(length(A))*length(B)
        volume=prod(s.boundary.lengths)
        factor=s.dimension==2 ? π : 4π/3
        for k in eachindex(counts)
            expected[k]+=Float64(factor*(e[k+1]^s.dimension-e[k]^s.dimension)/volume*np)
        end
        for i in A,j in B
            same && j<=i && continue
            d=_at_distance(s,s.positions[i],s.positions[j])
            _at_finite(d) && d>=zero(d) || return unknown("Invalid computed pair distance.")
            first(e)<=d<=last(e) || continue
            k=min(searchsortedlast(e,d),length(counts))
            counts[k]+=1
        end
        nf+=1
        push!(populations,(total=length(s.positions),central=length(A),neighbor=length(B),same=same))
        push!(pairs,np)
    end
    nf>0 || return unknown("No frames selected.")
    all(x->isfinite(x) && x>0,expected) || return unknown("No eligible pairs or invalid expected shell counts.")
    result(_at_observed(counts./expected;method=:streaming_pair_histogram,notes=copy(notes)))
end
