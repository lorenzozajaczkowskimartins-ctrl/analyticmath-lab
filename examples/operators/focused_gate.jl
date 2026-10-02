using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers, ComponentArrays, ADTypes, Zygote, Random
const A=AnalyticMathLab
function tinydata(kind)
    q=[0. 0.5 1.;0. 0.2 0.4]
    inputs=kind==:surrogate ? [[0.05],[0.2],[0.12],[0.3]] : [[0.1,0.4],[0.8,-0.1],[0.3,0.2],[1.5,0.2]]
    roles=[:training,:training,:interpolation,kind==:surrogate ? :parameter_extrapolation : :amplitude_extrapolation]
    ss=[ScientificSample(Symbol(:s,i),x,q,[sum(x)+a[1]-a[2] for a in eachcol(q)];split=roles[i],descriptor=kind==:operator ? x : nothing) for (i,x) in enumerate(inputs)]
    domain=kind==:surrogate ? (inputs=[0.05 0.2],coordinates=[0. 1.;0. 0.5]) : (descriptors=[-1. 1.;-1. 1.],coordinates=[0. 1.;0. 0.5])
    ScientificDataset(ss;kind,family=:tiny,input_names=kind==:surrogate ? (:alpha,) : (:s1,:s2),coordinate_names=(:x,:t),domain,
        reference=(kind=:manufactured,source="linear fixture",error=:roundoff),units=:dimensionless,grid=(resampling=:none,),rng=(seed=12,),sensors=kind==:operator ? [0.25 0.75] : nothing)
end
@testset "M9D optional model surface" begin
    @test isdefined(A,:learning_model)
end
if isdefined(A,:learning_model)
@testset "M9D focused surrogate and no target leakage" begin
    d=tinydata(:surrogate)
    m=learning_model(d,Lux.Dense(3=>1);rng=Xoshiro(42),normalization=:train_minmax,rng_provenance=(seed=42,))
    @test size(A.predict(m,[0.12],d.samples[3].coordinates))==(3,)
    @test_throws DimensionMismatch A.predict(m,[0.12,0.2],d.samples[3].coordinates)
    @test_throws DimensionMismatch A.predict(m,[0.12],zeros(3,2))
    packed=training_data(m,d)
    @test packed.ids==[:s1,:s2]
    v=ComponentArray{Float64}(m.parameters)
    before=learning_objective(m,v,packed)
    d.samples[3].values .= 1e8
    d.samples[4].values .= -1e8
    @test learning_objective(m,v,training_data(m,d))==before
    r=A.train(m,d;initial_parameters=v,optimizer=OptimizationOptimisers.Adam(0.05),adtype=ADTypes.AutoZygote(),maxiters=120)
    @test all(isfinite,A.predict(r,[0.12],d.samples[3].coordinates))
    @test r.objective.final<r.objective.initial
    @test r.dataset===d
    @test r.solution!==nothing && r.optimization_problem!==nothing
    @test r.model.network===m.network
    @test r.model.state==m.state
    @test r.normalization===m.normalization
    @test r.evidence.status==:unknown
    @test classify_query(r.model,[0.3],d.samples[3].coordinates).parameter==:outside
    @test length(r.history)<=100
end
@testset "M9D focused true operator" begin
    d=tinydata(:operator)
    net=DeepONet(Lux.Dense(2=>4),Lux.Chain(Lux.Dense(2=>5,tanh),Lux.Dense(5=>4)))
    m=learning_model(d,net;rng=Xoshiro(43),normalization=:train_minmax,rng_provenance=(seed=43,))
    @test m.architecture==:deeponet
    @test m.schema.sensors==[0.25 0.75]
    @test size(A.predict(m,[0.3,0.2],d.samples[3].coordinates;sensors=d.sensors))==(3,)
    @test_throws ArgumentError A.predict(m,[0.3,0.2],d.samples[3].coordinates;sensors=[0.2 0.8])
    @test classify_query(m,[0.3,0.2],d.samples[3].coordinates).function_family==:unknown
    @test classify_query(m,[1.5,0.2],d.samples[3].coordinates;descriptor=[1.5,0.2]).function_family==:outside
    r=A.train(m,d;initial_parameters=ComponentArray{Float64}(m.parameters),optimizer=OptimizationOptimisers.Adam(0.03),adtype=ADTypes.AutoZygote(),maxiters=60)
    @test isfinite(r.objective.final)
    @test r.objective.final<r.objective.initial
    @test all(isfinite,A.predict(r,d.samples[3].input,d.samples[3].coordinates))
    @test r.provenance.reference_used_in_objective==false
end
end
