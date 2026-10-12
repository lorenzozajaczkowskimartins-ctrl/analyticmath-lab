# Qualified experimental evidence inspection

AnalyticMathLab.scientific_metadata and AnalyticMathLab.scientific_origin are not exports. Known metadata means present, not proven. Recorded ancestry is distinct from equal values or an independently specified analytical reference.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/m10d_provenance.md">docs/m10d_provenance.md</a>; <a href="../repository/docs/tutorials/one-system-many-methods.md">docs/tutorials/one-system-many-methods.md</a>; <a href="../repository/docs/tutorials/scripts/one_system_many_methods.jl">docs/tutorials/scripts/one_system_many_methods.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

## [Qualified evidence family](@id family-qualified)

Neither name is part of the 177-export count. PropertyResult origin is explicitly unknown: its four fields do not retain ancestry. Metadata availability slots are distinct from scientific status or uncertainty.

<!-- aml-api: {"symbol": "scientific_metadata", "family": "Qualified scientific semantics (M10D.3)", "stability": "PUBLIC_EXPERIMENTAL", "qualified": true, "kind": "generic function", "variant_count": 1} -->
## [AnalyticMathLab.scientific_metadata](@id api-qualified-scientific-metadata)

**Identity:** generic function; Qualified scientific semantics (M10D.3); **PUBLIC_EXPERIMENTAL**; qualified, not exported.

<!-- aml-contract: {"variant": 0, "digest": "167279abbcedb62f9a02acb93535417cfe8d17344fc780275eb3d307905cc40b"} -->
**Purpose and output:** NamedTuple of scoped claims, method, backend, approximation, units, domain, coordinates, tolerances, reference, execution, sampling, rng, options, ownership, provenance; availability slots distinguish known/unknown/not_applicable

**Source declarations and forwarding context:**

```text
scientific_metadata(result) for the explicitly defined supported result types; no universal fallback
```

**Inputs:** PropertyResult, TrajectoryResult, ObservableSeries, ScientificDataset, LagrangianAnalysis, HamiltonianAnalysis, MechanicsDynamics, MechanicalLinearization, NormalModeAnalysis, ScientificModel, ScientificLearningResult, GeneralizationAnalysis, AtomisticSnapshot, AtomisticSystemAnalysis, AtomisticTrajectoryView, PINNPoints, PINNProblem, PINNTrainingResult, PINNAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unsupported type has no defined public method; metadata inspection does not validate arbitrary fabricated raw records

**Numerical limitations:** No recomputation, overall confidence score, accuracy bound or certification; known means present, not proven

**Units:** Existing units are described, not inferred or converted; string labels remain caller declarations

**Ownership:** Metadata values are borrowed/read-only; provenance is detached; native source/result may still retain arrays and backend objects

**Dependencies:** No additional import needed for the base methods; constructing backend-dependent payloads retains those families' extension requirements.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: Present and explicit; supported-type table and slot-by-slot tutorial still needed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_metadata.jl:1-10; src/scientific_metadata.jl:53-255.

