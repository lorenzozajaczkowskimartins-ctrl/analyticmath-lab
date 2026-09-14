# Run: julia --project=. notebooks/dynamical_systems.jl [output-directory]
using AnalyticMathLab, Symbolics
import Makie
@variables x v

field = analyze([v,-x],(x,v))
rotation = analyze(AutonomousSystem(field))
damped = analyze(AutonomousSystem([v,-x-v/2],(x,v)))
saddle = analyze(AutonomousSystem([x,-v],(x,v)))
logistic = analyze(AutonomousSystem([x*(1-x)],(x,)))
nonhyperbolic = analyze(AutonomousSystem([-x^3],(x,)))
hole = analyze(AutonomousSystem(@real_function([x/x]),(x,)))

@assert rotation.field === field
@assert only(stability(rotation)).stability.value == :center
@assert only(stability(damped)).stability.value == :locally_asymptotically_stable
@assert only(stability(saddle)).stability.value == :saddle
@assert only(stability(nonhyperbolic)).stability.status == :unknown
@assert domain_contains(hole.domain,[0]) === false
@assert jacobian(rotation,(0,0)) == [0 1;-1 0]
@assert length(nullclines(rotation).value) == 2
@assert length(equilibria(logistic).value) == 2

orbit = trajectory(rotation,[1,0],(0,2pi);saveat=0.05,abstol=1e-10,reltol=1e-10)
decay = trajectory(damped,[1,0],(0,20);saveat=0.05)
escape = trajectory(saddle,[0.1,1],(0,2);saveat=0.05)
growth = trajectory(logistic,0.25,(0,8);saveat=0.05)
forced = trajectory(FirstOrderODE((u,t)->[-2t*u[1]],1;labels=("y",)),1.0,(0,2);saveat=0.05)
@assert isapprox(orbit.solution.u[end], [1,0]; atol=1e-7)
@assert maximum(abs(sum(abs2,u)-1) for u in orbit.solution.u) < 1e-7
@assert sum(abs2,decay.solution.u[end]) < 1e-3
@assert isapprox(escape.solution.u[end], [0.1exp(2),exp(-2)]; atol=1e-6)
@assert isapprox(growth.solution.u[end][1], 1/(1+3exp(-8)); atol=1e-6)
@assert isapprox(forced.solution.u[end][1], exp(-4); atol=1e-7)
@assert all(p -> p.diagnostics.success && p.diagnostics.completed,(orbit,decay,escape,growth,forced))
@assert ismissing(Makie.current_backend())
@assert all(m -> nameof(m) ∉ (:CairoMakie,:GLMakie),values(Base.loaded_modules))

for (name,report) in (("Rotation",rotation),("Damping",damped),("Saddle",saddle),
        ("Logistic growth",logistic),("Nonhyperbolic: inconclusive",nonhyperbolic),("Preserved hole",hole))
    println("\n=== ",name," ===")
    show(stdout,MIME"text/plain"(),report)
    println()
end
for path in (orbit,decay,escape,growth,forced)
    show(stdout,MIME"text/plain"(),path)
    println()
end
println("All mathematical example assertions passed before backend loading.")

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(output)
for (name,figure) in (
        ("rotation_phase",phaseplot(rotation;trajectories=[orbit],show_nullclines=true,samples=13)),
        ("damped_phase",phaseplot(damped;trajectories=[decay],show_nullclines=true,samples=13)),
        ("saddle_phase",phaseplot(saddle;trajectories=[escape],show_nullclines=true,samples=13)),
        ("damped_time",timeplot(decay)),
        ("logistic_time",timeplot(growth)),
        ("nonautonomous_time",timeplot(forced)))
    target = joinpath(output,"dynamical_$(name).png")
    save(target,figure)
    println("Saved figure: ",abspath(target))
end
