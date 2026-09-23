module ArchitectureTests
using Test, AnalyticMathLab, Symbolics
import Makie, LinearAlgebra

# Core + restriction domains must load without univariate studies or plotting.
module CoreFixture
import Symbolics
const root = joinpath(@__DIR__, "..", "src")
const files = ["core/contracts.jl", "core/expressions.jl", "core/exact_algebra.jl",
               "multivariate_domain.jl"]
const available = all(file -> isfile(joinpath(root,file)), files)
if available
    for file in files
        include(joinpath(root,file))
    end
end
end

@testset "Shared infrastructure independent loading" begin
    @test CoreFixture.available
    if CoreFixture.available
        @test !isdefined(CoreFixture, :RealFunctionStudy)
        @test !isdefined(CoreFixture, :ScalarFieldAnalysis)
        @test !isdefined(CoreFixture, :Makie)
        p = CoreFixture.PropertyResult([], :unknown, :unsupported, ["No conclusion"])
        @test (p.status,p.method) == (:unknown,:unsupported)
        @test fieldnames(typeof(p)) == (:value,:status,:method,:notes)
        @test CoreFixture._residual_controls(1e-8,0.1,2).threshold == 1e-8 + 0.1*2
        @variables cx cy
        d = CoreFixture._mv_domain(:((cx^2+cy^2)/(cx^2+cy^2)),(cx,cy))
        @test CoreFixture.domain_contains(d,(0,0)) === false
        @test CoreFixture.domain_contains(d,(1,0)) === true
        @test CoreFixture._ra_op(Symbolics.toexpr(cx^2)) == CoreFixture._mv_op(:(cx^2))
    end
end

@testset "Architecture documentation and include ownership" begin
    root = joinpath(@__DIR__, "..")
    docpath = joinpath(root, "docs", "architecture.md")
    @test isfile(docpath)
    if isfile(docpath)
        document = read(docpath, String)
        paths = [m.captures[1] for m in eachmatch(r"`(src/[^`]+\.jl)`", document)]
        @test !isempty(paths)
        @test all(path -> isfile(joinpath(root, path)), paths)
        entry = read(joinpath(root, "src", "AnalyticMathLab.jl"), String)
        includes = [m.captures[1] for m in eachmatch(r"include\(\"([^\"]+)\"\)", entry)]
        @test length(includes) == length(unique(includes))
        @test Set(paths) == Set(vcat(["src/AnalyticMathLab.jl"], "src/" .* includes))
        for (directory, _, files) in walkdir(joinpath(root, "src")), file in files
            endswith(file, ".jl") || continue
            file == "AnalyticMathLab.jl" && continue
            @test !occursin(r"\binclude\s*\(", read(joinpath(directory, file), String))
        end
        @test occursin("(docs/architecture.md)", read(joinpath(root, "README.md"), String))
    end
end

@testset "Public dispatch and evidence contracts" begin
    expected = Symbol.(["@real_function", "AbstractAnalysis", "AnalyticMathLab",
        "CriticalPoint", "CriticalPointAnalysis", "DerivativeComparison",
        "DerivativeConvergenceAnalysis", "FunctionAnalysis", "MultivariateDomain",
        "PeriodicIntervalSet", "PeriodicPointSet", "PropertyResult", "RealDomain",
        "RealExpression", "RealFunctionStudy", "RealInterval", "ScalarFieldAnalysis",
        "StationaryPoint", "analyze", "compare_derivatives", "contour",
        "derivative_convergence", "directional_derivative", "domain_contains",
        "evaluate", "gradient", "gradientplot", "hessian", "levelset",
        "linearization", "plot", "surface", "VectorFieldAnalysis", "jacobian",
        "divergence", "curl", "potential", "vectorplot",
        "AutonomousSystem", "DynamicalSystemAnalysis", "equilibria", "stability", "nullclines",
        "FirstOrderODE", "TrajectoryResult", "trajectory", "phaseplot", "timeplot",
        "LagrangianSystem", "LagrangianAnalysis", "HamiltonianSystem", "HamiltonianAnalysis",
        "euler_lagrange", "generalized_momenta", "velocity_hessian", "energy_function",
        "cyclic_coordinates", "legendre_transform", "hamilton_equations", "poisson_bracket",
        "observable_derivative", "force_from_potential", "MechanicsDynamics", "dynamics",
        "energy_drift", "energyplot", "MechanicalLinearization", "linearize_mechanics",
        "NormalModeAnalysis", "normal_modes", "cartesian_mass_matrix", "modeplot",
        "AtomisticSnapshot", "AtomisticTrajectoryView", "atomistic_snapshot", "atomistic_trajectory",
        "pair_distances", "AtomisticSystemAnalysis", "mdcheck", "inspect_particle",
        "PotentialAnalysis", "analyze_potential", "lennard_jones_analysis", "potentialplot", "forceplot",
        "RadialDistributionAnalysis", "radial_distribution", "coordination", "mdplot",
        "SamplingInfo", "sampling_info", "ObservableSeries", "observable_series", "statistical_summary", "running_statistics",
        "AutocorrelationAnalysis", "autocorrelation", "integrated_autocorrelation_time", "correlated_mean",
        "BlockAnalysis", "block_average", "transient_analysis", "MeanSquaredDisplacement", "mean_squared_displacement",
        "diffusion_estimate", "VelocityAutocorrelation", "velocity_autocorrelation", "energy_diagnostics", "momentum_diagnostics",
        "MDTrajectoryAnalysis", "diagnose", "timeseriesplot", "autocorrelationplot", "blockplot", "msdplot", "vacfplot"])
    @test Set(names(AnalyticMathLab)) == Set(expected)
    @test (AnalyticMathLab.plot,AnalyticMathLab.surface,AnalyticMathLab.contour) ===
          (Makie.plot,Makie.surface,Makie.contour)
    @test all(m -> nameof(m) != :CairoMakie && nameof(m) != :GLMakie, values(Base.loaded_modules))
    ambiguities = Test.detect_ambiguities(AnalyticMathLab, Symbolics, Makie, LinearAlgebra; recursive=false)
    @test isempty(filter(pair -> any(m -> m.module === AnalyticMathLab, pair), ambiguities))
    @variables x y
    u = analyze(@real_function(x^3/x),x)
    s = analyze(@real_function((x^2+y^2)^2/(x^2+y^2)),(x,y))
    @test u isa FunctionAnalysis && s isa ScalarFieldAnalysis
    @test u isa AbstractAnalysis && s isa AbstractAnalysis
    @test domain_contains(u.real_analysis.domain,0) === false
    @test domain_contains(s.domain,(0,0)) === false
    # Milestone 5 adds a separate vector method, not a widened scalar method.
    @test analyze([x,y],(x,y)) isa VectorFieldAnalysis
    controls = (residual_tolerance=1e-7,residual_rtol=0.01,residual_scale=2)
    univariate = analyze(x^2,x;interval=(-1,1),controls...)
    scalar = analyze(x^2+y^2,(x,y);controls...)
    @test univariate.critical_points.effective_residual_tolerance ==
          only(scalar.stationary_points.value).residual_threshold
    @test (@inferred evaluate(univariate,0.5)) == 0.25
    @test (@inferred gradient(scalar,(0.5,0.5))) == [1.0,1.0]
    @test (@inferred hessian(scalar,(0.5,0.5))) == [2 0;0 2]
end
end
