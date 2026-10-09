"""
A tiny, intentionally underfit scalar surrogate of the same oscillator family.
    julia --project=examples/operators examples/integration/one_system_learning.jl
Only the symmetric initial amplitude varies. No learned dynamics or new model family.
"""
module OneSystemLearning
using AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers
using ComponentArrays, ADTypes, Zygote, Random
include("one_system_many_methods.jl")
const W = OneSystemManyMethods
const AML = AnalyticMathLab

function run_learning()
    core = W.investigate()
    s = core.system
    # Amplitude is a finite-dimensional parameter: parameter_extrapolation.
    # amplitude_extrapolation is reserved for function-input operator descriptors.
    cases = (canonical=(amplitude=s.amplitudes[1],split=:training),
             lower=(amplitude=0.15,split=:training),
             upper=(amplitude=0.25,split=:training),
             interior=(amplitude=0.175,split=:interpolation),
             outside=(amplitude=0.35,split=:parameter_extrapolation))
    sources = ScientificDataset[]
    samples = ScientificSample[]
    for (id,case) in pairs(cases)
        path = id == :canonical ? core.path : W.integrate(s,core.conversion;amplitude=case.amplitude)
        # A standalone bridge dataset must contain a training sample. Its local
        # bounds enclose this run; family bounds below remain [0.15,0.25].
        schema = W.simulation_schema(s;amplitude=case.amplitude,id)
        local_schema = merge(schema,(domain=(inputs=reshape([case.amplitude,case.amplitude],1,2),
                                             coordinates=schema.domain.coordinates),))
        source = id == :canonical ? core.dataset : ScientificDataset(path;
            schema=local_schema,source_retention=:descriptor)
        push!(sources,source)
        sample = only(source.samples)
        # Explicit family roles BEFORE training/scaling. Never fit the provisional
        # standalone datasets; never relabel numerical targets as analytical.
        push!(samples,ScientificSample(id,sample.input,sample.coordinates,sample.values;split=case.split))
    end
    reference = merge(core.dataset.reference,
        (description="Five explicitly assigned amplitude cases; numerical q1 at stored times",
         parameters=(fixed=s.parameters,antisymmetric_amplitude=s.amplitudes[2],cases=cases),
         runs=Tuple((id=x.samples[1].id,reference=x.reference) for x in sources)))
    dataset = ScientificDataset(samples;kind=:surrogate,family=core.dataset.family,
        input_names=core.dataset.input_names,coordinate_names=core.dataset.coordinate_names,
        domain=core.dataset.domain,reference,units=core.dataset.units,grid=core.dataset.grid,
        rng=(kind=:deterministic,),provenance=(origin=AML.scientific_origin(core.dataset),
            sources=Tuple(AML.scientific_origin(x) for x in sources),
            operation=:explicit_family_assembly,primary_parent=:canonical_dataset,
            omitted_from_single_parent_trace=:other_amplitude_runs,
            parameters=s.parameters,state_order=s.state_order,units=s.units,cases=cases))
    model = learning_model(dataset,Lux.Dense(2=>1);rng=Xoshiro(41),
        normalization=:train_minmax,rng_provenance=(seed=41,))
    batch = training_data(model,dataset)
    initial_loss = learning_objective(model,model.parameters,batch)
    fit = AML.train(model,dataset;initial_parameters=ComponentArray{Float64}(model.parameters),
        optimizer=OptimizationOptimisers.Adam(0.01),adtype=ADTypes.AutoZygote(),maxiters=1)
    analysis = analyze(fit)
    comparisons = NamedTuple[]
    errors = NamedTuple[]
    for (sample,case) in zip(dataset.samples,analysis.cases)
        amplitude = only(sample.input)
        predicted = W.quantity_contract(s,:q1,vec(sample.coordinates),:learned;amplitude)
        numerical = W.quantity_contract(s,:q1,vec(sample.coordinates),:numerical;amplitude)
        # Deliberately loose pipeline bound, not a surrogate accuracy milestone.
        push!(comparisons,W.compare_quantity(sample.id,case.prediction,case.reference,
            predicted,numerical;tolerance=2.0))
        oracle = [W.exact_state(s,t;amplitude)[1] for t in vec(sample.coordinates)]
        analytical = W.quantity_contract(s,:q1,vec(sample.coordinates),:analytical;amplitude)
        push!(comparisons,W.compare_quantity(Symbol(sample.id,:_oracle),case.prediction,oracle,
            predicted,analytical;tolerance=2.0))
        oracle_errors = field_errors(case.prediction,oracle)
        push!(errors,(id=sample.id,split=sample.split,
            numerical_reference_rms=case.errors.summary.rms,
            analytical_oracle_rms=oracle_errors.summary.rms,
            maximum_error=maximum(case.errors.absolute)))
    end
    all(c.agreement for c in comparisons) || error("Nonfinite or unbounded learning pipeline")
    (;core,cases,sources,dataset,model,batch,initial_loss,fit,analysis,comparisons,errors)
end

function main()
    r = run_learning()
    println("One affine coordinate network, seed 41, one Adam step; accuracy is NOT established.")
    println("Inputs: symmetric amplitude, then t. Fixed model: ",r.core.system.parameters)
    println("Explicit splits: ",r.cases)
    println("Loss: ",r.fit.objective)
    foreach(println,r.errors)
    println("Bounded primary derivation trace: ",W.origin_trace(r.analysis))
    println("References remain numerical; analytical errors are a separate same-model check.")
    r
end
end

if abspath(PROGRAM_FILE) == @__FILE__
    OneSystemLearning.main()
end
