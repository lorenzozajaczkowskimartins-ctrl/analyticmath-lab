"""
    ScientificDataset(path::TrajectoryResult; schema)

One completed FirstOrderODE simulation becomes one scalar-field surrogate sample.
This is not a generic simulation serializer. `schema` is an explicit NamedTuple:

- `family`, `id`, `input`, `input_names`: caller-defined model parameters in order;
- `coordinate_names=(:t,)`, `domain=(inputs=..., coordinates=...)`: saved numeric
  times are the sole query coordinate; bounds follow ScientificDataset contracts;
- `selection=(component=...,)` or `(observable=(u,t)->..., name=:...,)` selects the
  output through observable_series; exactly one selector is required;
- `split`: an existing supported split, never inferred (the dataset contract
  requires a training sample, so a standalone non-training run is refused);
- `reference=(kind=:numerical, description="...", error=:unknown)`: alternatively
  error may be `(estimate=nonnegative_number, method="...")`. This is a caller
  estimate, not a certificate; analytical/manufactured/exact labels are refused;
- `units=(inputs=(...,), coordinates=(...,), output=...)`: one string per input,
  one time-unit string, and an output-unit string. Use "unknown" where unavailable.
  These are caller declarations about numeric scales, NOT unit conversions;
- `grid=(sampling=:stored, resampling=:none)`, explicit `rng`, optional `context`.

Values and times must already be finite real nondimensionalized numeric data;
Unitful outputs are refused, not stripped. Solver/algorithm/tolerances/requested
span/saved grid/diagnostics are taken from the source, never the schema. Source
and selection are retained in dataset provenance, copied under the existing
ScientificDataset ownership contract. Unselected state values are not targets;
no particle meaning, uniform grid, split, rigorous error or physical truth inferred.
"""
function ScientificDataset(path::TrajectoryResult;schema=nothing)
    required=(:family,:id,:input,:input_names,:coordinate_names,:domain,:selection,
        :split,:reference,:units,:grid,:rng)
    schema isa NamedTuple && all(k->hasproperty(schema,k),required) ||
        throw(ArgumentError("explicit trajectory dataset schema required: $(required)"))
    all(k->k in (required...,:context),keys(schema)) || throw(ArgumentError("unsupported trajectory schema field"))
    schema.coordinate_names==(:t,) || throw(ArgumentError("this route supports only coordinate_names=(:t,) and stored times"))
    schema.input isa AbstractVector && schema.input_names isa Tuple ||
        throw(ArgumentError("input must be a vector with explicit ordered input_names"))
    length(schema.input)==length(schema.input_names) || throw(DimensionMismatch("one input per input name required"))
    schema.id isa Symbol && schema.split isa Symbol || throw(ArgumentError("sample id and explicit split must be Symbols"))
    schema.domain isa NamedTuple && hasproperty(schema.domain,:inputs) && hasproperty(schema.domain,:coordinates) ||
        throw(ArgumentError("explicit input and coordinate domain bounds required"))
    schema.domain.inputs isa AbstractMatrix && schema.domain.coordinates isa AbstractMatrix ||
        throw(DimensionMismatch("domain bounds must be matrices"))
    schema.grid==(sampling=:stored,resampling=:none) || throw(ArgumentError("only stored sampling with resampling=:none is supported"))
    schema.rng===nothing && throw(ArgumentError("explicit RNG provenance required, e.g. (kind=:deterministic,)"))
    reference=schema.reference
    reference isa NamedTuple && Set(keys(reference))==Set((:kind,:description,:error)) && reference.kind==:numerical ||
        throw(ArgumentError("simulation reference must be numerical with explicit description and error; solver success is not truth"))
    reference.description isa AbstractString && !isempty(strip(reference.description)) ||
        throw(ArgumentError("numerical source description must be nonempty"))
    error=reference.error
    error===:unknown || (error isa NamedTuple && Set(keys(error))==Set((:estimate,:method)) &&
        error.estimate isa Real && isfinite(error.estimate) && error.estimate>=0 &&
        error.method isa AbstractString && !isempty(strip(error.method))) ||
        throw(ArgumentError("reference error must be :unknown or a documented nonnegative estimate, never an exact-truth label"))
    units=schema.units
    units isa NamedTuple && Set(keys(units))==Set((:inputs,:coordinates,:output)) ||
        throw(ArgumentError("units must explicitly describe inputs, coordinates and output"))
    units.inputs isa Tuple && units.coordinates isa Tuple || throw(ArgumentError("ordered unit tuples required"))
    length(units.inputs)==length(schema.input) && length(units.coordinates)==1 || throw(DimensionMismatch("unit metadata must match schema ordering"))
    all(u->u isa AbstractString && !isempty(strip(u)),(units.inputs...,units.coordinates...,units.output)) ||
        throw(ArgumentError("use nonempty unit strings, or unknown; no unit inference is performed"))
    selection=schema.selection
    selection isa NamedTuple && all(k->k in (:component,:observable,:name),keys(selection)) ||
        throw(ArgumentError("selection must explicitly specify a component or observable(u,t), optionally a name"))
    diagnostics=path.diagnostics
    all(k->hasproperty(diagnostics,k),(:success,:completed,:algorithm,:abstol,:reltol)) ||
        throw(ArgumentError("source numerical diagnostics are required"))
    diagnostics.success===true && diagnostics.completed===true ||
        throw(ArgumentError("dataset route requires a completed successful solve; partial data remain available as an observable series"))
    hasproperty(path.solution,:prob) && hasproperty(path.solution.prob,:tspan) ||
        throw(ArgumentError("source must retain its requested integration span"))
    context=get(schema,:context,NamedTuple())
    series=observable_series(path;selection...,context)
    all(v->v isa Real && !(v isa Unitful.AbstractQuantity),series.values) ||
        throw(ArgumentError("dataset values must be explicitly nondimensionalized numeric scalars; units are never stripped"))
    sample=ScientificSample(schema.id,schema.input,reshape(series.sampling.times,1,:),series.values;split=schema.split)
    numerical=merge(reference,(solver=:SciMLBase,algorithm=diagnostics.algorithm,
        tolerances=(abstol=diagnostics.abstol,reltol=diagnostics.reltol),
        grid=copy(series.sampling.times),tspan=path.solution.prob.tspan,
        parameters=(names=schema.input_names,values=copy(schema.input)),
        diagnostics=diagnostics,error_interpretation=:caller_estimate_not_certificate))
    ScientificDataset([sample];kind=:surrogate,family=schema.family,
        input_names=schema.input_names,coordinate_names=schema.coordinate_names,
        domain=schema.domain,reference=numerical,units,grid=schema.grid,rng=schema.rng,
        provenance=(source=path,context=context,selection=series.provenance.selection,observable_name=series.name,
            state_labels=path.labels,domain=path.problem.domain,units_origin=:caller_declared,
            parameters_origin=:caller_declared,reference_quality=:numerical_not_truth))
end
