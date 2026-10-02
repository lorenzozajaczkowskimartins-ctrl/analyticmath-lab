"""Stored split-specific empirical errors, separate optional physics and timing evidence."""
struct GeneralizationAnalysis <: AbstractAnalysis
    training::ScientificLearningResult
    cases::Vector{NamedTuple}
    groups::Dict{Symbol,NamedTuple}
    reference
    physics
    timing
    evidence::PropertyResult
    limitations::Vector{String}
end
function analyze(r::ScientificLearningResult;physics=nothing,timing=nothing,relative_floor=1e-12)
    cases=NamedTuple[]
    for s in r.dataset.samples
        y=predict(r,s.input,s.coordinates)
        push!(cases,(id=s.id,split=s.split,input=s.input,coordinates=s.coordinates,
            prediction=y,reference=s.values,errors=field_errors(y,s.values;relative_floor),
            descriptor=s.descriptor,classification=classify_query(r.model,s.input,s.coordinates;descriptor=s.descriptor)))
    end
    groups=Dict{Symbol,NamedTuple}()
    for split in unique(c.split for c in cases)
        cs=filter(c->c.split==split,cases)
        same=all(c->c.coordinates==first(cs).coordinates,cs)
        percoordinate=same ? [sampled_summary([c.prediction[i]-c.reference[i] for c in cs]).rms for i in eachindex(first(cs).reference)] : nothing
        groups[split]=(sample_count=length(cs),ids=[c.id for c in cs],
            errors=field_errors(vcat((c.prediction for c in cs)...),vcat((c.reference for c in cs)...);relative_floor),
            per_sample_rms=[c.errors.summary.rms for c in cs],per_coordinate_rms=percoordinate,
            coordinate_grid=same ? first(cs).coordinates : nothing,aggregation=:unweighted_target_samples)
    end
    GeneralizationAnalysis(r,cases,groups,r.dataset.reference,physics,timing,
        PropertyResult(nothing,:unknown,:finite_family_evaluation,["Interpolation evidence applies only to evaluated cases; no universal generalization claim."]),
        ["Empirical sampled differences, not continuum norms or probabilistic uncertainty.",
         "Numerical references give surrogate-reference differences, not surrogate-exact errors.",
         "No automatic ranking, discretization invariance, or long-term stability established."])
end

"""Sample `u_t-alpha*u_xx` by ForwardDiff on a differentiable scalar `(x,t)` callable.
No finite-difference boundary stencil, no continuum norm, no global correctness claim.
Coordinates and summaries reuse M9B PINNPoints/sampled_summary, not PINN training objects.
"""
function heat_residual(predictor,points::PINNPoints;alpha)
    size(points.coordinates,1)==2 || throw(DimensionMismatch("heat residual expects ordered (x,t) rows"))
    isfinite(alpha) && alpha>0 || throw(ArgumentError("positive finite diffusivity required"))
    values=[begin
        g=ForwardDiff.gradient(predictor,q); h=ForwardDiff.hessian(predictor,q)
        g[2]-alpha*h[1,1]
    end for q in eachcol(points.coordinates)]
    all(isfinite,values) || throw(ArgumentError("nonfinite residual"))
    (points=points,values=values,summary=sampled_summary(values),alpha=alpha,
        derivative=:ForwardDiff_coordinate_gradient_hessian,coordinate_order=(:x,:t),
        boundary_treatment=:differentiate_coordinate_model,no_reference_targets=true,
        evidence=PropertyResult(nothing,:unknown,:sampled_residual_only,
            ["AD differentiates the represented model, not its error relative to the true field.",
             "A small sampled residual does not establish global correctness."]))
end

"""Time two caller-supplied, comparable complete queries, alternating warmed measurements.
First timed calls may include compilation; they are not necessarily first process calls.
An estimated break-even is withheld unless all reference timings exceed all inference timings.
"""
function benchmark_queries(reference,inference;training_seconds,repetitions::Integer=11,context=NamedTuple())
    isfinite(training_seconds) && training_seconds>=0 || throw(ArgumentError("finite nonnegative training cost required"))
    3<=repetitions<=1001 && isodd(repetitions) || throw(ArgumentError("odd repetition count between 3 and 1001 required"))
    first_reference=@elapsed reference()
    first_inference=@elapsed inference()
    reference(); inference()
    rs=Float64[]; ins=Float64[]
    for i in 1:repetitions
        if isodd(i)
            push!(rs,@elapsed reference()); push!(ins,@elapsed inference())
        else
            push!(ins,@elapsed inference()); push!(rs,@elapsed reference())
        end
    end
    rm=sort(rs)[(repetitions+1)÷2]; im=sort(ins)[(repetitions+1)÷2]
    break_even=minimum(rs)>maximum(ins) && rm>im ? training_seconds/(rm-im) : nothing
    (training_seconds=Float64(training_seconds),first_reference_seconds=first_reference,first_inference_seconds=first_inference,
        reference_seconds=rs,inference_seconds=ins,reference_median=rm,inference_median=im,
        break_even_queries=break_even,compilation=:first_timed_calls_may_include_compilation,
        runtime=(julia=string(VERSION),threads=Threads.nthreads(),cpu=Sys.CPU_NAME,os=string(Sys.KERNEL),
            blas_threads=LinearAlgebra.BLAS.get_num_threads()),context=context,
        limitations=("Same caller-defined query scope required; no universal speedup claim.",
            "Small local timing sample; memory and broad scaling are unmeasured.",
            "Break-even covers supplied training cost, not unmeasured dataset/engineering costs."))
end
