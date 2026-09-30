"""Explicit scalar-time observations: rows follow `variables`, columns follow `times`.
No noise model or units are invented. Missing data are rejected, not imputed.
Numeric values must already use a caller-declared consistent coordinate system.
`weights`, when supplied, multiply squared residuals; they are not inferred variances.
"""
struct ObservationSet
    times::Vector{Float64}
    values::Matrix{Float64}
    variables::Tuple
    units
    weights
    kind::Symbol
    role::Symbol
    provenance
    function ObservationSet(times,values::AbstractMatrix;variables,units=nothing,
            weights=nothing,kind=:user_supplied,role=:fit,provenance=NamedTuple())
        t=collect(times); v=Tuple(string.(variables))
        size(values)==(length(v),length(t)) || throw(DimensionMismatch("values must be variables × times"))
        !isempty(t) && !isempty(v) || throw(ArgumentError("nonempty observations required"))
        length(unique(v))==length(v) || throw(ArgumentError("variable identities must be unique"))
        all(x->x isa Real && isfinite(x),t) && all(x->x isa Real && isfinite(x),values) ||
            throw(ArgumentError("finite numeric observations required; missing data and implicit unit stripping unsupported"))
        ts=Float64.(t); ys=Matrix{Float64}(values)
        all(isfinite,ts) && all(isfinite,ys) && all(>(0),diff(ts)) ||
            throw(ArgumentError("times must be strictly increasing and all values representable in Float64"))
        role in (:fit,:heldout,:evaluation,:extrapolation) || throw(ArgumentError("invalid observation role"))
        kind in (:synthetic,:numerical,:experimental,:user_supplied) || throw(ArgumentError("invalid observation kind"))
        w=if weights===nothing
            nothing
        else
            size(weights)==size(ys) || throw(DimensionMismatch("one weight per observation required"))
            all(x->x isa Real && isfinite(x) && x>=0,weights) || throw(ArgumentError("finite nonnegative weights required"))
            z=Matrix{Float64}(weights)
            all(isfinite,z) && any(>(0),z) || throw(ArgumentError("weights must be representable and not all zero"))
            z
        end
        new(ts,ys,v,units,w,kind,role,provenance)
    end
end
