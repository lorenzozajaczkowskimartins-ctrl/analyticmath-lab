"""Bind an already-computed M8B result to metadata it does not itself retain.

`series` supplies observable identity/sampling/provenance, never observations for
recomputation. `parent` supplies the stored autocorrelation or MSD used upstream.
These associations are caller assertions, not reconstructed lineage. `selection`
is an explicit particle-population identity token for transport comparisons.
Inputs and their arrays are borrowed read-only; labels never imply independence.
"""
struct ComparisonInput{R,S,P,L,I} <: AbstractAnalysis
    result::R
    series::S
    parent::P
    label::L
    selection::I
end
ComparisonInput(result;series=nothing,parent=nothing,label=nothing,selection=nothing)=
    ComparisonInput(result,series,parent,label,selection)

"""Compatibility is :compatible, :incompatible, or :unknown, separately from evidence.
Each named check is a PropertyResult(true/false/nothing); reasons retain failures
and unresolved checks. An established compatibility is not physical certification.
"""
struct ComparisonCompatibility <: AbstractAnalysis
    status::Symbol
    checks::Dict{Symbol,PropertyResult}
    reasons::Vector{String}
end

"""Stored descriptive B − A, with separate uncertainty and retained input identities."""
struct ObservableComparison{A,B,M,D,U,S} <: AbstractAnalysis
    a::A
    b::B
    quantity::Symbol
    compatibility::ComparisonCompatibility
    metadata::M
    difference::D
    uncertainty::U
    assumptions::S
    notes::Vector{String}
end

_cmp_check(value,note)=PropertyResult(value,value===nothing ? :unknown : :established,
    :stored_metadata,[note])
_cmp_equal(a,b,note)=_cmp_check(a===nothing || b===nothing ? nothing : isequal(a,b),note)
function _cmp_compatibility(checks)
    vals=[p.value for p in values(checks)]
    status=any(==(false),filter(!isnothing,vals)) ? :incompatible :
        any(isnothing,vals) ? :unknown : :compatible
    reasons=["$(k): $(join(v.notes," "))" for (k,v) in sort!(collect(checks);by=first) if v.value!==true]
    ComparisonCompatibility(status,checks,reasons)
end
_cmp_values(x)=x isa AbstractArray ? x : (x,)
function _cmp_units(a,b;unitless=false)
    (a===nothing || b===nothing) && return _cmp_check(nothing,"Stored values unavailable.")
    xs,ys=_cmp_values(a),_cmp_values(b)
    (isempty(xs) || isempty(ys) || !all(_at_finite,xs) || !all(_at_finite,ys)) &&
        return _cmp_check(nothing,"Need finite available stored values.")
    ax=all(x->x isa Unitful.AbstractQuantity,xs)
    by=all(y->y isa Unitful.AbstractQuantity,ys)
    ax!=by && return _cmp_check(nothing,"One side lacks explicit units; no conversion scale is known.")
    dims=map(Unitful.dimension,(first(xs),first(ys)))
    dims[1]==dims[2] || return _cmp_check(false,"Physical dimensions differ.")
    all(x->Unitful.dimension(x)==dims[1],xs) && all(y->Unitful.dimension(y)==dims[2],ys) ||
        return _cmp_check(false,"Inconsistent dimensions within stored values.")
    physical=ax && by
    _cmp_check(physical || unitless ? true : nothing,
        physical ? "Compatible Unitful dimensions; subtraction converts B to A units." :
        unitless ? "Caller declares shared unitless/reduced-unit meaning." : "Physical units unknown; no common scale inferred.")
end

