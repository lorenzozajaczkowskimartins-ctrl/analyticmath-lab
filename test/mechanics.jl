using Test, Symbolics
const MC = AnalyticMathLab
@testset "Mechanics free-particle contract" begin
    @variables q v m
    @test isdefined(MC, :LagrangianSystem)
    if isdefined(MC, :LagrangianSystem)
        s = MC.LagrangianSystem(m*v^2/2; coordinates=(q,), velocities=(v,), nonzero=(m,))
        r = analyze(s)
        @test r isa AbstractAnalysis
        @test isequal(r.coordinates,(q,))
        @test iszero(Symbolics.simplify(r.momenta[1]-m*v))
        @test iszero(Symbolics.simplify(r.hessian[1,1]-m))
        @test r.regularity.value === true
        @test r.accelerations.status == :established
        @test iszero(r.accelerations.value[1])
        @test r.energy_conservation.value === true
        @test r.cyclic[1].conservation.value === true
        @test analyze(MC.LagrangianSystem(m*v^2/2;coordinates=(q,),velocities=(v,))).regularity.status == :unknown
    end
end

@testset "Recovered Lagrangian identities and input contracts" begin
    @variables q v r w t m k
    oscillator = analyze(LagrangianSystem(m*v^2/2-k*q^2/2;coordinates=(q,),velocities=(v,),nonzero=(m,)))
    @test MC._mc_zero(oscillator.accelerations.value[1]+k*q/m)
    @test MC._mc_zero(energy_function(oscillator)-(m*v^2+k*q^2)/2)
    @test isempty(cyclic_coordinates(oscillator))
    @test isequal(generalized_momenta(oscillator.system),oscillator.momenta)
    @test isequal(velocity_hessian(oscillator.system),oscillator.hessian)
    @test length(euler_lagrange(oscillator.system)) == 1
    damped = analyze(LagrangianSystem((v^2-q^2)/2;coordinates=(q,),velocities=(v,),rayleigh=v^2/4))
    @test MC._mc_zero(damped.accelerations.value[1]+q+v/2)
    @test MC._mc_zero(damped.energy_rate+v^2/2)
    @test damped.energy_conservation.status == :unknown
    @test legendre_transform(damped).status == :unknown
    pendulum = analyze(LagrangianSystem(v^2/2+cos(q);coordinates=(q,),velocities=(v,)))
    @test MC._mc_zero(pendulum.accelerations.value[1]+sin(q))
    central = analyze(LagrangianSystem((v^2+q^2*w^2)/2+1/q;coordinates=(q,r),velocities=(v,w),nonzero=(q,)))
    @test central.regularity.value === true
    @test isequal(only(central.cyclic).coordinate,r)
    @test MC._mc_zero(only(central.cyclic).momentum-q^2*w)
    @test only(central.cyclic).conservation.value === true
    cross = analyze(LagrangianSystem(v*w+q*w;coordinates=(q,r),velocities=(v,w)))
    @test cross.regularity.value === true
    @test all(MC._mc_zero.(cross.accelerations.value-[-v,w]))
    singular = analyze(LagrangianSystem((v+w)^2;coordinates=(q,r),velocities=(v,w)))
    @test singular.regularity.value === false
    @test singular.accelerations.value === nothing
    timed = analyze(LagrangianSystem(t*v^2/2;coordinates=(q,),velocities=(v,),time=t,nonzero=(t,)))
    @test MC._mc_zero(timed.accelerations.value[1]+v/t)
    @test MC._mc_zero(timed.energy_rate+v^2/2)
    forced = analyze(LagrangianSystem(v^2/2;coordinates=(q,),velocities=(v,),forces=(1,)))
    @test only(forced.cyclic).conservation.status == :unknown
    @test legendre_transform(forced).status == :unknown
    @test_throws ArgumentError LagrangianSystem(v;coordinates=(q,),velocities=(q,))
    @test_throws ArgumentError LagrangianSystem(v;coordinates=(),velocities=())
    @test_throws DimensionMismatch LagrangianSystem(v;coordinates=(q,r),velocities=(v,))
    @test_throws ArgumentError LagrangianSystem(v;coordinates=(q,),velocities=(v,),parameters=Dict(q=>1))
    @test_throws ArgumentError LagrangianSystem(v;coordinates=(q,),velocities=(v,),parameters=Dict(m=>Inf))
