"""Single-origin displacement; finite observations, not a diffusion certificate."""
struct MeanSquaredDisplacement <: AbstractAnalysis
    sampling
    times
    values::PropertyResult
    dimensions::Int
    particle_count::Int
    origin_count::Int
    species
    coordinate_semantics::Symbol
    method::Symbol
    notes::Vector{String}
end

_tr_fixed(t,assertion)=assertion || get(t.provenance,:fixed_particles,nothing)==:caller_asserted
function _tr_particles(s,species)
    species===nothing && return collect(eachindex(s.positions))
    s.species===nothing && return nothing
    length(s.species)==length(s.positions) || return nothing
    findall(==(species),s.species)
end
function _tr_same_particles(s,firstframe,indices,species)
    s.dimension==firstframe.dimension && length(s.positions)==length(firstframe.positions) &&
        _tr_particles(s,species)==indices
end

"""
    mean_squared_displacement(t; coordinates=:auto, fixed_particles=false, species=nothing, ...)

Single-origin particle mean of squared Cartesian displacement from frame 1.
O(frames*selected_particles*dimension) work, O(selected_particles*dimension + frames)
storage; only the origin coordinates are copied. Requires fixed particle ordering
asserted by caller/provenance. `:auto` admits open coordinates only. `:unwrapped`
is a caller assertion that supplied positions are trustworthy continuous images;
no minimum-image reconstruction from undersampled wrapped positions is attempted.
Explicit irregular times are supported for this single-origin statistic.
Time options are forwarded to `sampling_info`, never inferred from coordinates.
"""
function mean_squared_displacement(t::AtomisticTrajectoryView;coordinates=:auto,
        fixed_particles=false,species=nothing,time_options=NamedTuple())
    coordinates in (:auto,:unwrapped,:wrapped) || throw(ArgumentError("coordinates must be :auto, :unwrapped or :wrapped"))
    sampling=sampling_info(t;time_options...)
    dim=0; np=0
    result(p,times=nothing)=MeanSquaredDisplacement(sampling,times,p,dim,np,1,species,coordinates,
        :single_origin,["Fixed particle identity/order is a caller assertion; no unwrapping inferred.",
        "Single-origin particle average; no automatic diffusion regime or independent origins."])
    unknown(note)=result(_at_unknown(note))
    sampling.times===nothing && return unknown("Explicit time or declared interval/index time required.")
    length(t)>0 || return unknown("No frames.")
    _tr_fixed(t,fixed_particles) || return unknown("Explicit fixed_particles=true or equivalent provenance required.")
    coordinates==:wrapped && return unknown("Wrapped coordinates cannot establish displacement history.")
    firstframe=t[1]; dim=firstframe.dimension
    _at_positions_ok(firstframe) || return unknown("Finite Cartesian coordinates required.")
    indices=_tr_particles(firstframe,species)
    indices===nothing && return unknown("Species unavailable.")
    np=length(indices); np>0 || return unknown("Empty particle selection.")
    coordinates==:auto && _at_kind(firstframe)!=:open && return unknown("Periodic/unknown image history; supply trustworthy unwrapped coordinates explicitly.")
    origin=[copy(collect(firstframe.positions[i])) for i in indices]
    values=Any[]
    for f in 1:length(t)
        s=f==1 ? firstframe : t[f]
        _at_positions_ok(s) && _tr_same_particles(s,firstframe,indices,species) || return unknown("Particle count, dimension, selection or coordinates changed.")
        coordinates==:auto && _at_kind(s)!=:open && return unknown("Periodic frame lacks explicit unwrapped semantics.")
        value=sum(sum(abs2,collect(s.positions[i]).-origin[k]) for (k,i) in enumerate(indices))/np
        _at_finite(value) || return unknown("Nonfinite squared displacement.")
        push!(values,value)
    end
    times=sampling.times .- first(sampling.times)
    T=mapreduce(typeof,promote_type,values)
    result(_at_observed(T[x for x in values];method=:single_origin),times)
end

