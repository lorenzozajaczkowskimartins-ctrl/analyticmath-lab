# Manual bounded loader audit, not training and not part of the base canonical.
# julia --project=examples/<environment> test/m10d_extensions.jl <environment>
using Test
import TOML
const environment = only(ARGS)
@testset "M10D extension metadata: $environment" begin
    project = TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
    manifest = TOML.parsefile(joinpath(dirname(Base.active_project()), "Manifest.toml"))
    package = only(manifest["deps"]["AnalyticMathLab"])
    # A path dependency can load current source with stale extension registration.
    # Run Pkg.resolve() in this environment, then restart Julia before this audit.
    @test package["extensions"] == project["extensions"]
    @test package["weakdeps"] == project["weakdeps"]
end
if environment == "molly"
    using Molly
    using AnalyticMathLab
elseif environment == "pinn"
    using Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface
    using AnalyticMathLab
elseif environment == "inference"
    using AnalyticMathLab
    using Optimization, Lux
elseif environment == "operators"
    using AnalyticMathLab
    using Lux, Optimization, NeuralOperators
else
    error("supported environments: molly, pinn, inference, operators")
end
const A = AnalyticMathLab
const expected = environment == "molly" ? (:AnalyticMathLabMollyExt,) :
    # NeuralPDE in the pinned PINN environment also loads NeuralOperators.
    environment == "pinn" ? (:AnalyticMathLabInferenceExt, :AnalyticMathLabDynamicsExt,
        :AnalyticMathLabPINNExt, :AnalyticMathLabSurrogateExt) :
    environment == "operators" ? (:AnalyticMathLabInferenceExt, :AnalyticMathLabDynamicsExt, :AnalyticMathLabSurrogateExt) :
    (:AnalyticMathLabInferenceExt, :AnalyticMathLabDynamicsExt)
@testset "M10D extension loading: $environment" begin
    extensions = Module[]
    for name in (:AnalyticMathLabMollyExt, :AnalyticMathLabInferenceExt,
                 :AnalyticMathLabDynamicsExt, :AnalyticMathLabPINNExt, :AnalyticMathLabSurrogateExt)
        ext = Base.get_extension(A, name)
        @test (ext !== nothing) == (name in expected)
        ext === nothing || push!(extensions, ext)
    end
    @test length(methods(A.analyze)) == 11
    @test all(method.module === A for method in methods(A.analyze))
    scope = Module[A, extensions...]
    pairs = Test.detect_ambiguities(scope...; recursive=false)
    owned(m) = m.module in scope
    @test isempty(filter(pair -> any(owned, pair), pairs))
    @test :_scale_ode_problem ∉ names(A)
    if environment == "molly"
        @test hasmethod(A.atomistic_snapshot, Tuple{Molly.System})
        @test hasmethod(A.atomistic_trajectory, Tuple{Molly.System})
    elseif environment == "pinn"
        @test isdefined(Base.get_extension(A, :AnalyticMathLabPINNExt), :analyze_pinn)
        @test isdefined(Base.get_extension(A, :AnalyticMathLabPINNExt), :pinn_problem)
    elseif environment == "operators"
        @test isdefined(Base.get_extension(A, :AnalyticMathLabSurrogateExt), :learning_model)
        @test isdefined(Base.get_extension(A, :AnalyticMathLabSurrogateExt), :predict)
    else
        @test hasmethod(A.learned_energy, Tuple{A.HamiltonianNN, Vector{Float64}})
        @test isdefined(Base.get_extension(A, :AnalyticMathLabInferenceExt), :infer_parameters)
    end
end
