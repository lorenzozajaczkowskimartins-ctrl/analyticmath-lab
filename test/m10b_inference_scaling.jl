module M10BInferenceScalingTests
using Test, AnalyticMathLab, LinearAlgebra

@testset "M10B bounded local sensitivity and parameter boundaries" begin
    delta=2.0^-18
    factory=p->FirstOrderODE((u,t)->[p[1]+p[2],delta*p[2]],2;labels=("a","b"))
    obs=ObservationSet([1.],zeros(2,1);variables=(:a,:b))
    spec=InferenceParameters((:p,:q),[1.,1.];inferred=(:p,:q))
    problem=ParameterInferenceProblem(factory,spec,obs;u0=[0.,0.],tspan=(0.,1.))
    oracle=[1. 1.;0. delta]
    for theta in ([1.,1.],Float32[1,1])
        s=local_sensitivity(problem,theta;rank_rtol=0f0,rank_atol=0f0).value
        @test s.jacobian ≈ oracle rtol=64eps(Float32)
        @test s.singular_values ≈ svdvals(oracle) rtol=64eps(Float32)
        @test s.rank==2
        @test s.condition ≈ cond(oracle) rtol=64eps(Float32)
        cutoff=Float32(2.0^-17)
        limited=local_sensitivity(problem,theta;rank_rtol=cutoff).value
        @test limited.threshold == cutoff*maximum(limited.singular_values)
        @test limited.rank==1 && isinf(limited.condition)
    end
    @test_throws ArgumentError local_sensitivity(problem,[1.,1.];rank_atol=floatmax(Float64),rank_rtol=floatmax(Float64))
    for bad in (BigFloat("1e400"),BigFloat("1e-400"),BigFloat(1)+eps(BigFloat),NaN,Inf,1+im)
        @test_throws ArgumentError inference_predict(problem,[bad,bad])
    end
    for bad in (BigFloat("1e400"),BigFloat("1e-400"))
        @test_throws ArgumentError ParameterInferenceProblem(factory,spec,obs;u0=[0.,0.],tspan=(0.,1.),abstol=bad)
        @test_throws ArgumentError ParameterInferenceProblem(factory,spec,obs;u0=[bad,0],tspan=(0.,1.))
    end
end

function dataset(values;heldout=1e300)
    samples=[ScientificSample(Symbol("s",i),[Float64(i)],zeros(1,1),[v];split=:training) for (i,v) in enumerate(values)]
    push!(samples,ScientificSample(:heldout,[100.],zeros(1,1),[heldout];split=:parameter_extrapolation))
    ScientificDataset(samples;kind=:surrogate,family=:numeric,input_names=(:p,),coordinate_names=(:x,),
        domain=(inputs=[1. Float64(length(values))],coordinates=[0. 0.]),reference=(kind=:analytical,),
        units=:dimensionless,grid=(resampling=:none,),rng=(seed=1,))
end
@testset "M10B scaling constant, tiny, huge and held-out isolation" begin
    for values in ([1e300,1e300],[1e12,1e12+0.25],[-1e308,1e308])
        d=dataset(values); s=fit_scaling(d,:outputs)
        @test s.fitted_ids==[:s1,:s2]
        @test inverse_transform(s,transform(s,reshape(values,1,:))) ≈ reshape(values,1,:)
        other=fit_scaling(dataset(values;heldout=-1e300),:outputs)
        @test s.offset==other.offset && s.scale==other.scale
        @test s.scale==[values[1]==values[2] ? 1. : (values[2]/2-values[1]/2)]
    end
    tiny=nextfloat(0.)
    constant=fit_scaling(dataset([tiny,tiny]),:outputs)
    @test constant.offset==[tiny] && constant.scale==[1.]
    @test transform(constant,[tiny])==[0.]
    @test_throws ArgumentError fit_scaling(dataset([0.,tiny]),:outputs)
    z=AffineScaling([0.],[1.],[:s],:outputs)
    for bits in (128,256)
        setprecision(BigFloat,bits) do
            x=reshape([BigFloat("1e400"),BigFloat("1e-400")],1,:)
            @test transform(z,x)==x
            @test inverse_transform(z,x)==x
            e=field_errors(2x,x;relative_floor=0)
            @test e.summary.rms isa BigFloat
            @test e.relative_sampled_l2 ≈ BigFloat(1)
        end
    end
    @test sampled_summary([missing,1.]).finite_count==1
    @test sampled_summary([missing,1.]).rms===nothing
end
end
