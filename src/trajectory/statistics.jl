"""Borrowed saved-sample time metadata, not an inference of simulation timestep.

`evidence` is a PropertyResult. Unitless physical units remain unknown; explicit
index time is labeled as sample indices. Arrays are read-only by convention.
"""
struct SamplingInfo{T,I,U,P,E} <: AbstractAnalysis
    count::Int
    times::T
    interval::I
    regularity::Symbol
    units::U
    provenance::P
    evidence::E
end

_ts_result(v,status,method,notes=String[])=PropertyResult(v,status,method,notes)
_ts_unknown(note;method=:scalar_statistics)=_ts_result(nothing,:unknown,method,[note])
_ts_valid(x)=x isa Number && isreal(x) && isfinite(x)
_ts_close(a,b)=abs(a-b)<=1e-8*max(abs(a),abs(b))

"""`sampling_info(n; times, interval, index_time=false, provenance=NamedTuple())`

Borrow explicit times without copying; validate finite strictly increasing times.
Spacing uses relative tolerance 1e-8 with zero absolute tolerance. An explicit
positive interval generates a lazy range starting at zero. Index time must be
requested and cannot be combined with times/interval. Zero/one samples are
`:insufficient`; absent times are `:unknown`. Spacing describes saved samples,
never the integrator dt (even when provenance contains storage stride).
"""
function sampling_info(n::Integer;times=nothing,interval=nothing,index_time=false,provenance=NamedTuple())
    n>=0 || throw(ArgumentError("count must be nonnegative"))
    index_time && (times!==nothing || interval!==nothing) &&
        throw(ArgumentError("index_time cannot accompany physical time metadata"))
    interval===nothing || (_ts_valid(interval) && interval>zero(interval)) ||
        throw(ArgumentError("interval must be finite and positive"))
    index_time && (interval=1)
    if times===nothing && interval!==nothing
        times=range(zero(interval);step=interval,length=n)
    end
    regularity=n<2 ? :insufficient : :unknown
    if times!==nothing
        length(times)==n || throw(DimensionMismatch("times must match sample count"))
        all(_ts_valid,times) || throw(ArgumentError("times must be finite real scalars"))
        if n>=2
            previous=first(times); spacing=nothing; regular=true
            for t in Iterators.drop(times,1)
                d=t-previous
                _ts_valid(d) && d>zero(d) || throw(ArgumentError("times must increase strictly with finite spacing"))
                spacing===nothing && (spacing=d)
                regular &= _ts_close(d,spacing)
                interval===nothing || _ts_close(d,interval) || throw(ArgumentError("interval conflicts with explicit times"))
                previous=t
            end
            regularity=regular ? :regular : :irregular
            interval===nothing && regular && (interval=spacing)
        end
    end
    unit=index_time ? "sample index" : interval!==nothing ? _at_unit(interval) :
        times!==nothing && n>0 ? _at_unit(first(times)) : "unknown"
    evidence=_ts_result(regularity,regularity in (:unknown,:insufficient) ? :unknown : :established,
        :saved_sample_spacing,["Relative spacing tolerance 1e-8, zero absolute tolerance; no simulation dt inferred."])
    SamplingInfo(Int(n),times,interval,regularity,unit,provenance,evidence)
end
sampling_info(t::AtomisticTrajectoryView;times=t.times,provenance=t.provenance,kwargs...)=
    sampling_info(length(t);times,provenance,kwargs...)

"""Borrow an AbstractVector of scalar observations, including lazy mapped vectors.

Only the first value is inspected for units at construction (missing means
unknown units). No missing/nonfinite observations are dropped: `:reject` is the
only supported missing policy, and numerical analyses return unknown for them.
"""
struct ObservableSeries{V,S,U,P} <: AbstractAnalysis
    values::V
    sampling::S
    name::Symbol
    units::U
    provenance::P
    missing_policy::Symbol
end
function ObservableSeries(values::AbstractVector;times=nothing,interval=nothing,index_time=false,
        name=:observable,provenance=NamedTuple(),missing_policy=:reject)
    missing_policy==:reject || throw(ArgumentError("only missing_policy=:reject is supported"))
    sampling=sampling_info(length(values);times,interval,index_time,provenance)
    units=isempty(values) ? "unknown" : _at_unit(first(values))
    ObservableSeries(values,sampling,name,units,provenance,missing_policy)
end

