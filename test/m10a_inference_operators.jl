module M10AInferenceOperatorsTests
using Test, AnalyticMathLab, LinearAlgebra
const A = AnalyticMathLab
const FD = A.ForwardDiff
include(joinpath(@__DIR__, "..", "examples", "operators", "heat_family.jl"))

# Central differences exercise fresh public solves, not the AD implementation.
function central_jacobian(f, x; h=2e-5)
    hcat([(f(x + h .* Float64.(eachindex(x) .== j)) -
           f(x - h .* Float64.(eachindex(x) .== j))) / (2h) for j in eachindex(x)]...)
end

@testset "M10A deterministic inference: independent references and exclusion" begin
    times = [0., 0.13, 0.41, 0.83, 1.]
    factory = p -> FirstOrderODE((u,t)->[-p[1]*u[1]], 1; labels=("y",))
    obs = ObservationSet(times, reshape(exp.(-1.3 .* times),1,:); variables=(:y,), kind=:synthetic)
    held = ObservationSet([0.2,0.7], reshape(exp.(-1.3 .* [0.2,0.7]),1,:);
        variables=(:y,), kind=:synthetic, role=:heldout)
    spec = InferenceParameters((:rate,), [0.8]; inferred=(:rate,))
    p = ParameterInferenceProblem(factory,spec,obs;u0=[1.],tspan=(0.,1.),heldout=held,
        reference=(kind=:synthetic_truth,values=[1.3]))
    @test inference_predict(p,[1.3]) ≈ obs.values atol=2e-8
    theta = [0.9]
    expected = reshape(-times .* exp.(-theta[1] .* times),:,1)
    sensitivity = local_sensitivity(p,theta).value
    @test sensitivity.jacobian ≈ expected atol=2e-7
    @test sensitivity.jacobian ≈ central_jacobian(x->vec(inference_predict(p,x)),theta) rtol=2e-5 atol=2e-7
    @test sensitivity.rank == 1
    @test sensitivity.condition ≈ 1.
    @test sensitivity.singular_values ≈ [sqrt(sum(abs2,expected))] atol=2e-7
    @test sensitivity.threshold == sensitivity.rank_rtol*maximum(sensitivity.singular_values)
    # Strict > threshold semantics: rank can be intentionally suppressed, not certified.
    suppressed = local_sensitivity(p,theta;rank_rtol=0.,rank_atol=2.).value
    @test suppressed.threshold == 2.
    @test suppressed.rank == 0 && isinf(suppressed.condition)
    boundary = local_sensitivity(p,theta;rank_rtol=1.,rank_atol=0.).value
    @test boundary.threshold == maximum(boundary.singular_values)
    @test boundary.rank == 0 && isinf(boundary.condition)
    before = inference_objective(p,theta)
    gradient = FD.gradient(x->inference_objective(p,x),theta)
    p.reference.values .= 1e9
    p.heldout.values .= -1e8
    @test inference_objective(p,theta) == before
    @test FD.gradient(x->inference_objective(p,x),theta) == gradient
    @test inference_predict(p,theta) ≈ reshape(exp.(-theta[1] .* times),1,:) atol=2e-8
    userobs = ObservationSet(times,obs.values;variables=(:y,),kind=:user_supplied)
    @test_throws ArgumentError ParameterInferenceProblem(factory,spec,userobs;u0=[1.],tspan=(0.,1.),reference=(kind=:synthetic_truth,values=[1.3]))
    @test_throws DimensionMismatch inference_predict(p,[0.9,1.])
    @test_throws ArgumentError inference_predict(p,[NaN])
    overlap = ObservationSet([0.13],ones(1,1);variables=(:y,),role=:heldout)
    @test_throws ArgumentError ParameterInferenceProblem(factory,spec,obs;u0=[1.],tspan=(0.,1.),heldout=overlap)
end

