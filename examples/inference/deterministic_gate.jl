module DeterministicInferenceGate
using AnalyticMathLab, Test, Optimization, OptimizationOptimisers
const FD=AnalyticMathLab.ForwardDiff
function oscillator(c)
    truth=[1.,4.,c]
    factory=p->FirstOrderODE((u,t)->[u[2],-(p[2]*u[1]+p[3]*u[2])/p[1]],2;labels=("q","v"))
    path=trajectory(factory(truth),[1.,0.],(0.,4.);abstol=1e-12,reltol=1e-12)
    @test factory(truth).function_value([1.,0.],0.) == [0.,-4.]
    @test factory(truth).function_value([0.,1.],0.) == [1.,-c]
    @test path.diagnostics.success
    @test path.solution(0.) ≈ [1.,0.]
    if c==0
        @test path.solution(0.7) ≈ [cos(1.4),-2sin(1.4)] atol=1e-9
    end
    times=collect(range(0.,4.;length=41))
    fit=times[1:2:end]; held=times[2:2:end]
    obs=ObservationSet(fit,reshape([path.solution(t)[1] for t in fit],1,:);
        variables=(:q,),kind=:synthetic,provenance=(source=path,split=:odd_indices))
    ho=ObservationSet(held,reshape([path.solution(t)[1] for t in held],1,:);
        variables=(:q,),kind=:synthetic,role=:heldout,provenance=(source=path,split=:even_indices))
    spec=InferenceParameters((:m,:k,:c),[1.,3.,c==0 ? 0. : 0.2];inferred=c==0 ? (:k,) : (:k,:c))
    ref=(kind=:synthetic_truth,values=c==0 ? [4.] : [4.,c],provenance=:controlled_m6_generator)
    p=ParameterInferenceProblem(factory,spec,obs;u0=[1.,0.],tspan=(0.,4.),heldout=ho,reference=ref)
    p,path
end
@testset "Deterministic M6 inference" begin
    @test isdefined(AnalyticMathLab,:infer_parameters)
    if isdefined(AnalyticMathLab,:infer_parameters)
        for damping in (0.,0.6)
            p,path=oscillator(damping)
            x=p.parameters.initial[p.parameters.indices]
            g=FD.gradient(z->inference_objective(p,z),x)
            h=1e-5
            fd=[(inference_objective(p,x+h*Float64.(eachindex(x).==j))-inference_objective(p,x-h*Float64.(eachindex(x).==j)))/(2h) for j in eachindex(x)]
            @test g ≈ fd rtol=2e-4 atol=2e-5
            r=infer_parameters(p,OptimizationOptimisers.Adam(0.04);maxiters=500)
            @test maximum(abs.(r.parameters-p.reference.values)) < 0.04
            @test r.fit.rms < 0.01
            @test r.heldout.error.rms < 0.01
            @test r.sensitivity.value.rank == length(x)
            @test r.evidence.status == :unknown
            @test r.full_parameters[1] == 1.
            @test r.optimization_problem !== nothing && r.solution !== nothing
            @test isempty(intersect(p.observations.times,p.heldout.times))
            # Neither trusted truth nor held-out values enters the objective.
            before=inference_objective(p,x)
            p.reference.values .= 123.
            p.heldout.values .= -999.
            @test inference_objective(p,x) == before
            println("M9C damping=",damping," inferred=",r.parameters," fit=",r.fit," heldout=",r.heldout.error," sensitivity=",r.sensitivity.value.singular_values," condition=",r.sensitivity.value.condition," termination=",r.termination)
        end
    end
end
end
