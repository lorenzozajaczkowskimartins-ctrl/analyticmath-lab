module AtomisticCoreTests
using Test, AnalyticMathLab
const AML=AnalyticMathLab
@testset "Borrowed atomistic snapshot and lazy frames" begin
    @test isdefined(AML,:AtomisticSnapshot)
    if isdefined(AML,:AtomisticSnapshot)
        positions=[[0.,0.],[2.,0.]]
        s=AML.AtomisticSnapshot(positions;masses=[1.,3.],velocities=[[1.,0.],[-1.,0.]],species=[:A,:B])
        @test s.positions === positions
        @test s.dimension == 2
        @test AML.atomistic_snapshot(s) === s
        calls=Ref(0)
        t=AML.AtomisticTrajectoryView(3,i->(calls[]+=1;s);times=[0.,0.5,1.],provenance=(stride=5,))
        @test length(t)==3
        @test calls[]==0
        @test t[2] === s
        @test calls[]==1
        @test t.times[2]==0.5
        @test_throws BoundsError t[0]
        @test_throws DimensionMismatch AML.AtomisticTrajectoryView(3,i->s;times=[0.])
    end
@testset "Snapshot observations, not simulation certification" begin
    @test isdefined(AML,:mdcheck)
    if isdefined(AML,:mdcheck)
        s=AML.AtomisticSnapshot([[0.,0.],[2.,0.]];masses=[1.,3.],velocities=[[1.,0.],[-1.,0.]])
        r=AML.mdcheck(s;close_distance=3.)
        @test r.observations.total_mass.value==4
        @test r.observations.center_of_mass.value==[1.5,0]
        @test r.observations.total_momentum.value==[-2.,0]
        @test r.observations.center_of_mass_velocity.value==[-0.5,0]
        @test r.observations.kinetic_energy.value==2
        @test r.observations.potential_energy.status==:unknown
        @test r.observations.total_energy.status==:unknown
        @test r.observations.close_pairs.value==[(1,2)]
        @test r.observations.timestep_stability.status==:unknown
        @test AML.mdcheck(AML.AtomisticSnapshot([[NaN,0.]];masses=[1.])).checks.finite_positions==false
        @test AML.mdcheck(AML.AtomisticSnapshot([[0.,0.]];masses=[-1.])).checks.positive_masses==false
        overlap=AML.mdcheck(AML.AtomisticSnapshot([[0.,0.],[0.,0.]];masses=[1.,1.]))
        @test overlap.observations.exact_overlaps.value==[(1,2)]
        @test AML.inspect_particle(s,2).mass==3
        @test AML.inspect_particle(s,2).position === s.positions[2]
        incomplete=AML.AtomisticSnapshot(s.positions;species=[:A])
        @test AML.inspect_particle(incomplete,2).species === nothing
        invalid_distance=AML.AtomisticSnapshot(s.positions;distance=(a,b)->-1.)
        @test AML.pair_distances(invalid_distance).status==:unknown
        @test AML.inspect_particle(invalid_distance,1).local_distances.status==:unknown
        @test_throws BoundsError AML.inspect_particle(s,3)
        d=AML.pair_distances(s)
        @test d.value.distances==[2.]
        p=AML.AtomisticSnapshot([[0.1,0.],[9.9,0.]];boundary=(kind=:orthorhombic,lengths=[10.,10.]))
        @test AML.pair_distances(p).value.minimum ≈ 0.2
        @test AML.pair_distances(p;max_pairs=0).status==:unknown
        @test AML.pair_distances(AML.AtomisticSnapshot(p.positions;boundary=(kind=:unsupported,))).status==:unknown
    end
end
end
end
