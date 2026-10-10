const _learning_splits = (:training,:interpolation,:parameter_extrapolation,
    :amplitude_extrapolation,:frequency_extrapolation,:coordinate_extrapolation)

"""Explicit row-wise affine scaling `(x-offset)/scale`, fitted on training IDs only.
Constant rows use scale=1. Inverse transformation is always available.
"""
struct AffineScaling
    offset::Vector{Float64}
    scale::Vector{Float64}
    fitted_ids::Vector{Symbol}
    field::Symbol
    function AffineScaling(offset,scale,fitted_ids,field)
        length(offset)==length(scale) || throw(DimensionMismatch("scaling offset/scale lengths differ"))
        o=_checked_float64.(collect(offset),Ref("scaling offset"))
        s=_checked_float64.(collect(scale),Ref("scaling scale"))
        !isempty(s) && all(>(0),s) || throw(ArgumentError("scaling scale must be finite and positive"))
        new(o,s,collect(Symbol,fitted_ids),field)
    end
end
function transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
    size(x,1)==length(s.offset) || throw(DimensionMismatch("scaling row count mismatch"))
    all(v->v isa Real && isfinite(v),x) || throw(ArgumentError("transform input must be finite and real"))
    all(v->isfinite(v) && v>0,s.scale) || throw(ArgumentError("scaling scale must be finite and positive"))
    y=broadcast(x .- s.offset,x ./ s.scale,s.offset ./ s.scale,s.scale) do delta,scaled,offset,scale
        isfinite(delta) ? delta/scale : scaled-offset
    end
    all(isfinite,y) || throw(ArgumentError("transformed values are not representable"))
    y
end
function inverse_transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
    size(x,1)==length(s.offset) || throw(DimensionMismatch("scaling row count mismatch"))
    all(v->v isa Real && isfinite(v),x) || throw(ArgumentError("inverse transform input must be finite and real"))
    all(v->isfinite(v) && v>0,s.scale) || throw(ArgumentError("scaling scale must be finite and positive"))
    y=muladd.(x,s.scale,s.offset)
    all(isfinite,y) || throw(ArgumentError("inverse transformed values are not representable"))
    y
end

"""One scalar output field, sampled at coordinate columns. Arrays are copied; read-only by convention.
`descriptor` is optional function-family metadata, never a training input or target.
"""
struct ScientificSample
    id::Symbol
    input::Vector{Float64}
    coordinates::Matrix{Float64}
    values::Vector{Float64}
    split::Symbol
    descriptor
    function ScientificSample(id,input,coordinates::AbstractMatrix,values;split,descriptor=nothing)
        split in _learning_splits || throw(ArgumentError("explicit supported split required"))
        size(coordinates,2)==length(values) || throw(DimensionMismatch("one scalar target per coordinate column"))
        !isempty(input) && !isempty(values) && size(coordinates,1)>0 || throw(ArgumentError("nonempty arrays required"))
        x=_checked_float64.(input,Ref("sample input"))
        q=_checked_float64.(coordinates,Ref("sample coordinates"))
        y=_checked_float64.(values,Ref("sample values"))
        all(isfinite,x) && all(isfinite,q) && all(isfinite,y) || throw(ArgumentError("finite representable data required"))
        new(Symbol(id),copy(x),q,copy(y),split,deepcopy(descriptor))
    end
end

"""Scientific problem family, not a generic table or an ObservationSet.
Scalar-field samples may have different query grids. Function inputs use one explicit fixed
sensor grid. Domain membership is descriptive, never a correctness guarantee.
"""
struct ScientificDataset
    samples::Vector{ScientificSample}
    kind::Symbol
    family
    input_names::Tuple
    coordinate_names::Tuple
    domain
    sensors
    reference
    units
    grid
    rng
    provenance
end

function _learning_bounds(b,n)
    size(b)==(n,2) || throw(DimensionMismatch("bounds must be dimension × (lower,upper)"))
    all(isfinite,b) && all(b[:,1].<=b[:,2]) || throw(ArgumentError("finite ordered bounds required"))
end
_learning_inside(x,b)=all(b[:,1].<=x.<=b[:,2])
function _classify_learning_query(d,input,coordinates::AbstractMatrix;descriptor=nothing,sensors=d.sensors)
    length(input)==length(d.input_names) || throw(DimensionMismatch("input order/dimension mismatch"))
    size(coordinates,1)==length(d.coordinate_names) && size(coordinates,2)>0 || throw(DimensionMismatch("query coordinate order/dimension mismatch"))
    all(isfinite,input) && all(isfinite,coordinates) || throw(ArgumentError("finite query required"))
    isequal(sensors,d.sensors) || throw(ArgumentError("sensor grid changed; no implicit interpolation"))
    parameter=d.kind==:surrogate ? (_learning_inside(input,d.domain.inputs) ? :inside : :outside) : :not_applicable
    coordinate=all(_learning_inside(q,d.domain.coordinates) for q in eachcol(coordinates)) ? :inside : :outside
    function_family=if d.kind==:surrogate
        :not_applicable
    elseif descriptor===nothing
        :unknown
    else
        length(descriptor)==size(d.domain.descriptors,1) || throw(DimensionMismatch("function descriptor order mismatch"))
        all(isfinite,descriptor) || throw(ArgumentError("finite descriptors required"))
        _learning_inside(descriptor,d.domain.descriptors) ? :inside : :outside
    end
    (parameter=parameter,coordinate=coordinate,function_family=function_family,guarantee=:none)
