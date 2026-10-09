"""
    AnalyticMathLab.scientific_metadata(result)

Inspect scoped scientific claims and existing metadata without recomputing science.
This qualified experimental interface does not add an overall confidence status.
Metadata slots distinguish `availability=:unknown`, `:not_applicable`, and `:known`;
known means present, not scientifically certified. Values are borrowed/read-only.
Method, backend, approximation and tolerances are separate. See docs/m10d_semantics.md.
"""
function scientific_metadata end

"""
    AnalyticMathLab.scientific_origin(result)

Detached bounded origin descriptor. Contains process-local identity tokens, not
source objects, closures, datasets or reproducibility hashes. A token is useful
only within the originating process; it is not a persistent scientific identifier.
Parents trace recorded operations only; missing parents are not reconstructed.
An isolated PropertyResult has no stored origin and returns
`(availability=:unknown, value=nothing)` instead of an identity descriptor.
"""
function scientific_origin end

_sm_unknown()=(availability=:unknown,value=nothing)
_sm_na()=(availability=:not_applicable,value=nothing)
_sm_known(x)=x===nothing ? _sm_unknown() : (availability=:known,value=x)
_sm_claim(scope,p::PropertyResult)=(scope=scope,status=p.status,method=p.method,notes=p.notes)
function _sm_record(;claims=(),method=nothing,backend=_sm_unknown(),approximation=(),
        units=_sm_unknown(),domain=_sm_unknown(),coordinates=_sm_unknown(),
        tolerances=_sm_unknown(),reference=_sm_unknown(),execution=_sm_na(),
        sampling=_sm_na(),rng=_sm_unknown(),options=_sm_unknown(),ownership=:borrowed_read_only,origin)
    (;claims,method,backend,approximation,units,domain,coordinates,tolerances,
        reference,execution,sampling,rng,options,ownership,provenance=origin)
end
function _sm_origin(x,operation;parents=())
    # Whitelist descriptor fields: open user metadata is never a retention link.
    # Each supported operation has one immediate parent, at most eight levels.
    function bounded(p,depth)
        p isa NamedTuple && get(p,:kind,nothing)===:aml_scientific_origin || return nothing
        all(k->hasproperty(p,k),(:type,:token,:operation,:parents,:truncated)) || return nothing
        p.type isa AbstractString && p.token isa UInt && p.operation isa Symbol && p.parents isa Tuple || return nothing
        child=depth==0 || isempty(p.parents) ? nothing : bounded(first(p.parents),depth-1)
        (kind=:aml_scientific_origin,type=_sm_text(p.type),token=p.token,operation=p.operation,
            identity_scope=:process_local_not_reproducibility,parents=child===nothing ? () : (child,),
            truncated=p.truncated===true || length(p.parents)>1 || (depth==0 && !isempty(p.parents)))
    end
    parent=isempty(parents) ? nothing : bounded(first(parents),6)
    (kind=:aml_scientific_origin,type=string(nameof(typeof(x))),token=objectid(x),operation=operation,
        identity_scope=:process_local_not_reproducibility,
        parents=parent===nothing ? () : (parent,),truncated=length(parents)>1)
end
scientific_origin(::PropertyResult)=_sm_unknown()
function scientific_metadata(p::PropertyResult)
    # The established four-field atom records a claim, not its source context.
    # Inspect the enclosing result/series for units, controls and provenance.
    _sm_record(claims=(_sm_claim(:property,p),),method=p.method,
        backend=p.method in (:unsupported,:unsupported_backend_api) ? _sm_na() : _sm_unknown(),
        sampling=_sm_unknown(),execution=_sm_unknown(),origin=scientific_origin(p))
end