@testset "M10A oscillator: physical ordering, FD/AD, weighted SVD" begin
    # Full (mass, spring), inferred (spring, mass); observed (velocity, position).
    factory = p -> FirstOrderODE((u,t)->(u[2],-p[2]/p[1]*u[1]),2;labels=("q","v"))
    times = [0.,0.17,0.49,0.91,1.3]
    values = vcat(reshape(-2 .* sin.(2 .* times),1,:),reshape(cos.(2 .* times),1,:))
    weights = [1. 2. 3. 4. 5.; 5. 4. 3. 2. 1.]
    obs = ObservationSet(times,values;variables=(:v,:q),weights,kind=:synthetic)
    spec = InferenceParameters((:m,:k),[1.,4.];inferred=(:k,:m),bounds=([1.,0.2],[9.,3.]))
    p = ParameterInferenceProblem(factory,spec,obs;u0=[1.,0.],tspan=(0.,1.3))
    @test spec.indices == [2,1]
    @test p.indices == [2,1]
    @test inference_predict(p,[4.,1.]) ≈ values atol=2e-8
    @test inference_predict(p,[8.,2.]) ≈ values atol=2e-8
    theta = [3.6,1.1]
    s = local_sensitivity(p,theta;rank_rtol=1e-7).value
    fd = central_jacobian(x->vec(inference_predict(p,x)),theta)
    @test s.parameter_order == ("k","m")
    @test s.observation_order == :column_major_variables_within_time
    @test s.jacobian ≈ fd rtol=2e-5 atol=2e-7
    weighted_fd = sqrt.(vec(weights)) .* fd
    @test s.weighted_jacobian ≈ weighted_fd rtol=2e-5 atol=2e-7
    @test s.singular_values ≈ svdvals(weighted_fd) rtol=2e-5 atol=2e-7
    @test s.rank == 1
    @test isinf(s.condition)
    @test s.jacobian[:,2] ≈ -(theta[1]/theta[2]) .* s.jacobian[:,1] atol=2e-7
    @test s.column_cosines[1,2] ≈ -1 atol=1e-10
    residual = inference_predict(p,theta) - values
    @test inference_objective(p,theta) ≈ sum(weights .* residual.^2)
    gradfd = vec(central_jacobian(x->[inference_objective(p,x)],theta))
    @test FD.gradient(x->inference_objective(p,x),theta) ≈ gradfd rtol=2e-5 atol=2e-7
    short = ObservationSet([0.4],reshape([cos(0.8)],1,1);variables=(:q,))
    sp = ParameterInferenceProblem(factory,spec,short;u0=[1.,0.],tspan=(0.,1.3))
    ss = local_sensitivity(sp,[4.,1.]).value
    @test size(ss.jacobian) == (1,2)
    @test ss.rank == 1 && isinf(ss.condition) # thin SVD must not imply full rank
    @test_throws ArgumentError local_sensitivity(p,theta;rank_rtol=-1.)
    @test_throws ArgumentError inference_predict(p,theta,ObservationSet(times,reverse(values;dims=1);variables=(:q,:v)))
end

