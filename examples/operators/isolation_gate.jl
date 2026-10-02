# Lightweight optional registration gate; no training and no plotting backend.
using Test, AnalyticMathLab
import Optimization, Lux
const A = AnalyticMathLab
@testset "M9D optional activation requires operator backend" begin
    @test Base.get_extension(A,:AnalyticMathLabSurrogateExt) === nothing
    @test Base.get_extension(A,:AnalyticMathLabDynamicsExt) !== nothing
    @test Base.get_extension(A,:AnalyticMathLabPINNExt) === nothing
end
import NeuralOperators
@testset "M9D complete public registration and extension isolation" begin
    ext = Base.get_extension(A,:AnalyticMathLabSurrogateExt)
    @test ext !== nothing
    @test all(s -> isdefined(A,s), names(A))
    @test A.GeneralizationAnalysis <: A.AbstractAnalysis
    @test ismissing(A.Makie.current_backend())
    @test Base.get_extension(A,:AnalyticMathLabPINNExt) === nothing
    @test Base.get_extension(A,:AnalyticMathLabMollyExt) === nothing
    @test all(m -> nameof(m) ∉ (:NeuralPDE,:ModelingToolkit,:Molly,:CairoMakie,:GLMakie,:CUDA,:AMDGPU,:Metal,:Reactant), values(Base.loaded_modules))
    pairs = Test.detect_ambiguities(A,ext,Lux,NeuralOperators,Optimization;recursive=false)
    @test isempty(filter(p -> any(m -> m.module in (A,ext),p),pairs))
end
