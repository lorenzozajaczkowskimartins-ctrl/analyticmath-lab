"""CPU-only computational stress, not convergence evidence.
Run --project=examples/operators. AML_SCALE_LEVEL 0/1/2/3 selects small/local/stress/extreme;
level 2+ also requires AML_ML_TRAIN=1; extreme additionally requires AML_EXTREME=1.
All parameter/gradient/Adam/activation estimates are checked BEFORE Lux.setup.
"""
module MLTrainingStress
using AnalyticMathLab, Lux, Zygote, ComponentArrays, OptimizationOptimisers, Random
const O=OptimizationOptimisers.Optimisers
include("harness.jl")
using .ScaleHarness
function main(;budget=budget_from_env())
    budget.level>=2 && get(ENV,"AML_ML_TRAIN","0")!="1" && throw(ArgumentError("manual training stress requires AML_ML_TRAIN=1"))
    rows=NamedTuple[]
    width,batch=((16,32),(128,256),(1024,1024),(16384,4096))[budget.level+1]
    parameters=big(width)^2+5big(width)+1
    estimate=dense_bytes(parameters,12)+dense_bytes(width,batch,16)
    println((tier=(:small,:local,:stress,:extreme)[budget.level+1],width=width,batch=batch,parameters=parameters,
        estimated_peak_workspace_bytes=estimate,parameter_gradient_adam_payload_bytes=dense_bytes(parameters,4)))
    if estimate>budget.max_memory
        measure!(rows,budget,"model_preflight",parameters,estimate,()->error("guard failed");algorithm="CPU dense Lux + Adam; refused before model allocation")
        return report("ml_training_stress",rows,budget)
    end
    # No model, parameters, optimizer state, activations or dataset exist before preflight.
    net=Lux.Chain(Lux.Dense(2=>width,tanh),Lux.Dense(width=>width,tanh),Lux.Dense(width=>1))
    rng=Xoshiro(1042); ps,st=Lux.setup(rng,net); p=ComponentArray(Lux.f64(ps)); st=Lux.testmode(st)
    x=randn(rng,2,batch); y=reshape(x[1,:].-2x[2,:],1,:)
    @assert length(p)==parameters
    loss=p->sum(abs2,first(Lux.apply(net,x,p,st)).-y)/batch
    forward=()->first(Lux.apply(net,x,p,st))
    backward=()->only(Zygote.gradient(loss,p))
    g=backward(); step=1e-5
    plus=copy(p); minus=copy(p); plus[1]+=step; minus[1]-=step
    fd=(loss(plus)-loss(minus))/(2step)
    @assert isapprox(g[1],fd;atol=1e-7,rtol=1e-4)
    measure!(rows,budget,"forward",length(p),estimate,forward;
        check=z->begin @assert size(z)==(1,batch) && all(isfinite,z); 0. end,
        output_count=length,algorithm="CPU Float64 Lux dense tanh forward")
    measure!(rows,budget,"backward",length(p),estimate,backward;
        check=z->begin @assert all(isfinite,z) && isapprox(z[1],fd;atol=1e-7,rtol=1e-4); abs(z[1]-fd) end,
        output_count=length,algorithm="Zygote gradient; independent central-difference component oracle")
    measure!(rows,budget,"optimizer_state",length(p),estimate,()->O.setup(O.Adam(1e-3),p);
        check=z->0.,output_count=z->length(p),algorithm="Adam state construction; storage measured independently")
    opt=O.setup(O.Adam(1e-3),p)
    measure!(rows,budget,"optimizer_step",length(p),estimate,()->begin
        O.update!(opt,p,g); loss(p)
    end;check=z->begin @assert isfinite(z); 0. end,output_count=z->length(p),algorithm="Adam update with fixed measured gradient; includes objective check")
    initial=loss(p)
    measure!(rows,budget,"training_three_steps",length(p),estimate,()->begin
        q=copy(p); state=O.setup(O.Adam(1e-3),q)
        for _ in 1:3
            gradient=only(Zygote.gradient(loss,q)); O.update!(state,q,gradient)
        end
        (initial=initial,final=loss(q),steps=3)
    end;check=z->begin @assert isfinite(z.final) && z.final<z.initial; z.final end,
        output_count=z->z.steps,algorithm="3 CPU Adam steps; computational observation, NOT scientific convergence")
    println((parameter_bytes=Base.summarysize(p),adam_state_bytes=Base.summarysize(opt),gradient_bytes=Base.summarysize(g),batch_shape=size(x)))
    report("ml_training_stress",rows,budget)
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
end
