module MollyTrajectoryStatisticsTests
using Test, AnalyticMathLab, Molly
const A=AnalyticMathLab
@testset "Molly stored scalar observables and image honesty" begin
    @test hasmethod(A.observable_series,Tuple{typeof(TotalEnergyLogger(Float64,2))})
    if hasmethod(A.observable_series,Tuple{typeof(TotalEnergyLogger(Float64,2))})
        sys=System(atoms=[Atom(index=i,mass=1.,σ=1.,ϵ=1.) for i in 1:2],
            coords=[SVector(1.,1.,1.),SVector(2.2,1.,1.)],velocities=[SVector(0.01,0.,0.),SVector(-0.01,0.,0.)],
            boundary=CubicBoundary(8.),pairwise_inters=(LennardJones(),),force_units=NoUnits,energy_units=NoUnits,
            loggers=(coords=CoordinatesLogger(Float64,2),velocities=VelocitiesLogger(Float64,2),
                energy=TotalEnergyLogger(Float64,2),kinetic=KineticEnergyLogger(Float64,2),
                potential=PotentialEnergyLogger(Float64,2),temperature=TemperatureLogger(Float64,2)))
        simulate!(sys,VelocityVerlet(dt=0.001,remove_CM_motion=false),8;n_threads=1)
        times=collect(0:2:8).*0.001
        t=atomistic_trajectory(sys;fixed_box=true,times)
        e=A.observable_series(sys.loggers.energy;times,provenance=(ensemble=:NVE,))
        @test parent(e.values)===values(sys.loggers.energy)
        @test e.name==:total_energy
        @test e.provenance.stride==2
        @test A.sampling_info(t).interval≈0.002
        @test e.values[end]≈Molly.total_energy(sys;n_threads=1)
        @test A.observable_series(sys.loggers.kinetic;times).values[end]≈Molly.kinetic_energy(sys)
        @test A.observable_series(sys.loggers.potential;times).values[end]≈Molly.potential_energy(sys;n_threads=1)
        temp=A.observable_series(sys.loggers.temperature;times)
        @test temp.values[end]≈Molly.temperature(sys)
        @test temp.provenance.temperature_convention==:Molly_backend_df
        @test A.observable_series(sys.loggers.energy).sampling.times===nothing
        @test A.correlated_mean(A.observable_series(sys.loggers.energy)).status==:unknown
        @test A.mean_squared_displacement(t).values.status==:unknown
        @test A.velocity_autocorrelation(t).raw.status==:heuristic
        @test A.statistical_summary(A.observable_series(t,:potential_energy)).status==:unknown
        @test_throws DimensionMismatch A.observable_series(sys.loggers.energy;times=[0.])
        @test_throws ArgumentError A.observable_series(sys.loggers.coords;times)
        @test A.analyze(t;series=(total_energy=e,temperature=temp)).summaries[:temperature].status==:heuristic
        @test ismissing(A.Makie.current_backend())
    end
end
end
