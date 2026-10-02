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
end
function transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
    size(x,1)==length(s.offset) || throw(DimensionMismatch("scaling row count mismatch"))
    (x.-s.offset)./s.scale
end
function inverse_transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
    size(x,1)==length(s.offset) || throw(DimensionMismatch("scaling row count mismatch"))
    x.*s.scale.+s.offset
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
        x,q,y=Float64.(input),Matrix{Float64}(coordinates),Float64.(values)
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
    offset=lo ./ 2 .+ hi ./ 2; scale=hi ./ 2 .- lo ./ 2
    scale=ifelse.(iszero.(scale),1.,scale)
    all(isfinite,offset) && all(x->isfinite(x) && x>0,scale) || throw(ArgumentError("unrepresentable scaling"))
    AffineScaling(offset,scale,[s.id for s in ss],field)
end

"""Unweighted scalar-field sample errors in physical output units, not continuum norms.
Relative L2 is unavailable when reference RMS is at/below the explicit absolute floor.
"""
function field_errors(prediction,reference;relative_floor=1e-12)
    size(prediction)==size(reference) || throw(DimensionMismatch("reference shape mismatch"))
    !isempty(reference) && all(isfinite,prediction) && all(isfinite,reference) || throw(ArgumentError("finite nonempty field values required"))
    isfinite(relative_floor) && relative_floor>=0 || throw(ArgumentError("nonnegative relative floor required"))
    difference=prediction.-reference
    all(isfinite,difference) || throw(ArgumentError("unrepresentable field difference"))
    summary=sampled_summary(difference); baseline=sampled_summary(reference)
    relative=baseline.rms<=relative_floor ? nothing : summary.rms/baseline.rms
    (summary=summary,relative_sampled_l2=relative,relative_floor=relative_floor,
        absolute=abs.(difference),normalization=:physical_unweighted_samples)
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
predict(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_surrogate_extension().predict(m,input,coordinates;kwargs...)
predict(r::ScientificLearningResult,input,coordinates::AbstractMatrix;kwargs...)=predict(r.model,input,coordinates;kwargs...)
classify_query(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_classify_learning_query(m.schema,input,coordinates;kwargs...)