"""Fit an explicitly selected time interval: MSD = intercept + 2*d*D*t.
No OLS uncertainty is reported: MSD points/origins are correlated. The caller must
justify a diffusive regime independently. A finite positive slope is not proof of it.
"""
function diffusion_estimate(m::MeanSquaredDisplacement;fit_window=nothing)
    fit_window===nothing && return _at_unknown("Diffusion requires an explicit physically justified fit_window.")
    m.values.value===nothing && return _at_unknown("MSD unavailable.")
    m.dimensions>0 || return _at_unknown("Positive spatial dimension required.")
    fit_window isa Tuple && length(fit_window)==2 || throw(ArgumentError("fit_window must be (start,stop)"))
    a,b=fit_window
    all(_at_finite,(a,b)) && a<b || return _at_unknown("Fit window must have finite positive span.")
    indices=findall(x->a<=x<=b,m.times)
    length(indices)>=3 || return _at_unknown("At least three selected MSD points required.")
    x=m.times[indices]; y=m.values.value[indices]
    all(_at_finite,x) && all(_at_finite,y) || return _at_unknown("Finite fit data required.")
    mx=sum(x)/length(x); my=sum(y)/length(y)
    xx=sum(abs2,z-mx for z in x)
    xx>zero(xx) || return _at_unknown("Zero time span.")
    slope=sum((x[i]-mx)*(y[i]-my) for i in eachindex(x))/xx
    intercept=my-slope*mx
    residuals=[y[i]-(intercept+slope*x[i]) for i in eachindex(x)]
    all(_at_finite,(slope,intercept)) && all(_at_finite,residuals) || return _at_unknown("Nonfinite regression arithmetic.")
    slope>=zero(slope) || return _at_unknown("Negative fitted slope cannot estimate nonnegative diffusion.")
    _at_observed((diffusion=slope/(2m.dimensions),slope=slope,intercept=intercept,
        dimensions=m.dimensions,fit_window=fit_window,selected_interval=(first(x),last(x)),indices=indices,
        points=length(x),residuals=residuals,rms_residual=sqrt(sum(abs2,residuals)/length(x)),
        standard_error=_at_unknown("Correlated MSD points: no independent-residual OLS error bar."),
        units=_at_unit(slope));method=:explicit_window_least_squares,
        notes=["Caller-selected putative diffusive interval; no automatic regime identification.",
               "Finite-sample estimate, not an established transport coefficient."])
end

"""Particle/origin-averaged dot-product VACF; velocities are not mean-centered."""
struct VelocityAutocorrelation <: AbstractAnalysis
    sampling
    lags
    lag_times
    raw::PropertyResult
    normalized::PropertyResult
    origin_counts
    particle_count::Int
    dimensions::Int
    species
    method::Symbol
    notes::Vector{String}
end
"""
    velocity_autocorrelation(t; maxlag=min(length(t)-1,128), normalize=false, ...)

C(k) = sum(v_i(j) dot v_i(j+k))/(selected_particles*(frames-k)).
Bounded direct lags: O(frames*maxlag*particles*dimension) work, O(frames*selected
particles*dimension) velocity-only history. No coordinates/snapshots are copied.
Uniform known sampling and fixed particle identity/order required; no fabricated
velocities. Normalization is C(k)/C(0), not fluctuation autocorrelation.
"""
function velocity_autocorrelation(t::AtomisticTrajectoryView;maxlag=min(max(length(t)-1,0),128),
        normalize=false,species=nothing,fixed_particles=false,time_options=NamedTuple())
    sampling=sampling_info(t;time_options...); np=0; dim=0
    result(raw,norm,lags=Int[],times=nothing,counts=Int[])=VelocityAutocorrelation(sampling,lags,times,raw,norm,counts,np,dim,species,
        :bounded_direct_dot_product,["No velocity mean subtraction; correlated origins are not independent experiments."])
    unknown(note)=result(_at_unknown(note),_at_unknown(note))
    sampling.regularity==:regular || return unknown("Uniform known sampling with at least two frames required.")
    _tr_fixed(t,fixed_particles) || return unknown("Fixed particle ordering must be explicitly asserted.")
    n=length(t)
    maxlag isa Integer && 0<=maxlag<n || throw(ArgumentError("maxlag must be in 0:frames-1"))
    firstframe=t[1];dim=firstframe.dimension
    indices=_tr_particles(firstframe,species)
    indices===nothing && return unknown("Species unavailable.")
    np=length(indices);np>0 || return unknown("Empty particle selection.")
    history=Vector{Any}(undef,n)
    for f in 1:n
        s=f==1 ? firstframe : t[f]
        _tr_same_particles(s,firstframe,indices,species) && _at_velocities_ok(s) || return unknown("Finite, aligned historical velocities required.")
        history[f]=[copy(collect(s.velocities[i])) for i in indices]
    end
    lags=collect(0:maxlag); counts=n .- lags
    raw=[sum(LinearAlgebra.dot(history[j][i],history[j+k][i]) for j in 1:n-k for i in 1:np)/(np*(n-k)) for k in lags]
    all(_at_finite,raw) || return unknown("Nonfinite velocity products.")
    norm=normalize ? (first(raw)>zero(first(raw)) ? _at_observed(raw./first(raw);method=:zero_lag_normalization) :
        _at_unknown("Zero velocity variance/mean square: normalized VACF unavailable.")) : PropertyResult(nothing,:not_requested,:not_requested,String[])
    result(_at_observed(raw;method=:bounded_direct_dot_product),norm,lags,lags.*sampling.interval,counts)
end
