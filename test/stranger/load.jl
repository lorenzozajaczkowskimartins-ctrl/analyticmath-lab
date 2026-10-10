using LinearAlgebra
const blas_before=BLAS.get_num_threads()
using AnalyticMathLab
using Test
import Makie
@testset "Stranger headless base load and runtime" begin
    @test BLAS.get_num_threads()==blas_before
    @test ismissing(Makie.current_backend())
    @test all(m->nameof(m) ∉ (:Lux,:Molly,:Optimization,:NeuralPDE,:ModelingToolkit,:NeuralOperators,:CairoMakie,:GLMakie),values(Base.loaded_modules))
    for ext in (:AnalyticMathLabMollyExt,:AnalyticMathLabPINNExt,:AnalyticMathLabDynamicsExt,:AnalyticMathLabInferenceExt,:AnalyticMathLabSurrogateExt)
        @test Base.get_extension(AnalyticMathLab,ext)===nothing
    end
    s=ObservableSeries([1.,2.,3.];times=[0.,1.,2.])
    @test statistical_summary(s).value.mean==2.
    @test_throws DimensionMismatch ObservableSeries([1.,2.,3.];times=[0.,1.])
    @test_throws ArgumentError pinn_network(1,1)
end
println("RUNTIME julia=",VERSION," julia_threads=",Threads.nthreads()," blas_threads=",BLAS.get_num_threads()," blas=",BLAS.get_config())
println("STRANGER_PASS load")
