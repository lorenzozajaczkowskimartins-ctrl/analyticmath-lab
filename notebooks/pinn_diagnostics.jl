### A Pluto.jl notebook ###
# Run: julia +release --project=examples/pinn notebooks/pinn_diagnostics.jl
# Bounded CPU heat-equation showcase; no base-test dependency.
using AnalyticMathLab, Test
include(joinpath(@__DIR__,"..","examples","pinn","benchmarks.jl"))
const B=PINNBenchmarks
heat=B.run(:heat;maxiters=1500,n=21)
a=heat.analysis
B.report(heat)
@testset "M9B heat showcase" begin
    @test a.reference.value.summary[1].max_absolute<0.2
    @test a.residuals[1].summary.rms<0.3
    @test maximum(r.summary.rms for r in a.residuals if r.role!=:pde)<0.2
    @test all(r->all(isfinite,r.values),a.residuals)
    @test length(heat.result.history.entries)>1
    @test a.reference.value.provenance.kind==:analytical
    @test a.evidence.status==:unknown
    @test ismissing(AnalyticMathLab.Makie.current_backend())
end
using CairoMakie
CairoMakie.activate!()
out=isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(out)
save(joinpath(out,"m9b_heat_panel.png"),pinnplot(a))
save(joinpath(out,"m9b_heat_residual.png"),residualplot(a))
save(joinpath(out,"m9b_heat_error.png"),errorplot(a))
save(joinpath(out,"m9b_heat_collocation.png"),collocationplot(a))
save(joinpath(out,"m9b_heat_components.png"),losscomponentsplot(a))
save(joinpath(out,"m9b_heat_history.png"),lossplot(heat.result))
println("Plots consume stored diagnostics only. Output: ",abspath(out))
println("Snapshot only: resampling history and domain coverage are not established.")
println("Adaptive weight evolution is not available.")
