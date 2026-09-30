"""Bounded CPU examples. Run with the optional inference environment."""
module NeuralShowcase
using AnalyticMathLab, Lux, Optimization, OptimizationOptimisers, Random, CairoMakie, Test
using AnalyticMathLab: Symbolics
const AML=AnalyticMathLab
rmse(a,b)=sqrt(sum(abs2,a-b)/length(a))
columns(sol,t)=hcat(sol.(t)...)
function run(;output_dir=joinpath(@__DIR__,"artifacts"))
    mkpath(output_dir)
    Symbolics.@variables q p
    mechanics=analyze(HamiltonianSystem((q^2+p^2)/2;coordinates=(q,),momenta=(p,)))
    reference_dynamics=dynamics(mechanics)
    # Small polynomial-activation network: trainable output weights and bias.
    # Deliberately strong inductive bias; not a generic function-discovery claim.
    hnet=Lux.Chain(Lux.WrappedFunction(x->x.^2),Lux.Dense(2=>1))
    hs=Lux.testmode(last(Lux.setup(Random.Xoshiro(91),hnet)))
    hp(v)=(layer_1=NamedTuple(),layer_2=(weight=reshape(v[1:2],1,2),bias=v[3:3]))
    h0=AML.HamiltonianNN(mechanics,hnet,hp([0.2,0.8,2.]),hs)
    trainx=hcat(([a,b] for a in (-1.,-0.5,0.,0.5,1.) for b in (-1.,-0.5,0.,0.5,1.))...)
    heldx=hcat(([a,b] for a in (-0.85,-0.35,0.15,0.65) for b in (-0.75,-0.25,0.25,0.75))...)
    field(x)=hcat((evaluate(reference_dynamics.system.field,z) for z in eachcol(x))...)
    @test field(reshape([2.,3.],2,1)) ≈ reshape([3.,-2.],2,1)
    hd=AML.DerivativeData(trainx,field(trainx))
    hf=AML.train(h0,hd;initial_parameters=[0.2,0.8,2.],reconstruct=hp,
        optimizer=OptimizationOptimisers.Adam(0.03),maxiters=220,history_limit=220)
    times=collect(range(0.,6.;length=121))
    htraj=AML.predict(hf,[0.8,0.3],(0.,6.))
    hv=columns(htraj.solution,times)
    exact=hcat(([0.8cos(t)+0.3sin(t),0.3cos(t)-0.8sin(t)] for t in times)...)
    henergy=[AML.aligned_energy(hf.model,hv[:,i];reference=zeros(2)) for i in axes(hv,2)]
    htrue=[sum(abs2,hv[:,i])/2 for i in axes(hv,2)]
    hex=hcat(([a,b] for a in (-2.,-1.5,1.5,2.) for b in (-2.,-1.5,1.5,2.))...)
    # Only linear force is known. Cubic coefficient is never passed to train.
    known=FirstOrderODE((u,t)->[u[2],-u[1]],2;labels=("q","p"))
    reference=FirstOrderODE((u,t)->[u[2],-u[1]-0.2u[1]^3],2)
    @test reference.function_value([0.7,0.2],0.)-known.function_value([0.7,0.2],0.) ≈ [0.,-0.2*0.7^3]
    unet=Lux.Chain(Lux.WrappedFunction(x->[x[1]^3]),Lux.Dense(1=>1;use_bias=false))
    us=Lux.testmode(last(Lux.setup(Random.Xoshiro(92),unet)))
    up(v)=(layer_1=NamedTuple(),layer_2=(weight=reshape(v,1,1),))
    u0=AML.UDEProblem(known,unet,up([-0.04]),us;correction_indices=(2,))
    fit_times=collect(range(0.,3.;length=25))
    ref_fit=trajectory(reference,[1.,0.],(0.,3.);abstol=1e-11,reltol=1e-10)
    data=AML.TrajectoryData(fit_times,columns(ref_fit.solution,fit_times))
    uf=AML.train(u0,data;initial_parameters=[-0.04],reconstruct=up,
        optimizer=OptimizationOptimisers.Adam(0.02),maxiters=160,history_limit=160)
    upred=AML.predict(uf,[1.,0.],(0.,3.))
    held_times=collect(range(0.,6.;length=121))
    uheld=AML.predict(uf,[0.65,0.25],(0.,6.))
    heldref=trajectory(reference,[0.65,0.25],(0.,6.);abstol=1e-11,reltol=1e-10)
    uex=AML.predict(uf,[1.5,0.],(0.,9.))
    exref=trajectory(reference,[1.5,0.],(0.,9.);abstol=1e-11,reltol=1e-10)
    extimes=collect(range(0.,9.;length=151))
    cx=collect(range(-0.95,0.95;length=42))
    corr=[AML.learned_correction(uf.model,[x,0.17],0.)[2] for x in cx]
    # Reference correction appears only here, after optimization.
    truecorr=-0.2 .* cx.^3
    metrics=(hnn_fit_mse=AML.dynamics_objective(hf.model,hd),
        hnn_heldout_mse=AML.dynamics_objective(hf.model,AML.DerivativeData(heldx,field(heldx))),
        hnn_extrapolation_mse=AML.dynamics_objective(hf.model,AML.DerivativeData(hex,field(hex))),
        hnn_rollout_rmse=rmse(hv,exact),hnn_energy_aligned_rmse=rmse(henergy,htrue),
        hnn_learned_energy_drift=maximum(abs.(henergy.-first(henergy))),
        hnn_true_energy_drift=maximum(abs.(htrue.-first(htrue))),
        ude_fit_rmse=rmse(columns(upred.solution,fit_times),data.states),
        ude_heldout_rmse=rmse(columns(uheld.solution,held_times),columns(heldref.solution,held_times)),
        ude_extrapolation_rmse=rmse(columns(uex.solution,extimes),columns(exref.solution,extimes)),
        ude_correction_rmse=rmse(corr,truecorr))
    fig=Figure(size=(1000,720))
    a=Axis(fig[1,1],title="HNN: derivative training objective",xlabel="callback",ylabel="MSE",yscale=log10)
    lines!(a,max.(hf.history,eps()))
    a=Axis(fig[1,2],title="Independent rollout",xlabel="q",ylabel="p")
    lines!(a,exact[1,:],exact[2,:],label="analytic"); lines!(a,hv[1,:],hv[2,:],linestyle=:dash,label="learned"); axislegend(a)
    a=Axis(fig[2,1],title="Energy aligned at (0,0)",xlabel="t",ylabel="H - H(reference)")
    lines!(a,times,htrue,label="analytic on learned states"); lines!(a,times,henergy,label="learned",linestyle=:dash); axislegend(a)
    a=Axis(fig[2,2],title="Held-out derivative errors",xlabel="q",ylabel="p")
    errors=[sqrt(sum(abs2,AML.learned_vector_field(hf.model,heldx[:,i])-field(heldx)[:,i])) for i in axes(heldx,2)]
    sc=scatter!(a,heldx[1,:],heldx[2,:],color=errors,markersize=16); Colorbar(fig[2,3],sc)
    hpath=joinpath(output_dir,"harmonic_hnn.png"); save(hpath,fig)
    fig=Figure(size=(1000,720))
    a=Axis(fig[1,1],title="UDE: trajectory-only objective",xlabel="callback",ylabel="MSE",yscale=log10)
    lines!(a,max.(uf.history,eps()))
    a=Axis(fig[1,2],title="Independent correction comparison",xlabel="q",ylabel="missing force")
    lines!(a,cx,truecorr,label="reference (evaluation only)"); lines!(a,cx,corr,linestyle=:dash,label="learned"); axislegend(a)
    a=Axis(fig[2,1],title="Held-out initial condition",xlabel="t",ylabel="q")
    lines!(a,held_times,columns(heldref.solution,held_times)[1,:],label="reference"); lines!(a,held_times,columns(uheld.solution,held_times)[1,:],linestyle=:dash,label="UDE"); axislegend(a)
    a=Axis(fig[2,2],title="Amplitude + time extrapolation",xlabel="t",ylabel="q")
    lines!(a,extimes,columns(exref.solution,extimes)[1,:],label="reference"); lines!(a,extimes,columns(uex.solution,extimes)[1,:],linestyle=:dash,label="UDE"); axislegend(a)
    upath=joinpath(output_dir,"nonlinear_ude.png"); save(upath,fig)
    report=joinpath(output_dir,"neural_report.md")
    open(report,"w") do io
        println(io,"# Bounded CPU learned dynamics\n\nGlobal correctness: **unknown**. These are numerical samples, not certificates.")
        println(io,"\nQuadratic HNN: 3 trainable scalar parameters, 220 Adam steps, seed 91. Cubic-basis UDE: 1 trainable scalar parameter, 160 Adam steps, seed 92. Strong polynomial architecture priors; no general function discovery claim.")
        println(io,"\nHNN derivative fit: 25 states; held-out: 16 distinct states; extrapolation: 16 states outside the training box. Rollout initial condition (0.8,0.3), t=0..6. Energy reference (0,0).")
        println(io,"\nUDE training: 25 trajectory observations, initial (1,0), t=0..3. Held-out: initial (0.65,0.25), t=0..6. Extrapolation: initial (1.5,0), t=0..9. Correction evaluated on 42 independent states. No analytic missing force in objective.")
        println(io,"\n| Metric | Value |\n|---|---:|")
        for (key,value) in pairs(metrics); println(io,"| $key | $value |"); end
        println(io,"\nHNN optimizer retcode: $(hf.solution.retcode); UDE optimizer retcode: $(uf.solution.retcode). Bounded optimization stopping is not a convergence certificate.")
        println(io,"\nUDE solver: $(uf.provenance.solver). Prediction retains native M6 TrajectoryResult/SciML solution. HNN gradient: ForwardDiff through scalar Lux energy, then stored M7 symplectic matrix. UDE gradient: ForwardDiff through native Tsit5.")
        println(io,"\nFigures: harmonic_hnn.png; nonlinear_ude.png. LNN deferred: velocity Hessian invertibility/conditioning and nested derivative checks are not established here. Nonlinear pendulum HNN not attempted.")
    end
    println("NEURAL_METRICS ",metrics)
    println("NEURAL_REPORT ",abspath(report))
    println("NEURAL_FIGURES ",abspath(hpath)," ",abspath(upath))
    evaluation=(hnn=(training=hd,heldout_states=heldx,extrapolation_states=hex,
            energy_reference=zeros(2),rollout=htraj,reference_states=exact,times=times,
            learned_energy=henergy,reference_energy=htrue),
        ude=(training=data,heldout=uheld,heldout_reference=heldref,heldout_times=held_times,
            extrapolation=uex,extrapolation_reference=exref,extrapolation_times=extimes,
            correction_states=cx,learned_correction=corr,reference_correction=truecorr))
    (;metrics,figures=(hpath,upath),report,hnn=hf,ude=uf,evaluation)
end
end
if abspath(PROGRAM_FILE)==@__FILE__
    NeuralShowcase.run()
end
