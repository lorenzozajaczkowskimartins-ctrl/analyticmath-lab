"""
Native SciML ensembles: deterministic independent decays, serial/threaded,
full trajectories vs bounded batches reduced to sum/count/max-error/RHS calls.
AML_SCALE_LEVEL=1 JULIA_NUM_THREADS=2 julia --project=. examples/scaling/ode_ensemble.jl
Level 0:100, 1:100/1000, 2:plus10000, 3:plus100000 (AML_EXTREME=1).
No shared mutable state or custom solver; no universal parallel-speedup claim.
"""
module ODEEnsemble
using AnalyticMathLab
import SciMLBase
import OrdinaryDiffEqTsit5: Tsit5
if !isdefined(AnalyticMathLab,:_scale_ode_problem)
    Base.include(AnalyticMathLab,joinpath(@__DIR__,"../../src/dynamical_systems/scaling.jl"))
end
decay!(du,u,p,t) = (du[1]=-p*u[1]; nothing)
rate(i)=0.5+(i%10)/10
function member(prob,ctx)
    SciMLBase.remake(prob;u0=[1.],p=rate(ctx.sim_id))
end
function output(sol,ctx)
    SciMLBase.successful_retcode(sol) && last(sol.t)==1. || error("ensemble member failed")
    value=last(sol.u)[1]
    ((value,1.,abs(value-exp(-rate(ctx.sim_id))),Float64(sol.stats.nf)),false)
end
function reduce_batch(u,data,I)
    for v in data
        u[1]+=v[1]; u[2]+=v[2]; u[3]=max(u[3],v[3]); u[4]+=v[4]
    end
    (u,false)
end
function ensemble(n;threaded=false,aggregate=true)
    n>0 || throw(ArgumentError("positive trajectory count required"))
    p=AnalyticMathLab._scale_ode_problem(decay!,[1.],(0.,1.);p=0.5)
    options = aggregate ? (output_func=output,reduction=reduce_batch,u_init=zeros(4)) : (;)
    ep=SciMLBase.EnsembleProblem(p;prob_func=member,safetycopy=true,options...)
    backend=threaded ? SciMLBase.EnsembleThreads() : SciMLBase.EnsembleSerial()
    SciMLBase.solve(ep,Tsit5(),backend;trajectories=n,batch_size=min(n,32),
        adaptive=false,dt=0.05,maxiters=100,dense=!aggregate,
        save_everystep=!aggregate,save_start=!aggregate,save_end=true)
end
function ensemble_error(result,n,aggregate)
    if aggregate
        @assert result.u[2]==n
        expected=sum(exp(-rate(i)) for i in 1:n)
        max(abs(result.u[1]-expected)/n,result.u[3])
    else
        @assert length(result.u)==n
        maximum(begin
            @assert SciMLBase.successful_retcode(sol) && last(sol.t)==1.
            maximum(abs(u[1]-exp(-rate(i)*t)) for (u,t) in zip(sol.u,sol.t))
        end for (i,sol) in enumerate(result.u))
    end
end
function verify_ensemble()
    n=12
    full=ensemble(n;aggregate=false)
    aggregate=ensemble(n)
    e=max(ensemble_error(full,n,false),ensemble_error(aggregate,n,true),
        abs(sum(last(sol.u)[1] for sol in full.u)-aggregate.u[1])/n)
    if Threads.nthreads()>1
        threaded=ensemble(n;threaded=true)
        threaded_full=ensemble(n;threaded=true,aggregate=false)
        e=max(e,ensemble_error(threaded,n,true),ensemble_error(threaded_full,n,false),
            maximum(abs.(threaded.u-aggregate.u)))
    end
    @assert e<1e-7
    e
end
function main()
    include(joinpath(@__DIR__,"harness.jl"))
    Base.invokelatest(run_scaling)
end
function run_scaling()
    H=ScaleHarness; b=H.budget_from_env(); rows=NamedTuple[]
    verify_ensemble()
    sizes=b.level==0 ? (100,) : b.level==1 ? (100,1000) :
        b.level==2 ? (100,1000,10000) : (100,1000,10000,100000)
    backends=min(Threads.nthreads(),b.threads)>1 ? (false,true) : (false,)
    for n in sizes, threaded in backends, aggregate in (true,false)
        # Full native solution has many small vectors/objects, not just scalar payload.
        estimate=aggregate ? 4*1024^2+min(n,32)*16384 : 4*1024^2+n*32768
        check=r->begin
            e=ensemble_error(r,n,aggregate); @assert e<1e-7
            nf=aggregate ? r.u[4] : sum(s.stats.nf for s in r.u)
            println((trajectories=n,threaded=threaded,aggregate=aggregate,nf=nf)); e
        end
        count=aggregate ? r->4 : r->sum(length(s.u) for s in r.u)
        H.measure!(rows,b,"ensemble_$(threaded ? "threaded" : "serial")_$(aggregate ? "aggregate" : "full")",
            n,estimate,()->ensemble(n;threaded,aggregate);check,output_count=count,algorithm="native EnsembleProblem/Tsit5")
        H.report("ode_ensemble",rows,b)
    end
    H.report("ode_ensemble",rows,b)
end
end
if abspath(PROGRAM_FILE)==@__FILE__
    ODEEnsemble.main()
end
