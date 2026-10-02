module HeatReferenceTests
using Test, AnalyticMathLab
const file=joinpath(@__DIR__,"..","examples","operators","heat_family.jl")
@testset "M9D analytical heat consistency before optimization" begin
    @test isfile(file)
    if isfile(file)
        include(file)
        H=HeatFamily
        @test H.verify_reference()
        p=H.parametric_dataset()
        o=H.operator_dataset()
        @test p.reference.kind==:analytical
        @test o.reference.kind==:analytical
        @test p.domain.inputs==[0.05 0.2]
        @test Set(s.split for s in o.samples)==Set((:training,:interpolation,:amplitude_extrapolation,:frequency_extrapolation,:coordinate_extrapolation))
        @test o.sensors==reshape(collect(range(0.,1.;length=9)),1,:)
        @test o.rng.seed==902
        @test all(a.input==b.input && a.values==b.values for (a,b) in zip(o.samples,H.operator_dataset().samples))
        @test length(unique(Tuple(s.input) for s in o.samples if s.split!=:coordinate_extrapolation))==length(filter(s->s.split!=:coordinate_extrapolation,o.samples))
        @test_throws ArgumentError H.heat_solution([1.],-0.1,[0.2,0.3])
    end
end
end
