module HeatFamily
using AnalyticMathLab, Random
using AnalyticMathLab: ForwardDiff

"""Analytical finite Fourier heat family; floating evaluation introduces roundoff only."""
function heat_solution(a,alpha,q)
    alpha>0 && isfinite(alpha) || throw(ArgumentError("positive finite diffusivity required"))
    length(q)==2 && !isempty(a) && all(isfinite,a) && all(isfinite,q) || throw(ArgumentError("finite coefficients and (x,t) required"))
    sum(a[k]*sin(k*pi*q[1])*exp(-alpha*(k*pi)^2*q[2]) for k in eachindex(a))
end
function grid(xs,ts)
    hcat(([x,t] for t in ts for x in xs)...)
end
function verify_reference()
    for a in ([1.],[0.3,-0.7,0.4]), alpha in (0.05,0.1,0.3), x in (0.13,0.41,0.87), t in (0.,0.17,0.53)
        f=q->heat_solution(a,alpha,q); q=[x,t]
        g=ForwardDiff.gradient(f,q); h=ForwardDiff.hessian(f,q)
        abs(g[2]-alpha*h[1,1])<1e-11 || error("inconsistent heat PDE reference")
        abs(f([0.,t]))<1e-12 && abs(f([1.,t]))<1e-12 || error("inconsistent heat BC reference")
        isapprox(f([x,0.]),sum(a[k]*sin(k*pi*x) for k in eachindex(a));atol=1e-12) || error("inconsistent heat IC reference")
    end
    true
end
const REFERENCE=(kind=:analytical,source="finite sine-series heat equation on [0,1], homogeneous Dirichlet BC",solver=nothing,
    algorithm=:closed_form,tolerances=nothing,error=:floating_roundoff,formula="sum(a[k]*sin(k*pi*x)*exp(-alpha*(k*pi)^2*t))")
const GRID=(ordering=:x_fastest_then_time,regular=true,boundaries=:included,resampling=:none,
    input_representation=:fixed_sensor_values,output=:scalar_u,coordinate_units=(:dimensionless,:dimensionless))
function parametric_dataset()
    verify_reference() # must precede all optimization
    q=grid(range(0.,1.;length=13),range(0.,0.5;length=9))
    qe=grid(range(0.,1.;length=21),range(0.,0.5;length=13))
    ss=ScientificSample[]
    for (role,alphas) in ((:training,collect(range(0.05,0.2;length=7))),
            (:interpolation,[0.0625,0.0875,0.1125,0.1375,0.1625,0.1875]),
            (:parameter_extrapolation,[0.015,0.3,0.45]))
        qs=role==:training ? q : qe
        for (i,a) in enumerate(alphas)
            push!(ss,ScientificSample(Symbol(role,i),[a],qs,[heat_solution([1.],a,p) for p in eachcol(qs)];split=role))
        end
    end
    qt=grid(range(0.,1.;length=21),range(0.65,0.85;length=5))
    push!(ss,ScientificSample(:later,[0.1125],qt,[heat_solution([1.],0.1125,p) for p in eachcol(qt)];split=:coordinate_extrapolation))
    ScientificDataset(ss;kind=:surrogate,family=:parametric_heat,input_names=(:alpha,),coordinate_names=(:x,:t),
        domain=(inputs=[0.05 0.2],coordinates=[0. 1.;0. 0.5]),reference=REFERENCE,
        units=:dimensionless,grid=merge(GRID,(input_representation=:parameters,)),rng=(seed=901,generation=:deterministic_parameter_grid),
        provenance=(initial_condition=:sine_pi_x,shifts=(parameter=[0.015,0.3,0.45],time=(0.65,0.85)),evaluation_grid=:explicit_denser_queries_no_resampling))
end
function operator_dataset()
    verify_reference()
    rng=Xoshiro(902); sensors=reshape(collect(range(0.,1.;length=9)),1,:)
    q=grid(range(0.,1.;length=13),range(0.,0.5;length=9))
    qe=grid(range(0.,1.;length=21),range(0.,0.5;length=13))
    qt=grid(range(0.,1.;length=21),range(0.65,0.85;length=5))
    ss=ScientificSample[]; alpha=0.1
    function add(id,a,role,qs)
        input=[heat_solution(a,alpha,[x,0.]) for x in vec(sensors)]
        push!(ss,ScientificSample(id,input,qs,[heat_solution(a,alpha,p) for p in eachcol(qs)];split=role,descriptor=a))
    end
    for i in 1:32
        add(Symbol(:train,i),[2rand(rng)-1,2rand(rng)-1,0.],:training,q)
    end
    held=[vcat(2rand(rng,2).-1,0.) for _ in 1:8]
    for (i,a) in enumerate(held)
        add(Symbol(:held,i),a,:interpolation,qe)
    end
    for (i,a) in enumerate(([1.5,1.3,0.],[-1.4,0.2,0.],[0.1,-1.6,0.]))
        add(Symbol(:amplitude,i),a,:amplitude_extrapolation,qe)
    end
    for (i,a) in enumerate(([0.3,-0.4,0.8],[-0.2,0.5,-0.7],[0.,0.,1.]))
        add(Symbol(:frequency,i),a,:frequency_extrapolation,qe)
    end
    add(:later,held[1],:coordinate_extrapolation,qt)
    ScientificDataset(ss;kind=:operator,family=:fourier_heat,input_names=Tuple(Symbol(:sensor,i) for i in 1:9),coordinate_names=(:x,:t),
        domain=(descriptors=[-1. 1.;-1. 1.;0. 0.],coordinates=[0. 1.;0. 0.5]),sensors,reference=REFERENCE,
        units=:dimensionless,grid=GRID,rng=(seed=902,type=:Xoshiro,generation=:independent_uniform_coefficients),
        provenance=(alpha=alpha,descriptor_order=(:a1,:a2,:a3),training_modes=(1,2),
            amplitude_shift=:a1_or_a2_outside_minus1_plus1,frequency_shift=:nonzero_mode3,time_shift=(0.65,0.85),
            evaluation_grid=:explicit_denser_queries_no_resampling,near_duplicate_policy=:no_exact_sensor_duplicates))
end
end
