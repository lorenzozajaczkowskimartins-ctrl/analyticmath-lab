# Optional bounded gate in examples/pinn: affine ODE PINN, one optimizer step.
module M10DSemanticsPINNTests
using Test, Random, AnalyticMathLab
import NeuralPDE, ModelingToolkit, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@testset "M10D3 PINN diagnostics scoped evidence and reference" begin
    @parameters t
    @variables u(..)
    @named sys=PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],
        [t ∈ (0.,1.)],[t],[u(t)])
    p=pinn_problem(sys;network=pinn_network(1,1;hidden=[]),strategy=NeuralPDE.GridTraining(0.5),
        rng=Xoshiro(14),adtype=ADTypes.AutoZygote())
    r=A.train(p,OptimizationOptimisers.Adam();maxiters=1)
    points=PINNPoints(reshape([0.17,0.41],1,:);provenance=(coordinate_names=(:t,),),generation=:explicit)
    a=analyze(r;residual_points=Dict(1=>points),reference_points=points,
        reference=x->[exp(-x[1])],reference_provenance=(kind=:analytical,source="exp(-t)"),relative_guard=3e-11)
    pm=A.scientific_metadata(p); rm=A.scientific_metadata(r); am=A.scientific_metadata(a)
    @test only(pm.claims).scope == :backend_construction
    @test only(pm.claims).status == :established
    @test rm.claims[1].scope == :physical_validation
    @test rm.claims[1].status == :unknown
    @test only(am.claims).status == :unknown
    @test am.reference.value.kind == :analytical
    @test am.reference.value.trust == :caller_declared_not_certified
    @test am.units.availability == :unknown
    @test am.domain.value === p.domains
    @test am.coordinates.value.independent === p.independent_variables
    @test am.method == :sampled_residual_diagnostics
    @test :NeuralPDE in am.backend.value.packages
    @test :sampled_residuals_only in am.approximation
    @test am.tolerances.value.relative_guard == 3e-11
    @test rm.options.value.maxiters == 1
    @test rm.tolerances.availability == :unknown
    @test am.options.value.derivative === p.provenance.derivative
    @test only(A.scientific_origin(a).parents).token == objectid(r)
    @test only(only(A.scientific_origin(a).parents).parents).token == objectid(p)
    @test Base.summarysize(A.scientific_origin(a)) < 4096
    no_reference=analyze(r)
    @test A.scientific_metadata(no_reference).reference.availability == :unknown
    wrong=PINNPoints(points.coordinates;provenance=(coordinate_names=(:x,),),generation=:declared)
    @test_throws ArgumentError analyze(r;residual_points=Dict(1=>wrong))
    @test_throws ArgumentError analyze(r;reference_points=wrong,reference=x->[exp(-x[1])])
end
end
