### A Pluto.jl notebook ###
# v0.20
# Run from repository root: julia --project=examples/molly notebooks/molly_companion.jl

# ╔═╡ 0a8a0000-0000-4000-8000-000000000001
begin
    using AnalyticMathLab, Molly, Unitful, LinearAlgebra
    import CairoMakie
end

# ╔═╡ 0a8a0000-0000-4000-8000-000000000002
begin
    # Molly runs MD; AML does not implement an integrator or force engine.
    @assert pkgversion(Molly)==v"0.23.3"
    @assert Base.get_extension(AnalyticMathLab,:AnalyticMathLabMollyExt)!==nothing
    coordinates=[SVector(0.8+1.6i,0.8+1.6j) for i in 0:3 for j in 0:3]
    velocities=[SVector(0.06*(-1)^i,0.04*(-1)^j) for i in 0:3 for j in 0:3]
    system=Molly.System(atoms=[Atom(index=i,mass=1.,σ=1.,ϵ=1.,atom_type=1) for i in eachindex(coordinates)],
        coords=coordinates,velocities=velocities,boundary=RectangularBoundary(6.4),
        pairwise_inters=(LennardJones(cutoff=ShiftedPotentialCutoff(2.5)),),
        force_units=NoUnits,energy_units=NoUnits,
        loggers=(coords=CoordinatesLogger(Float64,10;dims=2),
            velocities=VelocitiesLogger(Float64,10;dims=2),energy=TotalEnergyLogger(Float64,10)))
    simulator=VelocityVerlet(dt=0.002,remove_CM_motion=false)
    simulate!(system,simulator,200;n_threads=1)
    # Valid only because this is ONE fresh, fixed-dt simulation call with stride 10.
    saved_times=(0:10:200).*simulator.dt
    frames=atomistic_trajectory(system;fixed_box=true,times=saved_times)
    @assert length(frames)==21
    @assert frames[1].positions === values(system.loggers.coords)[1]
    @assert frames[length(frames)].time==0.4
end

# ╔═╡ 0a8a0000-0000-4000-8000-000000000003
begin
    observed=mdcheck(atomistic_snapshot(system;observables=true,n_threads=1);close_distance=0.9)
    @assert observed.checks.finite_positions
    @assert isempty(observed.observations.exact_overlaps.value)
    @assert isapprox(observed.observations.total_energy.value,Molly.total_energy(system;n_threads=1))
    particle=inspect_particle(frames[length(frames)],1;cutoff=2.5)
    @assert particle.coordination.status==:heuristic
    distribution=radial_distribution(frames;edges=range(0.,3.2;length=33))
    @assert distribution.rdf.status==:heuristic
    @assert distribution.frame_count==length(frames)
    @assert all(isfinite,distribution.rdf.value)
    neighbors=coordination(frames[length(frames)];cutoff=2.5)
    @assert neighbors.value.mean>0
    # This short deterministic example is not equilibrated; RDF is not a certificate.
end

# ╔═╡ 0a8a0000-0000-4000-8000-000000000004
begin
    textbook=lennard_jones_analysis(epsilon=1.,sigma=1.,units=(length=:reduced,energy=:reduced))
    radial_minimum=only(textbook.equilibria.value).x
    @assert isapprox(evaluate(textbook,radial_minimum),-1;atol=1e-12)
    # Compare the configured shifted potential using Molly's public pair API.
    atom=system.atoms[1]
    configured=Molly.potential_energy(system.pairwise_inters[1],SVector(1.2,0.),atom,atom,NoUnits)
    @assert isapprox(configured,evaluate(textbook,1.2)-evaluate(textbook,2.5);atol=1e-12)
    @assert normal_modes(frames[length(frames)]).evidence.status==:unknown # Molly Hessian unavailable
    # Separate local dimer example: supplied Cartesian energy Hessian, not inferred
    # from the 16-particle trajectory. Ordering: x1,y1,x2,y2.
    dimer=AtomisticSnapshot([[0.,0.],[radial_minimum,0.]];masses=[1.,2.])
    curvature=Float64(evaluate(textbook,radial_minimum;order=2))
    K=zeros(4,4); K[1,1]=K[3,3]=curvature; K[1,3]=K[3,1]=-curvature
    modes=normal_modes(dimer;hessian=K)
    @assert modes.evidence.status==:heuristic
    @assert length(modes.zero_modes)==3
    @assert isapprox(last(modes.frequencies),sqrt(1.5curvature))
end

# ╔═╡ 0a8a0000-0000-4000-8000-000000000005
begin
    # Explicit caller-side backend activation, not performed by AML.
    CairoMakie.activate!()
    output=joinpath(@__DIR__,"output"); mkpath(output)
    snapshot_figure=mdplot(frames;frame=length(frames),selected_particle=1,color=:speed)
    potential_figure=potentialplot(textbook;rmin=0.95,rmax=3.,samples=301)
    force_figure=forceplot(textbook;rmin=0.95,rmax=3.,samples=301)
    rdf_figure=AnalyticMathLab.plot(distribution)
    modes_figure=modeplot(modes;modes=[4])
    energy_figure=CairoMakie.Figure(size=(800,450))
    energy_axis=CairoMakie.Axis(energy_figure[1,1];xlabel="Time [reduced]",ylabel="Molly total energy [reduced]",
        title="Configured shifted-LJ energy — deterministic short trajectory")
    logged_energy=values(system.loggers.energy)
    @assert length(logged_energy)==length(saved_times)
    @assert all(isfinite,logged_energy)
    CairoMakie.lines!(energy_axis,saved_times,logged_energy)
    for (name,figure) in (("snapshot",snapshot_figure),("potential",potential_figure),
            ("force",force_figure),("rdf",rdf_figure),("modes",modes_figure),("energy",energy_figure))
        path=joinpath(output,"m8a_molly_"*name*".png")
        CairoMakie.save(path,figure)
        @assert filesize(path)>1000
        println("PLOT ",path)
    end
    println("MOLLY_VERSION=",pkgversion(Molly))
    println("FRAMES=",length(frames)," PARTICLES=",length(system.coords)," FINAL_TIME=",last(saved_times))
    println("ENERGY_INITIAL=",first(logged_energy)," ENERGY_FINAL=",last(logged_energy))
    println("RDF_COUNTS=",sum(distribution.counts)," RDF_STATUS=",distribution.rdf.status)
    println("DIMER_FREQUENCY=",last(modes.frequencies))
    println("M8A_FLAGSHIP_OK")
end

# ╔═╡ Cell order:
# ╠═0a8a0000-0000-4000-8000-000000000001
# ╠═0a8a0000-0000-4000-8000-000000000002
# ╠═0a8a0000-0000-4000-8000-000000000003
# ╠═0a8a0000-0000-4000-8000-000000000004
# ╠═0a8a0000-0000-4000-8000-000000000005
