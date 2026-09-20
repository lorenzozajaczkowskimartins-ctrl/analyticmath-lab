# Run: julia --project=. notebooks/mechanics.jl [output-directory]
using AnalyticMathLab, Symbolics
import Makie
@variables q v p r w t m k
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.simplify_fractions(e);expand=true))

free = analyze(LagrangianSystem(m*v^2/2;coordinates=(q,),velocities=(v,),nonzero=(m,)))
oscillator = analyze(LagrangianSystem(m*v^2/2-k*q^2/2;coordinates=(q,),velocities=(v,),nonzero=(m,)))
pendulum = analyze(LagrangianSystem(v^2/2+cos(q);coordinates=(q,),velocities=(v,)))
damped = analyze(LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),rayleigh=v^2/4))
coupled = analyze(LagrangianSystem((v^2+w^2-q^2-(r-q)^2)/2;coordinates=(q,r),velocities=(v,w)))
driven = analyze(LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),time=t,forces=(sin(t),)))
central = analyze(LagrangianSystem((v^2+q^2*w^2)/2+1/q;coordinates=(q,r),velocities=(v,w),nonzero=(q,)))
singular = analyze(LagrangianSystem((v+w)^2;coordinates=(q,r),velocities=(v,w)))
hamiltonian = legendre_transform(oscillator;momenta=(p,))
@assert hamiltonian.status == :established
@assert zero_identity(only(free.accelerations.value))
@assert zero_identity(only(oscillator.accelerations.value)+k*q/m)
@assert zero_identity(hamiltonian.value.energy-p^2/(2m)-k*q^2/2)
@assert zero_identity(poisson_bracket(hamiltonian.value,q,p)-1)
@assert zero_identity(only(pendulum.accelerations.value)+sin(q))
@assert zero_identity(damped.energy_rate+v^2/2)
@assert only(central.cyclic).conservation.value === true
@assert singular.regularity.value === false
@assert legendre_transform(singular).status == :unknown
@assert legendre_transform(damped).status == :unknown

hd = dynamics(hamiltonian.value;parameters=Dict(m=>1,k=>1))
pd, dd, cd, td = dynamics(pendulum), dynamics(damped), dynamics(coupled), dynamics(driven)
orbit = trajectory(hd,[1,0],(0,2pi);saveat=0.05,abstol=1e-10,reltol=1e-10)
swing = trajectory(pd,[1,0],(0,12);saveat=0.05)
decay = trajectory(dd,[1,0],(0,16);saveat=0.05)
exchange = trajectory(cd,[1,0,0,0],(0,12);saveat=0.05)
response = trajectory(td,[0,0],(0,6);saveat=0.05)
@assert isapprox(orbit.solution.u[end],[1,0];atol=1e-7)
@assert isapprox(orbit.solution(0.137),[cos(0.137),-sin(0.137)];atol=1e-7)
@assert energy_drift(hd,orbit).value.maximum_absolute_drift < 1e-7
@assert last(energy_drift(dd,decay).value.values) < 0.001
@assert all(path->path.diagnostics.success && path.diagnostics.completed,(orbit,swing,decay,exchange,response))
@assert ismissing(Makie.current_backend())
println("All symbolic identities and five trajectory examples passed before backend loading.")
println("Oscillator maximum saved energy drift: ",energy_drift(hd,orbit).value.maximum_absolute_drift)
println("Damped final saved energy: ",last(energy_drift(dd,decay).value.values))

using CairoMakie
output = isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(output)
for (name,fig) in (
        ("oscillator_phase",phaseplot(hd;trajectories=[orbit],energy_levels=[0.5,1.0],samples=13)),
        ("oscillator_energy",energyplot(hd,orbit)),
        ("pendulum_phase",phaseplot(pd;trajectories=[swing],xrange=(-3,3),yrange=(-2,2),samples=13)),
        ("damped_energy",energyplot(dd,decay)),
        ("coupled_time",timeplot(exchange)),
        ("driven_time",timeplot(response)))
    file = joinpath(output,"mechanics_$(name).png")
    save(file,fig)
    println("Saved figure: ",abspath(file))
end
