# Tiny deterministic numerical gate; no optimizer or training is run.
module M10BOptionalNumericGate
using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, Random
using AnalyticMathLab: Symbolics
const A=AnalyticMathLab
include("heat_family.jl")

@testset "M10B native neural nonfinite and huge-output contracts" begin
    d=HeatFamily.parametric_dataset()
    output=Ref(0.)
    net=Lux.WrappedFunction(x->fill(output[],1,size(x,2)))
    m=learning_model(d,net;rng=Xoshiro(1020),normalization=:none,rng_provenance=(seed=1020,))
    s=first(d.samples); batch=training_data(m,d)
    for bad in (NaN,Inf,-Inf)
        output[]=bad
        @test_throws DomainError A.predict(m,s.input,s.coordinates)
        @test_throws DomainError learning_objective(m,m.parameters,batch)
    end
    output[]=1e200
    @test all(==(1e200),A.predict(m,s.input,s.coordinates))
    # MSE is truly outside Float64 range: explicit failure, not an Inf loss.
    @test_throws DomainError learning_objective(m,m.parameters,batch)
    output[]=2.
    scale=A.AffineScaling([-1e308],[1e308],m.normalization.outputs.fitted_ids,:outputs)
    extreme=A.ScientificModel(m.architecture,m.network,m.parameters,m.state,m.schema,
        merge(m.normalization,(outputs=scale,)),m.provenance)
    @test all(y->isapprox(y,1e308),A.predict(extreme,s.input,s.coordinates))
    output[]=4.
    @test_throws ArgumentError A.predict(extreme,s.input,s.coordinates)

    known=FirstOrderODE((u,t)->[floatmax(Float64)],1)
    correction=Ref(0.)
    u=A.UDEProblem(known,Lux.WrappedFunction(x->[correction[]]),NamedTuple(),NamedTuple();correction_indices=(1,))
    for bad in (NaN,Inf,-Inf)
        correction[]=bad
        @test_throws DomainError A.learned_correction(u,[0.])
    end
    correction[]=floatmax(Float64)
    @test_throws DomainError A.learned_vector_field(u,[0.])
    Symbolics.@variables q p
    mechanics=analyze(HamiltonianSystem((q^2+p^2)/2;coordinates=(q,),momenta=(p,)))
    energy=Ref(0.)
    h=A.HamiltonianNN(mechanics,Lux.WrappedFunction(x->[energy[]]),NamedTuple(),NamedTuple())
    for bad in (NaN,Inf,-Inf)
        energy[]=bad
        @test_throws DomainError A.learned_energy(h,[0.,0.])
    end
    energy[]=1e300
    @test A.learned_energy(h,[0.,0.])==1e300
    @test ismissing(A.Makie.current_backend())
    @test Base.get_extension(A,:AnalyticMathLabPINNExt)===nothing
end
end
