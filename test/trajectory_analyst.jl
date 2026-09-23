module TrajectoryAnalystTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
@testset "Lazy observables and nonjudgmental diagnostics" begin
    @test isdefined(A,:observable_series)
    if isdefined(A,:observable_series)
        calls=Ref(0)
        t=AtomisticTrajectoryView(10,i->begin
            calls[]+=1
            AtomisticSnapshot([[0.,0.]];velocities=[[i*1.,0.]],masses=[2.],potential_energy=3.)
        end;times=collect(0.:9.),provenance=(ensemble=:NVT,))
        r=A.analyze(t)
        @test r isa A.MDTrajectoryAnalysis
        @test calls[]==0
        @test r.msd.status==:not_requested
        k=A.observable_series(t,:kinetic_energy)
        @test calls[]<=1
        @test collect(k.values)==Float64[i^2 for i in 1:10]
        @test A.observable_series(t,:total_energy).values[2]==7
        @test A.observable_series(t,:total_momentum).values[2]==[4.,0.]
        @test A.observable_series(t,:center_of_mass_velocity;component=1).values[2]==2
        @test A.statistical_summary(A.observable_series(t,:temperature)).status==:unknown
        temp=A.observable_series(t,:temperature;dof=2,boltzmann=1.)
        @test temp.values[2]==4
        @test temp.provenance.temperature_convention==:caller_dof_and_boltzmann
        missing_t=AtomisticTrajectoryView(3,i->AtomisticSnapshot([[0.,0.]]);times=[0.,1.,2.])
        @test A.statistical_summary(A.observable_series(missing_t,:potential_energy)).status==:unknown
        @test_throws ArgumentError A.observable_series(t,:invalid)
        e=A.ObservableSeries([10.,11.,12.,13.];interval=2.,name=:total_energy,provenance=(ensemble=:NVT,))
        d=A.energy_diagnostics(e)
        @test d.value.maximum_absolute==3
        @test d.value.maximum_relative≈0.3
        @test d.value.linear_slope.value≈0.5
        @test d.value.ensemble==:NVT
        @test d.value.conservation_expected==false
        @test A.energy_diagnostics(A.ObservableSeries([0.,1.];interval=1)).value.maximum_relative===nothing
        @test A.energy_diagnostics(A.ObservableSeries([1.,2.])).value.linear_slope.status==:unknown
        p=A.momentum_diagnostics(A.observable_series(t,:total_momentum))
        @test p.value.maximum_absolute==18
        @test p.value.conservation_expected==false
        report=A.analyze(t;observables=(:kinetic_energy,:total_momentum),correlations=(:kinetic_energy,),window=0)
        @test haskey(report.summaries,:kinetic_energy)
        @test haskey(report.deviations,:total_momentum)
        diag=A.diagnose(report)
        @test diag.value.stored_frames==10
        @test diag.status==:heuristic
        @test !hasproperty(diag.value,:score)
        @test diag.value.diffusion.status==:not_requested
        @test A.diagnose(missing_t).value.stored_frames==3
        # Unitful explicit temperature convention, no d*N guess.
        u=AtomisticTrajectoryView(3,i->AtomisticSnapshot([[0.,0.]]u"nm";velocities=[[1.,0.]]u"nm/ps",masses=[1.]u"g/mol");times=[0.,1.,2.]u"ps")
        ut=A.observable_series(u,:temperature;dof=2,boltzmann=0.01u"kJ/mol/K")
        @test uconvert(u"K",ut.values[1])≈50u"K"
    end
end
end
