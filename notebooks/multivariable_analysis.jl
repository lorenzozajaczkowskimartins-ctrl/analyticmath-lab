# Run: julia --project=. notebooks/multivariable_analysis.jl [output-directory]
# Construct every mathematical report before loading a rendering backend.
using AnalyticMathLab
using Symbolics
import Makie

@variables x y
reports = (
    quadratic = analyze(x^2 + 2y^2 - x*y, (x,y)),
    saddle = analyze(x^2 - y^2, (x,y)),
    quartic = analyze(x^4 + y^4 - 2x^2 - 2y^2, (x,y)),
    excluded_circle = analyze(@real_function(1/(x^2+y^2-1)), (x,y);
        bounds=((-2,2),(-2,2))),
)

for (name, report) in pairs(reports)
    println("\n=== ", name, " ===")
    show(stdout, MIME"text/plain"(), report)
    println()
    for candidate in report.stationary_points.value
        println("  ", candidate.point, ": ", candidate.classification,
            "; residual=", candidate.residual_norm)
    end
end
println("Directional derivative: ", directional_derivative(reports.quadratic,(1,2),(3,4)))
println("Linearization: ", linearization(reports.quadratic,(1,2)))
println("Circle point (1,0) allowed: ", domain_contains(reports.excluded_circle.domain,(1,0)))

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__, "output") : only(ARGS)
mkpath(output)

figures = (
    quadratic_surface = surface(reports.quadratic; xrange=(-3,3), yrange=(-3,3),
        samples=121, tangent_at=(1,1)),
    saddle_contour = contour(reports.saddle; xrange=(-3,3), yrange=(-3,3), samples=151),
    quartic_gradient = gradientplot(reports.quartic; xrange=(-2,2), yrange=(-2,2), samples=13, arrowscale=0.01),
    excluded_circle_contour = contour(reports.excluded_circle;
        xrange=(-2,2), yrange=(-2,2), samples=101, levels=[-10,-3,-1,0,1,3,10]),
)
for (name, figure) in pairs(figures)
    path = joinpath(output, "multivariable_$(name).png")
    save(path, figure)
    println("Saved figure: ", path)
end