_sm_units(u::AbstractString)=startswith(lowercase(u),"unknown") ? _sm_unknown() : _sm_known(u)
_sm_units(u::Symbol)=u in (:unknown,:unspecified) ? _sm_unknown() : _sm_known(u)
_sm_units(u)=_sm_known(u)
_sm_get(x,k,default=nothing)=x isa NamedTuple || x isa AbstractDict ? get(x,k,default) : default
_sm_text(x)=x===nothing ? nothing : first(string(x),min(length(string(x)),128))
function _sm_check_coordinate_names(points::PINNPoints,expected)
    declared=_sm_get(points.provenance,:coordinate_names,())
    declared isa Union{Tuple,AbstractVector} || throw(ArgumentError("coordinate_names must be ordered names"))
    isempty(declared) || Tuple(string.(declared))==Tuple(string.(expected)) ||
        throw(ArgumentError("declared coordinate order does not match the operation; no reordering is inferred"))
    nothing
end
function scientific_origin(r::TrajectoryResult)
    parent=_sm_get(r.diagnostics,:origin)
    _sm_origin(r,:numerical_integration;parents=parent===nothing ? () : (parent,))
end
function scientific_metadata(r::TrajectoryResult)
    d=r.diagnostics
    # Termination controls availability of numerical evidence, never physical truth.
    claim=PropertyResult(nothing,_sm_get(d,:success)===true && _sm_get(d,:completed)===true ? :heuristic : :unknown,
        :numerical_integration,["Solver completion is not physical validation or a certified error bound."])
    _sm_record(claims=(_sm_claim(:numerical_trajectory,claim),),method=:numerical_integration,
        backend=_sm_known(:SciMLBase),approximation=(:numerical_integration,),
        domain=_sm_known(r.problem.domain),coordinates=_sm_known(r.labels),
        tolerances=_sm_known((abstol=_sm_get(d,:abstol),reltol=_sm_get(d,:reltol))),
        execution=_sm_known((success=_sm_get(d,:success),completed=_sm_get(d,:completed),
            retcode=_sm_get(d,:retcode),algorithm=_sm_get(d,:algorithm))),
        sampling=_sm_known((sampling=:stored,resampling=:none,order=:native_saved)),
        ownership=:native_solution_retained,origin=scientific_origin(r))
end
function scientific_origin(s::ObservableSeries)
    source=_sm_get(s.provenance,:source)
    parent=source isa Union{TrajectoryResult,AtomisticTrajectoryView} ? scientific_origin(source) : nothing
    _sm_origin(s,source isa TrajectoryResult ? :stored_observable_selection : :observable_series;
        parents=parent===nothing ? () : (parent,))
end
function scientific_metadata(s::ObservableSeries)
    source=_sm_get(s.provenance,:source)
    selection=_sm_get(s.provenance,:selection)
    coordinates=selection===nothing ? _sm_known((name=s.name,physical_identity=:unknown)) : _sm_known(selection)
    _sm_record(method=:scalar_observation,units=_sm_units(s.units),
        domain=_sm_known(_sm_get(s.provenance,:domain)),coordinates=coordinates,
        tolerances=source isa TrajectoryResult ? scientific_metadata(source).tolerances : _sm_unknown(),
        approximation=source isa TrajectoryResult ? (:numerical_integration,:stored_samples_only) : (:stored_samples_only,),
        sampling=_sm_known((count=s.sampling.count,regularity=s.sampling.regularity,
            time_units=s.sampling.units,sampling=:stored,resampling=:none,order=:increasing)),
        ownership=:values_times_borrowed_source_may_be_retained,origin=scientific_origin(s))
end
scientific_origin(t::AtomisticTrajectoryView)=_sm_origin(t,:atomistic_history_view)
function scientific_origin(d::ScientificDataset)
    source=_sm_get(d.provenance,:origin,nothing)
    _sm_origin(d,:scientific_dataset;parents=source===nothing ? () : (source,))
end
function scientific_metadata(d::ScientificDataset)
    reference=(kind=_sm_get(d.reference,:kind,nothing),trust=:caller_declared_not_certified,
        error=_sm_get(d.reference,:error,nothing))
    _sm_record(method=:scientific_dataset,backend=_sm_na(),units=_sm_known(d.units),
        domain=_sm_known((bounds=d.domain,interpretation=:descriptive_bounds_not_validity)),
        coordinates=_sm_known((inputs=d.input_names,query=d.coordinate_names,order=:rows_in_declared_order)),
        reference=reference.kind===nothing ? _sm_unknown() : _sm_known(reference),
        approximation=reference.kind===:numerical ? (:numerical_reference,) : (),
        tolerances=_sm_known(_sm_get(d.reference,:tolerances,nothing)),
        rng=_sm_known(d.rng),sampling=_sm_known(d.grid),
        ownership=_sm_get(d.provenance,:source_retention,:caller_managed),origin=scientific_origin(d))
