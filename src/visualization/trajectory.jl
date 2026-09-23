# Rendering reads stored arrays; no correlation, fitting or transient inference.
function _ts_curve(times,values;title,ylabel=nothing)
    times===nothing && throw(ArgumentError("Explicit times required; declare index time upstream if intended."))
    values===nothing && throw(ArgumentError("Requested statistic unavailable."))
    length(times)==length(values) && !isempty(values) || throw(ArgumentError("Nonempty aligned data required."))
    all(_at_finite,values) || throw(ArgumentError("Finite scalar plot values required."))
    ts=oneunit(first(times)); ys=oneunit(first(values))
    fig=Makie.Figure(size=(850,470))
    ax=Makie.Axis(fig[1,1];xlabel="Time / lag [$(_at_unit(first(times)))]",
        ylabel=ylabel===nothing ? "Value [$(_at_unit(first(values)))]" : ylabel,title)
    Makie.lines!(ax,[_at_plot_scale(x,ts) for x in times],[_at_plot_scale(y,ys) for y in values];label="Observed")
    fig,ax,ts,ys
end
"""Plot selected stored scalar observations; unknown times are not index time."""
timeseriesplot(s::ObservableSeries)=first(_ts_curve(s.sampling.times,collect(s.values);title=string(s.name)))
"""Plot normalized scalar correlation, without estimating a new lag window."""
autocorrelationplot(a::AutocorrelationAnalysis)=first(_ts_curve(a.lag_times,a.autocorrelation;title="Finite-sample autocorrelation",ylabel="ρ(k) [dimensionless]"))
"""Display block-size dependence, not an automatically selected plateau."""
function blockplot(b::BlockAnalysis)
    b.evidence.status==:unknown && throw(ArgumentError("Block analysis unavailable."))
    indices=findall(!isnothing,b.standard_errors)
    isempty(indices) && throw(ArgumentError("At least two complete blocks required for plotting SE."))
    ys=b.standard_errors[indices]; scale=oneunit(first(ys))
    fig=Makie.Figure(size=(850,470))
    ax=Makie.Axis(fig[1,1];xlabel="Block size [stored samples]",ylabel="Block-mean SE [$(_at_unit(first(ys)))]",
        title="Block-size diagnostic — independence not established")
    Makie.scatterlines!(ax,b.block_sizes[indices],[_at_plot_scale(y,scale) for y in ys])
    fig
end
"""Plot stored single-origin MSD with an optional already-computed fit window."""
function msdplot(m::MeanSquaredDisplacement;fit=nothing)
    fig,ax,ts,ys=_ts_curve(m.times,m.values.value;title="Single-origin mean-squared displacement")
    if fit!==nothing
        fit isa PropertyResult && fit.value!==nothing || throw(ArgumentError("An available stored diffusion fit is required."))
        r=fit.value; x=collect(r.selected_interval)
        y=r.intercept .+ r.slope.*x
        Makie.lines!(ax,[_at_plot_scale(v,ts) for v in x],[_at_plot_scale(v,ys) for v in y];
            color=:darkorange,linestyle=:dash,label="Selected-window linear fit (heuristic)")
        Makie.axislegend(ax;position=:lt)
    end
    fig
end
"""Plot raw or previously requested normalized VACF; no mean subtraction."""
function vacfplot(v::VelocityAutocorrelation;normalized=false)
    values=normalized ? v.normalized.value : v.raw.value
    first(_ts_curve(v.lag_times,values;title="Particle/origin velocity correlation"))
end
"""Plot stored energy deviations, without recomputing observables or dynamics."""
function energyplot(r::MDTrajectoryAnalysis;observable=:total_energy)
    haskey(r.deviations,observable) || throw(ArgumentError("Request energy diagnostics in analyze first."))
    d=r.deviations[observable]
    d.value===nothing && throw(ArgumentError("Energy deviations unavailable."))
    first(_ts_curve(r.sampling.times,d.value.deviations;title="$(observable) deviation from first frame — no conservation grade"))
end
