# M8B executable Molly trajectory workflow (no hidden simulation engine).
# julia --project=examples/molly notebooks/molly_trajectory_analysis.jl
using AnalyticMathLab, Molly
import CairoMakie
const A=AnalyticMathLab
@assert pkgversion(Molly)==v"0.23.3"
@assert ismissing(A.Makie.current_backend()) || nameof(A.Makie.current_backend())==:CairoMakie
coords=[SVector(0.8+1.6i,0.8+1.6j) for i in 0:3 for j in 0:3]
vels=[SVector(0.06*(-1)^i,0.04*(-1)^j) for i in 0:3 for j in 0:3]
sys=Molly.System(atoms=[Atom(index=i,mass=1.,σ=1.,ϵ=1.) for i in eachindex(coords)],
    coords=coords,velocities=vels,boundary=RectangularBoundary(6.4),
    pairwise_inters=(LennardJones(cutoff=ShiftedPotentialCutoff(2.5)),),force_units=NoUnits,energy_units=NoUnits,
    loggers=(coords=CoordinatesLogger(Float64,2;dims=2),velocities=VelocitiesLogger(Float64,2;dims=2),
        energy=TotalEnergyLogger(Float64,2),temperature=TemperatureLogger(Float64,2)))
sim=VelocityVerlet(dt=0.002,remove_CM_motion=false)
simulate!(sys,sim,400;n_threads=1)
# Valid for THIS fresh fixed-dt simulation call only; no continuation-time inference.
times=(0:2:400).*sim.dt
t=atomistic_trajectory(sys;fixed_box=true,times)
sampling=sampling_info(t)
@assert sampling.regularity==:regular
@assert isapprox(sampling.interval,0.004)
e=observable_series(sys.loggers.energy;times,provenance=(ensemble=:NVE,simulation_timestep=sim.dt))
temp=observable_series(sys.loggers.temperature;times)
@assert parent(e.values)===values(sys.loggers.energy)
stats=statistical_summary(e)
@assert stats.value.standard_error===nothing
ac=autocorrelation(e;maxlag=80)
@assert ac.evidence.status==:heuristic
uncertainty=correlated_mean(e;maxlag=80) # May be unknown; no forced IID conclusion.
explicit_uncertainty=correlated_mean(e;maxlag=80,window=10)
blocks=block_average(e;block_sizes=[1,2,4,8,16,32,64])
running=running_statistics(e)
report=analyze(t;series=(total_energy=e,temperature=temp),observables=(:total_momentum,),
    correlations=(:total_energy,:temperature),transients=true,maxlag=80,msd=true,vacf=true)
@assert report.msd.values.status==:unknown # Molly stored wrapped coordinates, not image history.
@assert diffusion_estimate(report.msd;fit_window=(0.4,0.8)).status==:unknown
@assert report.vacf.raw.status==:heuristic
information=diagnose(report)
@assert information.value.stored_frames==201

# A separate real Molly free-flight fixture supplies trustworthy open coordinates.
# Ballistic MSD is valid; it is NOT a diffusive-regime demonstration.
free=Molly.System(atoms=[Atom(index=1,mass=1.,σ=0.,ϵ=0.)],coords=[SVector(0.,0.,0.)],
    velocities=[SVector(1.,0.,0.)],boundary=CubicBoundary(Inf),force_units=NoUnits,energy_units=NoUnits,
    loggers=(coords=CoordinatesLogger(Float64,1),velocities=VelocitiesLogger(Float64,1)))
simulate!(free,VelocityVerlet(dt=0.01,remove_CM_motion=false),40;n_threads=1)
ft=atomistic_trajectory(free;fixed_box=true,times=(0:40).*0.01)
ballistic=mean_squared_displacement(ft)
@assert isapprox(ballistic.values.value,ballistic.times.^2;atol=1e-12)
@assert diffusion_estimate(ballistic).status==:unknown # No scientifically justified diffusive fit window.

CairoMakie.activate!()
output=joinpath(@__DIR__,"output");mkpath(output)
figures=(series=timeseriesplot(e),correlation=autocorrelationplot(ac),blocks=blockplot(blocks),
    vacf=vacfplot(report.vacf),energy=energyplot(report),msd=msdplot(ballistic),
    running=timeseriesplot(ObservableSeries(running.value.means;times,name=:cumulative_energy_mean)))
for (name,fig) in pairs(figures)
    path=joinpath(output,"m8b_$(name).png")
    CairoMakie.save(path,fig)
    @assert filesize(path)>1000
    println("PLOT ",path)
end
println("MOLLY_VERSION=",pkgversion(Molly)," FRAMES=",length(t)," SAMPLE_INTERVAL=",sampling.interval)
println("ENERGY_MEAN=",stats.value.mean," ENERGY_STD=",stats.value.std)
println("AUTO_UNCERTAINTY_STATUS=",uncertainty.status)
if explicit_uncertainty.value!==nothing
    println("EXPLICIT_WINDOW=10 TAU=",explicit_uncertainty.value.tau_int,
        " N_EFF=",explicit_uncertainty.value.effective_samples," SE=",explicit_uncertainty.value.standard_error)
end
println("ENERGY_MAX_DEVIATION=",report.deviations[:total_energy].value.maximum_absolute)
println("PERIODIC_MSD_STATUS=",report.msd.values.status," DIFFUSION_WITHOUT_WINDOW=",diffusion_estimate(ballistic).status)
println("M8B_FLAGSHIP_OK — short run, no equilibration or diffusion claim")
