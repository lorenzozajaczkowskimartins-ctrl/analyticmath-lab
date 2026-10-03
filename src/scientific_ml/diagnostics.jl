"""Explicit evaluation coordinates (rows × samples), not implicitly training/held-out data.
For residuals rows follow that block's `ivs`; reference points follow global IV order.
Metadata may carry units and RNG provenance; coordinates use the M9A Float64 policy.
"""
struct PINNPoints
    coordinates::Matrix{Float64}
    generation::Symbol
    provenance
    function PINNPoints(X::AbstractMatrix;generation::Symbol=:user_supplied,provenance=NamedTuple())
        size(X,2)>0 || throw(ArgumentError("at least one evaluation point is required"))
        all(x->x isa Real && isfinite(x),X) || throw(ArgumentError("finite real coordinates required"))
        coords=_checked_float64.(X,Ref("PINN coordinates"))
        all(isfinite,coords) || throw(ArgumentError("coordinates must be representable in Float64"))
        new(coords,generation,provenance)
    end
end

"""Unweighted finite-sample statistics, without a domain measure or global norm claim.
Floating inputs preserve their promoted floating type (including BigFloat); exact
inputs use Julia's `float` promotion. Nonfinite/non-real/empty inputs give unavailable
metrics. An unrepresentable L2 norm is `nothing`, even if RMS remains representable.
"""
function sampled_summary(values)
    v=vec(collect(values)); n=length(v)
    finite=count(x->x isa Real && isfinite(x),v)
    if n==0 || finite!=n
        return (count=n,finite_count=finite,rms=nothing,mean_absolute=nothing,
            max_absolute=nothing,sampled_l2=nothing,normalization=:unweighted_samples)
    end
    a=abs.(float.(v)); scale=maximum(a)
    # Normalize before summing/squaring; dividing subnormal inputs by n first
    # would erase a representable mean. Use direct L2 to avoid a second rounding.
    normalized=iszero(scale) ? a : a./scale
    squares=sum(abs2,normalized)
    rms=iszero(scale) ? zero(scale) : scale*sqrt(squares/n)
    mean_absolute=iszero(scale) ? zero(scale) : scale*(sum(normalized)/n)
    l2=iszero(scale) ? zero(scale) : scale*sqrt(squares)
    available(x)=isfinite(x) ? x : nothing
    (count=n,finite_count=finite,rms=available(rms),mean_absolute=available(mean_absolute),
        max_absolute=scale,sampled_l2=available(l2),normalization=:unweighted_samples)
end

"""Stored diagnostics referring to (not copying) the M9A trained result.
`evidence` concerns global correctness and remains unknown, regardless of sampled metrics.
"""
struct PINNAnalysis <: AbstractAnalysis
    training::PINNTrainingResult
    residuals::Vector{NamedTuple}
    reference::PropertyResult
    collocation_metadata
    loss_diagnostics
    adaptive_loss_metadata::PropertyResult
    evidence::PropertyResult
    provenance
    limitations::Vector{String}
end

analyze(r::PINNTrainingResult;kwargs...)=_pinn_extension().analyze_pinn(r;kwargs...)
pinn_inspect(a::PINNAnalysis)=(training=a.training,residuals=a.residuals,reference=a.reference,
    collocation_metadata=a.collocation_metadata,loss_diagnostics=a.loss_diagnostics,
    adaptive_loss_metadata=a.adaptive_loss_metadata,evidence=a.evidence,
    provenance=a.provenance,limitations=a.limitations)
loss_breakdown(a::PINNAnalysis)=a.loss_diagnostics
loss_breakdown(r::PINNTrainingResult)=_pinn_extension().loss_breakdown(r)
function residualplot end
function errorplot end
function collocationplot end
function losscomponentsplot end
function pinnplot end
