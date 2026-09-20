"""
    potentialplot(report::PotentialAnalysis; rmin, rmax, samples=501)

Plot stored energy and radial force callables on an explicit positive interval.
No symbolic analysis is repeated. Original-domain separators are reused from the
scalar view; NaN gaps are rendering omissions, not inferred limits. Cutoff metadata
never modifies the curves. Load a Makie backend only in the caller for rendering.
"""
function _potential_plot_data(p::PotentialAnalysis,rmin,rmax,samples)
    a,b=_interval_bounds((rmin,rmax))
    a>0 || throw(ArgumentError("plot radius must be positive"))
    samples>=2 || throw(ArgumentError("samples must be at least two"))
    xs,ys=_real_plot_curve(p.function_analysis,a,b,samples)
    fs=map(eachindex(xs)) do i
        isfinite(ys[i]) || return NaN
        value=try p.numerical.force(xs[i]) catch err
            err isa DomainError || rethrow()
            return NaN
        end
        value isa Real && isfinite(value) ? Float64(value) : NaN
    end
    (a,b,xs,ys,fs)
end
"""Plot stored pair energy and radial force on an explicit positive interval; no backend activation."""
function potentialplot(p::PotentialAnalysis;rmin::Real,rmax::Real,samples::Integer=501)
    a,b,xs,ys,fs=_potential_plot_data(p,rmin,rmax,samples)
    fig=Makie.Figure(size=(900,650))
    radius="r [$(p.units.length)]"
    ax=Makie.Axis(fig[1,1];xlabel=radius,ylabel="U [$(p.units.energy)]",title="Pair energy — unmodified scalar model")
    af=Makie.Axis(fig[2,1];xlabel=radius,ylabel="F = -dU/dr",title="Radial force")
    Makie.lines!(ax,xs,ys)
    Makie.lines!(af,xs,fs;color=:darkorange)
    if p.equilibria.value!==nothing
        points=filter(q->a<=q.x<=b,p.equilibria.value)
        if !isempty(points)
            Makie.scatter!(ax,Float64[q.x for q in points],Float64[q.value for q in points];
                color=:red,label="Stored stationary points")
            Makie.axislegend(ax;position=:rt)
        end
    end
    Makie.hlines!(af,[0.];color=:gray,linestyle=:dash)
    fig
end
plot(p::PotentialAnalysis;kwargs...)=potentialplot(p;kwargs...)

"""Plot the stored radial force F=-dU/dr without analysis or backend activation."""
function forceplot(p::PotentialAnalysis;rmin::Real,rmax::Real,samples::Integer=501)
    _,_,xs,_,fs=_potential_plot_data(p,rmin,rmax,samples)
    fig=Makie.Figure(size=(900,400))
    ax=Makie.Axis(fig[1,1];xlabel="r [$(p.units.length)]",
        ylabel="F [$(p.units.energy)/$(p.units.length)]",title="Radial force — unmodified scalar model")
    Makie.lines!(ax,xs,fs;color=:darkorange)
    Makie.hlines!(ax,[0.];color=:gray,linestyle=:dash)
    fig
end
