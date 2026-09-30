module AnalyticMathLabInferenceExt
import AnalyticMathLab as AML
import Optimization
import AnalyticMathLab: ForwardDiff, SciMLBase

function infer_parameters(p::AML.ParameterInferenceProblem,optimizer;maxiters::Integer,
        history_stride::Integer=10,history_capacity::Integer=1000,rank_rtol=1e-8,rank_atol=0.,kwargs...)
    maxiters>0 && history_stride>0 && history_capacity>0 || throw(ArgumentError("positive iteration/history controls required"))
    x=copy(p.parameters.initial[p.parameters.indices])
    objective=(theta,_=nothing)->AML.inference_objective(p,theta)
    grad! = (g,theta,_)->ForwardDiff.gradient!(g,z->AML.inference_objective(p,z),theta)
    fun=Optimization.OptimizationFunction(objective;grad=grad!)
    bounds=p.parameters.bounds
    opt=bounds===nothing ? Optimization.OptimizationProblem(fun,x) :
        Optimization.OptimizationProblem(fun,x;lb=copy(bounds[1]),ub=copy(bounds[2]))
    history=NamedTuple[]; truncated=Ref(false)
    function observe(state,loss)
        if state.iter==1 || state.iter%history_stride==0
            if length(history)<history_capacity
                push!(history,(iteration=Int(state.iter),objective=Float64(loss)))
            else
                truncated[]=true
            end
        end
        false
    end
    solution=Optimization.solve(opt,optimizer;maxiters,callback=observe,kwargs...)
    theta=copy(solution.u)
    fit_solution=AML._inference_solve(p,theta,p.observations.times)
    prediction=Array(fit_solution)[p.indices,:]
    fit=AML.sampled_summary(prediction.-p.observations.values)
    held=p.heldout===nothing ? nothing : begin
        values=AML.inference_predict(p,theta,p.heldout)
        (observations=p.heldout,prediction=values,error=AML.sampled_summary(values.-p.heldout.values),
            domain=(first(p.heldout.times),last(p.heldout.times)),excluded_from_objective=true)
    end
    comparison=p.reference===nothing ? nothing : (
        kind=p.reference.kind,values=copy(p.reference.values),
        absolute_error=abs.(theta.-p.reference.values),
        relative_error=[iszero(v) ? nothing : abs((theta[i]-v)/v) for (i,v) in enumerate(p.reference.values)],
        provenance=p.reference.provenance)
    termination=(retcode=solution.retcode,backend_success=SciMLBase.successful_retcode(solution),
        iterations=solution.stats.iterations,requested_maxiters=Int(maxiters))
    AML.ParameterInferenceResult(p,opt,solution,theta,AML._inference_parameters(p.parameters,theta),
        fit_solution,prediction,fit,held,AML.local_sensitivity(p,theta;rank_rtol,rank_atol),comparison,
        (entries=history,stride=history_stride,capacity=history_capacity,truncated=truncated[]),
        termination,optimizer,AML.inference_objective(p,theta),
        AML.PropertyResult(nothing,:unknown,:global_physics_not_established,
            ["Optimizer termination is not correct physics; synthetic recovery is not global identifiability."]),
        (model=p.provenance,parameters=p.parameters.provenance,solver=p.solver,
         packages=(Optimization=pkgversion(Optimization),ForwardDiff=pkgversion(ForwardDiff),SciMLBase=pkgversion(SciMLBase)),
         optimizer_options=(maxiters=maxiters,kwargs...)),
        ["Direct ForwardDiff through a numerical solve is local sensitivity, not a structural identifiability method.",
         "Only explicit parameter bounds are enforced by a compatible backend optimizer; no positivity is inferred.",
         "No likelihood, posterior, or uncertainty interval is constructed.",
         "Model factories and parameter-dependent domain tests must support dual numbers; nonsmooth models are not certified."])
end
end
