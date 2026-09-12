# Run from the repository root: julia --project=. notebooks/function_analysis.jl
# This script is also suitable for executing cell-by-cell in a Julia notebook.
using AnalyticMathLab
using Symbolics
using CairoMakie

@variables x
f = x^3 - 6x^2 + 9x + 1
report = analyze(f, x; interval=(0, 4))
show(stdout, MIME"text/plain"(), report)
println()

comparison = compare_derivatives(report, 2.0)
println("Derivative values at x=2: ", comparison.values)
println("Absolute discrepancies: ", comparison.absolute_errors)

fig = plot(report; xmin=0, xmax=4)
output = joinpath(@__DIR__, "output")
mkpath(output)
path = joinpath(output, "function_analysis.png")
save(path, fig)
println("Saved figure: ", path)
