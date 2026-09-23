"""Estimate tau_int = 1/2 + sum(rho[1:window]), in saved-sample units.

An explicit window is caller-selected. Automatic selection stops immediately before
its first nonpositive lag; if none occurs within the computed lags, uncertainty is
unknown rather than silently truncating a positive tail. Raw tau is retained; the
information estimate uses max(1/2,raw_tau), conservatively disallowing N_eff>N.
Neither choice establishes stationarity or adequate run length.
"""
function integrated_autocorrelation_time(a::AutocorrelationAnalysis;window=nothing)
    rho=a.autocorrelation
    rho===nothing && return _ts_unknown("Normalized autocorrelation unavailable.")
    length(rho)>=1 && a.sampling.count>=4 || return _ts_unknown("At least four samples required.")
    automatic=window===nothing
    if automatic
        crossing=findfirst(x->x<=0,view(rho,2:length(rho)))
        crossing===nothing && return _ts_unknown("No nonpositive tail encountered; increase maxlag/run length or supply a justified window.")
        window=crossing-1
    end
    window isa Integer && 0<=window<length(rho) || throw(ArgumentError("window outside computed lag range"))
    raw=0.5+sum(view(rho,2:window+1);init=0.0)
    _ts_valid(raw) || return _ts_unknown("Nonfinite integrated correlation estimate.")
    tau=max(0.5,raw)
    _ts_result((tau=tau,raw_tau=raw,physical_tau=tau*a.sampling.interval,window=window,
        method=automatic ? :initial_positive_lags : :explicit_window,clamped=tau!=raw,
        assumptions=(:stationary_mean,:regular_sampling,:truncated_tail)),:heuristic,
        automatic ? :initial_positive_lags : :explicit_window,
        ["tau convention is 1/2 + sum positive-lag rho; finite noisy tail, not a certificate.",
         "Information estimate capped at sample count; negative correlations do not increase reported N_eff."])
end

"""Correlation-aware uncertainty in a mean, never an IID fallback.
Materializes only scalar values once, O(N) storage; correlations cost O(N*maxlag).
"""
function correlated_mean(s::ObservableSeries;window=nothing,maxlag=min(length(s.values)-1,128),normalization=:biased)
    values=collect(s.values)
    cached=ObservableSeries(values,s.sampling,s.name,s.units,s.provenance,s.missing_policy)
    stats=statistical_summary(cached)
    stats.value===nothing && return stats
    ac=autocorrelation(cached;maxlag,normalization)
    tau=integrated_autocorrelation_time(ac;window)
    tau.value===nothing && return tau
    r=stats.value; t=tau.value.tau; neff=r.count/(2t)
    _ts_valid(neff) && neff>=1 || return _ts_unknown("Less than one effective sample; run/window insufficient for mean uncertainty.")
    _ts_result((mean=r.mean,std=r.std,standard_error=r.std/sqrt(neff),tau_int=t,
        effective_samples=neff,count=r.count,window=tau.value.window,correlation=ac,
        integration=tau,method=:windowed_autocorrelation),:heuristic,:windowed_autocorrelation,
        ["Stationarity assumed, not tested; effective information is not a count of independent experiments."])
end

"""Inspect complete nonoverlapping blocks without automatic plateau selection."""
struct BlockAnalysis <: AbstractAnalysis
    block_sizes
    block_counts
    discarded
    block_means
    variances
    standard_errors
    sampling
    units
    evidence::PropertyResult
end
function block_average(s::ObservableSeries;block_sizes=[2^k for k in 0:floor(Int,log2(max(1,length(s.values)÷2)))])
    sizes=collect(block_sizes); n=length(s.values)
    all(b->b isa Integer && b>0,sizes) || throw(ArgumentError("block sizes must be positive integers"))
    values=collect(s.values)
    counts=[n÷b for b in sizes]; tails=[n%b for b in sizes]
    means=Any[]; vars=Any[]; errors=Any[]
    result(e)=BlockAnalysis(sizes,counts,tails,means,vars,errors,s.sampling,s.units,e)
    _ts_moments(values)===nothing && return result(_ts_unknown("Finite nonempty scalar values required."))
    for (b,nb) in zip(sizes,counts)
        bm=[_ts_moments(view(values,(j-1)*b+1:j*b)).mean for j in 1:nb]
        push!(means,bm)
        m=_ts_moments(bm)
        v=m===nothing ? nothing : m.variance
        push!(vars,v);push!(errors,v===nothing ? nothing : sqrt(v/nb))
    end
    result(_ts_result(nothing,:heuristic,:nonoverlapping_blocks,
        ["Tail observations omitted separately for each size; block independence is NOT established.",
         "SE = sqrt(sample variance of complete block means / number of blocks); inspect size dependence."]))
end

"""Early/late half-window shift compared with pooled fluctuations, NOT IID SE.
Requires eight observations. A large shift suggests a midpoint analysis start,
never applies it, and never establishes equilibrium or a stable late region.
"""
function transient_analysis(s::ObservableSeries;threshold=1.0)
    threshold isa Real && isfinite(threshold) && threshold>0 || throw(ArgumentError("threshold must be positive"))
    n=length(s.values); n>=8 || return _ts_unknown("Insufficient data for early/late windows.")
    x=collect(s.values); split=n÷2
    early=_ts_moments(view(x,1:split)); late=_ts_moments(view(x,split+1:n))
    (early===nothing || late===nothing) && return _ts_unknown("Finite observations required.")
    shift=late.mean-early.mean
    fluctuation=sqrt((early.variance+late.variance)/2)
    detected=abs(shift)>threshold*fluctuation
    start=detected ? split+1 : nothing
    _ts_result((observable=s.name,apparent_transient=detected,mean_shift=shift,
        pooled_fluctuation=fluctuation,threshold=threshold,suggested_start=start,
        suggested_time=start===nothing || s.sampling.times===nothing ? nothing : s.sampling.times[start],
        applied=false,equilibrium_proven=false),:heuristic,:early_late_shift,
        ["No independent-sample significance test; late stationarity is not established.",
         "No detected shift does not prove equilibrium; suggested cutoff is never applied automatically."])
end
