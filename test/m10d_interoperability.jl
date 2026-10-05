module M10DInteroperabilityTests
using Test, AnalyticMathLab, Symbolics, LinearAlgebra, Unitful

@testset "M10D2 stored trajectory selection" begin
    problem=FirstOrderODE((u,t)->[2.,-3.],2;labels=("position","auxiliary"))
    path=trajectory(problem,[1.,4.],(0.,1.);dt=0.13,saveat=0.3)
    # An explicit selector is a public route, not native-solution serialization.
    @test applicable(observable_series,path)
    if applicable(observable_series,path)
        s=observable_series(path;component=1,context=(experiment=:linear,))
        @test s.values == [u[1] for u in path.solution.u]
        @test s.values ≈ 1 .+ 2 .* path.solution.t
        @test s.sampling.times == path.solution.t
        @test s.provenance.source === path
        @test s.provenance.context == (experiment=:linear,)
        @test s.sampling.times !== path.solution.t
        @test length(s.values)==length(path.solution.u)
        @test s.provenance.domain === problem.domain
        @test s.provenance.diagnostics === path.diagnostics
        @test s.provenance.state_labels == problem.labels
        @test s.provenance.resampling == :none
        @test s.provenance.selection.label == "position"
        @test s.units == "unknown (unitless values)"
        @test s.sampling.units == "unknown (unitless values)"
        @test observable_series(path;component=:auxiliary).values == [u[2] for u in path.solution.u]
        @test statistical_summary(s).value.mean ≈ sum(1 .+ 2 .* path.solution.t)/length(path.solution.t)
        @test statistical_summary(s).status == :heuristic
        @test statistical_summary(s).value.standard_error === nothing
        fn=(u,t)->u[1]+u[2]+t
        f=observable_series(path;observable=fn,name=:combination)
        @test f.values ≈ fill(5.,length(f.values))
        @test f.provenance.selection.observable === fn
        @test f.name == :combination
        physical=observable_series(path;observable=(u,t)->u[1]*u"m")
        @test physical.units == "m"
        @test statistical_summary(physical).value.mean ≈ statistical_summary(s).value.mean*u"m"
        @test_throws ArgumentError observable_series(path;observable=(u,t)->t==0 ? 1u"m" : 1u"s")
        @test_throws ArgumentError observable_series(path;observable=(u,t)->t==0 ? 1. : 1u"m")
        compatible=observable_series(path;observable=(u,t)->t==0 ? 1u"m" : 100u"cm")
        @test statistical_summary(compatible).value.mean == 1u"m"
        original=deepcopy(path.solution.u)
        observable_series(path;observable=(u,t)->(u[1]=99.))
        @test path.solution.u == original
        for component in (0,3,-1,true,1.5,:missing,[1,2])
            @test_throws ArgumentError observable_series(path;component)
        end
        @test_throws ArgumentError observable_series(path)
        @test_throws ArgumentError observable_series(path;component=1,observable=fn)
        for fn in (42,u->u[1],(u,t)->u,(u,t)->NaN,(u,t)->missing)
            @test_throws ArgumentError observable_series(path;observable=fn)
        end
        # Generic ODE coordinates are not an atomistic conversion API.
        @test !applicable(atomistic_trajectory,path)
        @test !applicable(AtomisticTrajectoryView,path)
        @test !applicable(compare,path,path)
    end
end

