"""
Bounded native SciML oscillator storage experiment (Float64).
Run: AML_SCALE_LEVEL=1 julia --project=. examples/scaling/large_oscillator_ode.jl
Level 0: 32/100 states; 1: through 10000; 2: through 100000;
3: through 200000 (100000 oscillators), requires AML_EXTREME=1.
Full dense history may be REFUSED even when endpoint/observable solves fit.
"""
module LargeOscillatorODE
using AnalyticMathLab
import SciMLBase
import OrdinaryDiffEqTsit5: Tsit5

# Recovery-friendly until the parent registers the internal source include.
if !isdefined(AnalyticMathLab,:_scale_ode_problem)
    Base.include(AnalyticMathLab,joinpath(@__DIR__,"../../src/dynamical_systems/scaling.jl"))
end
const STOP = 5.0
const DT = 0.05
const GRID = range(0.,STOP;length=101)
function oscillator!(du,u,p,t)
    @inbounds for i in 1:2:length(u)
        du[i]=u[i+1]
        du[i+1]=-u[i]
    end
    nothing
end
function problem(n)
    n > 0 && iseven(n) || throw(ArgumentError("positive even state dimension required"))
    u=zeros(n)
    u[1:2:end] .= 1.
    AnalyticMathLab._scale_ode_problem(oscillator!,u,(0.,STOP))
end
observables(u) = (coordinate=u[1],energy=sum(abs2,u)/2,rms=sqrt(sum(abs2,u)/length(u)))
function stored(n,strategy)
    options = strategy == :full ? (dense=true,save_everystep=true,) :
        strategy == :sparse ? (dense=false,save_everystep=false,saveat=0.:1.:STOP,) :
        strategy == :endpoints ? (dense=false,save_everystep=false,) :
        throw(ArgumentError("unknown storage strategy"))
    sol=SciMLBase.solve(problem(n),Tsit5();adaptive=false,dt=DT,maxiters=1000,
        save_start=true,save_end=true,tstops=GRID,options...)
    SciMLBase.successful_retcode(sol) && last(sol.t)==STOP || error("incomplete solve")
    sol
end
function reduced(n)
    integrator=SciMLBase.init(problem(n),Tsit5();adaptive=false,dt=DT,maxiters=1000,
        dense=false,save_everystep=false,save_start=false,save_end=false)
    # Only three scalars per requested time; no n-by-time state history.
    trace=[observables(integrator.u)]
    for t in Iterators.drop(GRID,1)
        SciMLBase.step!(integrator,t-integrator.t,true)
        integrator.t == t || error("incomplete native step")
        push!(trace,observables(integrator.u))
    end
    (trace=trace,nf=integrator.sol.stats.nf,saved_states=length(integrator.sol.u))
end
function final_error(sol)
    n=length(last(sol.u))
    maximum(abs(last(sol.u)[i]-(isodd(i) ? cos(STOP) : -sin(STOP))) for i in 1:n)
end
function reduced_error(r,n)
    maximum(max(abs(v.coordinate-cos(t)),abs(v.energy/(n/4)-1),abs(v.rms-sqrt(0.5)))
        for (t,v) in zip(GRID,r.trace))
end
function verify_storage()
    full=stored(10,:full)
    sparse=stored(10,:sparse)
    endpoints=stored(10,:endpoints)
    r=reduced(10)
    @assert r.saved_states == 0
    @assert length(sparse.u)==6 && length(endpoints.u)==2
    err=maximum(max(abs(v.coordinate-full(t)[1]),abs(v.energy-observables(full(t)).energy),
        abs(v.rms-observables(full(t)).rms)) for (t,v) in zip(GRID,r.trace))
    err=max(err,final_error(full),final_error(sparse),final_error(endpoints),reduced_error(r,10))
    @assert err < 1e-7
    err
end
# Separate the call boundary from construction and the solve allocations.
function rhs_audit(n;legacy=false)
    u=zeros(n); u[1:2:end].=1.; du=similar(u)
    if legacy
        f=FirstOrderODE((u,t)->(v=similar(u); oscillator!(v,u,nothing,t); v),n)
        run=()->AnalyticMathLab._ode_rhs(f,u,0.)
    else
        p=problem(n)
        run=()->p.f(du,u,p.p,0.)
    end
    for _ in 1:100; run(); end
    bytes=@allocated run()
    seconds=@elapsed for _ in 1:1000; run(); end
    (states=n,legacy=legacy,rhs_allocated_bytes=bytes,rhs_seconds=seconds/1000)
end
function main()
    include(joinpath(@__DIR__,"harness.jl"))
    # Include happens at runtime; use invokelatest for freshly loaded harness methods.
    Base.invokelatest(run_scaling)
end
function run_scaling()
    H=ScaleHarness; b=H.budget_from_env(); rows=NamedTuple[]
    verify_storage()
    sizes=b.level==0 ? (32,100) : b.level==1 ? (32,100,1000,10000) :
        b.level==2 ? (32,100,1000,10000,100000) : (32,100,1000,10000,100000,200000)
    for n in sizes
        H.measure!(rows,b,"rhs_inplace",n,H.dense_bytes(n,5),()->rhs_audit(n);
            check=r->(println(r); @assert r.rhs_allocated_bytes==0; 0.),algorithm="checked native in-place RHS")
        if n==32
            H.measure!(rows,b,"rhs_legacy",n,H.dense_bytes(n,5),()->rhs_audit(n;legacy=true);
                check=r->(println(r); 0.),algorithm="legacy out-of-place RHS")
        end
        for strategy in (:full,:sparse,:endpoints,:reduced)
            # Tsit5 solver workspace plus snapshots and dense interpolation stages.
            # Conservative controlled fixed-step bound, not a general adaptive bound.
            vectors=strategy==:full ? 1000 : strategy==:sparse ? 40 : 32
            estimate=H.dense_bytes(n,vectors)+65536
            f=strategy==:reduced ? ()->reduced(n) : ()->stored(n,strategy)
            check = strategy==:reduced ? r->begin
                e=reduced_error(r,n); @assert e<1e-7 && r.saved_states==0
                println((states=n,strategy=strategy,nf=r.nf,saved_states=r.saved_states)); e
            end : sol->begin
                e=final_error(sol); @assert e<1e-7
                println((states=n,strategy=strategy,nf=sol.stats.nf,saved_states=length(sol.u))); e
            end
            count = strategy==:reduced ? r->3length(r.trace) : sol->length(sol.u)*n
            H.measure!(rows,b,"oscillator_$(strategy)",n,estimate,f;check,
                output_count=count,algorithm="native Tsit5 fixed dt=0.05")
            H.report("large_oscillator_ode",rows,b)
        end
    end
    H.report("large_oscillator_ode",rows,b)
end
end
if abspath(PROGRAM_FILE)==@__FILE__
    LargeOscillatorODE.main()
end
