# Run: julia --project=. notebooks/derivative_convergence.jl [output-directory]
# Execute cell-by-cell in a notebook, or run as a script. No backend is loaded
# until the mathematical results have been constructed.
using AnalyticMathLab
using Symbolics

@variables x
report = analyze(sin(x), x)
forward = derivative_convergence(report, 0.4; method=:forward)
central = derivative_convergence(report, 0.4; method=:central)

# Each method has its own stored result. Float64 roundoff eventually competes
# with truncation error. Reported orders are empirical and may be unavailable;
# the evaluated symbolic reference is not a rigorous error oracle.
for result in (forward, central)
    show(stdout, MIME"text/plain"(), result)
    println()
end

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__, "output") : only(ARGS)
mkpath(output)
for result in (forward, central)
    path = joinpath(output, "derivative_convergence_$(result.method).png")
    save(path, plot(result))
    println("Saved figure: ", path)
end