function _cmp_descriptor(i::ComparisonInput,q)
    r=i.result; s=i.series
    identity=s===nothing ? nothing : s.name==:observable ? nothing : s.name
    sampling=s===nothing ? nothing : s.sampling
    value=nothing; estimator=nothing; grid=nothing; se=nothing; ue=nothing; reference=nothing
    timed=false; spaced=false; dimensionless=false; selected=false; semantics=nothing
    evidence=r isa PropertyResult ? r : _ts_unknown("Unsupported stored result.")
    if r isa PropertyResult && r.method==:welford
        q=q==:auto ? :mean : q
        q in (:count,:mean,:variance,:std,:minimum,:maximum) || throw(ArgumentError("Unsupported summary quantity"))
        value=r.value===nothing ? nothing : getproperty(r.value,q)
        reference=r.value===nothing ? nothing : r.value.mean
        estimator=(:welford,q)
        dimensionless=q==:count
    elseif r isa AutocorrelationAnalysis
        q=q==:auto ? :autocorrelation : q
        q in (:autocorrelation,:autocovariance) || throw(ArgumentError("Unsupported correlation quantity"))
        sampling=r.sampling; grid=r.lag_times; timed=true; spaced=true
        value=getproperty(r,q); evidence=r.evidence
        reference=r.autocovariance
        estimator=(r.method,r.normalization,r.lags,q)
        dimensionless=q==:autocorrelation
    elseif r isa BlockAnalysis
        q=q==:auto ? :standard_errors : q
        q in (:standard_errors,:variances,:block_counts,:discarded) || throw(ArgumentError("Unsupported block quantity"))
        sampling=r.sampling; grid=r.block_sizes; spaced=true; timed=true
        value=getproperty(r,q); evidence=r.evidence
        firstblock=findfirst(!isempty,r.block_means)
        reference=firstblock===nothing ? nothing : first(r.block_means[firstblock])
        estimator=(:nonoverlapping_blocks,r.block_sizes,q)
        dimensionless=q in (:block_counts,:discarded)
    elseif r isa PropertyResult && r.method==:windowed_autocorrelation && r.value!==nothing
        q=q==:auto ? :mean : q
        q in (:mean,:std,:standard_error,:tau_int,:effective_samples,:count) || throw(ArgumentError("Unsupported correlated-mean quantity"))
        v=r.value; ac=v.correlation; tau=v.integration
        sampling=ac.sampling; value=getproperty(v,q)
        reference=v.mean
        ue=(ac.method,ac.normalization,ac.lags,tau.method,tau.value.window)
        estimator=q in (:mean,:std,:count) ? (:welford,q) : ue
        q==:mean && (se=v.standard_error)
        timed=spaced=q in (:tau_int,:effective_samples,:standard_error)
        dimensionless=q in (:tau_int,:effective_samples,:count)
    elseif r isa PropertyResult && r.method in (:explicit_window,:initial_positive_lags) && r.value!==nothing
        q=q==:auto ? :tau : q
        q in (:tau,:raw_tau,:physical_tau) || throw(ArgumentError("Unsupported IAT quantity"))
        value=getproperty(r.value,q); timed=true; spaced=true
        ac=i.parent
        if ac isa AutocorrelationAnalysis
            sampling=ac.sampling
            reference=ac.autocovariance
            estimator=(ac.method,ac.normalization,ac.lags,r.method,r.value.window,q)
            if q==:physical_tau && sampling.units=="sample index"
                value=nothing; evidence=_ts_unknown("Physical tau unavailable for index time.")
            end
        end
        dimensionless=q!=:physical_tau
    elseif r isa MeanSquaredDisplacement
        q=q==:auto ? :msd : q
        q==:msd || throw(ArgumentError("MSD quantity must be :msd"))
        identity=:position_displacement; sampling=r.sampling; grid=r.times
        timed=true; selected=true; value=r.values.value; evidence=r.values
        estimator=(r.method,r.origin_count)
        semantics=(dimensions=r.dimensions,particles=r.particle_count,species=r.species,
            coordinates=r.coordinate_semantics)
    elseif r isa VelocityAutocorrelation
        q=q==:auto ? :raw : q
        q in (:raw,:normalized) || throw(ArgumentError("VACF quantity must be :raw or :normalized"))
        identity=:velocity_dot_product; sampling=r.sampling; grid=r.lag_times
        timed=true; spaced=true; selected=true
        evidence=getproperty(r,q); value=evidence.value; dimensionless=q==:normalized
        reference=r.raw.value
        estimator=(r.method,r.lags,q,:all_overlapping_origins)
        semantics=(dimensions=r.dimensions,particles=r.particle_count,species=r.species)
    elseif r isa PropertyResult && r.method==:explicit_window_least_squares && r.value!==nothing
        q=q==:auto ? :diffusion : q
        q in (:diffusion,:slope,:intercept,:rms_residual) || throw(ArgumentError("Unsupported diffusion quantity"))
        identity=:position_displacement; timed=true; selected=true
        value=getproperty(r.value,q)
        m=i.parent
        if m isa MeanSquaredDisplacement
            sampling=m.sampling
            estimator=(r.method,r.value.dimensions,r.value.fit_window,r.value.selected_interval,m.method,m.origin_count,q)
            semantics=(dimensions=m.dimensions,particles=m.particle_count,species=m.species,
                coordinates=m.coordinate_semantics)
        end
    end
    if r isa PropertyResult && r.method==:initial_reference_deviations && r.value!==nothing
        q=q==:auto ? :maximum_absolute : q
        q in (:maximum_absolute,:maximum_relative,:rms,:linear_slope) || throw(ArgumentError("Unsupported deviation quantity"))
        v=r.value; value=getproperty(v,q)
        reference=v.rms
        q==:linear_slope && (evidence=value; value=value.value; timed=true)
        estimator=(r.method,q)
        firstdelta=isempty(v.deviations) ? nothing : first(v.deviations)
        semantics=(vector_dimension=firstdelta isa AbstractVector ? length(firstdelta) : 0,)
        dimensionless=q==:maximum_relative
    elseif r isa PropertyResult && r.method==:early_late_shift && r.value!==nothing
        q=q==:auto ? :mean_shift : q
        q in (:mean_shift,:pooled_fluctuation,:suggested_start,:suggested_time) || throw(ArgumentError("Unsupported transient quantity"))
        value=getproperty(r.value,q)
        identity=r.value.observable==:observable ? nothing : r.value.observable
        reference=r.value.pooled_fluctuation
        estimator=sampling===nothing ? nothing : (r.method,r.value.threshold,sampling.count,q)
        timed=true; spaced=true; dimensionless=q==:suggested_start
    end
    estimator!==nothing && semantics===nothing && (semantics=NamedTuple())
    (identity=identity,sampling=sampling,quantity=q,value=value,grid=grid,
        estimator=estimator,evidence=evidence,se=se,uncertainty_estimator=ue,
        time_required=timed,interval_required=spaced,dimensionless=dimensionless,
        selection_required=selected,selection=i.selection,semantics=semantics,
        unit_reference=reference===nothing ? value : reference)