Inventory-listed candidate references (not a verified call graph or new execution): test/m10d_semantics.jl; test/m10d_semantics_learning.jl; examples/integration/one_system_many_methods.jl:67-79.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/scientific_metadata.jl">src/scientific_metadata.jl</a>; <a href="../repository/test/m10d_semantics.jl">test/m10d_semantics.jl</a>; <a href="../repository/test/m10d_semantics_learning.jl">test/m10d_semantics_learning.jl</a></p>
```

**Exact qualified dispatch declarations (current source):**

```text
AnalyticMathLab.scientific_metadata(p::PropertyResult)
AnalyticMathLab.scientific_metadata(r::TrajectoryResult)
AnalyticMathLab.scientific_metadata(s::ObservableSeries)
AnalyticMathLab.scientific_metadata(d::ScientificDataset)
AnalyticMathLab.scientific_metadata(r::Union{LagrangianAnalysis,HamiltonianAnalysis})
AnalyticMathLab.scientific_metadata(r::MechanicsDynamics)
AnalyticMathLab.scientific_metadata(r::MechanicalLinearization)
AnalyticMathLab.scientific_metadata(r::NormalModeAnalysis)
AnalyticMathLab.scientific_metadata(m::ScientificModel)
AnalyticMathLab.scientific_metadata(r::ScientificLearningResult)
AnalyticMathLab.scientific_metadata(r::GeneralizationAnalysis)
AnalyticMathLab.scientific_metadata(s::AtomisticSnapshot)
AnalyticMathLab.scientific_metadata(r::AtomisticSystemAnalysis)
AnalyticMathLab.scientific_metadata(t::AtomisticTrajectoryView)
AnalyticMathLab.scientific_metadata(p::PINNPoints)
AnalyticMathLab.scientific_metadata(p::PINNProblem)
AnalyticMathLab.scientific_metadata(r::PINNTrainingResult)
AnalyticMathLab.scientific_metadata(r::PINNAnalysis)
```

<!-- aml-api: {"symbol": "scientific_origin", "family": "Qualified scientific semantics (M10D.3)", "stability": "PUBLIC_EXPERIMENTAL", "qualified": true, "kind": "generic function", "variant_count": 1} -->
## [AnalyticMathLab.scientific_origin](@id api-qualified-scientific-origin)

**Identity:** generic function; Qualified scientific semantics (M10D.3); **PUBLIC_EXPERIMENTAL**; qualified, not exported.

<!-- aml-contract: {"variant": 0, "digest": "0703078f11ba7e3c633480a3895ced8c1ed44028a9b4754d2286c4ce43acf284"} -->
**Purpose and output:** Detached bounded NamedTuple descriptor with type, process-local token, operation, parents, truncation and identity_scope; PropertyResult returns (availability=:unknown,value=nothing)

**Source declarations and forwarding context:**

```text
scientific_origin(result) for supported concrete result types; no universal fallback
```

**Inputs:** Explicit supported result types listed alongside scientific_metadata; PropertyResult is a special unknown-origin case

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unsupported types have no public method; missing recorded ancestry is not reconstructed

**Numerical limitations:** Tokens are object identity within the originating process, not persistent reproducibility hashes or scientific equality; ancestry is bounded and can be truncated

**Units:** No unit inference or conversion

**Ownership:** Descriptor contains no source objects, closures or datasets; only whitelisted bounded parent descriptors

**Dependencies:** None beyond constructing the relevant result.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: Present, explicit warning; future reference needs supported types and truncation illustration. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_metadata.jl:12-22; src/scientific_metadata.jl:35-52; src/scientific_metadata.jl:73-255.

Inventory-listed candidate references (not a verified call graph or new execution): test/m10d_semantics.jl; test/m10d_semantics_review.jl; examples/integration/one_system_many_methods.jl:67-79.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/scientific_metadata.jl">src/scientific_metadata.jl</a>; <a href="../repository/test/m10d_semantics.jl">test/m10d_semantics.jl</a>; <a href="../repository/test/m10d_semantics_review.jl">test/m10d_semantics_review.jl</a></p>
```

**Exact qualified dispatch declarations (current source):**

```text
AnalyticMathLab.scientific_origin(::PropertyResult)
AnalyticMathLab.scientific_origin(r::TrajectoryResult)
AnalyticMathLab.scientific_origin(s::ObservableSeries)
AnalyticMathLab.scientific_origin(t::AtomisticTrajectoryView)
AnalyticMathLab.scientific_origin(d::ScientificDataset)
AnalyticMathLab.scientific_origin(r::Union{LagrangianAnalysis,HamiltonianAnalysis})
AnalyticMathLab.scientific_origin(r::MechanicsDynamics)
AnalyticMathLab.scientific_origin(r::MechanicalLinearization)
AnalyticMathLab.scientific_origin(r::AtomisticSnapshot)
AnalyticMathLab.scientific_origin(r::NormalModeAnalysis)
AnalyticMathLab.scientific_origin(m::ScientificModel)
AnalyticMathLab.scientific_origin(r::ScientificLearningResult)
AnalyticMathLab.scientific_origin(r::GeneralizationAnalysis)
AnalyticMathLab.scientific_origin(r::AtomisticSystemAnalysis)
AnalyticMathLab.scientific_origin(p::PINNPoints)
AnalyticMathLab.scientific_origin(p::PINNProblem)
AnalyticMathLab.scientific_origin(r::PINNTrainingResult)
AnalyticMathLab.scientific_origin(r::PINNAnalysis)
```
