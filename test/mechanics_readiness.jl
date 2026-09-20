module MechanicsReadinessTests
using Test, AnalyticMathLab, Symbolics
import LinearAlgebra
const AML = AnalyticMathLab
@variables x y v w t p s k r0
z(e) = AML._mc_zero(e)

@testset "Existing generalized forces: viscous, Stokes, quadratic and drive" begin
    lag = (2v^2+3w^2-4x^2-5y^2)/2
    C = [2 1;1 3]
    rayleigh = (2v^2+2v*w+3w^2)/2
    damped = analyze(LagrangianSystem(lag;coordinates=(x,y),velocities=(v,w),rayleigh))
    forced = analyze(LagrangianSystem(lag;coordinates=(x,y),velocities=(v,w),forces=(-2v-w,-v-3w)))
    @test all(z.(damped.accelerations.value-forced.accelerations.value))
    @test z(damped.energy_rate+2v^2+2v*w+3w^2)
    @test damped.energy_conservation.status == :unknown
    @test forced.energy_conservation.status == :unknown
    # eta=2, sphere radius=3: creeping-flow Stokes model, not universal drag.
    coefficient = 6*pi*2*3
    stokes = analyze(LagrangianSystem(v^2/2;coordinates=(x,),velocities=(v,),forces=(-coefficient*v,)))
    @test z(stokes.accelerations.value[1]+coefficient*v)
    @test stokes.energy_conservation.status == :unknown
    quadratic = analyze(LagrangianSystem(v^2/2;coordinates=(x,),velocities=(v,),forces=(-2abs(v)*v,)))
    @test z(quadratic.accelerations.value[1]+2abs(v)*v)
    @test quadratic.energy_conservation.status == :unknown
    for speed in (-2,0,2)
        acceleration = Symbolics.build_function(only(quadratic.accelerations.value),v;expression=Val{false})(speed)
        @test acceleration == -2abs(speed)*speed
    end
    radial = analyze(LagrangianSystem((v^2+w^2)/2;coordinates=(x,y),velocities=(v,w),
        forces=(-2sqrt(v^2+w^2)*v,-2sqrt(v^2+w^2)*w)))
    @test all(z.(radial.accelerations.value-[-2sqrt(v^2+w^2)*v,-2sqrt(v^2+w^2)*w]))
    @test radial.energy_conservation.status == :unknown
    driven = analyze(LagrangianSystem((v^2-x^2)/2;coordinates=(x,),velocities=(v,),time=t,
        rayleigh=v^2/4,forces=(2cos(3t),)))
    @test z(only(driven.accelerations.value)+x+v/2-2cos(3t))
    @test z(driven.energy_rate-(2v*cos(3t)-v^2/2))
    @test driven.energy_conservation.status == :unknown
    conversion = dynamics(driven)
    @test conversion.system isa FirstOrderODE
    path = trajectory(conversion,[0,0],(0,2);abstol=1e-10,reltol=1e-10)
    @test path.diagnostics.success && path.diagnostics.completed
    @test energy_drift(conversion,path).status == :heuristic
    arbitrary = analyze(LagrangianSystem(v^2/2;coordinates=(x,),velocities=(v,),time=t,forces=(x*v+cos(t),)))
    @test z(only(arbitrary.accelerations.value)-x*v-cos(t))
end

@testset "Generic harmonic pair reuses scalar calculus and Hamilton equations" begin
    U = k*((y-x)-r0)^2/2
    # The generic scalar-field report has no separate parameter bindings.
    potential = analyze(3*((y-x)-2)^2/2,(x,y))
    F = force_from_potential(potential)
    @test all(z.(F-[3*(y-x-2),-3*(y-x-2)]))
    @test z(sum(F))
    @test all(z.(F+AnalyticMathLab.gradient(potential)))
    K = AnalyticMathLab.hessian(potential)
    @test all(z.(K-[3 -3;-3 3]))
    @test AnalyticMathLab.hessian(potential,(0,2)) == [3 -3;-3 3]
    @test potential.domain.status == :established
    @test potential.stationary_points.status != :heuristic
    H = p^2/4+s^2/10+U
    h = analyze(HamiltonianSystem(H;coordinates=(x,y),momenta=(p,s)))
    @test z(energy_function(h)-H)
    @test all(z.(hamilton_equations(h)-[p/2,s/5,k*(y-x-r0),-k*(y-x-r0)]))
    @test h.energy_conservation.value === true
    @test h.phase_variables == (x,y,p,s)
    # No new differentiation implementation: both routes use the stored report.
    @test all(z.(force_from_potential(potential)+potential.gradient_expression))
end
end
