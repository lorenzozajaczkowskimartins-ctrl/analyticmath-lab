"""
    normal_modes(snapshot::AtomisticSnapshot; hessian=nothing, metadata=NamedTuple(), kwargs...)

Minimal particle-major Cartesian bridge to M7. Supply a finite symmetric Cartesian
energy Hessian at the snapshot; no Hessian estimation or equilibrium certification
is attempted. Without a Hessian or compatible masses the result is unknown.

All M7 numerical fields use explicit scales stored in metadata: coordinates in
`length_scale`, masses in `mass_scale`, stiffness in `stiffness_scale`, frequencies
in `frequency_scale = sqrt(stiffness_scale/mass_scale)`. Unitful values are converted
before stripping, including molar mass/energy conventions. Physical angular
frequencies are also in `metadata.angular_frequencies` (not cycles per second).
Modes obey the M7 mass-orthonormal convention for the scaled mass matrix. This is a
local quadratic model at supplied coordinates, not proof they are an equilibrium.
"""
function normal_modes(s::AtomisticSnapshot;hessian=nothing,metadata=NamedTuple(),kwargs...)
    meta=merge(metadata,(coordinate_ordering=:particle_major_cartesian,
        coordinate_layout=(particles=length(s.positions),dimension=s.dimension),
        equilibrium_status=:not_verified,hessian_source=:caller_supplied))
    unknown(note)=_nm_unknown(hessian,nothing,nothing,meta,note;source=s)
    hessian===nothing && return unknown("Cartesian Hessian unavailable; no derivative or eigensolver invoked.")
    _at_positions_ok(s) && _at_masses_ok(s) && !isempty(s.positions) ||
        return unknown("Finite Cartesian coordinates and positive masses required.")
    n=length(s.positions)*s.dimension
    hessian isa AbstractMatrix && size(hessian)==(n,n) || throw(DimensionMismatch("Hessian must be Nd by Nd in particle-major order."))
    q=[x for p in s.positions for x in p]
    quantities=map(a->all(x->x isa Unitful.AbstractQuantity,a),(q,s.masses,hessian))
    plain=all(a->all(x->!(x isa Unitful.AbstractQuantity),a),(q,s.masses,hessian))
    all(quantities) || plain || return unknown("Coordinates, masses and Hessian must all have units or all be unitless.")
    ls,ms,ks=plain ? (1,1,1) : (oneunit(first(q)),oneunit(first(s.masses)),oneunit(first(hessian)))
    local qn,mn,kn,frequency_scale
    try
        if !plain
            Unitful.uconvert(Unitful.u"m",ls)
            md=Unitful.dimension(ms)
            md in (Unitful.dimension(1 * Unitful.u"kg"),Unitful.dimension(1 * Unitful.u"kg/mol")) ||
                return unknown("Mass units must be mass or molar mass.")
            Unitful.uconvert(Unitful.u"s^-2",ks/ms)
        end
        scale(x,u)=plain ? x : Unitful.ustrip(Unitful.NoUnits,x/u)
        qn=scale.(q,Ref(ls)); mn=scale.(s.masses,Ref(ms)); kn=scale.(hessian,Ref(ks))
        frequency_scale=plain ? 1 : sqrt(ks/ms)
    catch err
        err isa Union{Unitful.DimensionError,MethodError,DomainError} || rethrow()
        return unknown("Incompatible coordinate, mass or Hessian units.")
    end
    M=cartesian_mass_matrix(mn,s.dimension)
    meta=merge(meta,(length_scale=ls,mass_scale=ms,stiffness_scale=ks,frequency_scale=frequency_scale,
        units=plain ? :unknown : :explicit_scales))
    r=normal_modes(kn,M;equilibrium=qn,metadata=meta,kwargs...)
    physical=r.frequencies===nothing ? nothing : [ismissing(f) ? missing : f*frequency_scale for f in r.frequencies]
    meta=merge(r.metadata,(angular_frequencies=physical,))
    NormalModeAnalysis(s,r.equilibrium,r.mass_matrix,r.stiffness_matrix,r.eigenvalues,
        r.frequencies,r.mode_vectors,r.weighted_vectors,r.mass_sqrt,r.mass_inverse_sqrt,
        r.dynamical_matrix,r.normalization,r.representation,r.reconstruction,
        r.degeneracies,r.zero_modes,r.classifications,r.evidence,meta)
end
