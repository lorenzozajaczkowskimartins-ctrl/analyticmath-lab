# Manual optional gate: --project=examples/<family> ... <family> <aml-first|backend-first>
using Test
family,order=ARGS
order in ("aml-first","backend-first") || error("specify aml-first or backend-first")
if order=="aml-first"
    using AnalyticMathLab
end
if family=="molly"
    using Molly, Unitful
elseif family=="inference"
    using Lux, Optimization
elseif family=="operators"
    using Lux, Optimization, NeuralOperators, Random
elseif family=="pinn"
    using Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface
else
    error("unsupported optional family")
end
using AnalyticMathLab
@testset "User optional $family $order" begin
    expected=family=="molly" ? (:AnalyticMathLabMollyExt,) :
        family=="inference" ? (:AnalyticMathLabInferenceExt,:AnalyticMathLabDynamicsExt) :
        family=="operators" ? (:AnalyticMathLabInferenceExt,:AnalyticMathLabDynamicsExt,:AnalyticMathLabSurrogateExt) :
        (:AnalyticMathLabInferenceExt,:AnalyticMathLabDynamicsExt,:AnalyticMathLabSurrogateExt,:AnalyticMathLabPINNExt)
    modules=Module[AnalyticMathLab]
    for name in expected
        extension=Base.get_extension(AnalyticMathLab,name)
        @test extension!==nothing
        extension===nothing || push!(modules,extension)
    end
    @test isempty(Test.detect_ambiguities(modules...;recursive=false))
    if family=="molly"
        coordinates=[SVector(0.,0.,0.),SVector(1.,0.,0.)]
        system=Molly.System(atoms=[Molly.Atom(index=i,mass=1.,σ=1.,ϵ=1.) for i in 1:2],
            coords=coordinates,velocities=zero(coordinates),boundary=Molly.CubicBoundary(8.),
            force_units=NoUnits,energy_units=NoUnits)
        snapshot=atomistic_snapshot(system)
        @test snapshot.positions===system.coords
        @test pair_distances(snapshot).value.minimum==1.
        @test_throws ArgumentError atomistic_trajectory(system)
    elseif family=="inference"
        known=FirstOrderODE((u,t)->[-u[1]],1)
        model=UDEProblem(known,Lux.WrappedFunction(x->[0.]),NamedTuple(),NamedTuple())
        @test learned_vector_field(model,[1.])==[-1.]
        @test learned_correction(model,[1.])==[0.]
        @test AnalyticMathLab.predict(model,[1.],(0.,0.1)).diagnostics.success
    elseif family=="operators"
        sample=ScientificSample(:train,[1.],reshape([0.,1.],1,:),[1.,2.];split=:training)
        dataset=ScientificDataset([sample];kind=:surrogate,family=:line,input_names=(:a,),coordinate_names=(:t,),
            domain=(inputs=[0. 2.],coordinates=[0. 1.]),reference=(kind=:analytical,),
            units=(inputs=("dimensionless",),coordinates=("dimensionless",),output="dimensionless"),grid=:explicit,rng=:deterministic)
        model=learning_model(dataset,Lux.Dense(2=>1);rng=Xoshiro(9),
            rng_provenance=(kind=:Xoshiro,seed=9),normalization=:train_minmax)
        @test length(AnalyticMathLab.predict(model,[1.],sample.coordinates))==2
        @test isfinite(learning_objective(model,model.parameters,training_data(model,dataset)))
    else
        network=pinn_network(1,1;hidden=[])
        @test network isa Lux.AbstractLuxLayer
    end
end
println("STRANGER_OPTIONAL_PASS ",family," ",order)