end

function _cmp_shape(x,y)
    (x.value===nothing || y.value===nothing) && return _cmp_check(nothing,"Stored values unavailable.")
    for d in (x,y)
        if d.value isa AbstractArray
            d.grid!==nothing && length(d.grid)==length(d.value) ||
                return _cmp_check(false,"Curve values must match their stored grid; no truncation.")
        end
    end
    _cmp_check(size(x.value)==size(y.value),"Stored value shapes must agree; no truncation.")
end

function _cmp_context(i,d)
    s=i.series
    s===nothing && return _cmp_check(true,"No additional series context supplied.")
    if d.sampling!==nothing
        t=d.sampling
        s.sampling.count==t.count || return _cmp_check(false,"Series/result sample counts conflict.")
        if s.sampling.times!==nothing && t.times!==nothing
            isequal(s.sampling.times,t.times) && (s.sampling.units=="sample index")==(t.units=="sample index") ||
                return _cmp_check(false,"Series/result clocks conflict.")
        elseif s.sampling.times!==t.times
            return _cmp_check(nothing,"Series/result time association unresolved.")
        end
    end
    r=i.result
    if r isa PropertyResult && r.value!==nothing
        hasproperty(r.value,:count) && r.value.count!=s.sampling.count &&
            return _cmp_check(false,"Series/result sample counts conflict.")
        hasproperty(r.value,:observable) && r.value.observable!=s.name &&
            return _cmp_check(false,"Series/result observable identities conflict.")
    end
    _cmp_check(true,"Consistent stored metadata; lineage association remains caller-asserted.")
end

_cmp_unit(x)=x===nothing || isempty(_cmp_values(x)) ? nothing :
    first(_cmp_values(x)) isa Unitful.AbstractQuantity ? Unitful.unit(first(_cmp_values(x))) : nothing

function _cmp_time(a,b;unitless_time=false,interval=false)
    (a===nothing || b===nothing || a.times===nothing || b.times===nothing) &&
        return _cmp_check(nothing,"Time metadata unavailable.")
    ia,ib=a.units=="sample index",b.units=="sample index"
    ia!=ib && return _cmp_check(false,"Index time and explicit time cannot be equated.")
    (isempty(a.times) || isempty(b.times)) && return _cmp_check(nothing,"Empty time grid.")
    u=_cmp_units(first(a.times),first(b.times);unitless=ia || unitless_time)
    u.value===true || return u
    if !ia && first(a.times) isa Unitful.AbstractQuantity
        Unitful.dimension(first(a.times))==Unitful.dimension(1*Unitful.u"s") ||
            return _cmp_check(false,"Explicit clock does not have time dimensions.")
    end
    interval && return _cmp_equal(a.interval,b.interval,"Saved-sample intervals must match for this estimator.")
    _cmp_check(true,ia ? "Explicit sample-index semantics." : "Compatible explicit time scales.")
