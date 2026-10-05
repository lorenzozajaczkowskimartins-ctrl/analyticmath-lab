"""
    observable_series(path::TrajectoryResult; component=nothing, observable=nothing,
                      name=:observable, context=NamedTuple())

Select exactly one state component (integer index or unique source label), or a
scalar callable `observable(u,t)`. Labels identify stored coordinates; they do not
establish units or particle identities. Callables receive a copy of each state.

Copies saved times and extracted values in their original order; never calls the
native interpolant, sorts, resamples, or drops samples. Backward/duplicate times
are refused because SamplingInfo requires increasing times. Partial solutions
are allowed, with their unchanged diagnostics retained. Numeric units remain
unknown; Unitful observable values retain units. Mixed known/unknown units or
incompatible dimensions are refused. Source, domain, state labels,
selector and caller context are retained in provenance (read-only by convention).
No reference truth or continuum claim follows from these sampled observations.
"""
function observable_series(path::TrajectoryResult;component=nothing,observable=nothing,
        name=:observable,context=NamedTuple())
    (component===nothing) != (observable===nothing) ||
        throw(ArgumentError("select exactly one component or scalar observable(u,t)"))
    path.problem isa FirstOrderODE || throw(ArgumentError("a FirstOrderODE trajectory is required; no state layout is inferred"))
    name isa Symbol || throw(ArgumentError("observable name must be a Symbol"))
    solution=path.solution
    hasproperty(solution,:t) && hasproperty(solution,:u) ||
        throw(ArgumentError("trajectory must retain saved times and states"))
    times=collect(solution.t); states=solution.u
    length(times)==length(states) || throw(DimensionMismatch("saved times and states must align"))
    isempty(times) && throw(ArgumentError("trajectory has no saved samples"))
    length(path.labels)==path.problem.dimension || throw(DimensionMismatch("state labels must match the ODE dimension"))
    all(u->u isa AbstractVector && length(u)==path.problem.dimension,states) ||
        throw(DimensionMismatch("each saved state must match the ODE dimension"))
    # Validate before evaluating a user observable, without weakening time semantics.
    sampling_info(length(times);times)
    index=component
    if component!==nothing
        if component isa Union{Symbol,AbstractString}
            matches=findall(==(string(component)),string.(path.labels))
            length(matches)==1 || throw(ArgumentError("component label must identify exactly one stored coordinate"))
            index=only(matches)
        end
        index isa Integer && !(index isa Bool) && 1<=index<=path.problem.dimension ||
            throw(ArgumentError("component must be a valid state index or unique source label"))
    else
        applicable(observable,copy(first(states)),first(times)) ||
            throw(ArgumentError("observable must accept (state,time) and return one finite real scalar"))
    end
    values=[component===nothing ? observable(copy(u),t) : u[index] for (u,t) in zip(states,times)]
    all(_ts_valid,values) || throw(ArgumentError("selected observations must be finite real scalars; no samples are dropped"))
    quantity=first(values) isa Unitful.AbstractQuantity
    all(v->(v isa Unitful.AbstractQuantity)==quantity,values) ||
        throw(ArgumentError("observable cannot mix unit-bearing values with unknown unitless values"))
    if quantity
        dimension=Unitful.dimension(first(values))
        all(v->Unitful.dimension(v)==dimension,values) ||
            throw(ArgumentError("observable units must have compatible dimensions across saved samples"))
    end
    selection=(component=index,label=component===nothing ? nothing : path.labels[index],observable=observable)
    provenance=(source=path,context=context,selection=selection,state_labels=path.labels,
        domain=path.problem.domain,diagnostics=path.diagnostics,sampling=:stored,resampling=:none)
    ObservableSeries(values;times,name,provenance)
end
