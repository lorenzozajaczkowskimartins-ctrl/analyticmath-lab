# On-demand observations; no history of snapshots and no force evaluation.
struct TrajectoryObservations{T,F} <: AbstractVector{Any}
    trajectory::T
    observable::F
end
Base.size(v::TrajectoryObservations)=(length(v.trajectory),)
Base.IndexStyle(::Type{<:TrajectoryObservations})=IndexLinear()
Base.getindex(v::TrajectoryObservations,i::Int)=v.observable(v.trajectory[i])

"""Lazy frame-derived observable. Vector momentum/CM velocity may be retained for
vector diagnostics; request `component=axis` for scalar statistics. Missing data
stay `missing`, never dropped. No backend force evaluation is performed.
Temperature requires BOTH caller DOF and Boltzmann constant, or a stored backend
series passed directly to analysis. No automatic d*N or COM correction is made.
"""
function observable_series(t::AtomisticTrajectoryView,name::Symbol;component=nothing,
        dof=nothing,boltzmann=nothing,time_options=NamedTuple())
    name in (:kinetic_energy,:potential_energy,:total_energy,:temperature,:total_momentum,:center_of_mass_velocity) ||
        throw(ArgumentError("Unsupported observable"))
    component===nothing || (name in (:total_momentum,:center_of_mass_velocity) && component isa Integer && component>0) ||
        throw(ArgumentError("component is a positive vector-observable axis"))
    dof===nothing || (dof isa Integer && dof>0) || throw(ArgumentError("dof must be a positive integer"))
    boltzmann===nothing || (_at_finite(boltzmann) && boltzmann>zero(boltzmann)) || throw(ArgumentError("positive Boltzmann constant required"))
    function getvalue(s)
        if name==:potential_energy
            p=s.potential_energy
            return p isa PropertyResult ? (p.value===nothing ? missing : p.value) : p===nothing ? missing : p
        end
        name==:temperature && (dof===nothing || boltzmann===nothing) && return missing
        # Reuse M8A arithmetic with pair storage disabled; O(particles), not O(particles²).
        obs=mdcheck(s;max_pairs=0).observations
        p=getproperty(obs,name==:temperature ? :kinetic_energy : name)
        p.value===nothing && return missing
        value=name==:temperature ? 2p.value/(dof*boltzmann) : p.value
        component===nothing ? value : component<=length(value) ? value[component] : missing
    end
    sampling=sampling_info(t;time_options...)
    values=TrajectoryObservations(t,getvalue)
    provenance=merge(t.provenance,(observable=name,component=component,dof=dof,boltzmann=boltzmann,
        temperature_convention=name==:temperature ? :caller_dof_and_boltzmann : :not_applicable,
        evaluation=:lazy_no_force_evaluation))
    ObservableSeries(values,sampling,name,"inherited from supplied data",provenance,:reject)
end

_tr_not_requested()=PropertyResult(nothing,:not_requested,:not_requested,String[])

"""Stored finite deviations from the first observation, not a conservation grade."""
struct DeviationAnalysis <: AbstractAnalysis
    series::ObservableSeries
    values::PropertyResult
end
function _trajectory_deviations(s::ObservableSeries;ensemble=get(s.provenance,:ensemble,:unknown),vector=false)
    x=collect(s.values); n=length(x)
    unknown(note)=DeviationAnalysis(s,_at_unknown(note))
    n>0 || return unknown("Empty observations.")
    valid=vector ? all(v->v isa AbstractVector && !isempty(v) && length(v)==length(first(x)) && all(_at_finite,v),x) : all(_at_finite,x)
    valid || return unknown("Finite aligned observations required.")
    delta=[v-first(x) for v in x]
    magnitude=vector ? LinearAlgebra.norm.(delta) : abs.(delta)
    all(_at_finite,magnitude) || return unknown("Nonfinite deviations.")
    denominator=vector ? LinearAlgebra.norm(first(x)) : abs(first(x))
    relative=iszero(denominator) ? nothing : maximum(magnitude)/denominator
    slope=_at_unknown("Scalar observations and explicit times required for linear trend.")
    if !vector && n>=2 && s.sampling.times!==nothing
        times=s.sampling.times
        # Remove absolute clock offset before fitting; descriptive trend only.
        tx=[v-first(times) for v in times]; mx=sum(tx)/n
        my=_ts_moments(x).mean
        xx=sum(abs2,v-mx for v in tx)
        slope=xx>zero(xx) ? _at_safe(()->sum((tx[i]-mx)*(x[i]-my) for i in 1:n)/xx,"linear trend") : slope
    end
    value=(deviations=delta,maximum_absolute=maximum(magnitude),maximum_relative=relative,
        rms=sqrt(sum(abs2,magnitude)/n),linear_slope=slope,ensemble=ensemble,
        conservation_expected=!vector && ensemble==:NVE,
        interpretation=:descriptive_deviations)
    DeviationAnalysis(s,_at_observed(value;method=:initial_reference_deviations,
        notes=["Energy exchange or external forcing is not classified as numerical failure.",
               "A fitted trend is descriptive, not proof of secular drift or stationarity."]))