end
scientific_origin(r::Union{LagrangianAnalysis,HamiltonianAnalysis})=_sm_origin(r,:symbolic_mechanics)
function scientific_metadata(r::Union{LagrangianAnalysis,HamiltonianAnalysis})
    order=r isa LagrangianAnalysis ? (r.coordinates...,r.velocities...) : r.phase_variables
    claims=Tuple(_sm_claim(k,p) for (k,p) in pairs(r.evidence) if p isa PropertyResult)
    _sm_record(claims=claims,method=:symbolic_mechanics,backend=_sm_known(:Symbolics),
        domain=_sm_known(r.domain),coordinates=_sm_known(order),tolerances=_sm_na(),
        execution=_sm_na(),ownership=:source_system_retained,origin=scientific_origin(r))
end
scientific_origin(r::MechanicsDynamics)=_sm_origin(r,:mechanics_to_dynamics;parents=(scientific_origin(r.source),))
scientific_metadata(r::MechanicsDynamics)=_sm_record(method=:mechanics_to_dynamics,
    backend=_sm_known(:Symbolics),domain=_sm_known(r.domain),coordinates=_sm_known(r.variables),
    ownership=:mechanics_source_retained,origin=scientific_origin(r))
scientific_origin(r::MechanicalLinearization)=_sm_origin(r,:mechanical_linearization;parents=(scientific_origin(r.source),))
scientific_metadata(r::MechanicalLinearization)=_sm_record(claims=(_sm_claim(:local_applicability,r.evidence),),
    method=:mechanical_linearization,backend=_sm_known(:Symbolics),approximation=(:linearization,),
    domain=_sm_known(r.domain),coordinates=_sm_known(r.source.coordinates),tolerances=_sm_na(),
    ownership=:mechanics_source_retained,origin=scientific_origin(r))
scientific_origin(r::AtomisticSnapshot)=_sm_origin(r,:atomistic_snapshot)
function scientific_origin(r::NormalModeAnalysis)
    parents=r.source isa Union{MechanicalLinearization,AtomisticSnapshot} ? (scientific_origin(r.source),) : ()
    _sm_origin(r,:normal_mode_analysis;parents)
end
function scientific_metadata(r::NormalModeAnalysis)
    l=r.source isa MechanicalLinearization ? r.source : nothing
    _sm_record(claims=(_sm_claim(:modal_analysis,r.evidence),),method=:normal_mode_analysis,
        backend=r.eigenvalues===nothing ? _sm_unknown() : _sm_known(:LinearAlgebra),
        approximation=l===nothing ? (:numerical_eigensolve,) : (:linearization,:numerical_eigensolve),
        units=_sm_units(get(r.metadata,:units,nothing)),domain=l===nothing ? _sm_unknown() : _sm_known(l.domain),
        coordinates=l===nothing ? _sm_known((representation=r.representation,reconstruction=r.reconstruction)) : _sm_known(l.source.coordinates),
        tolerances=_sm_known((atol=get(r.metadata,:atol,nothing),rtol=get(r.metadata,:rtol,nothing))),
        ownership=:source_and_matrices_retained,origin=scientific_origin(r))
end
_sm_reference_descriptor(r)=(kind=_sm_get(r,:kind,:unknown),trust=:caller_declared_not_certified,
    uncertainty=_sm_get(r,:error) in (nothing,:unknown) ? :unknown : :caller_declared)
function _sm_numeric_tolerances(options)
    options isa NamedTuple || return nothing
    allowed=(:abstol,:reltol,:atol,:rtol,:f_abstol,:f_reltol,:x_abstol,:x_reltol,:g_abstol,:g_reltol)
    keys=Tuple(k for k in allowed if hasproperty(options,k) && options[k] isa Real && isfinite(options[k]))
    isempty(keys) ? nothing : NamedTuple{keys}(Tuple(options[k] for k in keys))
