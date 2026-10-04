module M10CGuardrailTests
using Test
const helper=joinpath(@__DIR__,"..","examples","scaling","harness.jl")
@testset "M10C budget preflight and report semantics" begin
    @test isfile(helper)
    if isfile(helper)
        include(helper)
        H=ScaleHarness
        b=H.StressBudget(max_memory=1024,max_seconds=10.,threads=Threads.nthreads(),level=0)
        @test H.dense_bytes(10,10)==800
        @test H.dense_bytes(big(10)^20,big(10)^20)==8big(10)^40
        @test_throws ArgumentError H.dense_bytes(-1,2)
        @test_throws ArgumentError H.StressBudget(max_memory=0)
        @test_throws ArgumentError H.StressBudget(max_seconds=NaN)
        @test_throws ArgumentError H.StressBudget(threads=0)
        withenv("AML_EXTREME"=>"0") do
            @test_throws ArgumentError H.StressBudget(level=3)
        end
        called=Ref(false); rows=NamedTuple[]
        H.measure!(rows,b,"unsafe",30000,H.dense_bytes(30000,30000),()->(called[]=true))
        @test !called[]
        @test only(rows).status=="refused_by_guardrail"
        @test only(rows).allocated_bytes==0
        @test only(rows).estimated_bytes>1024
        H.measure!(rows,b,"small",3,24,()->[1.,2.,3.];check=x->abs(sum(x)-6),output_count=length,repeats=2)
        @test last(rows).status=="completed"
        @test last(rows).correctness_metric==0
        @test last(rows).output_count==3
        @test last(rows).allocated_bytes>=0
        @test last(rows).result_bytes>=24
        @test last(rows).warmup_seconds>=0
        mktempdir() do dir
            H.report("smoke",rows,b;directory=dir)
            @test isfile(joinpath(dir,"smoke.csv"))
            @test occursin("refused_by_guardrail",read(joinpath(dir,"smoke.csv"),String))
            @test occursin("rss",read(joinpath(dir,"smoke.toml"),String))
        end
    end
end
end
