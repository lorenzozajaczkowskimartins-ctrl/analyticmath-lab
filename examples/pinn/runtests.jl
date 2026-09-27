# Separated optional ML integration gate. Never included by base Pkg.test().
using Test, AnalyticMathLab
import Lux, NeuralPDE, ModelingToolkit, Optimization, OptimizationOptimisers, ADTypes
import SymbolicIndexingInterface
const root=joinpath(@__DIR__,"..","..")
@testset verbose=true "M9A optional integration" begin
    include(joinpath(root,"test","pinn_construction.jl"))
    include(joinpath(root,"test","pinn_training.jl"))
    include(joinpath(root,"test","pinn_pde.jl"))
    include(joinpath(root,"test","pinn_edges.jl"))
    @testset "Extension activation and package-owned ambiguities" begin
        ext=Base.get_extension(AnalyticMathLab,:AnalyticMathLabPINNExt)
        @test ext!==nothing
        @test ismissing(AnalyticMathLab.Makie.current_backend())
        @test Base.get_extension(AnalyticMathLab,:AnalyticMathLabMollyExt)===nothing
        @test all(m->!(nameof(m) in (:CUDA,:AMDGPU,:Metal,:Reactant,:Molly,:CairoMakie,:GLMakie)),values(Base.loaded_modules))
        ambiguities=Test.detect_ambiguities(AnalyticMathLab,ext,Lux,NeuralPDE,
            ModelingToolkit,Optimization,SymbolicIndexingInterface;recursive=false)
        @test isempty(filter(pair->any(m->m.module in (AnalyticMathLab,ext),pair),ambiguities))
    end
end