@testset "M10A LJ independent formula and epsilon-only map" begin
    epsilon, sigma, mass = 1.2, 0.9, 1.7
    energy(r,e,s) = 4e*((s/r)^12-(s/r)^6)
    force(r,e,s) = 24e/r*(2*(s/r)^12-(s/r)^6)
    potential = lennard_jones_analysis(;epsilon,sigma)
    # Explicit audit ranges, not falsely described as an observed trajectory envelope.
    near = collect(range(0.95,1.35;length=7))
    outside = collect(range(1.5,2.5;length=7))
    @test maximum(near) < minimum(outside)
    for r in vcat(near,outside)
        @test evaluate(potential,r) ≈ energy(r,epsilon,sigma) atol=1e-11
        @test potential.numerical.force(r) ≈ force(r,epsilon,sigma) atol=1e-10
        h = 1e-6
        @test -(energy(r+h,epsilon,sigma)-energy(r-h,epsilon,sigma))/(2h) ≈ force(r,epsilon,sigma) rtol=2e-7 atol=1e-8
    end
    @test force(sigma,epsilon,sigma) > 0
    @test force(1.5sigma,epsilon,sigma) < 0
    @test force(2.0^(1/6)*sigma,epsilon,sigma) ≈ 0 atol=1e-12
    factory = p -> FirstOrderODE((u,t)->[u[2],2force(u[1],p[1],p[2])/mass],2;
        labels=("r","dr"),domain=(u,t)->u[1]>0)
    spec = InferenceParameters((:epsilon,:sigma),[0.8,sigma];inferred=(:epsilon,),bounds=([0.1],[3.]))
    # A fixed point at t=0 is deliberately not claimed to identify epsilon.
    obs = ObservationSet([0.],reshape([1.2],1,1);variables=(:r,),kind=:synthetic)
    p = ParameterInferenceProblem(factory,spec,obs;u0=[1.2,0.],tspan=(0.,0.1))
    @test spec.indices == [1] && spec.inferred == ("epsilon",)
    @test p.native_problem.p == [0.8,sigma]
    @test p.native_problem.f([1.2,0.],[epsilon,sigma],0.) ≈ [0.,2force(1.2,epsilon,sigma)/mass]
    @test inference_predict(p,[epsilon]) == reshape([1.2],1,1)
    @test local_sensitivity(p,[epsilon]).value.rank == 0
    @test p.parameters.initial[2] == sigma
    @test_throws DimensionMismatch inference_predict(p,[epsilon,sigma])
    @test_throws ArgumentError InferenceParameters((:epsilon,:sigma),[0.8,sigma];inferred=(:epsilon,),bounds=([1.],[3.]))
    # Bounded Cartesian dimer observations vs the independent radial reduction.
    # Both solves use Tsit5; this checks reduction/order, not solver independence.
    cartesian = FirstOrderODE((u,t)->begin
        f = force(u[2]-u[1],epsilon,sigma)
        [u[3],u[4],-f/mass,f/mass]
    end,4)
    times = [0.,0.03,0.07,0.1]
    path = trajectory(cartesian,[0.,1.2,0.,0.],(0.,0.1);abstol=1e-12,reltol=1e-12)
    @test path.diagnostics.success && path.diagnostics.completed
    states = path.solution.(times)
    view = AtomisticTrajectoryView(length(times),i->AtomisticSnapshot([[states[i][1]],[states[i][2]]]);times)
    distances = distance_observations(view,(1,2);units=:reduced_length)
    measured = ObservationSet(distances;kind=:synthetic)
    inferred = ParameterInferenceProblem(factory,spec,measured;u0=[1.2,0.],tspan=(0.,0.1))
    @test inference_predict(inferred,[epsilon]) ≈ measured.values atol=2e-8
    lo,hi = extrema(measured.values)
    @test lo < hi
    extrapolation = [hi+0.1,hi+0.3]
    @test all(r->r>hi,extrapolation)
    for r in (lo,hi,extrapolation...)
        @test potential.numerical.force(r) ≈ force(r,epsilon,sigma) atol=1e-10
    end
    @test inferred.parameters.inferred == ("epsilon",)
    @test inferred.parameters.initial[2] == sigma
end

