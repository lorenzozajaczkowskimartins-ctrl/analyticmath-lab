# Optional bounded M10D.2 gate; run with --project=examples/operators.
# Four trainable affine coefficients, one optimizer step; no accuracy benchmark.
module M10DInteroperabilityLearningTests
using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers
using ComponentArrays, ADTypes, Zygote, Random

@testset "M10D2 simulation dataset learning preservation" begin
    path=trajectory(FirstOrderODE((u,t)->[2.],1;labels=("position",)),[1.],(0.,1.);dt=0.25)
    schema=(family=:linear_motion,id=:run1,input=[1.,2.],input_names=(:initial_position,:speed),
        coordinate_names=(:t,),domain=(inputs=[0. 2.;1. 3.],coordinates=[0. 1.]),
        selection=(component=1,),split=:training,
        reference=(kind=:numerical,description="constant velocity ODE",error=:unknown),
        units=(inputs=("unknown","unknown"),coordinates=("unknown",),output="unknown"),
        grid=(sampling=:stored,resampling=:none),rng=(kind=:deterministic,))
    d=ScientificDataset(path;schema)
    m=learning_model(d,Lux.Dense(3=>1);rng=Xoshiro(12),normalization=:train_minmax,rng_provenance=(seed=12,))
    b=training_data(m,d)
    sample=only(d.samples)
    @test m.schema.input_names == schema.input_names
    @test m.schema.coordinate_names == (:t,)
    @test m.schema.units == schema.units
    @test m.schema.grid == schema.grid
    @test m.provenance.resampling == :none
    @test b.ids == [:run1]
    @test b.inputs[1:2,:] == repeat(AnalyticMathLab.transform(m.normalization.inputs,sample.input),1,length(sample.values))
    @test b.inputs[3:3,:] == AnalyticMathLab.transform(m.normalization.coordinates,sample.coordinates)
    @test inverse_transform(m.normalization.outputs,b.targets) ≈ reshape(sample.values,1,:)
    @test isfinite(learning_objective(m,m.parameters,b))
    result=AnalyticMathLab.train(m,d;initial_parameters=ComponentArray{Float64}(m.parameters),
        optimizer=OptimizationOptimisers.Adam(0.01),adtype=ADTypes.AutoZygote(),maxiters=1)
    @test result.dataset === d
    @test result.evidence.status == :unknown
    @test result.provenance.training_ids == [:run1]
    a=analyze(result)
    @test a.training === result
    @test a.reference === d.reference
    @test a.reference.kind == :numerical
    @test a.reference.error == :unknown
    @test a.evidence.status == :unknown
    @test only(a.cases).id == :run1
    @test only(a.cases).split == :training
    @test only(a.cases).coordinates == sample.coordinates
    @test only(a.cases).reference == sample.values
    @test Set(keys(a.groups)) == Set([:training])
    @test a.physics === nothing
    @test length(AnalyticMathLab.predict(result,sample.input,sample.coordinates)) == length(path.solution.t)
    # Even literally zero sampled error is not a continuum proof.
    @test field_errors(sample.values,sample.values).summary.rms == 0.
    @test classify_query(d,sample.input,sample.coordinates).guarantee == :none
end
end
