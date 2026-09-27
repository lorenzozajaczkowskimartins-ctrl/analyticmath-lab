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
        coords=Matrix{Float64}(X)
        all(isfinite,coords) || throw(ArgumentError("coordinates must be representable in Float64"))
        new(coords,generation,provenance)
    end
end

"""Unweighted finite-sample statistics, without a domain measure or global norm claim."""
function sampled_summary(values)
    v=vec(collect(values)); n=length(v)
    finite=count(x->x isa Real && isfinite(x),v)
    if n==0 || finite!=n
        return (count=n,finite_count=finite,rms=nothing,mean_absolute=nothing,
            max_absolute=nothing,sampled_l2=nothing,normalization=:unweighted_samples)
    end
    a=abs.(Float64.(v)); scale=maximum(a)
    # Scaling avoids overflow in squaring otherwise representable residuals.
    rms=scale==0 ? 0.0 : scale*sqrt(sum(abs2,a./scale)/n)
    (count=n,finite_count=finite,rms=rms,mean_absolute=sum(a./n),
        max_absolute=scale,sampled_l2=rms*sqrt(n),normalization=:unweighted_samples)
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
