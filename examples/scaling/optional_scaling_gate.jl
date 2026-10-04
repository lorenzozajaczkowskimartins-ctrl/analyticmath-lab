# Run with --project=examples/operators. No training or plotting backend required.
module OptionalScalingGate
using Test, AnalyticMathLab, Random
if get(ENV,"AML_PINN_SCALE","0")!="1"
    using Lux, NeuralOperators, Optimization
end
const A=AnalyticMathLab
function fixture(kind)
    q=[0. 0.25 0.5 0.75 1.;0. 0.1 0.2 0.3 0.4]
    input=kind==:surrogate ? [0.2] : [0.2,0.4]
    sample=ScientificSample(:train,input,q,collect(q[1,:]);split=:training,descriptor=kind==:operator ? input : nothing)
    domain=kind==:surrogate ? (inputs=[0.1 0.3],coordinates=[0. 1.;0. 1.]) : (descriptors=[0. 1.;0. 1.],coordinates=[0. 1.;0. 1.])
    ScientificDataset([sample];kind,family=:controlled,input_names=kind==:surrogate ? (:a,) : (:s1,:s2),coordinate_names=(:x,:t),domain,
        reference=(kind=:manufactured,),units=:dimensionless,grid=(resampling=:none,),rng=(seed=42,),sensors=kind==:surrogate ? nothing : [0. 1.])
end
function main()
    @testset "M10C bounded Lux / DeepONet prediction" begin
        for kind in (:surrogate,:operator)
            d=fixture(kind); s=only(d.samples)
            net=kind==:surrogate ? Lux.Chain(Lux.Dense(3=>32,tanh),Lux.Dense(32=>1)) : DeepONet(Lux.Dense(2=>16),Lux.Chain(Lux.Dense(2=>32,tanh),Lux.Dense(32=>16)))
            m=learning_model(d,net;rng=Xoshiro(42),normalization=:train_minmax,rng_provenance=(seed=42,))
            q=repeat(s.coordinates,1,2000)
            A.predict(m,s.input,q)
            println((kind=kind,n=size(q,2),unsplit_bytes=@allocated(A.predict(m,s.input,q))))
            for batch in (1,2,5,20)
                @test A.predict(m,s.input,s.coordinates;batch_size=batch) ≈ A.predict(m,s.input,s.coordinates) rtol=1e-12
            end
            @test_throws ArgumentError A.predict(m,s.input,s.coordinates;batch_size=0)
            @test_throws ArgumentError A.predict(m,s.input,s.coordinates;batch_size=-1)
            @test A.predict(m,s.input,q;batch_size=128) ≈ A.predict(m,s.input,q) rtol=1e-12
            println((kind=kind,n=size(q,2),chunked_bytes=@allocated(A.predict(m,s.input,q;batch_size=128))))
        end
    end
end
function pinn_main()
    include(joinpath(@__DIR__,"..","pinn","m10b_gate.jl"))
    # Include defines a real untrained fixture, never presented as optimizer output.
    Base.invokelatest(pinn_checks)
end
function pinn_checks()
    r=M10BPINNNumericGate.fixture(); ext=Base.get_extension(A,:AnalyticMathLabPINNExt)
    X=reshape(collect(range(0.,1.;length=17)),1,:)
    @testset "M10C bounded PINN prediction and residual" begin
        for batch in (1,4,17,32)
            @test A.predict(r,X;batch_size=batch) ≈ A.predict(r,X)
        end
        @test_throws ArgumentError A.predict(r,X;batch_size=0)
        block=first(r.problem.backend_metadata.blocks)
        for n in (17,10_000)
            points=PINNPoints(reshape(collect(range(0.,1.;length=n)),1,:))
            full=ext._sample_residual(r,block,points)
            bounded=ext._sample_residual(r,block,points;summary_only=true)
            @test bounded.count==n
            @test bounded.rms ≈ sampled_summary(full).rms rtol=1e-12
            @test bounded.mean_absolute ≈ sampled_summary(full).mean_absolute rtol=1e-12
            @test bounded.max_absolute == sampled_summary(full).max_absolute
            before=@timed ext._sample_residual(r,block,points)
            after=@timed ext._sample_residual(r,block,points;summary_only=true)
            println((n=n,full_seconds=before.time,full_bytes=before.bytes,full_result_bytes=Base.summarysize(before.value),
                summary_seconds=after.time,summary_bytes=after.bytes,summary_result_bytes=Base.summarysize(after.value),batch_size=block.npoints))
        end
    end
end
if abspath(PROGRAM_FILE)==(@__FILE__)
    get(ENV,"AML_PINN_SCALE","0")=="1" ? pinn_main() : main()
end
end
