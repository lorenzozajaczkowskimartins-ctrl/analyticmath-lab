"""
    plot(report::FunctionAnalysis; xmin=-5, xmax=5, samples=501)

Return a Makie Figure with the function and stored stationary candidates in the
plot window. Load a backend such as CairoMakie before rendering. This method
neither recomputes analysis, activates a backend, opens a window, nor saves files.

Uniform sampling is intended for simple functions. Sampled domain errors and
nonfinite values become gaps; discontinuities between samples may still be
connected. Plot bounds are a view, not an inferred mathematical domain.
"""
function plot(report::FunctionAnalysis; xmin::Real=-5, xmax::Real=5,
              samples::Integer=501)
    a, b = _interval_bounds((xmin, xmax))
    samples >= 2 || throw(ArgumentError("samples must be at least 2"))
    xs = range(a, b; length=samples)
    ys = [_plot_value(report, t) for t in xs]
    figure = Makie.Figure()
    axis = Makie.Axis(figure[1, 1]; xlabel=string(report.variable), ylabel="f(x)",
                      title=string(report.expression))
    Makie.lines!(axis, xs, ys; label="f(x)")
    points = filter(p -> a <= p.x <= b, report.critical_points.points)
    if !isempty(points)
        Makie.scatter!(axis, getproperty.(points, :x), getproperty.(points, :value);
                       color=:orange, markersize=12, label="Stationary candidates")
        Makie.axislegend(axis)
    end
    Makie.xlims!(axis, a, b)
    return figure
end

function _plot_value(report, x)
    value = try
        evaluate(report, x)
    catch error
        error isa DomainError || rethrow()
        return NaN
    end
    return value isa Real && isfinite(value) ? Float64(value) : NaN
end