end
scientific_origin(m::ScientificModel)=_sm_origin(m,:scientific_model;
    parents=_sm_get(m.provenance,:origin)===nothing ? () : (m.provenance.origin,))
function scientific_metadata(m::ScientificModel)
    _sm_record(method=m.architecture,backend=_sm_known((packages=(:Lux,:NeuralOperators,:Optimization),
        versions=_sm_get(m.provenance,:packages))),approximation=(:surrogate,),units=_sm_known(m.schema.units),
        domain=_sm_known((bounds=m.schema.domain,interpretation=:descriptive_bounds_not_validity)),
        coordinates=_sm_known((inputs=m.schema.input_names,query=m.schema.coordinate_names,order=:rows_in_declared_order)),
        reference=_sm_known(_sm_get(m.provenance,:reference)),tolerances=_sm_known(_sm_get(m.provenance,:reference_tolerances)),
        rng=_sm_known(_sm_get(m.provenance,:rng)),sampling=_sm_known(m.schema.grid),
        options=_sm_known((normalization=m.normalization.method,precision=_sm_get(m.provenance,:precision))),
        ownership=:network_parameters_and_schema_retained_no_targets,origin=scientific_origin(m))
end
scientific_origin(r::ScientificLearningResult)=_sm_origin(r,:scientific_learning;parents=(scientific_origin(r.dataset),))
function scientific_metadata(r::ScientificLearningResult)
    m=scientific_metadata(r.model); d=scientific_metadata(r.dataset)
    _sm_record(claims=(_sm_claim(:generalization,r.evidence),),method=:scientific_learning,
        backend=m.backend,approximation=m.approximation,units=d.units,domain=d.domain,coordinates=d.coordinates,
        reference=d.reference,tolerances=d.tolerances,rng=m.rng,sampling=d.sampling,
        execution=_sm_known(_sm_get(r.provenance,:termination)),options=_sm_known(r.provenance),
        ownership=:dataset_and_optimization_objects_retained,origin=scientific_origin(r))
end
scientific_origin(r::GeneralizationAnalysis)=_sm_origin(r,:sampled_generalization_analysis;parents=(scientific_origin(r.training),))
function scientific_metadata(r::GeneralizationAnalysis)
    m=scientific_metadata(r.training)
    floor=isempty(r.cases) ? nothing : first(r.cases).errors.relative_floor
    _sm_record(claims=(_sm_claim(:global_generalization,r.evidence),),method=:sampled_generalization_analysis,
        backend=m.backend,approximation=(m.approximation...,:sampled_errors_only),units=m.units,domain=m.domain,
        coordinates=m.coordinates,reference=m.reference,
        tolerances=_sm_known((relative_floor=floor,reference=m.tolerances.value)),rng=m.rng,sampling=m.sampling,
        ownership=:training_and_sample_arrays_retained,origin=scientific_origin(r))
end
function scientific_metadata(s::AtomisticSnapshot)
    unit(a)=a===nothing || isempty(a) ? _sm_unknown() : _sm_units(_at_unit(first(a)))
    positions=isempty(s.positions) ? nothing : first(s.positions)
    velocities=s.velocities===nothing || isempty(s.velocities) ? nothing : first(s.velocities)
    _sm_record(method=:atomistic_snapshot,backend=_sm_known(_sm_get(s.provenance,:backend)),
        units=_sm_known((position=unit(positions),mass=unit(s.masses),velocity=unit(velocities))),
        coordinates=_sm_known((order=:particle_major_cartesian,dimension=s.dimension)),
        domain=_sm_known((boundary=s.boundary,interpretation=:boundary_not_validity)),
        ownership=:arrays_borrowed_unless_copy_data,origin=scientific_origin(s))