@testset "M10D2 saved-only and partial-solve boundaries" begin
    p=FirstOrderODE((u,t)->[2.,-3.],2;labels=("position","auxiliary"))
    # No interpolant exists on this stored-only result. Exact binary times and
    # linear values are an independently specified ordering/no-resampling oracle.
    times=[0.,0.125,0.5,1.]
    states=[[1+2t,4-3t] for t in times]
    partial=(success=false,completed=false,retcode=:MaxIters,algorithm=:fixture,
        abstol=1e-9,reltol=1e-7)
    saved=TrajectoryResult((t=times,u=states),p,p.labels,partial)
    s=observable_series(saved;component=1)
    @test s.values == [1.,1.25,2.,3.]
    @test s.sampling.times == times
    @test s.sampling.regularity == :irregular
    @test s.provenance.diagnostics === partial
    @test !s.provenance.diagnostics.success
    @test autocorrelation(s).evidence.status == :unknown
    @test running_statistics(s).value.means ≈ [1.,1.125,17/12,29/16]
    times[2]=0.25; states[1][1]=99.
    @test s.sampling.times == [0.,0.125,0.5,1.]
    @test s.values == [1.,1.25,2.,3.]
    back=trajectory(p,[3.,1.],(1.,0.))
    before=copy(back.solution.t)
    @test_throws ArgumentError observable_series(back;component=1)
    @test back.solution.t == before
    @test_throws ArgumentError observable_series(TrajectoryResult((t=[0.,0.],u=[[1.,2.],[3.,4.]]),p,p.labels,partial);component=1)
    @test_throws DimensionMismatch observable_series(TrajectoryResult((t=[0.,1.],u=[[1.,2.]]),p,p.labels,partial);component=1)
    @test_throws DimensionMismatch observable_series(TrajectoryResult((t=[0.],u=[[1.]]),p,p.labels,partial);component=1)
    @test_throws ArgumentError observable_series(TrajectoryResult((t=[0.],u=[[1.,2.]]),:unknown,p.labels,partial);component=1)
    duplicate=FirstOrderODE((u,t)->u,2;labels=("q","q"))
    @test_throws ArgumentError observable_series(TrajectoryResult((t=[0.],u=[[1.,2.]]),duplicate,duplicate.labels,partial);component=:q)
end
@testset "M10D2 explicit numerical dataset schema" begin
    path=trajectory(FirstOrderODE((u,t)->[2.,-3.],2;labels=("position","auxiliary")),[1.,4.],(0.,1.);dt=0.13)
    schema=(family=:linear_motion,id=:run1,input=[4.,2.],input_names=(:initial_auxiliary,:speed),
        coordinate_names=(:t,),domain=(inputs=[3. 5.;1. 3.],coordinates=[0. 1.]),
        selection=(component=1,),split=:training,
        reference=(kind=:numerical,description="Constant derivative simulation",error=:unknown),
        units=(inputs=("unknown","unknown"),coordinates=("unknown",),output="unknown"),
        grid=(sampling=:stored,resampling=:none),rng=(kind=:deterministic,),context=(run=:small,))
    @test_throws ArgumentError ScientificDataset(path)
    d=ScientificDataset(path;schema)
    @test only(d.samples).input == [4.,2.]
    @test only(d.samples).coordinates == reshape(path.solution.t,1,:)
    @test only(d.samples).values == [u[1] for u in path.solution.u]
    @test only(d.samples).values ≈ 1 .+ 2 .* path.solution.t
    @test d.reference.kind == :numerical
    @test d.reference.error == :unknown
    @test d.reference.tolerances == (abstol=path.diagnostics.abstol,reltol=path.diagnostics.reltol)
    @test d.provenance.context == schema.context
    @test d.grid.resampling == :none
    @test d.units == schema.units
    @test only(d.samples).split == :training
    @test classify_query(d,schema.input,only(d.samples).coordinates).guarantee == :none
    z=fit_scaling(d,:outputs)
    y=reshape(only(d.samples).values,1,:)
    @test inverse_transform(z,transform(z,y)) ≈ y
    @test z.fitted_ids == [:run1]
    @test d.input_names == (:initial_auxiliary,:speed)
    @test d.coordinate_names == (:t,)
    @test d.reference.grid == path.solution.t
    @test d.reference.tspan == (0.,1.)
    @test d.reference.parameters.values == schema.input
    @test d.reference.algorithm == path.diagnostics.algorithm
    @test d.reference.description == schema.reference.description
    @test d.provenance.source.solution.t == path.solution.t
    @test d.provenance.source.diagnostics == path.diagnostics
    @test d.provenance.state_labels == path.labels
    @test d.provenance.reference_quality == :numerical_not_truth
    @test d.provenance.parameters_origin == :caller_declared
    @test d.provenance.units_origin == :caller_declared
    @test d.rng == (kind=:deterministic,)
    @test d.domain == schema.domain
    @test d.domain !== schema.domain
    known=(inputs=("m","m/s"),coordinates=("s",),output="m")
    @test ScientificDataset(path;schema=merge(schema,(units=known,))).units == known
    fn=(u,t)->u[1]+u[2]+t
    selected=ScientificDataset(path;schema=merge(schema,(selection=(observable=fn,name=:combination),)))
    @test only(selected.samples).values ≈ fill(5.,length(path.solution.t))
    @test selected.provenance.selection.observable === fn
    @test hasproperty(selected.provenance,:observable_name)
    if hasproperty(selected.provenance,:observable_name)
        @test selected.provenance.observable_name == :combination
    end
    estimated=merge(schema.reference,(error=(estimate=1e-10,method="independent analytic sample check"),))
    @test ScientificDataset(path;schema=merge(schema,(reference=estimated,))).reference.error == estimated.error
    for field in keys(schema)
        field==:context && continue
        absent=NamedTuple{Tuple(k for k in keys(schema) if k!=field)}(Tuple(v for (k,v) in pairs(schema) if k!=field))
        @test_throws ArgumentError ScientificDataset(path;schema=absent)
    end
    for update in ((selection=NamedTuple(),),(selection=(component=1,observable=fn),),
            (selection=(component=:missing,),),(selection=(observable=(u,t)->u,),),
            (selection=(observable=(u,t)->u[1]*u"m",),),
            (coordinate_names=(:x,:t),),(grid=(sampling=:stored,resampling=:linear),),
            (split=:validation,),(split=:interpolation,),
            (reference=(kind=:analytical,description="solver succeeded",error=:unknown),),
            (reference=merge(schema.reference,(error=:exact,)),),(rng=nothing,),
            (selection=(component=1,particle_identity=true),))
        @test_throws ArgumentError ScientificDataset(path;schema=merge(schema,update))
    end
    for update in ((input=[2.],),(domain=(inputs=[0. 5.],coordinates=[0. 1.]),),
            (units=(inputs=("m",),coordinates=("s",),output="m"),))
        @test_throws DimensionMismatch ScientificDataset(path;schema=merge(schema,update))
    end
    partial=TrajectoryResult(path.solution,path.problem,path.labels,merge(path.diagnostics,(success=false,completed=false)))
    @test_throws ArgumentError ScientificDataset(partial;schema)
    old=copy(only(d.samples).values)
    path.solution.u[1][1]=99.; schema.input[1]=99.
    @test only(d.samples).values == old
    @test only(d.samples).input == [4.,2.]
    @test d.provenance.source.solution.u[1][1] == 1.
