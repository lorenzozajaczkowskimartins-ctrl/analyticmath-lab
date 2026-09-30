using AnalyticMathLab, Optimization, OptimizationOptimisers, CairoMakie, Test

function parameter_showcase()
    factory=p->FirstOrderODE((u,t)->[u[2],-(p[2]*u[1]+p[3]*u[2])/p[1]],2;labels=("q","v"))
    truth=[1.,4.,0.6]
    trusted=trajectory(factory(truth),[1.,0.],(0.,4.);abstol=1e-12,reltol=1e-12)
    fit_times=collect(0.:0.2:4.); held_times=collect(0.1:0.2:3.9)
    make(t,role)=ObservationSet(t,reshape([trusted.solution(x)[1] for x in t],1,:);
        variables=(:q,),kind=:synthetic,role,provenance=(source=trusted,split=role))
    spec=InferenceParameters((:m,:k,:c),[1.,3.,0.2];inferred=(:k,:c),
        units=(m=:reduced_mass,k=:reduced_stiffness,c=:reduced_damping))
    p=ParameterInferenceProblem(factory,spec,make(fit_times,:fit);u0=[1.,0.],tspan=(0.,4.),
        heldout=make(held_times,:heldout),reference=(kind=:synthetic_truth,values=[4.,0.6],provenance=:m6_synthetic))
    result=infer_parameters(p,OptimizationOptimisers.Adam(0.04);maxiters=500)
    @test result.fit.rms<0.01
    @test result.heldout.error.rms<0.01
    @test isdefined(AnalyticMathLab,:parameterfitplot)
    if isdefined(AnalyticMathLab,:parameterfitplot)
        fig=parameterfitplot(result)
        output=joinpath(@__DIR__,"..","..","notebooks","output","m9c_parameter_inference.png")
        mkpath(dirname(output))
        save(output,fig)
        println("PARAMETER_SHOWCASE ",output," parameters=",result.parameters," recovery=",result.reference_comparison,
            " fit_rms=",result.fit.rms," heldout_rms=",result.heldout.error.rms,
            " singular_values=",result.sensitivity.value.singular_values," condition=",result.sensitivity.value.condition)
    end
    result
end
parameter_showcase()