end
scientific_origin(r::AtomisticSystemAnalysis)=_sm_origin(r,:snapshot_inspection;parents=(scientific_origin(r.source),))
function scientific_metadata(r::AtomisticSystemAnalysis)
    s=scientific_metadata(r.source)
    claims=Tuple(_sm_claim(k,p) for (k,p) in pairs(r.observations) if p isa PropertyResult)
    _sm_record(claims=claims,method=:snapshot_inspection,backend=s.backend,units=s.units,domain=s.domain,
        coordinates=s.coordinates,ownership=:snapshot_retained,origin=scientific_origin(r))
end
scientific_metadata(t::AtomisticTrajectoryView)=_sm_record(method=:atomistic_history_view,
    backend=_sm_known(_sm_get(t.provenance,:backend)),approximation=(:stored_samples_only,),
    sampling=_sm_known((order=:stored,sampling=:stored,resampling=:none)),
    ownership=:history_source_retained_frames_lazy,origin=scientific_origin(t))
scientific_origin(p::PINNPoints)=_sm_origin(p,:declared_coordinates)
scientific_metadata(p::PINNPoints)=_sm_record(method=:declared_coordinates,
    coordinates=_sm_known((order=:rows_in_declared_order,variables=_sm_get(p.provenance,:coordinate_names,()),
        identity_origin=:caller_declared)),
    sampling=_sm_known((count=size(p.coordinates,2),domain_inference=:none)),
    ownership=:coordinate_matrix_copied_on_construction,origin=scientific_origin(p))
scientific_origin(p::PINNProblem)=_sm_origin(p,:pinn_construction)
function scientific_metadata(p::PINNProblem)
    _sm_record(claims=(_sm_claim(:backend_construction,p.evidence),),method=:physics_informed_learning,
        backend=_sm_known((packages=(:NeuralPDE,:Lux,:Optimization),versions=_sm_get(p.provenance,:packages))),
        approximation=(:surrogate,:sampled_training_costs,:backend_derivative),domain=_sm_known(p.domains),
        coordinates=_sm_known((independent=p.independent_variables,mapping=p.network_mapping)),
        rng=_sm_known((type=_sm_get(p.provenance,:rng_type),initialization=_sm_get(p.provenance,:initialization))),
        options=_sm_known((derivative=_sm_get(p.provenance,:derivative),optimization=_sm_get(p.provenance,:optimization_options))),
        ownership=:symbolic_system_networks_and_backend_objects_retained,origin=scientific_origin(p))
end
scientific_origin(r::PINNTrainingResult)=_sm_origin(r,:pinn_training;parents=(scientific_origin(r.problem),))
function scientific_metadata(r::PINNTrainingResult)
    m=scientific_metadata(r.problem)
    _sm_record(claims=(_sm_claim(:physical_validation,r.evidence),_sm_claim(:sampled_costs,r.losses)),
        method=:physics_informed_learning,backend=m.backend,approximation=m.approximation,domain=m.domain,
        coordinates=m.coordinates,rng=m.rng,execution=_sm_known(r.termination),options=_sm_known(r.provenance.options),
        tolerances=_sm_known(_sm_numeric_tolerances(_sm_get(r.provenance.options,:solver))),
        ownership=:problem_network_and_solutions_retained,origin=scientific_origin(r))
end
scientific_origin(r::PINNAnalysis)=_sm_origin(r,:sampled_pinn_diagnostics;parents=(scientific_origin(r.training),))
function scientific_metadata(r::PINNAnalysis)
    m=scientific_metadata(r.training)
    ref=r.reference.value
    reference=ref===nothing ? _sm_unknown() : _sm_known((kind=_sm_get(ref.provenance,:kind,:unknown),
        trust=:caller_declared_not_certified,provenance=ref.provenance))
    _sm_record(claims=(_sm_claim(:global_correctness,r.evidence),),method=:sampled_residual_diagnostics,
        backend=m.backend,approximation=(m.approximation...,:sampled_residuals_only),domain=m.domain,
        coordinates=m.coordinates,reference=reference,rng=m.rng,
        tolerances=_sm_known((relative_guard=_sm_get(r.provenance,:reference_relative_guard),training=m.tolerances.value)),
        options=_sm_known((derivative=_sm_get(r.provenance,:derivative),)),
        ownership=:training_collocation_and_reference_arrays_retained,origin=scientific_origin(r))
end
