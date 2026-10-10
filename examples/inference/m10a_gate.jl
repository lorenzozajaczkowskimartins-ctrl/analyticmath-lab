# Optional algebraic M10A audit: native Lux parameters, no optimizer or showcase runs.
module M10AInferenceGate
using Test, AnalyticMathLab, Lux, Optimization, Random
using Symbolics
const A = AnalyticMathLab
Symbolics.@variables q1 q2 p1 p2

@testset "M10A independent canonical J signs and energy gauge" begin
    mechanics = analyze(HamiltonianSystem((q1^2+2q2^2+3p1^2+4p2^2)/2;
        coordinates=(q1,q2),momenta=(p1,p2)))
    # Cross term detects more than the separable harmonic example does.
    net = Lux.Chain(Lux.WrappedFunction(x->vcat(x.^2,x[1]*x[4])),Lux.Dense(5=>1))
    state = Lux.testmode(last(Lux.setup(Xoshiro(1010),net)))
    parameters(c) = (layer_1=NamedTuple(),layer_2=(weight=reshape([0.5,1.,1.5,2.,0.25],1,5),bias=[c]))
    m = A.HamiltonianNN(mechanics,net,parameters(3.),state)
    shifted = A.HamiltonianNN(mechanics,net,parameters(-11.),state)
    xs = [1. -0.7 0.2;2. 0.3 -1.;3. 1.1 0.4;4. -0.9 2.]
    # Hard-coded canonical derivative oracle; never uses mechanics.symplectic_matrix.
    oracle(x) = [3x[3],4x[4]+0.25x[1],-x[1]-0.25x[4],-2x[2]]
    energy(x) = (x[1]^2+2x[2]^2+3x[3]^2+4x[4]^2)/2 + 0.25x[1]*x[4]
    saved = deepcopy(state)
    for x in eachcol(xs)
        @test A.learned_energy(m,x) ≈ energy(x)+3.
        @test A.learned_energy(shifted,x)-A.learned_energy(m,x) ≈ -14.
        @test A.learned_vector_field(m,x) ≈ oracle(x) atol=1e-12
        @test A.learned_vector_field(shifted,x) ≈ oracle(x) atol=1e-12
        @test A.aligned_energy(m,x;reference=zeros(4)) ≈ energy(x)
        @test A.aligned_energy(shifted,x;reference=zeros(4)) ≈ energy(x)
    end
    data = A.DerivativeData(xs,hcat(oracle.(eachcol(xs))...))
    @test A.dynamics_objective(m,data) < 1e-24
    @test A.dynamics_objective(shifted,data) < 1e-24
    @test isequal(m.state,saved)
    @test_throws DimensionMismatch A.learned_energy(m,[1.,2.])
    vector_energy = A.HamiltonianNN(mechanics,Lux.WrappedFunction(identity),NamedTuple(),NamedTuple())
    @test_throws DimensionMismatch A.learned_energy(vector_energy,ones(4))
end

@testset "M10A UDE known plus hidden, before training" begin
    net = Lux.Chain(Lux.WrappedFunction(x->[x[1]^3]),Lux.Dense(1=>1;use_bias=false))
    state = Lux.testmode(last(Lux.setup(Xoshiro(1011),net)))
    parameters(c) = (layer_1=NamedTuple(),layer_2=(weight=reshape([c],1,1),))
    known = FirstOrderODE((u,t)->(u[2],-u[1]),2;labels=("q","v"))
    make(c) = A.UDEProblem(known,net,parameters(c),state;correction_indices=(2,))
    correct, wrong = make(-0.2), make(-0.05)
    xs = [-1. 0. 0.7 2.;0.2 1. -0.4 3.]
    for x in eachcol(xs)
        hidden = [0.,-0.2x[1]^3]
        @test A.learned_correction(correct,x) ≈ hidden
        @test A.learned_vector_field(correct,x) ≈ [x[2],-x[1]-0.2x[1]^3]
        @test A.learned_vector_field(correct,x)-collect(known.function_value(x,0.)) ≈ hidden
    end
    @test correct.known === known
    @test correct.correction_indices == (2,)
    # On the equilibrium trajectory even an incorrect cubic coefficient fits exactly.
    # Report trajectory MSE and off-trajectory hidden-term RMS separately.
    stationary = A.TrajectoryData([0.,0.2,0.5],zeros(2,3))
    trajectory_mse = A.dynamics_objective(wrong,stationary)
    hidden_rms = sqrt(sum((A.learned_correction(wrong,x)[2]+0.2x[1]^3)^2 for x in eachcol(xs))/size(xs,2))
    @test trajectory_mse < 1e-24
    @test hidden_rms > 0.1
    @test A.dynamics_objective(correct,stationary) < 1e-24
    @test all(abs(A.learned_correction(correct,x)[2]+0.2x[1]^3)<1e-14 for x in eachcol(xs))
    # Independent nonstationary M6 numerical reference; no training involved.
    reference = trajectory(FirstOrderODE((u,t)->[u[2],-u[1]-0.2u[1]^3],2),[1.,0.],(0.,0.5);abstol=1e-12,reltol=1e-12)
    @test reference.diagnostics.success
    times = collect(range(0.,0.5;length=7))
    data = A.TrajectoryData(times,hcat(reference.solution.(times)...))
    @test A.dynamics_objective(correct,data;abstol=1e-11,reltol=1e-10) < 1e-16
    @test A.dynamics_objective(wrong,data) > 1e-6
    @test_throws ArgumentError A.UDEProblem(known,net,parameters(-0.2),state;correction_indices=(2,2))
    @test_throws ArgumentError A.UDEProblem(known,net,parameters(-0.2),state;correction_indices=(3,))
    @test_throws DimensionMismatch A.learned_correction(correct,[1.])
    bad = A.UDEProblem(known,Lux.WrappedFunction(identity),NamedTuple(),NamedTuple();correction_indices=(2,))
    @test_throws DimensionMismatch A.learned_correction(bad,[1.,0.])
end
end
