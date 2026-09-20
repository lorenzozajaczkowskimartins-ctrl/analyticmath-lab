module MollyIntegrationTests
using Test, AnalyticMathLab, Molly, Unitful
const AML = AnalyticMathLab
function fixture(; unitful=false, stride=2)
    if unitful
        c=[SVector(0.5,0.5,0.5)u"nm",SVector(0.86,0.5,0.5)u"nm"]
        return System(atoms=[Atom(index=i,mass=10.0u"g/mol",σ=0.3u"nm",ϵ=0.2u"kJ/mol") for i in 1:2],
            coords=c,velocities=zero(c)*u"ps^-1",boundary=CubicBoundary(2.0u"nm"),
            pairwise_inters=(LennardJones(cutoff=ShiftedPotentialCutoff(0.8u"nm")),),
            loggers=(coords=CoordinatesLogger(stride),velocities=VelocitiesLogger(stride)))
    end
    c=[SVector(1.,1.,1.),SVector(2.2,1.,1.)]
    System(atoms=[Atom(index=i,atom_type=i,mass=1.,σ=1.,ϵ=1.) for i in 1:2],
        coords=c,velocities=zero(c),boundary=CubicBoundary(8.),
        pairwise_inters=(LennardJones(cutoff=ShiftedPotentialCutoff(2.5)),),
        force_units=NoUnits,energy_units=NoUnits,
        loggers=(coords=CoordinatesLogger(Float64,stride),velocities=VelocitiesLogger(Float64,stride)))
end
@testset "Molly optional borrowed adapter" begin
    @test pkgversion(Molly)==v"0.23.3"
    @test Base.get_extension(AML,:AnalyticMathLabMollyExt)!==nothing
    @test ismissing(AML.Makie.current_backend())
    sys=fixture()
    s=atomistic_snapshot(sys)
    @test s.positions === sys.coords
    @test s.velocities === sys.velocities
    @test s.masses === Molly.masses(sys)
    @test collect(s.species)==[1,2]
    @test s.potential_energy===nothing
    @test s.forces===nothing
    @test s.boundary.lengths === sys.boundary.side_lengths
    @test pair_distances(s).value.minimum ≈ 1.2
    owned=atomistic_snapshot(sys;copy_data=true)
    @test owned.positions !== sys.coords
    sys.coords[1]=SVector(1.1,1.,1.)
    @test s.positions[1]==sys.coords[1]
    @test owned.positions[1]!=sys.coords[1]
    sampled=atomistic_snapshot(sys;observables=true,n_threads=1)
    @test sampled.potential_energy ≈ Molly.potential_energy(sys;n_threads=1)
    @test sampled.forces ≈ Molly.forces(sys;n_threads=1)
    @test mdcheck(sampled).observations.total_energy.value ≈ Molly.total_energy(sys;n_threads=1)
    @test_throws ArgumentError atomistic_trajectory(sys)
    vv=VelocityVerlet(dt=0.001,remove_CM_motion=false)
    simulate!(sys,vv,5;n_threads=1)
    times=[0.,0.002,0.004]
    t=atomistic_trajectory(sys;fixed_box=true,times)
    @test length(t)==3
    @test t.times === times
    @test t[2].positions === values(sys.loggers.coords)[2]
    @test t[2].velocities === values(sys.loggers.velocities)[2]
    @test t[2].time==0.002
    @test t[1].potential_energy===nothing
    @test atomistic_trajectory(sys;fixed_box=true,velocity_logger=nothing)[1].velocities===nothing
    @test t[1].forces===nothing
    @test t.provenance.stride==2
    @test atomistic_trajectory(sys;fixed_box=true).times===nothing
    @test_throws DimensionMismatch atomistic_trajectory(sys;fixed_box=true,times=[0.])
    @test_throws ArgumentError atomistic_trajectory(sys;fixed_box=true,times=[0.,0.004,0.002])
    # Continuation restarts Molly's step counter: no invented global timestamps.
    simulate!(sys,vv,2;n_threads=1)
    @test length(atomistic_trajectory(sys;fixed_box=true))==5
    @test atomistic_trajectory(sys;fixed_box=true).times===nothing
    u=fixture(unitful=true)
    us=atomistic_snapshot(u;observables=true,n_threads=1)
    @test us.positions === u.coords
    @test pair_distances(us).value.minimum ≈ 0.36u"nm"
    @test mdcheck(us).observations.total_energy.value ≈ Molly.total_energy(u;n_threads=1)
    uvv=VelocityVerlet(dt=0.001u"ps",remove_CM_motion=false)
    simulate!(u,uvv,4;n_threads=1)
    ut=atomistic_trajectory(u;fixed_box=true,times=(0:2:4).*uvv.dt)
    @test ut[3].time==0.004u"ps"
    @test ut[1].masses === u.masses
    @test normal_modes(atomistic_snapshot(sys)).evidence.status==:unknown
    # Configured cutoffs use Molly's actual public pair API, never AML metadata.
    ai,aj=sys.atoms
    raw=LennardJones()
    shifted=LennardJones(cutoff=ShiftedPotentialCutoff(2.5))
    dr=SVector(1.2,0.,0.)
    ur=Molly.potential_energy(raw,dr,ai,aj,NoUnits)
    us=Molly.potential_energy(shifted,dr,ai,aj,NoUnits)
    uc=Molly.potential_energy(raw,SVector(2.5,0.,0.),ai,aj,NoUnits)
    @test us ≈ ur-uc
    @test Molly.force(raw,dr,ai,aj,NoUnits) ≈ Molly.force(shifted,dr,ai,aj,NoUnits)
    @test Molly.potential_energy(shifted,SVector(3.,0.,0.),ai,aj,NoUnits)==0
    @test Molly.potential_energy(raw,SVector(3.,0.,0.),ai,aj,NoUnits)!=0
    @test atomistic_snapshot(System(sys;boundary=CubicBoundary(Inf))).boundary.kind==:open
    @test atomistic_snapshot(System(sys;boundary=CubicBoundary(8.,Inf,8.))).boundary.kind==:unsupported
    @test_throws ArgumentError atomistic_trajectory(sys;fixed_box=true,coordinate_logger=sys.loggers.velocities)
    @test_throws ArgumentError atomistic_trajectory(sys;fixed_box=true,velocity_logger=VelocitiesLogger(Float64,3))
end
# Exercise the device rejection guard without requiring or pretending to have a GPU.
struct DeviceSentinel end
Molly.is_on_gpu(::DeviceSentinel)=true
@testset "Molly device guard before scalar access" begin
    ext=Base.get_extension(AML,:AnalyticMathLabMollyExt)
    @test_throws ArgumentError ext.require_cpu(DeviceSentinel())
end
end
