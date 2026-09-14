# Adapt a stored component to the existing original-domain scalar rendering grid.
struct _NullclineView{F,D,V}
    field::F
    component::Int
    dimension::Int
    domain::D
    variables::V
end
evaluate(view::_NullclineView,p::Union{Tuple,AbstractVector}) = evaluate(view.field,p)[view.component]

function _ds_segment_allowed(field,a,b)
    domain_contains(field.domain,a) === true && domain_contains(field.domain,b) === true || return false
    names = Symbol[_mv_ast(v) for v in field.variables]
    box = tuple(((min(a[i],b[i]),max(a[i],b[i])) for i in eachindex(a))...)
    for restriction in field.domain.restrictions
        low,high = _mv_interval(restriction.expression,names,box)
        ok = restriction.relation == :nonzero ? !(low <= 0 <= high) :
            restriction.relation == :positive ? low > 0 : low >= 0
        ok || return false
    end
    return true
end

"""
    phaseplot(report; trajectories=(), show_nullclines=false, ...)

Planar autonomous field, stored equilibrium markers and precomputed trajectories.
No solving or stability inference occurs here. Arrows are unnormalized with an
explicit scale; line segments crossing unresolved domain cells are omitted.
Only trajectories produced from this report's underlying field are accepted.
"""
function phaseplot(report::DynamicalSystemAnalysis; trajectories=(),show_nullclines::Bool=false,
        xrange=(-2,2),yrange=(-2,2),samples::Integer=15,arrowscale::Real=0.1)
    report.dimension == 2 || throw(ArgumentError("phase portraits require two state variables"))
    for path in trajectories
        path isa TrajectoryResult && path.problem.function_value isa _AutonomousRHS &&
            path.problem.function_value.field === report.field ||
            throw(ArgumentError("phase trajectories must originate from this report's field"))
    end
    fig = vectorplot(report.field;xrange,yrange,samples,arrowscale)
    axis = only(filter(c -> c isa Makie.Axis,fig.content))
    axis.title = "Phase portrait (unnormalized; scale=$(Float64(arrowscale)))"
    for (k,path) in enumerate(trajectories)
        xs = Float64[]; ys = Float64[]
        previous = nothing
        for u in path.solution.u
            if previous !== nothing && !_ds_segment_allowed(report.field,previous,u)
                push!(xs,NaN); push!(ys,NaN)
            end
            allowed = domain_contains(report.domain,u) === true
            push!(xs,allowed ? u[1] : NaN); push!(ys,allowed ? u[2] : NaN)
            previous = u
        end
        Makie.lines!(axis,xs,ys;linewidth=2,label="trajectory $k ($(path.diagnostics.retcode))")
    end
    if show_nullclines
        for i in 1:2
            view = _NullclineView(report.field,i,2,report.domain,report.variables)
            xs,ys,zs = _mv_grid(view,xrange,yrange,101)
            Makie.contour!(axis,xs,ys,zs;levels=[0.0],color=i==1 ? :darkorange : :purple,
                linewidth=2,linestyle=:dash,label="$(report.variables[i])′ = 0")
        end
    end
    for (k,e) in enumerate(report.equilibria.value)
        domain_contains(report.domain,e.point) === true || continue
        Makie.scatter!(axis,[Float64(e.point[1])],[Float64(e.point[2])];
            color=:red,strokecolor=:white,strokewidth=1,markersize=13,
            label="equilibrium $k ($(e.status))")
    end
    (!isempty(trajectories) || !isempty(report.equilibria.value) || show_nullclines) &&
        Makie.Legend(fig[1,2],axis)
    return fig
end

"""Plot saved state values versus time; no RHS calls, interpolation or new solving."""
function timeplot(path::TrajectoryResult)
    fig = Makie.Figure()
    axis = Makie.Axis(fig[1,1];xlabel="t",ylabel="state",
        title="Numerical trajectory ($(path.diagnostics.retcode))")
    for i in 1:path.problem.dimension
        Makie.lines!(axis,path.solution.t,[u[i] for u in path.solution.u];
            label=path.labels[i],linewidth=2)
    end
    Makie.Legend(fig[1,2],axis)
    return fig
end
