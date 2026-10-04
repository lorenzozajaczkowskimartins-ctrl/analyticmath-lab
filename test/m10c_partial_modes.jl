using Test, LinearAlgebra
using AnalyticMathLab

struct M10CUnreadableMatrix <: AbstractMatrix{Float64}
    n::Int
end
Base.size(A::M10CUnreadableMatrix)=(A.n,A.n)
Base.getindex(::M10CUnreadableMatrix,::Int,::Int)=error("coefficient access before preflight")

@testset "M10C dense preflight before coefficient access" begin
    # Large structured inputs are cheap; refusal must precede n² conversion.
    K = Diagonal(ones(3000))
    @test_throws ArgumentError normal_modes(K,K; max_memory_bytes=1024)
    huge=M10CUnreadableMatrix(typemax(Int))
    @test_throws ArgumentError normal_modes(huge,huge)
    @test normal_modes(Diagonal([2.,3.]),Diagonal(ones(2))).eigenvalues≈[2.,3.]
    @test_throws ArgumentError normal_modes(Diagonal(ones(2)),Diagonal(ones(2)); max_memory_bytes=-1)
end

# Optional maintained backend gate: run with --project=examples/scaling and
# AML_PARTIAL_TEST=1. The root smoke test has no transitive dependency import.
if get(ENV,"AML_PARTIAL_TEST","0") == "1"
    path = joinpath(@__DIR__,"../examples/scaling/partial_modes.jl")
    isfile(path) && include(path)
    @testset "M10C controlled partial route exists" begin
        @test isdefined(@__MODULE__, :ControlledModes)
    end
    using .ControlledModes
    @testset "M10C controlled chain generalized residual and semantics" begin
        for mass in (ones(24),collect(range(1.,2.;length=24))), offset in (0., -0.1, -4sin(pi/50)^2)
            K=SymTridiagonal(fill(2.0+offset,24),fill(-1.,23)); M=Diagonal(mass)
            r=ControlledModes.partial_chain(24; k=4, masses=mass, offset=offset)
            full=normal_modes(K,M)
            @test r.eigenvalues ≈ full.eigenvalues[1:4] atol=1e-9
            @test norm(K*r.mode_vectors-M*r.mode_vectors*Diagonal(r.eigenvalues)) < 1e-8
            @test r.mode_vectors'*M*r.mode_vectors ≈ Matrix{Float64}(I,4,4) atol=1e-8
            @test r.classifications == full.classifications[1:4]
            @test all(isequal.(ismissing.(r.frequencies), ismissing.(full.frequencies[1:4])))
            action=ControlledModes.ChainAction(24,offset)
            x=collect(range(-1.,1.;length=24)); y=similar(x); mul!(y,action,x)
            @test y ≈ K*x
            @test r.metadata.converged
            @test r.metadata.spectrum == :partial
        end
        @test_throws ArgumentError ControlledModes.partial_chain(100000;k=4,max_memory_bytes=1024)
        @test_throws ArgumentError ControlledModes.partial_chain(24;masses=zeros(24))
        @test_throws ArgumentError ControlledModes.partial_chain(24;k=24)
    end
end
