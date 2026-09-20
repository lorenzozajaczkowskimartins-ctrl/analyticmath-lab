module MechanicsDynamicsTests
using Test, AnalyticMathLab, Symbolics
import Makie, LinearAlgebra, SciMLBase, OrdinaryDiffEqTsit5
@variables q v p t m k q2 v2 p2

@testset "Mechanics delegates dynamics and integration to M6" begin
    @test isdefined(AnalyticMathLab,:dynamics)
    if isdefined(AnalyticMathLab,:dynamics)
        h = analyze(HamiltonianSystem((p^2+q^2)/2;coordinates=(q,),momenta=(p,)))
        d = dynamics(h)
        @test d isa MechanicsDynamics
        @test d.source === h
        @test d.system isa AutonomousSystem
        @test d.analysis isa DynamicalSystemAnalysis
        @test d.analysis.field === d.system.field
        @test d.variables == (q,p)
        @test evaluate(d.analysis,(1,2)) == [2,-1]
        path = trajectory(d,[1,0],(0,2pi);abstol=1e-10,reltol=1e-10,saveat=0.1)
        @test path isa TrajectoryResult
        @test path.problem.function_value.field === d.system.field
        @test path.diagnostics.success && path.diagnostics.completed
        @test path.solution.u[end] ≈ [1,0] atol=1e-7
        energies = energy_drift(d,path)
        @test energies.status == :heuristic
        @test maximum(abs,energies.value.drift) < 1e-7
        @test energies.value.times == path.solution.t
        @test energies.value.values[1] ≈ 0.5
        @test_throws ArgumentError energy_drift(d,trajectory(dynamics(h),[1,0],(0,1)))
        @test_throws ArgumentError dynamics(analyze(LagrangianSystem(v;coordinates=(q,),velocities=(v,))))
    end
end

@testset "Lagrangian parameters, dissipation and multidimensional bridge" begin
    if isdefined(AnalyticMathLab,:dynamics)
        lag = analyze(LagrangianSystem(m*v^2/2-k*q^2/2;coordinates=(q,),velocities=(v,),nonzero=(m,)))
        @test_throws ArgumentError dynamics(lag)
        d = dynamics(lag;parameters=Dict(m=>2,k=>8))
        @test d.variables == (q,v)
        @test evaluate(d.analysis,(1,0)) == [0,-4]
        @test_throws ArgumentError dynamics(lag;parameters=Dict(m=>0,k=>8))
        damped = analyze(LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),rayleigh=v^2/4))
        dd = dynamics(damped)
        path = trajectory(dd,[1,0],(0,12);saveat=0.1)
        energy = energy_drift(dd,path)
        @test path.diagnostics.success
        @test last(energy.value.values) < first(energy.value.values)
        @test all(diff(energy.value.values) .<= 1e-7)
        coupled = analyze(LagrangianSystem((v^2+v2^2-q^2-(q2-q)^2)/2;
            coordinates=(q,q2),velocities=(v,v2)))
        dc = dynamics(coupled)
        @test dc.variables == (q,q2,v,v2)
        @test dc.analysis.dimension == 4
        @test evaluate(dc.analysis,(1,2,0,0)) == [0,0,0,-1]
        @test trajectory(dc,[1,2,0,0],(0,1)).diagnostics.success
    end
end

@testset "Explicit-time mechanics and preserved original domains" begin
    if isdefined(AnalyticMathLab,:dynamics)
        driven = analyze(LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),time=t,forces=(sin(t),)))
        d = dynamics(driven)
        @test d.system isa FirstOrderODE
        @test d.analysis === nothing
        @test trajectory(d,[0,0],(0,1)).diagnostics.success
        h = analyze(HamiltonianSystem(p^2/2+t*q;coordinates=(q,),momenta=(p,),time=t))
        hd = dynamics(h)
        @test hd.system isa FirstOrderODE
        path = trajectory(hd,[0,0],(0,1);abstol=1e-10,reltol=1e-10)
        @test path.solution.u[end] ≈ [-1/6,-1/2] atol=1e-7
        @test length(energy_drift(hd,path).value.values) == length(path.solution.t)
        # Original syntax can impose exclusions even when a derivative cancels them.
        hole = analyze(HamiltonianSystem(@real_function(p^2/2+q/q);coordinates=(q,),momenta=(p,)))
        dh = dynamics(hole)
        @test domain_contains(dh.system.field.domain,(0,1)) === false
        @test_throws DomainError trajectory(dh,[0,1],(0,1))
    end
end

