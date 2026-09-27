# These views consume M8C output only. They never align curves or recalculate SE.
function _cmp_unavailable_plot(c)
    fig=Makie.Figure(size=(900,500))
    Makie.Label(fig[1,1],"Comparison $(c.compatibility.status) — $(c.quantity)";
        fontsize=22,tellwidth=false)
    reasons=isempty(c.compatibility.reasons) ? c.difference.notes : c.compatibility.reasons
    Makie.Label(fig[2,1],join(reasons,"\n");fontsize=14,tellwidth=false,word_wrap=true)
    fig
end
_cmp_plot_unit(c,v)=c.metadata.a.dimensionless ? "dimensionless / counts" : _at_unit(v)
function _cmp_grid_label(c)
    c.a.result isa BlockAnalysis && return "Block size [saved samples]"
    s=c.metadata.a.sampling
    s!==nothing && s.units=="sample index" && return "Lag [saved-sample index]"
    "Time / lag [$(_at_unit(first(c.metadata.a.grid)))]"
end

"""Overlay compatible stored curves or scalar values. No new error estimates.
Incompatible/unknown comparisons produce a labeled refusal figure, not a fake zero.
"""
function comparisonplot(c::ObservableComparison)
    c.difference.value===nothing && return _cmp_unavailable_plot(c)
    x,y=c.metadata.a.value,c.metadata.b.value
    fig=Makie.Figure(size=(900,500))
    values=_cmp_values(x); scale=oneunit(first(values))
    ax=Makie.Axis(fig[1,1];title="$(c.quantity): stored A and B — descriptive only",
        ylabel="Value [$(_cmp_plot_unit(c,first(values)))]")
    labels=(c.a.label===nothing ? "A" : string(c.a.label),c.b.label===nothing ? "B" : string(c.b.label))
    if x isa AbstractArray
        grid=c.metadata.a.grid; tscale=oneunit(first(grid))
        times=[_at_plot_scale(t,tscale) for t in grid]
        ax.xlabel=_cmp_grid_label(c)
        Makie.lines!(ax,times,[_at_plot_scale(v,scale) for v in x];label=labels[1])
        Makie.lines!(ax,times,[_at_plot_scale(v,scale) for v in y];label=labels[2],linestyle=:dash)
        Makie.axislegend(ax)
    else
        ax.xticks=([1,2],collect(labels))
        Makie.scatter!(ax,[1,2],[_at_plot_scale(x,scale),_at_plot_scale(y,scale)])
    end
    fig
end

"""Plot stored B − A. Scalar SE bars appear only when M8C propagated uncertainty;
these are heuristic standard errors, not confidence intervals or significance.
"""
function differenceplot(c::ObservableComparison)
    c.difference.value===nothing && return _cmp_unavailable_plot(c)
    d=c.difference.value; values=_cmp_values(d); scale=oneunit(first(values))
    fig=Makie.Figure(size=(900,500))
    ax=Makie.Axis(fig[1,1];title="$(c.quantity): B − A — no significance claim",
        ylabel="Difference [$(_cmp_plot_unit(c,first(values)))]")
    if d isa AbstractArray
        grid=c.metadata.a.grid; tscale=oneunit(first(grid))
        ax.xlabel=_cmp_grid_label(c)
        Makie.lines!(ax,[_at_plot_scale(t,tscale) for t in grid],[_at_plot_scale(v,scale) for v in d])
    else
        value=_at_plot_scale(d,scale)
        ax.xticks=([1],["B − A"])
        Makie.scatter!(ax,[1],[value])
        if c.uncertainty.value!==nothing
            Makie.errorbars!(ax,[1],[value],[_at_plot_scale(c.uncertainty.value,scale)])
            Makie.Label(fig[2,1],"±1 heuristic SE; independent estimators explicitly assumed")
        else
            Makie.Label(fig[2,1],"Combined uncertainty unavailable; independence is not inferred")
        end
    end
    fig
end
