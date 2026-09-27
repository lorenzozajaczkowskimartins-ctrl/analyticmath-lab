### A Pluto.jl notebook ###
# Run: julia +release --project=examples/pinn notebooks/scientific_ml.jl
# CPU-only demonstration; all training is explicit and bounded.
using AnalyticMathLab, Random
import Lux, NeuralPDE, ModelingToolkit, Optimization, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem

@parameters t
@variables u(..)
@named ode=PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],
    [t ∈ (0.,1.)],[t],[u(t)])
network=pinn_network(1,1;hidden=[8],activation=tanh)
problem=pinn_problem(ode;network,strategy=NeuralPDE.GridTraining(0.1),
    rng=Xoshiro(42),adtype=ADTypes.AutoZygote(),provenance=(seed=42,example=:exponential_decay))
inspection=pinn_inspect(problem)
@assert inspection.system===ode
@assert inspection.symbolic_discretization===problem.optimization_problem.f.sys
@assert inspection.discretization isa NeuralPDE.PhysicsInformedNN
println("Independent-variable order: ",inspection.independent_variables)
println("Dependent-variable order: ",inspection.dependent_variables)
println("Backend symbolic costs: ",getproperty.(inspection.loss_components,:kind))
println("Backend versions: ",inspection.provenance.packages)

result=AnalyticMathLab.train(problem,OptimizationOptimisers.Adam(0.02);maxiters=500,
    history=true,log_every=10,history_capacity=100,record_components=true)
@assert pinn_inspect(result).backend_solution===result.solution.original_sol
# Half-offset independent points, not the 0.1 training grid.
points=collect(range(0.0125,0.9875;length=40))
predictions=vec(predict(result,reshape(points,1,:)))
reference=exp.(-points)
errors=abs.(predictions.-reference)
@assert all(isfinite,predictions)
@assert maximum(errors)<0.12
println("Retcode (not physical convergence): ",result.termination.retcode)
println("Optimizer objective: ",result.losses.value.objective)
println("Unweighted component costs: ",result.losses.value.components)
println("Independent sampled maximum absolute error: ",maximum(errors))
println("History records: ",length(result.history.entries),"; truncated: ",result.history.truncated)
println("Low training loss is not proof of a correct physical solution.")
@assert ismissing(AnalyticMathLab.Makie.current_backend())
@assert Base.get_extension(AnalyticMathLab,:AnalyticMathLabMollyExt)===nothing

# Presentation only: consume stored history and the predictions computed above.
using CairoMakie
CairoMakie.activate!()
out=isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(out)
save(joinpath(out,"m9a_loss.png"),lossplot(result))
fig=Figure(size=(1000,650))
ax=Axis(fig[1,1];xlabel="t",ylabel="u(t)",title="PINN: u′ = −u, u(0) = 1")
lines!(ax,points,reference;label="Analytical exp(−t)",linewidth=3)
scatter!(ax,points,predictions;label="PINN at independent points",markersize=7)
axislegend(ax)
err=Axis(fig[2,1];xlabel="t (independent evaluation points)",ylabel="Absolute sampled error")
lines!(err,points,errors)
Label(fig[3,1],"Sampled reference agreement is not a global error bound or a physical certificate.")
save(joinpath(out,"m9a_prediction.png"),fig)
println("Saved M9A loss and prediction/reference/error plots to ",abspath(out))