# Welford updates use constant auxiliary storage unless cumulative output requested.
function _ts_moments(values;running=false)
    n=0; mean=nothing; m2=nothing; lo=nothing; hi=nothing
    means=Any[]; variances=Any[]
    for raw in values
        _ts_valid(raw) || return nothing
        x=float(real(raw)); n+=1
        if n==1
            mean=x; m2=zero(x*x); lo=x; hi=x
        else
            delta=x-mean; mean+=delta/n; m2+=delta*(x-mean)
            lo=min(lo,x); hi=max(hi,x)
        end
        _ts_valid(mean) && _ts_valid(m2) || return nothing
        if running
            push!(means,mean); push!(variances,n>1 ? m2/(n-1) : nothing)
        end
    end
    n==0 && return nothing
    variance=n>1 ? m2/(n-1) : nothing
    (count=n,mean=mean,variance=variance,std=variance===nothing ? nothing : sqrt(variance),
        minimum=lo,maximum=hi,standard_error=nothing,means=means,variances=variances)
end

"""One-pass O(1) auxiliary storage sample moments; variance uses n-1.

Descriptive arithmetic is not an IID assumption. `standard_error=nothing` is
explicitly unknown; empty, missing, nonfinite, or non-real data yield unknown.
"""
function statistical_summary(s::ObservableSeries)
    r=_ts_moments(s.values)
    r===nothing && return _ts_unknown("Need nonempty finite real scalar observations; none are dropped.")
    value=(count=r.count,mean=r.mean,variance=r.variance,std=r.std,minimum=r.minimum,
        maximum=r.maximum,standard_error=nothing)
    _ts_result(value,:heuristic,:welford,["Sample variance uses n-1; correlated standard error not inferred."])
end

"""Cumulative Welford means/variances; first sample variance is `nothing`."""
function running_statistics(s::ObservableSeries)
    r=_ts_moments(s.values;running=true)
    r===nothing && return _ts_unknown("Need nonempty finite real observations; none are dropped.";method=:running_welford)
    _ts_result((counts=1:r.count,means=r.means,variances=r.variances),:heuristic,:running_welford)
end

"""Lag-domain scalar analysis; unavailable arrays are `nothing`, never NaN sentinels.

`counts` records overlapping pairs; covariance retains squared observable units.
`evidence` describes normalized correlation availability and assumptions.
"""
struct AutocorrelationAnalysis{S,L,T,C,R,N,E} <: AbstractAnalysis
    sampling::S
    lags::L
    lag_times::T
    autocovariance::C
    autocorrelation::R
    counts::N
    normalization::Symbol
    method::Symbol
    evidence::E
end

"""Direct mean-subtracted autocovariance, O(N*K) work and O(N+K) storage.

Default `maxlag=min(N-1,128)` bounds the lag domain (linear work at fixed K).
`:biased` divides every lag by N; `:unbiased` divides by N-k (a denominator
convention, not a claim of exact unbiasedness with an estimated mean). Regular
saved-sample spacing is required; explicit index time is allowed. Only scalar
values are cached. Constant series have zero covariance and unknown correlation.
"""
function autocorrelation(s::ObservableSeries;maxlag=min(length(s.values)-1,128),normalization=:biased)
    n=length(s.values)
    normalization in (:biased,:unbiased) || throw(ArgumentError("normalization must be :biased or :unbiased"))
    maxlag isa Integer && (n==0 ? maxlag in (-1,0) : 0<=maxlag<n) ||
        throw(ArgumentError("maxlag must be between zero and N-1"))
    lags=0:min(maxlag,n-1); counts=[n-k for k in lags]
    dt=s.sampling.interval
    lag_times=dt===nothing ? nothing : range(zero(dt);step=dt,length=length(lags))
    result(c,r,e)=AutocorrelationAnalysis(s.sampling,lags,lag_times,c,r,counts,normalization,:direct_bounded,e)
    unknown(note)=result(nothing,nothing,_ts_unknown(note;method=:direct_bounded))
    n>=2 && s.sampling.regularity==:regular || return unknown("At least two regularly timed samples required.")
    values=collect(s.values)
    moments=_ts_moments(values)
    moments===nothing && return unknown("Finite real scalar observations required; none dropped.")
    centered=[float(real(x))-moments.mean for x in values]
    covariance=[sum(centered[i]*centered[i+k] for i in 1:n-k)/(normalization==:biased ? n : n-k) for k in lags]
    all(_ts_valid,covariance) || return unknown("Covariance arithmetic was nonfinite.")
    iszero(first(covariance)) && return result(covariance,nothing,
        _ts_unknown("Constant series: normalized autocorrelation is undefined.";method=:direct_bounded))
    rho=[_at_number(c/first(covariance)) for c in covariance]
    all(_ts_valid,rho) || return unknown("Normalized covariance was nonfinite.")
    result(covariance,rho,_ts_result(nothing,:heuristic,:direct_bounded,
        ["Finite-window estimate using the full sample mean; stationarity is not established."]))
end