@testset "Captured nonzero assumptions preserve their original domain" begin
    assumption = @real_function(m*q/q)
    lag = LagrangianSystem(m*v^2/2;coordinates=(q,),velocities=(v,),nonzero=(assumption,))
    direct = HamiltonianSystem(p^2/(2m);coordinates=(q,),momenta=(p,),nonzero=(assumption,))
    @test analyze(lag).regularity.value === true
    transformed = legendre_transform(lag;momenta=(p,))
    @test transformed.status == :established
    for source in (lag,direct,transformed.value)
        @test domain_contains(source.domain,(0,1,2)) === false
        @test domain_contains(source.domain,(1,1,2)) === true
        @test domain_contains(source.domain,(1,1,0)) === false
        conversion = dynamics(source;parameters=Dict(m=>2))
        @test domain_contains(conversion.domain,(0,1)) === false
        @test domain_contains(conversion.domain,(1,1)) === true
        @test_throws DomainError trajectory(conversion,[0,1],(0,0.1))
        @test trajectory(conversion,[1,1],(0,0.1)).diagnostics.success
    end
    # A cancelled velocity denominator must be pulled back through v = p/m.
    velocity = LagrangianSystem(m*v^2/2;coordinates=(q,),velocities=(v,),
        nonzero=(@real_function(m*v/v),))
    pulled = legendre_transform(velocity;momenta=(p,)).value
    @test isequal(pulled.domain.variables,(q,p,m))
    @test domain_contains(velocity.domain,(1,0,2)) === false
    @test domain_contains(pulled.domain,(1,0,2)) === false
    @test domain_contains(pulled.domain,(1,2,2)) === true
    converted = dynamics(pulled;parameters=Dict(m=>2))
    @test domain_contains(converted.domain,(1,0)) === false
    @test_throws DomainError trajectory(converted,[1,0],(0,0.1))
    @test evaluate(converted.analysis,(1,2)) == [1,0]
    # k exists only in the captured assumption, not its simplified value m.
    parameter_lag = LagrangianSystem(m*v^2/2;coordinates=(q,),velocities=(v,),
        nonzero=(@real_function(m*k/k),))
    parameter_ham = HamiltonianSystem(p^2/(2m);coordinates=(q,),momenta=(p,),
        nonzero=(@real_function(m*k/k),))
    for source in (parameter_lag,parameter_ham,legendre_transform(parameter_lag;momenta=(p,)).value)
        @test any(x->isequal(x,k),source.domain.variables)
        @test_throws ArgumentError dynamics(source;parameters=Dict(m=>2))
        valid = dynamics(source;parameters=Dict(m=>2,k=>3))
        @test domain_contains(valid.domain,(0,1)) === true
        invalid = dynamics(source;parameters=Dict(m=>2,k=>0))
        @test domain_contains(invalid.domain,(0,1)) === false
        @test_throws DomainError trajectory(invalid,[0,1],(0,0.1))
    end
end

@testset "Mechanics backend and package-owned dispatch" begin
    mixed = trajectory(FirstOrderODE((u,t)->Real[u[2],0],2),[0,1],(0,1))
    @test mixed.solution.u[end] ≈ [1,1]
    @test_throws DomainError trajectory(FirstOrderODE((u,t)->[big"1e1000"],1),[0],(0,1))
    @test_throws ArgumentError dynamics(HamiltonianSystem(@real_function(p^2/2+m/m);coordinates=(q,),momenta=(p,)))
    for input in (LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),
            rayleigh=@real_function(v^2*q/q)),
            LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),
            forces=(@real_function(q/q),)))
        conversion = dynamics(input)
        @test domain_contains(conversion.domain,(0,1)) === false
        @test_throws DomainError trajectory(conversion,[0,1],(0,1))
    end
    assumed = dynamics(HamiltonianSystem(p^2/2;coordinates=(q,),momenta=(p,),nonzero=(q,)))
    @test domain_contains(assumed.domain,(0,1)) === false
    bound = dynamics(HamiltonianSystem(@real_function(p^2/2+m/m);coordinates=(q,),momenta=(p,));parameters=Dict(m=>2))
    @test trajectory(bound,[0,1],(0,1)).diagnostics.success
    @test ismissing(Makie.current_backend())
    @test all(m -> nameof(m) ∉ (:CairoMakie,:GLMakie),values(Base.loaded_modules))
    pairs = Test.detect_ambiguities(AnalyticMathLab,Symbolics,Makie,LinearAlgebra,SciMLBase,OrdinaryDiffEqTsit5;recursive=false)
    @test isempty(filter(pair -> any(m -> m.module === AnalyticMathLab,pair),pairs))
end
end