end
# Convenience diagnostic results keep the established PropertyResult access pattern.
energy_diagnostics(s::ObservableSeries;kwargs...)=_trajectory_deviations(s;kwargs...).values
momentum_diagnostics(s::ObservableSeries;kwargs...)=_trajectory_deviations(s;vector=true,kwargs...).values

"""Opt-in trajectory composition. Default analysis reads time metadata only.
`series` supplies trustworthy stored observables (e.g. Molly logger series); values
are not copied except by requested history-dependent calculations. Supplied series
must match trajectory count/times. Expensive correlation, MSD and VACF are opt-in.
"""
struct MDTrajectoryAnalysis <: AbstractAnalysis
    sampling
    observables
    summaries
    correlations
    deviations
    transients
    msd
    vacf
    diffusion::PropertyResult
    notes::Vector{String}
end
function analyze(t::AtomisticTrajectoryView;observables=(),series=NamedTuple(),correlations=(),
        window=nothing,maxlag=min(max(length(t)-1,0),128),transients=false,
        msd=false,vacf=false,fit_window=nothing,transport_options=NamedTuple(),
        observable_options=NamedTuple(),time_options=NamedTuple())
    sampling=sampling_info(t;time_options...)
    extracted=Dict{Symbol,ObservableSeries}()
    for (name,s) in pairs(series)
        s isa ObservableSeries || throw(ArgumentError("supplied series must be ObservableSeries"))
        s.sampling.count==length(t) || throw(DimensionMismatch("observable/frame counts differ"))
        s.sampling.times==sampling.times || throw(ArgumentError("observable and trajectory times must match explicitly"))
        extracted[name]=s
    end
    for name in union(collect(observables),collect(correlations))
        haskey(extracted,name) || (extracted[name]=observable_series(t,name;time_options,observable_options...))
    end
    summaries=Dict{Symbol,PropertyResult}(); corr=Dict{Symbol,PropertyResult}()
    deviations=Dict{Symbol,PropertyResult}(); transient=Dict{Symbol,PropertyResult}()
    for (name,s) in extracted
        summaries[name]=statistical_summary(s)
        name in correlations && (corr[name]=correlated_mean(s;window,maxlag))
        if name in (:kinetic_energy,:potential_energy,:total_energy)
            deviations[name]=energy_diagnostics(s)
        elseif name in (:total_momentum,:center_of_mass_velocity)
            deviations[name]=momentum_diagnostics(s)
        end
        transients && (transient[name]=transient_analysis(s))
    end
    displacement=msd ? mean_squared_displacement(t;time_options,transport_options...) : _tr_not_requested()
    velocity=vacf ? velocity_autocorrelation(t;time_options,maxlag) : _tr_not_requested()
    diffusion=fit_window===nothing ? _tr_not_requested() : msd ? diffusion_estimate(displacement;fit_window) : _at_unknown("Request MSD before diffusion fitting.")
    MDTrajectoryAnalysis(sampling,extracted,summaries,corr,deviations,transient,displacement,velocity,diffusion,
        ["Only requested analyses computed; no burn-in applied, no simulation grade.",
         "Stored frames need not be independent; stationarity and transport regimes require physical justification."])
end

"""Compose structured sampling/statistical/transport evidence without a score.
No automatic burn-in removal or automatic diffusion window is performed.
"""
function diagnose(r::MDTrajectoryAnalysis)
    _at_observed((stored_frames=r.sampling.count,sampling=r.sampling,statistics=r.summaries,
        correlation=r.correlations,energy_momentum=r.deviations,transient=r.transients,
        msd=r.msd,vacf=r.vacf,diffusion=r.diffusion);method=:trajectory_evidence_composition,
        notes=[r.notes; "Diffusion unavailable unless explicitly requested with justified interval."])
end
diagnose(t::AtomisticTrajectoryView;kwargs...)=diagnose(analyze(t;kwargs...))
