module AtomisticModesTests
using Test, AnalyticMathLab, LinearAlgebra, Unitful
const AML=AnalyticMathLab
@testset "Atomistic M7 bridge and explicit scales" begin
    s=AtomisticSnapshot([[0.,0.],[1.,0.]];masses=[1.,2.])
    @test hasmethod(normal_modes,Tuple{typeof(s)})
    if hasmethod(normal_modes,Tuple{typeof(s)})
        @test normal_modes(s).evidence.status==:unknown
        K=diagm([1.,2.,6.,8.])
        r=normal_modes(s;hessian=K)
        @test r isa NormalModeAnalysis
        @test r.source === s
        @test r.equilibrium == (0.,0.,1.,0.)
        @test diag(r.mass_matrix)==[1.,1.,2.,2.]
        @test r.eigenvalues ≈ [1.,2.,3.,4.]
        @test r.evidence.method==:mass_weighted_symmetric_eigensolve
        @test r.metadata.coordinate_ordering==:particle_major_cartesian
        @test r.metadata.equilibrium_status==:not_verified
        @test r.metadata.frequency_scale==1
        @test_throws DimensionMismatch normal_modes(s;hessian=ones(3,3))
        @test normal_modes(AtomisticSnapshot(s.positions);hessian=K).evidence.status==:unknown
        su=AtomisticSnapshot([[0.,0.],[1.,0.]].*u"nm";masses=[1.,2.].*u"g/mol")
        ku=K.*u"kJ/mol/nm^2"
        ru=normal_modes(su;hessian=ku)
        @test ru.evidence.status==:heuristic
        @test ru.equilibrium == (0.,0.,1.,0.)
        @test ru.metadata.angular_frequencies ≈ sqrt.([1.,2.,3.,4.]).*u"ps^-1"
        # Mixed compatible input units must be converted, not independently stripped.
        sm=AtomisticSnapshot([[0.,0.].*u"nm",[10.,0.].*u"Å"];masses=[1u"g/mol",0.002u"kg/mol"])
        rm=normal_modes(sm;hessian=ku)
        @test rm.metadata.angular_frequencies ≈ ru.metadata.angular_frequencies
        @test rm.equilibrium==ru.equilibrium
        @test normal_modes(su;hessian=K).evidence.status==:unknown
        @test normal_modes(su;hessian=K.*u"s").evidence.status==:unknown
        @test normal_modes(s;hessian=diagm([-1.,0.,2.,2.])).classifications[1]==:unstable
    end
end
end