end

@testset "M10D2 mechanics and local modes preservation" begin
    @variables q v p q2 v2
    lag=analyze(LagrangianSystem(v^2/2-2q^2;coordinates=(q,),velocities=(v,)))
    dyn=dynamics(lag)
    path=trajectory(dyn,[1.,0.],(0.,1.);abstol=1e-11,reltol=1e-11)
    @test dyn.source === lag
    @test isequal(dyn.variables,(q,v))
    @test path.labels == string.(dyn.variables)
    @test domain_contains(dyn.domain,(1.,0.)) === true
    @test observable_series(path;component=1).values ≈ cos.(2 .* path.solution.t) atol=1e-9
    @test observable_series(path;component=2).values ≈ -2sin.(2 .* path.solution.t) atol=1e-9
    drift=energy_drift(dyn,path)
    @test drift.value.times == path.solution.t
    @test drift.value.values ≈ fill(2.,length(path.solution.t)) atol=1e-9
    @test drift.status == :heuristic
    @test lag.energy_conservation.status == :established
    unrelated=trajectory(FirstOrderODE((u,t)->[u[2],-4u[1]],2),[1.,0.],(0.,1.))
    @test_throws ArgumentError energy_drift(dyn,unrelated)
    legendre=legendre_transform(lag;momenta=(p,))
    @test legendre.status == :established
    h=legendre.value
    @test isequal(h.phase_variables,(q,p))
    @test iszero(Symbolics.simplify(Symbolics.expand(energy_function(h)-(p^2/2+2q^2))))
    coupled=analyze(LagrangianSystem((v^2+v2^2-q^2-q2^2-(q2-q)^2)/2;
        coordinates=(q,q2),velocities=(v,v2)))
    localmodel=linearize_mechanics(coupled,(0.,0.))
    modes=normal_modes(localmodel)
    @test localmodel.source === coupled
    @test modes.source === localmodel
    @test localmodel.domain_evidence.value === true
    @test modes.equilibrium == (0.,0.)
    @test localmodel.stiffness_matrix == [2 -1;-1 2]
    @test modes.eigenvalues ≈ [1.,3.]
    @test modes.evidence.status == :heuristic
    @test modes.mode_vectors'*modes.mass_matrix*modes.mode_vectors ≈ I
    @test normal_modes(linearize_mechanics(coupled,(1.,0.))).evidence.status == :unknown
    damped=LagrangianSystem(v^2/2-q^2/2;coordinates=(q,),velocities=(v,),rayleigh=v^2/2)
    @test normal_modes(linearize_mechanics(damped,(0.,))).evidence.status == :unknown
    restricted=analyze(LagrangianSystem(@real_function(v^2/2-q^2/2+q/q);coordinates=(q,),velocities=(v,)))
    @test domain_contains(dynamics(restricted).domain,(0.,1.)) === false
    @test_throws DomainError trajectory(dynamics(restricted),[0.,1.],(0.,1.))
