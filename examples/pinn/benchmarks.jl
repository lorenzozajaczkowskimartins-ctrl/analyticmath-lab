# Optional CPU benchmark definitions, not loaded by the package or base tests.
module PINNBenchmarks
using AnalyticMathLab, Random
import NeuralPDE, ModelingToolkit, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem

function specification(name::Symbol)
    @parameters x y t
    @variables u(..) v(..) p(..)
    Dx=Differential(x); Dy=Differential(y); Dt=Differential(t)
    if name==:heat
        @named sys=PDESystem([Dt(u(x,t)) ~ 0.1Dx(Dx(u(x,t)))],
            [u(0.,t) ~ 0.,u(1.,t) ~ 0.,u(x,0.) ~ sin(pi*x)],
            [x ∈ (0.,1.),t ∈ (0.,1.)],[x,t],[u(x,t)])
        return (system=sys,reference=z->[sin(pi*z[1])*exp(-0.1pi^2*z[2])],
            pdes=1,ic=[4],labels=[:heat],inputs=2,outputs=1)
    elseif name==:poisson2d
        @named sys=PDESystem([-Dx(Dx(u(x,y)))-Dy(Dy(u(x,y))) ~ 2pi^2*sin(pi*x)*sin(pi*y)],
            [u(0.,y) ~ 0.,u(1.,y) ~ 0.,u(x,0.) ~ 0.,u(x,1.) ~ 0.],
            [x ∈ (0.,1.),y ∈ (0.,1.)],[x,y],[u(x,y)])
        return (system=sys,reference=z->[sin(pi*z[1])*sin(pi*z[2])],
            pdes=1,ic=Int[],labels=[:poisson],inputs=2,outputs=1)
    elseif name==:coupled
        @named sys=PDESystem([Dt(u(x,t)) ~ 0.1Dx(Dx(u(x,t)))+v(x,t),
            Dt(v(x,t)) ~ 0.1Dx(Dx(v(x,t)))-u(x,t)],
            [u(0.,t) ~ 0.,u(1.,t) ~ 0.,v(0.,t) ~ 0.,v(1.,t) ~ 0.,
             u(x,0.) ~ sin(pi*x),v(x,0.) ~ 0.],
            [x ∈ (0.,1.),t ∈ (0.,1.)],[x,t],[u(x,t),v(x,t)])
        return (system=sys,reference=z->sin(pi*z[1])*exp(-0.1pi^2*z[2]).*[cos(z[2]),-sin(z[2])],
            pdes=2,ic=[7,8],labels=[:u_equation,:v_equation],inputs=2,outputs=2)
    elseif name==:burgers
        # Traveling viscous shock on a bounded domain; exact nonzero boundary data.
        nu=0.1
        exact=(a,b)->1-tanh((a-b)/(2nu))
        @named sys=PDESystem([Dt(u(x,t))+u(x,t)*Dx(u(x,t)) ~ nu*Dx(Dx(u(x,t)))],
            [u(0.,t) ~ exact(0.,t),u(1.,t) ~ exact(1.,t),u(x,0.) ~ exact(x,0.)],
            [x ∈ (0.,1.),t ∈ (0.,1.)],[x,t],[u(x,t)])
        return (system=sys,reference=z->[exact(z[1],z[2])],pdes=1,ic=[4],
            labels=[:burgers],inputs=2,outputs=1)
    elseif name==:navier_stokes
        # Unforced transient shear: u=exp(-nu*t)sin(y), v=p=0.
        # Full nonlinear momentum operators remain present in the trained system.
        nu=0.1
        U=u(x,y,t); V=v(x,y,t); P=p(x,y,t)
        exact=(b,c)->exp(-nu*c)*sin(b)
        eqs=[Dt(U)+U*Dx(U)+V*Dy(U)+Dx(P)-nu*(Dx(Dx(U))+Dy(Dy(U))) ~ 0.,
             Dt(V)+U*Dx(V)+V*Dy(V)+Dy(P)-nu*(Dx(Dx(V))+Dy(Dy(V))) ~ 0.,
             Dx(U)+Dy(V) ~ 0.]
        bcs=[u(0.,y,t) ~ exact(y,t),u(1.,y,t) ~ exact(y,t),
             u(x,0.,t) ~ 0.,u(x,1.,t) ~ exact(1.,t),
             v(0.,y,t) ~ 0.,v(1.,y,t) ~ 0.,v(x,0.,t) ~ 0.,v(x,1.,t) ~ 0.,
             p(0.,0.,t) ~ 0.,u(x,y,0.) ~ sin(y),v(x,y,0.) ~ 0.]
        @named sys=PDESystem(eqs,bcs,[x ∈ (0.,1.),y ∈ (0.,1.),t ∈ (0.,1.)],
            [x,y,t],[U,V,P])
        return (system=sys,reference=z->[exact(z[2],z[3]),0.,0.],pdes=3,
            ic=[13,14],labels=[:x_momentum,:y_momentum,:incompressibility],inputs=3,outputs=3)
    end
    throw(ArgumentError("unknown benchmark $name"))
