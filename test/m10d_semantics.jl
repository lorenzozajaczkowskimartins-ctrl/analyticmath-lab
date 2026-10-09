module M10DSemanticsTests
using Test, AnalyticMathLab, Unitful, Symbolics
const A=AnalyticMathLab
@testset "M10D3 scoped claims and detached origin" begin
    p=PropertyResult(nothing,:unknown,:unsupported,["No supported operation"])
    @test isdefined(A,:scientific_metadata)
    @test isdefined(A,:scientific_origin)
    if isdefined(A,:scientific_metadata) && isdefined(A,:scientific_origin)
        m=A.scientific_metadata(p)
        @test only(m.claims).status == :unknown
        @test m.method == :unsupported
        @test m.units.availability == :unknown
        @test m.backend.availability == :not_applicable
        @test only(m.claims).notes == p.notes
        @test A.scientific_origin(p) == (availability=:unknown,value=nothing)
        @test m.provenance == A.scientific_origin(p)
    end
end
@testset "M10D3 trajectory series moments semantics" begin
    path=trajectory(FirstOrderODE((u,t)->[2.,-1.],2),[1.,3.],(0.,1.);abstol=2e-9,reltol=3e-7)
    s=observable_series(path;component=2)
    @test applicable(A.scientific_metadata,path)
    @test applicable(A.scientific_metadata,s)
    if applicable(A.scientific_metadata,path) && applicable(A.scientific_metadata,s)
        m=A.scientific_metadata(path); sm=A.scientific_metadata(s)
        @test m.execution.value.success
        @test only(m.claims).status == :heuristic
        @test m.method == :numerical_integration
        @test m.backend.value == :SciMLBase
        @test m.tolerances.value == (abstol=2e-9,reltol=3e-7)
        @test m.units.availability == :unknown
        @test sm.coordinates.value.label == "u2"
        @test sm.coordinates.value.component == 2
        @test sm.sampling.value.resampling == :none
        @test sm.domain.value === path.problem.domain
        @test sm.tolerances == m.tolerances
    end
    summary=statistical_summary(s)
    @test !hasproperty(summary.value,:origin)
    @test fieldnames(typeof(summary)) == (:value,:status,:method,:notes)
    @test A.scientific_origin(summary) == (availability=:unknown,value=nothing)
    origin=A.scientific_origin(s)
    @test origin.operation == :stored_observable_selection
    @test only(origin.parents).operation == :numerical_integration
    @test Base.summarysize(origin) < 4096
    @test A.scientific_metadata(summary).units.availability == :unknown
    physical=ObservableSeries([1.,2.,3.].*u"m";times=[0.,1.,2.].*u"s")
    pm=statistical_summary(physical)
    @test pm.value.mean == 2u"m"
    @test pm.value.variance == 1u"m^2"
    @test !hasproperty(pm.value,:semantic_context)
    @test A.scientific_metadata(physical).units.value == "m"
    @test A.scientific_metadata(pm).units.availability == :unknown
end
@testset "M10D3 mechanics origin and modal scope" begin
    @variables q v
    r=analyze(LagrangianSystem(v^2/2-2q^2;coordinates=(q,),velocities=(v,)))
    conversion=dynamics(r)
    path=trajectory(conversion,[1.,0.],(0.,0.25))
    s=observable_series(path;component=2)
    @test applicable(A.scientific_metadata,r)
    @test applicable(A.scientific_metadata,conversion)
    @test hasproperty(path.diagnostics,:origin)
    if applicable(A.scientific_metadata,r) && applicable(A.scientific_metadata,conversion) && hasproperty(path.diagnostics,:origin)
        m=A.scientific_metadata(r)
        @test m.units.availability == :unknown
        @test m.domain.value === r.domain
        @test m.backend.value == :Symbolics
        @test any(c->c.scope==:energy_conservation && c.status==:established,m.claims)
        origin=A.scientific_origin(s)
        @test only(only(origin.parents).parents).operation == :mechanics_to_dynamics
        @test only(only(only(origin.parents).parents).parents).token == objectid(r)
        @test A.scientific_metadata(path).claims[1].status == :heuristic
        @test A.scientific_metadata(s).coordinates.value.label == "v"
    end
    l=linearize_mechanics(r,(0.,))
    modes=normal_modes(l;atol=2e-10,rtol=3e-8)
    @test applicable(A.scientific_metadata,l)
    @test applicable(A.scientific_metadata,modes)
    if applicable(A.scientific_metadata,l) && applicable(A.scientific_metadata,modes)
        lm=A.scientific_metadata(l); mm=A.scientific_metadata(modes)
        @test only(lm.claims).status == :established
        @test only(mm.claims).status == :heuristic
        @test :linearization in mm.approximation
        @test mm.backend.value == :LinearAlgebra
        @test mm.tolerances.value == (atol=2e-10,rtol=3e-8)
        @test mm.domain.value === l.domain
        @test only(A.scientific_origin(modes).parents).token == objectid(l)
    end