end

function _cmp_series_semantics(a,b)
    (a===nothing || b===nothing) && return _cmp_check(nothing,"Observable context missing.")
    for key in (:component,:temperature_convention,:dof,:boltzmann,:selection,:normalization)
        x,y=get(a.provenance,key,nothing),get(b.provenance,key,nothing)
        x===nothing && y===nothing && continue
        p=_cmp_equal(x,y,"Observable convention $(key) must agree.")
        p.value===true || return p
    end
    _cmp_check(true,"No conflicting stored observable conventions.")
end

_cmp_convert(b,a)=a isa Unitful.AbstractQuantity ? Unitful.uconvert(Unitful.unit(a),b) : b
function _cmp_difference(a,b)
    value=a isa AbstractArray ? [_cmp_convert(y,x)-x for (x,y) in zip(a,b)] : _cmp_convert(b,a)-a
    all(_at_finite,_cmp_values(value)) ? PropertyResult(value,:heuristic,:stored_difference,
        ["Descriptive B - A; not statistical significance or a quality ranking."]) :
        _ts_unknown("Nonfinite difference.";method=:stored_difference)
end

"""
    compare(a::ComparisonInput, b::ComparisonInput; quantity=:auto,
            independence=:unknown, unitless=false)

Compare stored results only. Unknown physical units require explicit `unitless=true`
(shared numeric/reduced-unit scale). No independence, alignment, dynamics or missing
analysis is inferred. The orientation is always B − A; no relative percentages.
"""
function compare(a::ComparisonInput,b::ComparisonInput;quantity=:auto,
        independence=:unknown,unitless=false,unitless_time=false)
    independence in (:unknown,:independent) || throw(ArgumentError("independence must be :unknown or :independent"))
    qa,qb=quantity isa Tuple && length(quantity)==2 ? quantity : (quantity,quantity)
    x,y=_cmp_descriptor(a,qa),_cmp_descriptor(b,qb)
    checks=Dict{Symbol,PropertyResult}(
        :observable=>_cmp_equal(x.identity,y.identity,"Observable identity must be known and equal."),
        :quantity=>_cmp_equal(x.quantity==:auto ? nothing : x.quantity,y.quantity==:auto ? nothing : y.quantity,"Selected quantities must agree."),
        :estimator=>_cmp_equal(x.estimator,y.estimator,"Stored estimator definitions must agree."),
        :units=>_cmp_units(x.value,y.value;unitless=unitless || (x.dimensionless && y.dimensionless)))
    if x.selection_required || y.selection_required
        checks[:selection]=_cmp_equal(x.selection,y.selection,"Particle population correspondence requires explicit equal selection tokens.")
    else
        checks[:observable_conventions]=_cmp_series_semantics(a.series,b.series)
    end
    checks[:semantics]=_cmp_equal(x.semantics,y.semantics,"Coordinate, vector, selection and diagnostic semantics must agree.")
    checks[:shape]=_cmp_shape(x,y)
    checks[:context_a]=_cmp_context(a,x)
    checks[:context_b]=_cmp_context(b,y)
    checks[:observable_units]=_cmp_units(x.unit_reference,y.unit_reference;
        unitless=unitless || (x.dimensionless && y.dimensionless))
    if x.time_required || y.time_required
        checks[:time]=_cmp_time(x.sampling,y.sampling;unitless_time,
            interval=x.interval_required || y.interval_required)
    end
    if x.grid!==nothing || y.grid!==nothing
        checks[:grid]=_cmp_equal(x.grid,y.grid,"Pointwise grids must match exactly after unit conversion; no alignment.")
    end
    checks[:evidence]=_cmp_check(x.evidence.status in (:established,:heuristic) &&
        y.evidence.status in (:established,:heuristic) ? true : nothing,"Both input estimates must be available.")
    compatibility=_cmp_compatibility(checks)
    difference=compatibility.status==:compatible ? _cmp_difference(x.value,y.value) :
        _ts_unknown("Compatibility not established.";method=:stored_difference)
    uncertainty=_ts_unknown("No justified combined standard error available.";method=:uncertainty_propagation)
    if difference.value!==nothing && independence==:independent && a.result!==b.result &&
            x.se!==nothing && y.se!==nothing &&
            _cmp_units(x.se,y.se;unitless).value===true &&
            _cmp_equal(x.uncertainty_estimator,y.uncertainty_estimator,"Uncertainty estimators").value===true &&
            _cmp_time(x.sampling,y.sampling;unitless_time,interval=true).value===true
        error=sqrt(x.se^2+_cmp_convert(y.se,x.se)^2)
        _at_finite(error) && (uncertainty=PropertyResult(error,:heuristic,:independent_standard_errors,
            ["Caller asserts independent estimators; stored stationarity/window assumptions still apply."]))
    end
    conversion=(a=_cmp_unit(x.value),b=_cmp_unit(y.value),target=_cmp_unit(x.value),
        applied=difference.value!==nothing && _cmp_unit(x.value)!==nothing,
        method=_cmp_unit(x.value)===nothing ? :no_unit_conversion : :unitful_to_reference)
    ObservableComparison(a,b,x.quantity,compatibility,(a=x,b=y,conversion=conversion),difference,uncertainty,
        (independence=independence,unitless=unitless,unitless_time=unitless_time),
        ["Inputs retain original evidence and provenance; no hidden recomputation.",
         "Standard deviation is not a standard error; no significance or equilibrium claim."])
