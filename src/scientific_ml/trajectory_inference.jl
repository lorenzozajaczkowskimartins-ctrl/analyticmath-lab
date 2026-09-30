"""
    distance_observations(view::AtomisticTrajectoryView, (i,j); frames=1:length(view), name=:r, units=nothing)

Freeze one pair's scalar distances and actual saved times, retaining the original
view as provenance (not copying its trajectory). Orthorhombic boundaries use M8
minimum-image semantics, including the supplied backend distance callback.
Unknown times stay unknown. Unitful quantities are retained, never stripped.
`units` labels unitless values only; it does not convert coordinates.
"""
function distance_observations(view::AtomisticTrajectoryView,pair::Tuple;
        frames=1:length(view),name=:r,units=nothing)
    length(pair)==2 && all(i->i isa Integer && i>0,pair) && pair[1]!=pair[2] ||
        throw(ArgumentError("pair must contain two distinct positive particle indices"))
    ids=collect(frames)
    !isempty(ids) && all(i->i isa Integer && 1<=i<=length(view),ids) && all(>(0),diff(ids)) ||
        throw(ArgumentError("frames must be nonempty, increasing valid indices"))
    values=Any[]; saved_times=Any[]; metadata=Any[]; geometry=Symbol[]
    for k in ids
        s=view[k]
        _at_positions_ok(s) || throw(ArgumentError("finite consistently shaped positions required"))
        (_at_kind(s)==:open || _at_box_ok(s)) || throw(ArgumentError("unsupported boundary geometry"))
        all(i->i<=length(s.positions),pair) || throw(ArgumentError("pair index outside snapshot"))
        d=_at_distance(s,s.positions[pair[1]],s.positions[pair[2]])
        _at_finite(d) && d>=zero(d) || throw(ArgumentError("invalid pair distance"))
        t=view.times===nothing ? s.time : view.times[k]
        view.times===nothing || s.time===nothing || s.time==t ||
            throw(ArgumentError("snapshot time conflicts with trajectory time"))
        push!(values,d); push!(saved_times,t)
        push!(metadata,deepcopy((boundary=s.boundary,provenance=s.provenance)))
        push!(geometry,s.distance!==nothing ? :backend_distance : _at_kind(s)==:open ? :open : :minimum_image)
    end
    times=any(isnothing,saved_times) ? nothing : saved_times
    provenance=(source=view,pair=pair,frames=copy(ids),snapshots=metadata,geometry=geometry,
        frozen=true,time_source=view.times===nothing ? :snapshots : :trajectory)
    sample=sampling_info(length(ids);times,provenance)
    label=units===nothing || first(values) isa Unitful.AbstractQuantity ? _at_unit(first(values)) : units
    ObservableSeries(values,sample,name,label,provenance,:reject)
end

"""Convert a scalar saved-time series to frozen numeric inference observations.
Unknown/index time is rejected. Unitful inputs require explicit compatible
`time_scale`/`length_scale`; original quantities remain in `source_series`.
Scales divide the supplied numbers; units metadata records that coordinate map.
"""
function ObservationSet(s::ObservableSeries;time_scale=nothing,length_scale=nothing,
        weights=nothing,kind=:user_supplied,role=:fit)
    s.sampling.times!==nothing && s.sampling.units!="sample index" ||
        throw(ArgumentError("inference requires actual known times, not sample indices"))
    function numeric(xs,scale,label)
        scale===nothing && any(x->x isa Unitful.AbstractQuantity,xs) &&
            throw(ArgumentError("Unitful $label requires an explicit scale"))
        scale===nothing || (_at_finite(scale) && scale>zero(scale)) ||
            throw(ArgumentError("$label scale must be finite and positive"))
        [begin
            y=scale===nothing ? x : x/scale
            y isa Unitful.AbstractQuantity && Unitful.dimension(y)!=Unitful.NoDims &&
                throw(ArgumentError("$label scale has incompatible dimensions"))
            z=y isa Unitful.AbstractQuantity ? Unitful.ustrip(y) : y
            z isa Real && isfinite(z) || throw(ArgumentError("finite real $label required"))
            Float64(z)
        end for x in xs]
    end
    times=numeric(s.sampling.times,time_scale,:time)
    values=numeric(s.values,length_scale,:length)
    ObservationSet(times,reshape(values,1,:);variables=(s.name,),weights,kind,role,
        units=(time=s.sampling.units,length=s.units,time_scale=time_scale,length_scale=length_scale),
        provenance=(source_series=s,conversion=:explicit_scales,time_scale=time_scale,length_scale=length_scale))
end
