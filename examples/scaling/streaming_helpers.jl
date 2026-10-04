module StreamingScale
using AnalyticMathLab

"""Read-only, O(1)-storage observations; no RNG state or stored trajectory."""
struct AlternatingSamples <: AbstractVector{Float64}
    n::Int
    function AlternatingSamples(n::Integer)
        0<=n<=typemax(Int) || throw(ArgumentError("sample count out of Int range"))
        new(Int(n))
    end
end
Base.size(v::AlternatingSamples)=(v.n,)
Base.IndexStyle(::Type{AlternatingSamples})=IndexLinear()
function Base.getindex(v::AlternatingSamples,i::Int)
    @boundscheck checkbounds(v,i)
    isodd(i) ? -1. : 1.
end

mutable struct DeadlineSamples
    values::AlternatingSamples
    chunk_size::Int
    started::UInt64
    max_seconds::Float64
    consumed::Int
    timed_out::Bool
    progress::Bool
end
Base.IteratorSize(::Type{DeadlineSamples})=Base.SizeUnknown()
Base.eltype(::Type{DeadlineSamples})=Float64
function Base.iterate(s::DeadlineSamples,i=1)
    i>length(s.values) && return nothing
    if (i-1)%s.chunk_size==0
        elapsed=(time_ns()-s.started)/1e9
        s.progress && println((consumed=s.consumed,requested=length(s.values),seconds=elapsed))
        if elapsed>=s.max_seconds
            s.timed_out=true
            return nothing
        end
    end
    s.consumed=i
    (s.values[i],i+1)
end

"""Deadline-aware use of AML's existing M10B variance kernel, not a new estimator.
Only the consumed prefix is summarized; requested and consumed counts differ on
termination. No per-observation output/history is retained. Deadline resolution
is one chunk, with elapsed monotonic time checked before the first sample.
"""
function stream_summary(samples::Integer;chunk_size=100_000,max_seconds=120.,progress=true)
    samples>0 || throw(ArgumentError("positive sample count required"))
    chunk_size isa Integer && chunk_size>0 || throw(ArgumentError("positive chunk size required"))
    max_seconds isa Real && isfinite(max_seconds) && max_seconds>0 || throw(ArgumentError("finite positive deadline required"))
    samples>=100_000_000 && get(ENV,"AML_EXTREME","0")!="1" &&
        throw(ArgumentError("100 million or more samples requires AML_EXTREME=1"))
    s=DeadlineSamples(AlternatingSamples(samples),Int(chunk_size),time_ns(),Float64(max_seconds),0,false,progress)
    moments=AnalyticMathLab._ts_moments(s)
    elapsed=(time_ns()-s.started)/1e9
    status=s.timed_out ? "timed_out_safely" : moments===nothing ? "invalid_observations" : "completed"
    (requested=samples,consumed=s.consumed,status=status,seconds=elapsed,
        samples_per_second=s.consumed/max(elapsed,eps()),moments=moments,
        storage_note="O(1) iterator and moment state; no trajectory or running-history collection")
end
end
