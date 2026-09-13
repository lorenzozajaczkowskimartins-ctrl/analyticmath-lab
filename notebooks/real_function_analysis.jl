# Run: julia --project=. notebooks/real_function_analysis.jl [output-directory]
# Mathematical studies are constructed before any rendering backend is loaded.
using AnalyticMathLab
using Symbolics
import Makie

@variables x
# Capture syntax before symbolic arithmetic: original restrictions survive even
# if an expression is automatically simplified while it is being constructed.
examples = (
    removable = @real_function((x^2 - 1) / (x - 1)),
    rational = @real_function((x^2 - 4) / (x^2 - 1)),
)
reports = map(expression -> analyze(expression, x), examples)
for (name, report) in pairs(reports)
    println("\n=== ", name, " ===")
    show(stdout, MIME"text/plain"(), report)
    println()
end

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__, "output") : only(ARGS)
mkpath(output)
for (name, report) in pairs(reports)
    figure = plot(report; xmin=-4, xmax=4, samples=801)
    # Display limits only: do not let near-pole samples hide finite features.
    axis = only(filter(item -> item isa Makie.Axis, figure.content))
    ylims!(axis, -6, 6)
    path = joinpath(output, "real_function_$(name).png")
    save(path, figure)
    println("Saved figure: ", path)
end