end

@testset "Mechanics assumptions retain compound and cancelled names" begin
    @variables q v p m k
    s = LagrangianSystem((m+k)*v^2/2;coordinates=(q,),velocities=(v,),nonzero=(m+k,))
    @test analyze(s).regularity.value === true
    @test domain_contains(s.domain,(1,2,3,-3)) === false
    h = HamiltonianSystem(@real_function(p^2/2+m/m);coordinates=(q,),momenta=(p,))
    @test isequal(h.domain.variables,(q,p,m))
    @test domain_contains(h.domain,(1,1,0)) === false
    @test domain_contains(h.domain,(1,1,2)) === true
end

@testset "Verified affine Legendre transformation" begin
    @variables q v p m
    @test isdefined(MC,:legendre_transform)
    if isdefined(MC,:legendre_transform)
        s = LagrangianSystem(m*v^2/2-q^2/2;coordinates=(q,),velocities=(v,),nonzero=(m,))
        result = MC.legendre_transform(s;momenta=(p,))
        @test result.status == :established
        @test MC._mc_zero(result.value.energy-p^2/(2m)-q^2/2)
        @test all(MC._mc_zero.(hamilton_equations(result.value)-[p/m,-q]))
        @test MC.legendre_transform(LagrangianSystem(v^2/2;coordinates=(q,),velocities=(v,))).status == :established
        for (L,R) in ((v,0),(m*v^2/2,0),(v^4,0),(v^2/2,v^2))
            @test MC.legendre_transform(LagrangianSystem(L;coordinates=(q,),velocities=(v,),rayleigh=R)).status == :unknown
        end
        hole = MC.legendre_transform(LagrangianSystem(@real_function(v^2/2+q/q);coordinates=(q,),velocities=(v,));momenta=(p,)).value
        @test domain_contains(hole.domain,(0,1)) === false
        @test domain_contains(hole.domain,(1,1)) === true
        vhole = MC.legendre_transform(LagrangianSystem(@real_function(v^2/2+v/v);coordinates=(q,),velocities=(v,));momenta=(p,)).value
        @test domain_contains(vhole.domain,(1,0)) === false
        restricted = LagrangianSystem(v^2/2;coordinates=(q,),velocities=(v,),
            rayleigh=@real_function(q/q),forces=(@real_function(0/q),))
        rh = legendre_transform(restricted;momenta=(p,)).value
        @test domain_contains(rh.domain,(0,1)) === false
    end
end

@testset "Canonical Hamiltonian oscillator" begin
    @variables q p t
    @test isdefined(MC, :HamiltonianSystem)
    if isdefined(MC, :HamiltonianSystem)
        h = analyze(MC.HamiltonianSystem((p^2+q^2)/2;coordinates=(q,),momenta=(p,)))
        @test h isa AbstractAnalysis
        @test isequal(h.phase_variables,(q,p))
        @test all(MC._mc_zero.(h.phase_field-[p,-q]))
        @test h.symplectic_matrix == [0 1;-1 0]
        @test h.energy_conservation.value === true
        @test MC._mc_zero(MC.energy_function(h)-(p^2+q^2)/2)
        @test MC._mc_zero(MC.poisson_bracket(h,q,p)-1)
        @test MC._mc_zero(MC.poisson_bracket(h,p,q)+1)
        @test MC._mc_zero(MC.observable_derivative(h,q)-p)
        ht = analyze(MC.HamiltonianSystem(p^2/2+t*q;coordinates=(q,),momenta=(p,),time=t))
        @test ht.energy_conservation.status == :unknown
        @test MC._mc_zero(MC.observable_derivative(ht,t*q)-q-t*p)
        @test all(MC._mc_zero.(MC.force_from_potential(analyze(q^2+p^2,(q,p)))-[-2q,-2p]))
    end
end
