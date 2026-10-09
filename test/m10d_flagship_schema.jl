module M10DFlagshipSchemaTests
using Test, AnalyticMathLab
include("../examples/integration/one_system_many_methods.jl")
const W=OneSystemManyMethods
@testset "M10D4 detached dataset retains fixed physical definition" begin
    s=W.canonical_system()
    schema=W.simulation_schema(s)
    @test schema.family isa NamedTuple
    if schema.family isa NamedTuple
        @test schema.family.parameters == s.parameters
        @test schema.family.coordinates == s.coordinates
        @test schema.family.state_order == s.state_order
        @test schema.family.antisymmetric_amplitude == s.amplitudes[2]
        @test schema.family.initial_modal_velocities == s.initial_modal_velocities
        @test schema.family.units == s.units
    end
end
end