end

function construct(name;strategy=NeuralPDE.GridTraining(0.25),seed=42,hidden=[12,12])
    s=specification(name)
    problem=pinn_problem(s.system;network=pinn_network(s.inputs,s.outputs;hidden),
        network_layout=:shared,strategy,rng=Xoshiro(seed),adtype=ADTypes.AutoZygote(),
        provenance=(benchmark=name,seed=seed))
    (spec=s,problem=problem)
end

# Supplied grids offset from the deterministic training grid; this says nothing
# about every past training set when caller callbacks resample.
function evaluation_points(b;n=9)
    d=length(b.ivs)
    d==0 && return PINNPoints(zeros(0,1))
    axes=[range(b.bounds[1][i]+0.037*(b.bounds[2][i]-b.bounds[1][i]),
        b.bounds[2][i]-0.043*(b.bounds[2][i]-b.bounds[1][i]);length=n) for i in 1:d]
    X=reduce(hcat,[collect(z) for z in Iterators.product(axes...)])
    PINNPoints(reshape(X,d,:);generation=:offset_tensor_grid,provenance=(purpose=:diagnostics,))
end

function run(name;maxiters=500,strategy=NeuralPDE.GridTraining(0.25),seed=42,hidden=[12,12],n=9)
    fixture=construct(name;strategy,seed,hidden)
    r=AnalyticMathLab.train(fixture.problem,OptimizationOptimisers.Adam(0.01);maxiters,
        history=true,record_components=true,log_every=25,history_capacity=100)
    blocks=fixture.problem.backend_metadata.blocks
    points=Dict(i=>evaluation_points(b;n) for (i,b) in enumerate(blocks))
    roles=Dict(i=>:ic for i in fixture.spec.ic)
    a=analyze(r;residual_points=points,condition_roles=roles,reference_points=points[1],
        reference=fixture.spec.reference,reference_provenance=(kind=:analytical,benchmark=name,),
        provenance=(equation_labels=fixture.spec.labels,))
    (;fixture...,result=r,analysis=a)
end

function report(run)
    a=run.analysis
    println("BENCHMARK ",run.problem.provenance.user.benchmark)
    println("objective=",a.loss_diagnostics.objective," evaluated_objective=",a.loss_diagnostics.evaluated_objective)
    println("retcode=",run.result.termination.retcode," budget=",run.result.termination.requested_maxiters)
    println("reference_rms=",getproperty.(a.reference.value.summary,:rms))
    println("reference_max=",getproperty.(a.reference.value.summary,:max_absolute))
    for r in a.residuals
        println("block=",r.index," role=",r.role," rms=",r.summary.rms,
            " max=",r.summary.max_absolute," snapshot_overlap=",r.sampling.snapshot_overlap_count)
    end
    println("global_correctness=",a.evidence.status," adaptive_weight_evolution=unavailable")
end
end