end
classify_query(d::ScientificDataset,input,coordinates::AbstractMatrix;kwargs...)=_classify_learning_query(d,input,coordinates;kwargs...)

function ScientificDataset(samples;kind,family,input_names,coordinate_names,domain,
        reference,units,grid,rng,sensors=nothing,provenance=NamedTuple())
    ss=ScientificSample[samples...]; ns=Tuple(input_names); cs=Tuple(coordinate_names)
    kind in (:surrogate,:operator) || throw(ArgumentError("kind must distinguish surrogate and operator"))
    !isempty(ss) && any(s->s.split==:training,ss) || throw(ArgumentError("training samples required"))
    length(unique(s.id for s in ss))==length(ss) || throw(ArgumentError("unique sample IDs required"))
    !isempty(ns) && length(unique(ns))==length(ns) && !isempty(cs) && length(unique(cs))==length(cs) || throw(ArgumentError("unique ordered input/coordinate names required"))
    required_domain=kind==:surrogate ? (:coordinates,:inputs) : (:coordinates,:descriptors)
    for field in required_domain
        hasproperty(domain,field) || throw(ArgumentError(
            "ScientificDataset domain is missing $field; received $(typeof(domain)). Supply domain.$field as a dimension × (lower,upper) matrix."))
    end
    hasproperty(reference,:kind) || throw(ArgumentError(
        "ScientificDataset reference is missing kind; received $(typeof(reference)). Supply reference=(kind=:analytical, ...) or another explicit supported source kind."))
    _learning_bounds(domain.coordinates,length(cs))
    if kind==:surrogate
        _learning_bounds(domain.inputs,length(ns))
        sensors===nothing || throw(ArgumentError("finite-dimensional surrogate has no function sensors"))
    else
        sensors isa AbstractMatrix && size(sensors,2)==length(ns) && all(isfinite,sensors) || throw(DimensionMismatch("one explicit sensor column per function input"))
        _learning_bounds(domain.descriptors,size(domain.descriptors,1))
    end
    reference.kind in (:analytical,:manufactured,:numerical,:experimental,:user_supplied) || throw(ArgumentError("explicit reference source kind required"))
    if reference.kind==:numerical
        all(k->hasproperty(reference,k),(:solver,:algorithm,:tolerances,:grid,:tspan,:parameters,:error)) || throw(ArgumentError("numerical reference needs solver/algorithm/tolerances/grid/tspan/parameters/error provenance"))
    end
    d=ScientificDataset(ss,kind,family,ns,cs,deepcopy(domain),deepcopy(sensors),deepcopy(reference),deepcopy(units),deepcopy(grid),deepcopy(rng),deepcopy(provenance))
    for s in ss
        c=classify_query(d,s.input,s.coordinates;descriptor=s.descriptor)
        if s.split in (:training,:interpolation)
            c.parameter!=:outside && c.coordinate==:inside && c.function_family in (:inside,:not_applicable) || throw(ArgumentError("training/interpolation must lie in declared domains"))
        elseif s.split==:parameter_extrapolation
            c.parameter==:outside && c.coordinate==:inside || throw(ArgumentError("parameter shift must be outside parameter bounds only"))
        elseif s.split in (:amplitude_extrapolation,:frequency_extrapolation)
            c.function_family==:outside && c.coordinate==:inside || throw(ArgumentError("functional shift requires out-of-domain descriptors"))
        elseif s.split==:coordinate_extrapolation
            c.coordinate==:outside && c.parameter!=:outside && c.function_family in (:inside,:not_applicable) || throw(ArgumentError("coordinate shift must be separate from other shifts"))
        end
    end
    for i in eachindex(ss), j in 1:i-1
        a,b=ss[i],ss[j]
        if a.input==b.input
            if :coordinate_extrapolation in (a.split,b.split)
                isempty(intersect(Tuple.(eachcol(a.coordinates)),Tuple.(eachcol(b.coordinates)))) || throw(ArgumentError("repeated function/parameter has overlapping query targets"))
            else
                throw(ArgumentError("duplicate parameter/function representation across scientific samples"))
            end
        end
    end
    d