end
@testset "M10D3 dataset detached provenance and reference" begin
    path=trajectory(FirstOrderODE((u,t)->[2.],1),[1.],(0.,1.))
    schema=(family=:linear,id=:run,input=[2.],input_names=(:speed,),coordinate_names=(:t,),
        domain=(inputs=[1. 3.],coordinates=[0. 1.]),selection=(component=1,),split=:training,
        reference=(kind=:numerical,description="linear ODE",error=:unknown),
        units=(inputs=("unknown",),coordinates=("unknown",),output="unknown"),
        grid=(sampling=:stored,resampling=:none),rng=(kind=:deterministic,))
    @test applicable(A.scientific_metadata,ScientificDataset(path;schema))
    let
        d=ScientificDataset(path;schema,source_retention=:descriptor)
        @test !hasproperty(d.provenance.source,:solution)
        @test d.provenance.source.token == objectid(path)
        @test Base.summarysize(d.provenance) < 4096
        @test d.reference.kind == :numerical
        @test d.reference.error == :unknown
        @test d.reference.tolerances == (abstol=1e-9,reltol=1e-7)
        m=A.scientific_metadata(d)
        @test m.reference.value.kind == :numerical
        @test m.reference.value.trust == :caller_declared_not_certified
        @test m.domain.value.interpretation == :descriptive_bounds_not_validity
        @test m.coordinates.value.query == (:t,)
        @test m.coordinates.value.inputs == (:speed,)
        @test m.sampling.value.resampling == :none
        @test classify_query(d,[2.],reshape([0.,1.],1,:)).function_family == :not_applicable
        @test classify_query(d,[2.],reshape([0.,1.],1,:)).guarantee == :none
        @test_throws ArgumentError ScientificDataset(path;schema,source_retention=:invented)
        @test_throws ArgumentError ScientificDataset(path;schema=merge(schema,(reference=(kind=:analytical,description="success",error=:unknown),)),source_retention=:descriptor)
        @test_throws ArgumentError ScientificDataset(path;schema=merge(schema,(reference=merge(schema.reference,(error=:exact,)),)),source_retention=:descriptor)
        large_source=let payload=fill(2.,4096)
            trajectory(FirstOrderODE((u,t)->[payload[1]],1),[1.],(0.,1.))
        end
        detached=ScientificDataset(large_source;schema,source_retention=:descriptor)
        @test Base.summarysize(large_source) > 32768
        @test Base.summarysize(detached.provenance) < 4096
        @test detached.provenance.context === nothing
        @test detached.provenance.source.token == objectid(large_source)
    end
end
@testset "M10D3 declared order, unit refusals and bounded ownership" begin
    xy=PINNPoints([0.1 0.7;0.2 0.6];provenance=(coordinate_names=(:x,:t),),generation=:declared)
    swapped=PINNPoints(reverse(xy.coordinates;dims=1);provenance=(coordinate_names=(:t,:x),),generation=:declared)
    @test A.scientific_metadata(xy).coordinates.value.variables == (:x,:t)
    @test A.scientific_metadata(xy).domain.availability == :unknown
    @test heat_residual(q->q[1]^2+3q[2],xy;alpha=0.2).values ≈ fill(3-2*0.2,2)
    @test_throws ArgumentError heat_residual(q->q[1]^2+3q[2],swapped;alpha=0.2)
    @test A.scientific_metadata(PropertyResult(false,:established,:exact,String[])).claims[1].status == :established
    @test A.scientific_metadata(PropertyResult(nothing,:unknown,:unsupported,String[])).claims[1].method == :unsupported
    small=ObservableSeries(collect(1.:8.))
    values=collect(1.:4096.)
    bigger=ObservableSeries(values)
    @test Base.summarysize(A.scientific_origin(small)) == Base.summarysize(A.scientific_origin(bigger))
    @test Base.summarysize(statistical_summary(bigger)) < 4096
    @test bigger.values === values
    @test A.scientific_metadata(bigger).units.availability == :unknown
    dimensionless=ObservableSeries([1.,2.],sampling_info(2),:ratio,"dimensionless",NamedTuple(),:reject)
    @test A.scientific_metadata(dimensionless).units.availability == :known
    path=trajectory(FirstOrderODE((u,t)->[1.],1),[0.],(0.,1.))
    @test_throws ArgumentError observable_series(path;observable=(u,t)->t==0 ? 1u"m" : 1u"s")
    @test_throws ArgumentError observable_series(path;observable=(u,t)->t==0 ? 1. : 1u"m")
    failed=TrajectoryResult(path.solution,path.problem,path.labels,merge(path.diagnostics,(success=false,completed=false)))
    @test only(A.scientific_metadata(failed).claims).status == :unknown
    @test !A.scientific_metadata(failed).execution.value.success
    snapshot=AtomisticSnapshot([[0u"m"],[1u"m"]];masses=[1u"kg",1u"kg"],velocities=[[1u"m/s"],[2u"m/s"]])
    sm=A.scientific_metadata(snapshot)
    @test sm.units.value.position.value == "m"
    @test sm.coordinates.value.order == :particle_major_cartesian
    @test sm.domain.value.interpretation == :boundary_not_validity
    check=mdcheck(snapshot;max_pairs=2)
    @test only(A.scientific_origin(check).parents).token == objectid(snapshot)
    @test all(c->c.status in (:heuristic,:unknown),A.scientific_metadata(check).claims)
    @test snapshot.positions[1][1] == 0u"m"
end
end