end
compare(a::Union{PropertyResult,AutocorrelationAnalysis,BlockAnalysis,MeanSquaredDisplacement,VelocityAutocorrelation},
        b::Union{PropertyResult,AutocorrelationAnalysis,BlockAnalysis,MeanSquaredDisplacement,VelocityAutocorrelation};kwargs...)=
    compare(ComparisonInput(a),ComparisonInput(b);kwargs...)

"""A selective composition of two stored reports, never an ensemble score."""
struct MDTrajectoryComparison{A,B,L,C,S} <: AbstractAnalysis
    a::A
    b::B
    labels::L
    components::C
    assumptions::S
    notes::Vector{String}
end

"""
    compare_runs(a, b; components=(:summaries, :correlations, :deviations,
                 :transients, :msd, :vacf, :diffusion), labels=(nothing,nothing),
                 selections=(nothing,nothing), kwargs...)

Consume stored MDTrajectoryAnalysis only. Named component maps use the union of
stored keys, but observable identity comes from each ObservableSeries, NOT its map
key. Missing components remain unknown. `selections` supplies explicit population
identity tokens for transport; identical particle counts do not establish identity.
Each component compares its documented default quantity; use ComparisonInput and
`compare` for other quantities. No missing M8B analysis is computed here.
"""
function compare_runs(a::MDTrajectoryAnalysis,b::MDTrajectoryAnalysis;
        components=(:summaries,:correlations,:deviations,:transients,:msd,:vacf,:diffusion),
        labels=(nothing,nothing),selections=(nothing,nothing),kwargs...)
    length(labels)==2 && length(selections)==2 || throw(ArgumentError("Two labels and selections required"))
    all(c->c in (:summaries,:correlations,:deviations,:transients,:msd,:vacf,:diffusion),components) ||
        throw(ArgumentError("Unsupported stored component"))
    result=Dict{Symbol,Union{ObservableComparison,Dict{Symbol,ObservableComparison}}}()
    for component in components
        x,y=getproperty(a,component),getproperty(b,component)
        if x isa AbstractDict
            pairs=Dict{Symbol,ObservableComparison}()
            for name in union(keys(x),keys(y))
                left=ComparisonInput(get(x,name,nothing);series=get(a.observables,name,nothing),label=labels[1])
                right=ComparisonInput(get(y,name,nothing);series=get(b.observables,name,nothing),label=labels[2])
                pairs[name]=compare(left,right;kwargs...)
            end
            result[component]=pairs
        else
            left=ComparisonInput(x;parent=component==:diffusion ? a.msd : nothing,label=labels[1],selection=selections[1])
            right=ComparisonInput(y;parent=component==:diffusion ? b.msd : nothing,label=labels[2],selection=selections[2])
            result[component]=compare(left,right;kwargs...)
        end
    end
    MDTrajectoryComparison(a,b,labels,result,(options=(;kwargs...),selections=selections),
        ["Only supplied stored results compared; missing is not zero.",
         "Component compatibility does not rank runs or establish equilibrium."])
end
compare(a::MDTrajectoryAnalysis,b::MDTrajectoryAnalysis;kwargs...)=compare_runs(a,b;kwargs...)
diagnose(c::MDTrajectoryComparison)=PropertyResult(c.components,:heuristic,:stored_comparison_composition,c.notes)