@testset "M10A Fourier heat: independent substitution, IC and BC" begin
    for a in ([1.], [0.3,-0.7,0.4]), alpha in (0.05,0.1,0.3), x in (0.13,0.41,0.87), t in (0.,0.17,0.53)
        modes = collect(eachindex(a)) .* pi
        terms = a .* sin.(modes .* x) .* exp.(-alpha .* modes.^2 .* t)
        ut = sum(-alpha .* modes.^2 .* terms)
        uxx = sum(-modes.^2 .* terms)
        f = q -> HeatFamily.heat_solution(a,alpha,q)
        @test f([x,t]) ≈ sum(terms) atol=1e-13
        @test FD.gradient(f,[x,t])[2] ≈ ut atol=2e-11
        @test FD.hessian(f,[x,t])[1,1] ≈ uxx atol=2e-10
        @test ut-alpha*uxx ≈ 0 atol=2e-11
        @test f([x,0.]) ≈ sum(a .* sin.(modes .* x)) atol=1e-13
        @test f([0.,t]) ≈ 0 atol=1e-12
        @test f([1.,t]) ≈ 0 atol=1e-12
    end
    points = PINNPoints([0.13 0.41 0.87;0.17 0.29 0.53];generation=:independent_grid)
    # A nonzero signed residual prevents an always-zero residual implementation passing.
    f = q -> HeatFamily.heat_solution([0.3,-0.7,0.4],0.1,q) + 0.2q[1]^2 + 0.3q[2]
    @test heat_residual(f,points;alpha=0.1).values ≈ fill(0.26,3) atol=1e-11
    # A constant shift solves the same PDE but violates BC/IC: residual != error.
    correct = q -> HeatFamily.heat_solution([1.],0.1,q)
    shifted = q -> correct(q)+2.
    @test maximum(abs,heat_residual(shifted,points;alpha=0.1).values) < 1e-11
    errors = field_errors(shifted.(eachcol(points.coordinates)),correct.(eachcol(points.coordinates)))
    @test errors.summary.rms ≈ 2. atol=1e-12
    @test errors.normalization == :physical_unweighted_samples
    @test_throws ArgumentError HeatFamily.heat_solution([1.],0.,[0.2,0.3])
    @test_throws ArgumentError HeatFamily.heat_solution([NaN],0.1,[0.2,0.3])
end

@testset "M10A M9D categories, sensor representation and adversarial targets" begin
    surrogate, operator = HeatFamily.parametric_dataset(), HeatFamily.operator_dataset()
    @test Set(s.split for s in surrogate.samples) == Set((:training,:interpolation,:parameter_extrapolation,:coordinate_extrapolation))
    @test Set(s.split for s in operator.samples) == Set((:training,:interpolation,:amplitude_extrapolation,:frequency_extrapolation,:coordinate_extrapolation))
    for d in (surrogate,operator)
        poisoned = deepcopy(d)
        for (i,s) in enumerate(poisoned.samples)
            s.split == :training || (s.values .= (isodd(i) ? 1e12 : -1e12))
        end
        for field in (:inputs,:coordinates,:outputs)
            z, zp = fit_scaling(d,field), fit_scaling(poisoned,field)
            @test z.fitted_ids == [s.id for s in d.samples if s.split == :training]
            @test z.offset == zp.offset && z.scale == zp.scale
            @test z.fitted_ids == zp.fitted_ids
        end
        for s in d.samples
            alpha = d.kind == :surrogate ? only(s.input) : d.provenance.alpha
            a = d.kind == :surrogate ? [1.] : s.descriptor
            independent = [sum(a[k]*sinpi(k*q[1])*exp(-alpha*pi^2*k^2*q[2]) for k in eachindex(a)) for q in eachcol(s.coordinates)]
            @test s.values ≈ independent atol=1e-12
        end
    end
    for s in operator.samples
        @test length(s.input) == size(operator.sensors,2) == 9
        @test length(s.descriptor) == 3
        expected = [sum(s.descriptor[k]*sinpi(k*x) for k in eachindex(s.descriptor)) for x in vec(operator.sensors)]
        @test s.input ≈ expected atol=1e-12
        @test classify_query(operator,s.input,s.coordinates).function_family == :unknown
    end
    s = first(operator.samples)
    @test_throws ArgumentError classify_query(operator,reverse(s.input),s.coordinates;sensors=reverse(operator.sensors;dims=2))
    @test_throws DimensionMismatch classify_query(operator,s.descriptor,s.coordinates)
end
end
