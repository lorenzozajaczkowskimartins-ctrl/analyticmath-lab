# Bounded regression for the final review's orchestration findings.
# Run in examples/scaling environment; no stress workload.
using Test
include("mass_spring_mechanics.jl")
@testset "M10C example low-budget refusal" begin
    rows=mass_spring_mechanics_main(;budget=StressBudget(max_memory=1))
    @test length(rows)==4
    @test all(r->r.status=="refused_by_guardrail",rows)
    @test all(r->r.allocated_bytes==0,rows)
end
include("large_oscillator_ode.jl")
include("ode_ensemble.jl")
LargeOscillatorODE.main()
ODEEnsemble.main()
@testset "M10C checkpoint artifacts" begin
    for file in ("large_oscillator_ode.csv","ode_ensemble.csv")
        path=joinpath(@__DIR__,"../../output/scaling",file)
        @test isfile(path)
        @test occursin("completed",read(path,String))
    end
end