end

"""Fit a min/max midpoint and half-range using only the training subset. No implicit scaling."""
function fit_scaling(d::ScientificDataset,field::Symbol)
    field in (:inputs,:coordinates,:outputs) || throw(ArgumentError("field must be inputs, coordinates or outputs"))
    ss=filter(s->s.split==:training,d.samples)
    x=field==:inputs ? hcat((s.input for s in ss)...) :
      field==:coordinates ? hcat((s.coordinates for s in ss)...) : reshape(vcat((s.values for s in ss)...),1,:)
    lo=vec(minimum(x;dims=2)); hi=vec(maximum(x;dims=2))
    # Equal subnormals must retain their offset; only truly constant rows use 1.
    # Same-sign subtraction is safe and avoids dividing both endpoints first.
    scale=[a==b ? 1. : signbit(a)==signbit(b) ? (b-a)/2 : b/2-a/2 for (a,b) in zip(lo,hi)]
    offset=[a==b ? a : signbit(a)==signbit(b) ? a+(b-a)/2 : a/2+b/2 for (a,b) in zip(lo,hi)]
    all(isfinite,offset) && all(x->isfinite(x) && x>0,scale) || throw(ArgumentError("unrepresentable scaling"))
    AffineScaling(offset,scale,[s.id for s in ss],field)
end

"""Unweighted scalar-field sample errors in physical output units, not continuum norms.
Relative L2 is unavailable when reference RMS is at/below the explicit absolute floor.
`summary_only=true` omits the absolute-error array (`absolute=nothing`) and uses
bounded scratch space for machine floats; input arrays remain caller-owned.
"""
function field_errors(prediction,reference;relative_floor=1e-12,summary_only::Bool=false)
    size(prediction)==size(reference) || throw(DimensionMismatch("reference shape mismatch"))
    !isempty(reference) && all(x->x isa Real && isfinite(x),prediction) && all(x->x isa Real && isfinite(x),reference) || throw(ArgumentError("finite nonempty real field values required"))
    isfinite(relative_floor) && relative_floor>=0 || throw(ArgumentError("nonnegative relative floor required"))
    difference=summary_only ? (p-r for (p,r) in zip(prediction,reference)) : prediction.-reference
    all(isfinite,difference) || throw(ArgumentError("unrepresentable field difference"))
    summary=_sampled_summary_replayable(difference); baseline=sampled_summary(reference)
    relative=baseline.rms<=relative_floor ? nothing : summary.rms/baseline.rms
    relative===nothing || isfinite(relative) || (relative=nothing)
    (summary=summary,relative_sampled_l2=relative,relative_floor=relative_floor,
        absolute=summary_only ? nothing : abs.(difference),normalization=:physical_unweighted_samples)
end

"""Native Lux model/state and scientific schema; no reference targets in the model.
Arrays are read-only by convention. Function descriptors are not neural inputs.
"""
struct ScientificModel{N,P,S,C,Z,R}
    architecture::Symbol
    network::N
    parameters::P
    state::S
    schema::C
    normalization::Z
    provenance::R
end
struct LearningBatch{X,Y}
    inputs::X
    targets::Y
    ids::Vector{Symbol}
end
"""Native optimization objects, bounded history and a single borrowed dataset reference."""
struct ScientificLearningResult <: AbstractAnalysis
    model::ScientificModel
    dataset::ScientificDataset
    optimization_problem
    solution
    optimizer
    history::Vector{Float64}
    objective
    normalization
    timing
    evidence::PropertyResult
    provenance
end
function _surrogate_extension()
    ext=Base.get_extension(@__MODULE__,:AnalyticMathLabSurrogateExt)
    ext===nothing && throw(ArgumentError("load Lux, Optimization and NeuralOperators for scientific learning"))
    ext
end
learning_model(d::ScientificDataset,network;kwargs...)=_surrogate_extension().learning_model(d,network;kwargs...)
training_data(m::ScientificModel,d::ScientificDataset)=_surrogate_extension().training_data(m,d)
learning_objective(m::ScientificModel,p,b::LearningBatch)=_surrogate_extension().learning_objective(m,p,b)
train(m::ScientificModel,d::ScientificDataset;kwargs...)=_surrogate_extension().train(m,d;kwargs...)
"""Predict scalar query outputs. Optional `batch_size` bounds query activations for
query-independent networks (Dense/pointwise Lux and the tested DeepONet route).
Do not use it for networks that couple query columns. Output remains O(query count).
"""
predict(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_surrogate_extension().predict(m,input,coordinates;kwargs...)
predict(r::ScientificLearningResult,input,coordinates::AbstractMatrix;kwargs...)=predict(r.model,input,coordinates;kwargs...)
classify_query(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_classify_learning_query(m.schema,input,coordinates;kwargs...)
