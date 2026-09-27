module PINNDiagnosticsTests
using Test, Random, AnalyticMathLab
import NeuralPDE, ModelingToolkit, OptimizationOptimisers, ADTypes
import SymbolicIndexingInterface as SII
import Integrals
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@testset "M9B signed residuals on supplied points" begin
    @parameters t
    @variables u(..)
    @named sys=PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],
        [t ∈ (0.,1.)],[t],[u(t)])
    p=pinn_problem(sys;network=pinn_network(1,1;hidden=[]),
        strategy=NeuralPDE.GridTraining(0.25),rng=Xoshiro(6),adtype=ADTypes.AutoZygote())
    r=A.train(p,OptimizationOptimisers.Adam();maxiters=1)
    X=reshape([0.03,0.17,0.29,0.41,0.57,0.69,0.83],1,:)
    ps=A.PINNPoints(X;generation=:explicit_test_points,provenance=(source="test",))
    before=deepcopy(r.parameters)
    block=p.backend_metadata.blocks[1]
    collocation_before=copy(SII.getp(r.optimization_problem,block.xs)(r.backend_solution))
    a=analyze(r;residual_points=Dict(1=>ps,2=>A.PINNPoints(zeros(0,1))),
        condition_roles=Dict(2=>:ic),reference_points=ps,
        reference=x->[exp(-x[1])],reference_provenance=(kind=:analytical,source="exp(-t)",))
    @test a isa A.PINNAnalysis
    @test a.training===r
    @test r.parameters==before
    @test SII.getp(r.optimization_problem,block.xs)(r.backend_solution)==collocation_before
    slope=predict(r,1.)[1]-predict(r,0.)[1]
    @test a.residuals[1].values≈vec(predict(r,X)).+slope atol=1e-5
    @test a.residuals[2].values≈[predict(r,0.)[1]-1]
    @test a.residuals[1].summary.count==7
    @test a.residuals[2].role==:ic
    @test a.residuals[2].backend_kind==:bc
    @test a.residuals[1].sampling.snapshot_overlap_count==0
    @test a.residuals[1].sampling.all_training_overlap==:unknown
    @test a.evidence.status==:unknown
    @test a.reference.value.absolute_error≈abs.(predict(r,X).-exp.(-X))
    @test A.pinn_inspect(a).training===r
    b=analyze(r;residual_points=Dict(1=>ps))
    @test b.reference.status==:unknown
    @test b.reference.value===nothing
    @test b.residuals[2].summary===nothing
    @test A.loss_breakdown(a)===a.loss_diagnostics
    @test a.adaptive_loss_metadata.status==:unknown
    @test residualplot(a) isa A.Makie.Figure
    @test errorplot(a) isa A.Makie.Figure
    @test collocationplot(a) isa A.Makie.Figure
    @test losscomponentsplot(a) isa A.Makie.Figure
    @test pinnplot(a) isa A.Makie.Figure
    @test_throws ArgumentError errorplot(b)
    zero=analyze(r;reference_points=ps,reference=x->[0.])
    @test all(ismissing,zero.reference.value.relative_error)
    @test all(isfinite,zero.reference.value.absolute_error)
    @test zero.reference.value.provenance.kind==:user_supplied_unknown_trust
    @test_throws ArgumentError analyze(r;reference=x->[0.])
    @test_throws ArgumentError analyze(r;relative_guard=-1.)
    @test_throws DimensionMismatch analyze(r;reference_points=ps,reference=x->[0.,1.])
    overlap=analyze(r;residual_points=Dict(1=>A.PINNPoints(a.collocation_metadata.blocks[1].coordinates)))
    @test overlap.residuals[1].sampling.snapshot_overlap_count==a.collocation_metadata.blocks[1].count
    @test overlap.residuals[1].sampling.independence==:not_established
    @test_throws DimensionMismatch analyze(r;residual_points=Dict(1=>A.PINNPoints(zeros(2,3))))
    @test_throws ArgumentError analyze(r;condition_roles=Dict(1=>:ic))
    @test_throws ArgumentError analyze(r;residual_points=Dict(3=>ps))
    @test_throws ArgumentError analyze(r;reference_points=ps,reference=x->[NaN])
    @test_throws ArgumentError pinnplot(b)
    @test_throws ArgumentError residualplot(b;equation=2)
    outside=analyze(r;residual_points=Dict(1=>PINNPoints([-0.1 1.1])))
    @test outside.residuals[1].sampling.outside_domain_count==2
    @test a.loss_diagnostics.configured_weights==[1.,1.]
    @test a.loss_diagnostics.weight_provenance==:construction_configuration
    @test a.loss_diagnostics.weight_evolution==:not_recorded
    @test a.collocation_metadata.blocks[1].training_history==:unavailable
    @test a.collocation_metadata.blocks[1].snapshot==:returned_solution_parameters
    for (strategy,semantics) in ((NeuralPDE.StochasticTraining(5),:uniform_random),
            (NeuralPDE.QuasiRandomTraining(5),:quasi_random_not_iid),
            (NeuralPDE.QuadratureTraining(;quadrature_alg=Integrals.GaussLegendre(n=5)),:quadrature_nodes))
        other=pinn_problem(sys;network=pinn_network(1,1;hidden=[]),strategy,
            rng=Xoshiro(6),adtype=ADTypes.AutoZygote(),optimization_options=(weights=[2.,3.],))
        trained=A.train(other,OptimizationOptimisers.Adam();maxiters=1)
        diagnostic=analyze(trained;residual_points=Dict(1=>ps))
        @test diagnostic.collocation_metadata.strategy.semantics==semantics
        @test diagnostic.loss_diagnostics.configured_weights==[2.,3.]
        @test diagnostic.loss_diagnostics.evaluated_objective≈sum([2.,3.].*diagnostic.loss_diagnostics.components)
        @test diagnostic.residuals[1].summary.count==7
        @test all(isfinite,diagnostic.residuals[1].values)
        @test diagnostic.adaptive_loss_metadata.value===nothing
        if semantics==:quasi_random_not_iid
            @test diagnostic.collocation_metadata.strategy.rng_control==:not_forwarded_to_sampler
        elseif semantics==:quadrature_nodes
            @test diagnostic.collocation_metadata.blocks[1].quadrature_weights!==nothing
            @test diagnostic.residuals[1].summary.normalization==:unweighted_samples
        end
    end
end
end
