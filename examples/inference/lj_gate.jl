# Serial optional M8 -> pair distance -> epsilon inference showcase.
module LJInferenceGate
using AnalyticMathLab, Optimization, OptimizationOptimisers, Test
import CairoMakie
const AML=AnalyticMathLab
function run(;output_dir=joinpath(@__DIR__,"..","..","notebooks","output"))
    epsilon=1.2; sigma=1.; mass=1.; box=10.
    # Trusted Cartesian two-particle generator uses M8's symbolic derivative.
    potential=lennard_jones_analysis(;epsilon,sigma)
    force=potential.numerical.force
    generator=FirstOrderODE((u,t)->begin
        f=force(u[2]-u[1]); [u[3],u[4],-f/mass,f/mass]
    end,4;labels=("x1","x2","v1","v2"))
    initial=[8.8,10.1,1.,1.]
    trusted=trajectory(generator,initial,(0.,1.5);abstol=1e-12,reltol=1e-12)
    times=collect(0.:0.025:1.5)
    states=[trusted.solution(t) for t in times]
    frames=[AtomisticSnapshot([[mod(u[1],box)],[mod(u[2],box)]];
        velocities=[[u[3]],[u[4]]],masses=[mass,mass],time=t,
        boundary=(kind=:orthorhombic,lengths=[box]),
        provenance=(source=:controlled_cartesian_lj,coordinates=:wrapped,
            units=:declared_reduced,cutoff=:none,thermostat=:none)) for (t,u) in zip(times,states)]
    view=AtomisticTrajectoryView(length(frames),i->frames[i];times,
        provenance=(source=trusted,units=:declared_reduced,saved_times=:explicit_evaluation))
    fitseries=distance_observations(view,(1,2);frames=1:2:length(view),units=:reduced_length)
    heldseries=distance_observations(view,(1,2);frames=2:2:length(view),units=:reduced_length)
    fit=ObservationSet(fitseries;kind=:synthetic)
    held=ObservationSet(heldseries;kind=:synthetic,role=:heldout)
    # Independent explicit radial law; reduced mass is m/2, not m.
    radial_force(r,e,s)=24e/r*(2(s/r)^12-(s/r)^6)
    radial_energy(r,e,s)=4e*((s/r)^12-(s/r)^6)
    @testset "LJ reference consistency before inference" begin
        @test radial_force(1.,epsilon,sigma)>0
        @test radial_force(1.5,epsilon,sigma)<0
        for r in (1.,1.15,1.3,2.)
            @test radial_energy(r,epsilon,sigma) ≈ evaluate(potential,r)
            @test radial_force(r,epsilon,sigma) ≈ force(r)
            @test -AML.ForwardDiff.derivative(x->radial_energy(x,epsilon,sigma),r) ≈ force(r)
        end
    end
    factory=p->FirstOrderODE((u,t)->[u[2],2radial_force(u[1],p[1],p[2])/mass],2;
        labels=("r","dr"),domain=(u,t)->u[1]>0)
    spec=InferenceParameters((:epsilon,:sigma),[0.9,sigma];inferred=(:epsilon,),
        units=(epsilon=:reduced_energy,sigma=:reduced_length),
        provenance=(mass=mass,mass_kind=:each_particle,initial_relative_velocity=0.,sigma=:known))
    problem=ParameterInferenceProblem(factory,spec,fit;u0=[initial[2]-initial[1],0.],
        tspan=(0.,1.5),heldout=held,
        reference=(kind=:synthetic_truth,values=[epsilon],provenance=:controlled_cartesian_lj),
        provenance=(source=view,reduction=:isolated_collinear_dimer,relative_mass=mass/2,
            time_coordinate=:declared_reduced,cutoff=:none))
    result=infer_parameters(problem,OptimizationOptimisers.Adam(0.02);maxiters=400)
    lo,hi=extrema(vcat(vec(fit.values),vec(held.values)))
    observed=collect(range(lo,hi;length=80)); outside=collect(range(hi+0.05,2.5;length=80))
    estimate=only(result.parameters)
    errors(rs)=(energy=sampled_summary(radial_energy.(rs,estimate,sigma).-evaluate.(Ref(potential),rs)),
        force=sampled_summary(radial_force.(rs,estimate,sigma).-force.(rs)))
    inside_error=errors(observed); outside_error=errors(outside)
    @testset "M8 LJ epsilon inference and independent force sign" begin
        @test trusted.diagnostics.success
        @test fit.provenance.source_series.provenance.source === view
        @test fit.times == times[1:2:end]
        @test fit.values[1,:] ≈ [u[2]-u[1] for u in states[1:2:end]] atol=1e-12
        @test isempty(intersect(fit.times,held.times))
        @test maximum(abs.(inference_predict(problem,[epsilon])-fit.values))<1e-6
        @test abs(estimate-epsilon)<0.02
        @test result.full_parameters[2]==sigma
        @test result.fit.rms<0.002
        @test result.heldout.error.rms<0.002
        @test result.sensitivity.value.rank==1
        @test result.evidence.status==:unknown
        @test radial_force(1.,epsilon,sigma)>0
        @test radial_force(1.5,epsilon,sigma)<0
        @test abs(radial_force(exp2(1/6),epsilon,sigma))<1e-12
        @test radial_energy.(observed,epsilon,sigma) ≈ evaluate.(Ref(potential),observed) atol=1e-10
        @test radial_force.(observed,epsilon,sigma) ≈ force.(observed) atol=1e-10
        @test [-AML.ForwardDiff.derivative(r->radial_energy(r,epsilon,sigma),r) for r in observed] ≈ force.(observed) atol=1e-10
        @test inside_error.energy.rms<0.02
        @test inside_error.force.rms<0.1
    end
    mkpath(output_dir)
    fitpath=joinpath(output_dir,"m9c_lj_fit.png")
    CairoMakie.save(fitpath,parameterfitplot(result))
    fig=CairoMakie.Figure(size=(1050,720))
    for (row,rs,label) in ((1,observed,"Observed distance range"),(2,outside,"Extrapolation: not constrained by these observations"))
        a=CairoMakie.Axis(fig[row,1];xlabel="r (declared reduced length)",ylabel="V (reduced energy)",title=label)
        CairoMakie.lines!(a,rs,evaluate.(Ref(potential),rs);label="independent symbolic reference")
        CairoMakie.lines!(a,rs,radial_energy.(rs,estimate,sigma);linestyle=:dash,label="inferred epsilon")
        CairoMakie.axislegend(a)
        b=CairoMakie.Axis(fig[row,2];xlabel="r (declared reduced length)",ylabel="F = -dV/dr",title="Radial force; positive = repulsive")
        CairoMakie.lines!(b,rs,force.(rs);label="reference")
        CairoMakie.lines!(b,rs,radial_force.(rs,estimate,sigma);linestyle=:dash,label="inferred")
    end
    CairoMakie.Label(fig[3,1:2],"Known LJ family and sigma; isolated collinear dimer only. No many-body law discovery or global identifiability claim.";tellwidth=false,fontsize=13)
    forcepath=joinpath(output_dir,"m9c_lj_potential_force.png"); CairoMakie.save(forcepath,fig)
    println("LJ_RESULT epsilon=",estimate," fit_rms=",result.fit.rms," heldout_rms=",result.heldout.error.rms,
        " observed_range=",(lo,hi)," observed_error=",inside_error," extrapolation_error=",outside_error,
        " singular_values=",result.sensitivity.value.singular_values," termination=",result.termination)
    (;result,inside_error,outside_error,figures=(fitpath,forcepath))
end
end
LJInferenceGate.run()