end

@testset "M10D2 field and radial bridge preservation" begin
    @variables x y r
    field=analyze(3*((y-x)-2)^2/2,(y,x))
    @test isequal(field.variables,(y,x))
    @test AnalyticMathLab.gradient(field,(3.,0.)) == [3.,-3.]
    @test AnalyticMathLab.hessian(field,(3.,0.)) == [3. -3.;-3. 3.]
    @test field.domain.status == :established
    hole=analyze(@real_function(x/x+y^2),(y,x))
    @test_throws DomainError AnalyticMathLab.gradient(hole,(1.,0.))
    radial=analyze_potential((r-2)^2,r;interval=(0.5,4.),units=(length=:nm,energy=:kJ),
        provenance=(source=:harmonic,),cutoff=3.)
    @test radial.numerical.force(3.) == -2.
    @test only(radial.equilibria.value).x == 2
    @test radial.units == (length=:nm,energy=:kJ)
    @test radial.provenance.source == :harmonic
    @test radial.cutoff.modification == :none
    @test_throws DomainError evaluate(radial,0.)
end

@testset "M10D2 atomistic observations and modes preservation" begin
    times=[0.,0.25,1.]u"ps"
    frames=[AtomisticSnapshot([[0.,0.],[Float64(i),0.]]u"nm";masses=[1.,2.]u"g/mol",
        time=times[i],boundary=(kind=:open,),provenance=(run=:geometry,)) for i in 1:3]
    view=AtomisticTrajectoryView(3,i->frames[i];times,provenance=(run=:geometry,))
    s=distance_observations(view,(1,2))
    @test s.values == [1.,2.,3.]u"nm"
    @test s.sampling.times == times
    @test s.provenance.source === view
    @test s.provenance.pair == (1,2)
    @test s.provenance.geometry == fill(:open,3)
    stats=statistical_summary(s)
    @test stats.value.mean == 2u"nm"
    @test stats.value.variance == 1u"nm^2"
    @test stats.status == :heuristic
    @test stats.value.standard_error === nothing
    obs=ObservationSet(s;time_scale=1u"ps",length_scale=1u"nm",kind=:numerical)
    @test obs.times == [0.,0.25,1.]
    @test obs.values == [1. 2. 3.]
    @test obs.provenance.source_series === s
    @test obs.units.length_scale == 1u"nm"
    @test_throws ArgumentError ObservationSet(s)
    @test_throws ArgumentError distance_observations(view,(1,2);frames=[3,1])
    modes=normal_modes(frames[1];hessian=diagm([1.,2.,6.,8.])u"kJ/mol/nm^2")
    @test modes.source === frames[1]
    @test modes.metadata.coordinate_ordering == :particle_major_cartesian
    @test modes.equilibrium == (0.,0.,1.,0.)
    @test modes.metadata.equilibrium_status == :not_verified
    @test modes.metadata.angular_frequencies ≈ sqrt.([1.,2.,3.,4.])u"ps^-1"
    @test normal_modes(frames[1]).evidence.status == :unknown
    @test normal_modes(frames[1];hessian=ones(4,4)).evidence.status == :unknown
end
end
