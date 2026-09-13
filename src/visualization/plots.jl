"""
    plot(report::FunctionAnalysis; xmin=-5, xmax=5, samples=501)

Return a Makie Figure with the function and stored stationary candidates in the
plot window. Load a backend such as CairoMakie before rendering. This method
neither recomputes analysis, activates a backend, opens a window, nor saves files.

Stored established domains split curves at component boundaries, even between
samples. Unknown domains retain sampled gaps only. Stored finite features decorate
the view without inference. Plot bounds are a view, not a mathematical domain.
"""
function plot(report::FunctionAnalysis; xmin::Real=-5, xmax::Real=5,
              samples::Integer=501)
    a, b = _interval_bounds((xmin, xmax))
    samples >= 2 || throw(ArgumentError("samples must be at least 2"))
    xs, ys = _real_plot_curve(report, a, b, samples)
    figure = Makie.Figure()
    axis = Makie.Axis(figure[1, 1]; xlabel=string(report.variable), ylabel="f(x)",
                      title=string(report.expression))
    Makie.lines!(axis, xs, ys; label="f(x)")
    px, py = _real_plot_points(report, a, b)
    if !isempty(px)
        Makie.scatter!(axis, px, py;
                       color=:orange, markersize=12, label="Stored features / stationary candidates")
        Makie.axislegend(axis; position=:rb)
    end
    _real_plot_asymptotes!(axis, report.real_analysis, a, b)
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

"""
    plot(result::DerivativeConvergenceAnalysis)

Return a log-log Makie Figure from stored errors only. The subtitle annotates the
sampled minimum even when it is zero; positive minima also receive a marker.
Zero errors cannot appear on a log axis: omit them explicitly, state their count,
and never replace them with epsilon. An all-zero result has an empty log-log axis
and an explanatory subtitle. No analysis, evaluation, backend activation, window,
or file output occurs. Load a backend yourself before rendering.
"""
function plot(result::DerivativeConvergenceAnalysis)
    positive = findall(>(0), result.absolute_errors)
    omitted = length(result.steps) - length(positive)
    subtitle = "Sampled minimum = $(result.minimum_error) at h = $(result.best_step)"
    if omitted > 0
        subtitle *= "\n$(omitted) zero errors omitted from logarithmic axis"
    end
    figure = Makie.Figure()
    axis = Makie.Axis(figure[1, 1]; xlabel="Step h", ylabel="Absolute derivative error",
        xscale=log10, yscale=log10,
        title="$(result.method) differences at x = $(result.point)", subtitle)
    if !isempty(positive)
        Makie.lines!(axis, result.steps[positive], result.absolute_errors[positive])
        if result.minimum_error > 0
            Makie.scatter!(axis, [result.best_step], [result.minimum_error]; color=:orange, markersize=12)
        end
    else
        # Display limits only, not invented observations or an epsilon error floor.
        Makie.ylims!(axis, 0.1, 1.0)
    end
    Makie.xlims!(axis, last(result.steps), first(result.steps))
    return figure
end
