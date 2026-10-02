# Optional M10A contract audit with deterministic native Lux layers; no training.
module M10AOperatorGate
using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, Random
const A = AnalyticMathLab
include("heat_family.jl")

# Two unequal latent components make sensor/coordinate permutations observable.
branch(b) = vcat(sum(reshape(collect(1.:9.),:,1).*b;dims=1),b[3:3,:]-2b[7:7,:])
trunk(q) = vcat(q[1:1,:]+2q[2:2,:],3q[1:1,:]-q[2:2,:])
operator() = DeepONet(Lux.WrappedFunction(branch),Lux.WrappedFunction(trunk))
oracle(b,q) = sum(i*b[i] for i in 1:9)*(q[1]+2q[2])+(b[3]-2b[7])*(3q[1]-q[2])

struct ChangingState <: Lux.AbstractLuxLayer end
Lux.initialparameters(::AbstractRNG,::ChangingState) = NamedTuple()
Lux.initialstates(::AbstractRNG,::ChangingState) = (calls=0,)
(::ChangingState)(x,ps,st) = (sum(x;dims=1),(calls=st.calls+1,))

@testset "M10A DeepONet fixed sensor, trunk, batch and state contracts" begin
    d = HeatFamily.operator_dataset()
    m = learning_model(d,operator();rng=Xoshiro(1012),normalization=:none,rng_provenance=(seed=1012,))
    @test m.architecture == :deeponet
    @test m.schema.coordinate_names == (:x,:t)
    @test m.schema.sensors == d.sensors
    @test m.provenance.output_order == :query_columns
    @test m.provenance.discretization_invariance == :not_established
    s = d.samples[2]
    q = [0.13 0.67 0.31;0.21 0.09 0.43]
    expected = [oracle(s.input,col) for col in eachcol(q)]
    saved = deepcopy(m.state)
    @test A.predict(m,s.input,q;sensors=d.sensors) ≈ expected atol=1e-12
    @test A.predict(m,s.input,q[:,[3,1,2]]) ≈ expected[[3,1,2]] atol=1e-12
    @test A.predict(m,s.input,q[:,2:2]) ≈ expected[2:2] atol=1e-12
    @test !isapprox(A.predict(m,s.input,q[[2,1],:]),expected;atol=1e-12)
    @test isequal(m.state,saved)
    @test_throws DimensionMismatch A.predict(m,s.descriptor,q)
    @test_throws ArgumentError A.predict(m,reverse(s.input),q;sensors=reverse(d.sensors;dims=2))
    @test_throws ArgumentError A.predict(m,s.input,q;sensors=d.sensors.+0.01)
    # A bare vector carries no sensor metadata: caller must supply truthful ordering.
    @test !isapprox(A.predict(m,reverse(s.input),q),expected;atol=1e-12)
    batch = training_data(m,d)
    ss = filter(s->s.split==:training,d.samples)
    @test batch.ids == [s.id for s in ss]
    @test batch.inputs[1] == hcat((s.input for s in ss)...)
    @test batch.inputs[2] == first(ss).coordinates
    explicit = [oracle(s.input,col) for col in eachcol(first(ss).coordinates),s in ss]
    native,state = Lux.apply(m.network,batch.inputs,m.parameters,m.state)
    @test size(native) == (size(first(ss).coordinates,2),length(ss))
    @test native ≈ explicit atol=1e-11
    @test isequal(state,saved)
    @test learning_objective(m,m.parameters,batch) ≈ sum(abs2,explicit-batch.targets)/length(batch.targets) rtol=1e-12
    changed_grid = deepcopy(d)
    changed_grid.samples[2].coordinates[1,2] += 0.001
    @test_throws ArgumentError training_data(m,changed_grid)
end

@testset "M10A adversarial held-out targets never enter training" begin
    for d in (HeatFamily.parametric_dataset(),HeatFamily.operator_dataset())
        network = d.kind == :operator ? operator() : Lux.WrappedFunction(x->sum(x;dims=1))
        poisoned = deepcopy(d)
        for (i,s) in enumerate(poisoned.samples)
            s.split == :training || (s.values .= (isodd(i) ? 1e12 : -1e12))
        end
        model(data) = learning_model(data,network;rng=Xoshiro(1013),normalization=:train_minmax,rng_provenance=(seed=1013,))
        m,mp = model(d),model(poisoned)
        for field in (:inputs,:coordinates,:outputs)
            a,b = getproperty(m.normalization,field),getproperty(mp.normalization,field)
            @test a.offset == b.offset && a.scale == b.scale && a.fitted_ids == b.fitted_ids
        end
        b,bp = training_data(m,d),training_data(mp,poisoned)
        @test b.ids == bp.ids
        @test b.inputs == bp.inputs
        @test b.targets == bp.targets
        before = learning_objective(m,m.parameters,b)
        @test learning_objective(mp,mp.parameters,bp) == before
        @test learning_objective(m,m.parameters,training_data(m,poisoned)) == before
        saved = deepcopy(m.state)
        @test learning_objective(m,m.parameters,b) == before
        @test isequal(m.state,saved)
    end
    d = HeatFamily.parametric_dataset()
    @test_throws ArgumentError learning_model(d,ChangingState();rng=Xoshiro(1014),normalization=:none,rng_provenance=(seed=1014,))
end
end
