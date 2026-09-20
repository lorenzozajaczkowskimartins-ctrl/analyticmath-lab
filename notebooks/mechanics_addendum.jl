# Executable M7 addendum; generic spring models are not realistic molecules.
# Run: julia --project=. notebooks/mechanics_addendum.jl
using AnalyticMathLab, Symbolics
import LinearAlgebra, Makie
@variables x y z v w u t p s
identity_zero(e) = AnalyticMathLab._mc_zero(e)

# Effective damping models, not fluid dynamics.
viscous = analyze(LagrangianSystem((v^2-x^2)/2;coordinates=(x,),velocities=(v,),rayleigh=v^2/4))
stokes = analyze(LagrangianSystem(v^2/2;coordinates=(x,),velocities=(v,),forces=(-6*pi*2*3*v,)))
quadratic = analyze(LagrangianSystem(v^2/2;coordinates=(x,),velocities=(v,),forces=(-2abs(v)*v,)))
@assert identity_zero(only(viscous.accelerations.value)+x+v/2)
@assert identity_zero(only(stokes.accelerations.value)+36pi*v)
@assert identity_zero(only(quadratic.accelerations.value)+2abs(v)*v)
println("Stokes example assumes creeping flow / low Reynolds number around a sphere.")

driven = analyze(LagrangianSystem((v^2-x^2)/2;coordinates=(x,),velocities=(v,),time=t,
    rayleigh=v^2/4,forces=(2cos(3t),)))
@assert identity_zero(only(driven.accelerations.value)+x+v/2-2cos(3t))
@assert driven.energy_conservation.status == :unknown
conversion = dynamics(driven)
response = trajectory(conversion,[0,0],(0,16);saveat=0.05,abstol=1e-10,reltol=1e-10)
@assert response.diagnostics.success && response.diagnostics.completed
@assert energy_drift(conversion,response).status == :heuristic

# The same stored scalar-field derivatives feed force and stiffness.
U = 3*((y-x)-2)^2/2
potential_report = analyze(U,(x,y))
F = force_from_potential(potential_report)
Kpair = AnalyticMathLab.hessian(potential_report,(0,2))
@assert identity_zero(sum(F))
@assert Kpair == [3 -3;-3 3]
hamiltonian = analyze(HamiltonianSystem(p^2/4+s^2/10+U;coordinates=(x,y),momenta=(p,s)))
@assert all(identity_zero.(hamilton_equations(hamiltonian)-[p/2,s/5,F...]))
println("Unequal-mass pair: stored gradient, Hessian and Hamilton equations verified.")

# Normal-mode demonstrations follow below; no particle simulation is performed.
harmonic=normal_modes(LagrangianSystem((v^2-4x^2)/2;coordinates=(x,),velocities=(v,)),(0,))
coupled=normal_modes(LagrangianSystem((v^2+w^2-x^2-y^2-(y-x)^2)/2;
    coordinates=(x,y),velocities=(v,w)),(0,0))
pendulum=analyze(LagrangianSystem(3*2^2*v^2/2-3*10*2*(1-cos(x));coordinates=(x,),velocities=(v,)))
pendulum_modes=normal_modes(pendulum,(0,))
@assert harmonic.frequencies ≈ [2]
@assert coupled.eigenvalues ≈ [1,3]
@assert coupled.mode_vectors[1,1] ≈ coupled.mode_vectors[2,1]
@assert coupled.mode_vectors[1,2] ≈ -coupled.mode_vectors[2,2]
@assert pendulum_modes.eigenvalues ≈ [5]
@assert identity_zero(only(pendulum.accelerations.value)+5sin(x))
@assert linearize_mechanics(viscous,(0,)).damping_matrix == [1/2;;]
pair=normal_modes(Kpair,cartesian_mass_matrix([2,5],1);equilibrium=(0,2),
    metadata=(coordinate_layout=(particle_count=2,spatial_dimension=1,ordering=:particle_major),))
three=normal_modes([2 -2 0;-2 5 -3;0 -3 3],cartesian_mass_matrix([1,2,4],1);
    equilibrium=(0,1,2),metadata=(coordinate_layout=(particle_count=3,spatial_dimension=1,ordering=:particle_major),))
@assert pair.classifications == [:zero,:oscillatory]
@assert isapprox(pair.eigenvalues,[0,21/10];atol=1e-12)
@assert pair.mode_vectors[1,1] ≈ pair.mode_vectors[2,1]
@assert pair.mass_inverse_sqrt*pair.weighted_vectors ≈ pair.mode_vectors
@assert length(three.zero_modes)==1
@assert isapprox(three.reconstruction,three.stiffness_matrix;atol=1e-12)
@assert ismissing(Makie.current_backend())
println("Coupled squared frequencies: ",coupled.eigenvalues)
println("Pendulum local squared frequency g/l: ",only(pendulum_modes.eigenvalues))
println("Pair squared frequencies (translation, internal): ",pair.eigenvalues)
println("Three unequal-mass squared frequencies: ",three.eigenvalues)
println("All generic mode checks passed; future molecular dynamics is not implemented.")

using CairoMakie
output=joinpath(@__DIR__,"output")
mkpath(output)
for (name,figure) in (("coupled_modes",modeplot(coupled)),
        ("pair_modes",modeplot(pair)),("three_mass_modes",modeplot(three)),
        ("driven_damped",timeplot(response)))
    path=joinpath(output,"mechanics_addendum_$(name).png")
    save(path,figure)
    println("Saved: ",abspath(path))
end
