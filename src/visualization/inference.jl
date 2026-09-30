"""Stored inference panel. No solve, optimization, differentiation, or resampling.
Lines connect stored predictions only. Makie backend remains caller-controlled.
"""
function parameterfitplot(r::ParameterInferenceResult;variable::Integer=1)
    obs=r.problem.observations
    1<=variable<=length(obs.variables) || throw(ArgumentError("invalid observed variable index"))
    fig=Makie.Figure(size=(1100,760))
    ax=Makie.Axis(fig[1,1];xlabel="Time (supplied numerical coordinates)",ylabel=obs.variables[variable],
        title="Fit and excluded held-out observations")
    Makie.scatter!(ax,obs.times,obs.values[variable,:];label="Fit observations",color=:black)
    Makie.lines!(ax,obs.times,r.prediction[variable,:];label="Fitted prediction (stored)",color=:royalblue)
    if r.heldout!==nothing
        h=r.heldout
        Makie.scatter!(ax,h.observations.times,h.observations.values[variable,:];label="Held-out observations",marker=:xcross,color=:darkorange)
        Makie.lines!(ax,h.observations.times,h.prediction[variable,:];label="Held-out prediction",linestyle=:dash,color=:darkorange)
    end
    Makie.axislegend(ax;position=:rt)
    history=Makie.Axis(fig[1,2];xlabel="Optimizer iteration",ylabel="Sum of squared residuals",title="Stored objective history")
    entries=r.history.entries
    isempty(entries) || Makie.lines!(history,getproperty.(entries,:iteration),getproperty.(entries,:objective);color=:royalblue)
    sensitivity=Makie.Axis(fig[2,1];xlabel="Singular-value index",ylabel="Weighted sensitivity singular value",
        title="Local rank=$(r.sensitivity.value.rank), condition=$(round(r.sensitivity.value.condition;sigdigits=4))")
    values=r.sensitivity.value.singular_values
    Makie.scatter!(sensitivity,collect(eachindex(values)),values;markersize=14)
    lines=["$(n) = $(round(v;sigdigits=7))" for (n,v) in zip(r.problem.parameters.inferred,r.parameters)]
    if r.reference_comparison!==nothing
        append!(lines,["Absolute recovery error: $(round.(r.reference_comparison.absolute_error;sigdigits=3))",
            "Reference kind: $(r.reference_comparison.kind)"])
    end
    push!(lines,"Fit RMS: $(round(r.fit.rms;sigdigits=4))")
    r.heldout===nothing || push!(lines,"Held-out RMS: $(round(r.heldout.error.rms;sigdigits=4))")
    push!(lines,"Optimizer retcode: $(r.termination.retcode)")
    push!(lines,"Termination is not physical validation.")
    Makie.Label(fig[2,2],join(lines,"\n");halign=:left,tellwidth=false)
    Makie.Label(fig[3,1:2],"Synthetic recovery does not establish global identifiability. Local conditioning depends on units and scales.";
        fontsize=14,tellwidth=false)
    fig
end
