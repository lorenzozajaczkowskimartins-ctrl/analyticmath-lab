# Run: julia --project=. notebooks/vector_field_analysis.jl [output-directory]
using AnalyticMathLab, Symbolics
import Makie
@variables x y

rotation = analyze([-y,x],(x,y))
radial = analyze([2x,2y],(x,y))
punctured = analyze(@real_function([-y/(x^2+y^2),x/(x^2+y^2)]),(x,y))
rectangular = analyze([x+y,x-y,x^2],(x,y))

@assert jacobian(rotation) == [0 -1;1 0]
@assert divergence(rotation).value == 0
@assert curl(rotation).value == 2
@assert only(rotation.field_zeros.value).point == [0,0]
@assert rotation.conservative.value === false
@assert divergence(radial).value == 4
@assert curl(radial).value == 0
@assert radial.conservative.status == :established && radial.conservative.value === true
@assert iszero(Symbolics.simplify(potential(radial).value - x^2-y^2;expand=true))
@assert domain_contains(punctured.domain,(0,0)) === false
@assert iszero(curl(punctured).value)
@assert punctured.conservative.status == :unknown
@assert potential(punctured).status == :unknown
@assert size(jacobian(rectangular)) == (3,2)
@assert evaluate(rectangular,(1,2)) == [3,-1,1]
@assert all(p -> p.status == :unknown,(divergence(rectangular),curl(rectangular),potential(rectangular),rectangular.conservative))
@assert size(linearization(rectangular,(1,2)).coefficients) == (3,2)
@assert ismissing(Makie.current_backend())

for (label,report) in (("Rotation",rotation),("Radial gradient",radial),
        ("Punctured-plane topology trap",punctured),("Rectangular map",rectangular))
    println("\n=== ",label," ===")
    show(stdout,MIME"text/plain"(),report)
    println()
end
println("Rectangular Jacobian at (1,2): ",jacobian(rectangular,(1,2)))
println("All mathematical example assertions passed before backend loading.")

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(output)
for (name,report,scale) in (("rotation",rotation,0.12),("radial",radial,0.06),
        ("punctured",punctured,0.035))
    figure = vectorplot(report;xrange=(-2,2),yrange=(-2,2),samples=17,arrowscale=scale)
    path = joinpath(output,"vector_field_$(name).png")
    save(path,figure)
    println("Saved figure: ",abspath(path))
end
