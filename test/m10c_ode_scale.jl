using Test
using AnalyticMathLab
import SciMLBase
const AMLScaleODE = AnalyticMathLab
if !isdefined(AMLScaleODE, :_scale_ode_problem) && isfile(joinpath(@__DIR__, "../src/dynamical_systems/scaling.jl"))
    Base.include(AMLScaleODE, joinpath(@__DIR__, "../src/dynamical_systems/scaling.jl"))
end
@testset "M10C native in-place boundary" begin
    @test_throws ArgumentError FirstOrderODE((u,t)->-u, 100)
    @test isdefined(AMLScaleODE, :_scale_ode_problem)
    if isdefined(AMLScaleODE, :_scale_ode_problem)
        decay!(du,u,p,t) = (du .= -u; nothing)
        p = AMLScaleODE._scale_ode_problem(decay!, ones(100), (0,1))
        @test SciMLBase.isinplace(p)
        du=zeros(100); p.f(du,p.u0,p.p,0.0)
        @test du == -ones(100)
        @test_throws DomainError AMLScaleODE._scale_ode_problem(decay!, [Inf], (0,1))
        @test_throws DomainError AMLScaleODE._scale_ode_problem(decay!, [big"1e-1000"], (0,1))
        @test_throws DomainError AMLScaleODE._scale_ode_problem(decay!, [1], (0,1); domain=(u,t)->missing)
        @test_throws ArgumentError AMLScaleODE._scale_ode_problem(decay!, [1], (0,0))
        @test_throws DomainError AMLScaleODE._scale_ode_problem((du,u,p,t)->fill!(du,NaN), [1], (0,1))
        @test_throws DomainError AMLScaleODE._scale_ode_problem(decay!, [1+im], (0,1))
    end
end

@testset "M10C native storage and ensembles" begin
    oscillator_file = joinpath(@__DIR__, "../examples/scaling/large_oscillator_ode.jl")
    ensemble_file = joinpath(@__DIR__, "../examples/scaling/ode_ensemble.jl")
    @test isfile(oscillator_file)
    @test isfile(ensemble_file)
    if isfile(oscillator_file) && isfile(ensemble_file)
        include(oscillator_file)
        include(ensemble_file)
        @test LargeOscillatorODE.verify_storage() < 1e-7
        @test ODEEnsemble.verify_ensemble() < 1e-7
        p=LargeOscillatorODE.problem(32)
        du=similar(p.u0)
        p.f(du,p.u0,p.p,0.)
        @test (@allocated p.f(du,p.u0,p.p,0.)) <= 128
        @test_throws DomainError AMLScaleODE._scale_ode_problem((du,u,p,t)->nothing, [1.], (0.,1.))
        @test_throws ArgumentError AMLScaleODE._scale_ode_problem((du,u,p,t)->nothing, Float64[], (0.,1.))
        @test_throws DimensionMismatch p.f(zeros(2),ones(2),p.p,0.)
        @test_throws DomainError p.f(du,fill(NaN,32),p.p,0.)
    end
end
