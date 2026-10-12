# Memory and Performance

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q066 — Why was my 3000 x 3000 Hessian rejected, and what can I do?](Memory-and-Performance#user-content-q066)
- [Q067 — Is there a global AML memory-budget setter?](Memory-and-Performance#user-content-q067)
- [Q068 — Does a dense matrix size estimate include temporary storage?](Memory-and-Performance#user-content-q068)
- [Q069 — Which limits are internal rather than public configuration?](Memory-and-Performance#user-content-q069)
- [Q070 — Are maintainer scaling scripts supported matrix-free APIs?](Memory-and-Performance#user-content-q070)
- [Q086 — Which pair-output limits are public, and does RDF remove quadratic work?](Memory-and-Performance#user-content-q086)
- [Q087 — Does prediction batch_size bound the returned output or training memory?](Memory-and-Performance#user-content-q087)
- [Q088 — Which histories retain earliest entries and which retain the most recent?](Memory-and-Performance#user-content-q088)
- [Q089 — When does summary_only avoid output arrays, and are public iterators one-pass?](Memory-and-Performance#user-content-q089)
- [Q090 — What provenance is intentionally omitted with source_retention=:descriptor?](Memory-and-Performance#user-content-q090)

<!-- aml-faq: {"id": "Q066", "category": "Memory and Performance", "priority": "P0", "question_sha256": "496c041e446a668235499cbe3209c5049958340630ea3d101bde90c26ceb3cb7"} -->
<a name="q066"></a>

## Q066

**Question:** Why was my 3000 x 3000 Hessian rejected, and what can I do?

**Short answer:** First identify the operation: a 3000-variable symbolic Hessian and normal modes of an existing 3000×3000 numerical matrix hit different limits.

**Explanation:** Symbolic scalar-field analysis accepts 1 through 32 ordered variables. Exactly 32 passes the dimension guard; 3000 does not. Direct normal_modes instead estimates dense full-spectrum working storage as 24*sizeof(Float64)*n^2. At n=3000 that is 1,728,000,000 bytes, exceeding the default max_memory_bytes of 512*1024^2 = 536,870,912 bytes. These numbers are a preflight estimate, not a measured peak-RSS bound; adapters can allocate before reaching it.

**Practical action:** Check the input type, variable count or matrix dimension and exact refusal. For symbolic work, formulate a justified smaller model within the supported dimension range; AML does not automatically derive a reduced model. For existing small K/M matrices, use the direct route and its public budget only after assessing available resources. If genuinely large partial/sparse work is needed, use a separate appropriate solver outside AML, not a hidden AML switch.

**Scientific boundary:** Increasing max_memory_bytes does not bypass the symbolic dimension guard or change the dense algorithm. There is no generic public partial-mode, matrix-free, Hessian-vector-product or sparse-Hessian interface. Sparse storage and a 32-variable acceptance are not scalability guarantees; see [budget scope](Memory-and-Performance#user-content-q068).

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Source-audited resource controls](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q067", "category": "Memory and Performance", "priority": "P0", "question_sha256": "440e8f0abf578e3c6b230baf9685acad3acbed926222b13fc3e4b1aecfa253b7"} -->
<a name="q067"></a>

## Q067

**Question:** Is there a global AML memory-budget setter?

**Short answer:** No. AML has no global public memory-budget setter or global memory flag.

**Explanation:** The available controls apply to specific operations: normal_modes has max_memory_bytes, pair_distances has max_bytes/max_pairs, and learning diagnostics have history/chunk/retention controls. These constrain different things and do not collectively bound all retained inputs, backend allocations or process RSS.

**Practical action:** Read the exact operation contract and select only the applicable supported control. Estimate the actual computational regime before constructing large data, and distinguish [query chunks](Memory-and-Performance#user-content-q087) from output and training storage.

**Scientific boundary:** Maintainer harness environment variables are not supported global AML configuration. Do not fabricate a flag or modify internal constants to disable validation.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q068", "category": "Memory and Performance", "priority": "P0", "question_sha256": "f9c5c17128dda6c225a673bc6d6ff30404196681814da4e76015132f912d1039"} -->
<a name="q068"></a>

## Q068

**Question:** Does a dense matrix size estimate include temporary storage?

**Short answer:** The normal_modes estimate allows for dense working arrays, not merely one matrix; it is still not a peak-memory guarantee.

**Explanation:** The direct method uses 24*sizeof(Float64)*n^2, compared with the caller-selected positive byte budget before coefficient traversal, metadata copying and dense conversion. Caller inputs, arbitrary metadata, symbolic graphs and upstream adapter allocations are outside that estimate. Native eigensolver workspace and allocator behavior are not certified RSS.

**Practical action:** Inspect dimension and the estimate before taking the direct matrix route; retain the budget and environment when reporting a refusal. Use scientifically justified smaller matrices when possible. Treat any supported budget increase as permission for estimated dense work, not reservation of actual RAM.

**Scientific boundary:** A matrix-size calculation is not a measurement of peak process memory. Sparsity does not activate a sparse eigensolver, and a passed preflight cannot prevent every allocation failure.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q069", "category": "Memory and Performance", "priority": "P0", "question_sha256": "c37c00bb90f3954f76af5d3fb2c8b3630573bf6e6d86dfcf720917d56572dd47"} -->
<a name="q069"></a>

## Q069

**Question:** Which limits are internal rather than public configuration?

**Short answer:** Public operation keywords are supported controls; fixed symbolic/exact-algebra ceilings and maintainer harness settings are not user configuration.

**Explanation:** The 1–32 ordered-variable guard and bounded exact-algebra degree/coefficient/work/syntax ceilings are internal implementation boundaries. The audit separately lists max_memory_bytes, max_bytes/max_pairs, trajectory iteration/observation controls and learning diagnostic controls as operation-specific public settings.

**Practical action:** Compare the exact refusal with the boundary and resource-control tables. Use only the documented keyword for the intended operation, reduce or reformulate the problem truthfully, or report a supported-input defect with a small reproducer.

**Scientific boundary:** There is no public override for every internal ceiling. Changing constants can remove safeguards without supplying the algorithm, correctness or memory guarantees needed for the larger problem.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q070", "category": "Memory and Performance", "priority": "P0", "question_sha256": "622148d2fd3130e566632bea38d6316f2b4bff31d26c86fca862cc98de696507"} -->
<a name="q070"></a>

## Q070

**Question:** Are maintainer scaling scripts supported matrix-free APIs?

**Short answer:** No. Maintainer scaling experiments are not generic supported AML matrix-free or partial-spectrum APIs.

**Explanation:** The scripts explore particular chain models, native solver storage and cooperative stress controls. Their helpers and measurements do not extend the public normal_modes or symbolic Hessian contracts to arbitrary systems.

**Practical action:** Use the public small dense normal-modes tutorial for supported AML analysis. If your problem requires matrix-free derivatives or selected eigenpairs, choose and document a separate numerical implementation with its own residual, ordering and model checks.

**Scientific boundary:** A successful scaling experiment is not a portable performance guarantee or evidence that arbitrary Hessians support that method. UNAVAILABLE_CAPABILITY is distinct from a defect.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q086", "category": "Memory and Performance", "priority": "P1", "question_sha256": "dcf4c67c142afe6eca0eac6cd02cfe498c4d6884b5d07ea4f05f5eb20ea1ead0"} -->
<a name="q086"></a>

## Q086

**Question:** Which pair-output limits are public, and does RDF remove quadratic work?

**Short answer:** pair_distances exposes max_pairs and max_bytes; RDF and coordination avoid full pair-output retention but can still do quadratic work.

**Explanation:** The default max_pairs is 1_000_000 and max_bytes is 512*1024^2. The byte estimate is 64*pairs_count + sizeof(Int)*(length(A)+length(B)), with overflow-safe counting. Selection arrays may already be allocated; output refusal yields an unknown PropertyResult. mdcheck forwards max_pairs only. RDF/coordination traverse pairs without returning the whole pair list.

**Practical action:** Select scientifically relevant species/particles and inspect status/notes before consuming distances. Use radial_distribution or coordination when their geometry and summary answer match your question, not as a claim of subquadratic processing. Assess work separately from output size.

**Scientific boundary:** The fixed-width estimate is not peak RSS, arbitrary-precision storage accounting or a deadline. Omitting pair arrays does not create a generic streaming neighbor-list algorithm.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — atomistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/atomistics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q087", "category": "Memory and Performance", "priority": "P1", "question_sha256": "e59b4528ac760b5b469f962b7ebe20fdc9b40f92c6f24e47ca3b4b4e5692015d"} -->
<a name="q087"></a>

## Q087

**Question:** Does prediction batch_size bound the returned output or training memory?

**Short answer:** Prediction batch_size limits temporary query chunks, not necessarily the complete returned output or model-training memory.

**Explanation:** The supported PINN and surrogate/operator prediction routes assemble the full output in query order. Chunking can reduce temporary activations/input slices, but retained output remains proportional to queries. Batching assumes deterministic query-independent networks; AML does not automatically detect every coupled-query model.

**Practical action:** Use a positive supported batch_size only for the documented prediction route and assess output shape/storage separately. Reduce the requested query set explicitly if scientifically acceptable; use training/history controls only for their own documented purpose.

**Scientific boundary:** This is not a training minibatch, global memory cap or universal streaming API. Stateful/coupled-query behavior can invalidate equivalence between chunked and unchunked evaluation.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)
- [Repository resource — docs/pinn_diagnostics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/pinn_diagnostics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q088", "category": "Memory and Performance", "priority": "P1", "question_sha256": "60d81843c830cb34f9398de13bfae80098e2f63440ef8338ce97a51a5c4f7e86"} -->
<a name="q088"></a>

## Q088

**Question:** Which histories retain earliest entries and which retain the most recent?

**Short answer:** PINN and inference capacity-limited diagnostic histories retain earliest entries; learned-dynamics and surrogate histories retain rolling more-recent entries.

**Explanation:** PINNHistory defaults to stride=10, capacity=1000; PINN training history is opt-in, with log_every=10 and history_capacity=1000. Inference defaults history_stride=10 and history_capacity=1000. These first-entry histories record truncation after capacity. Learned-dynamics/surrogate history_limit defaults to 100, supports 1 through 10000, and drops the earliest retained value as new values arrive.

**Practical action:** Choose the documented stride/capacity or history_limit for the actual training family and inspect truncation before interpreting a loss curve. If late PINN/inference behavior matters, do not assume capacity overflow automatically replaces old entries.

**Scientific boundary:** History limits cover diagnostic records, not optimizer, AD, model, training batch or native solution storage. Disabling history is not a universal no-storage training mode.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Repository resource — docs/scientific_ml.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/scientific_ml.md)
- [Repository resource — docs/parameter_inference.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/parameter_inference.md)
- [Repository resource — docs/learned_dynamics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/learned_dynamics.md)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q089", "category": "Memory and Performance", "priority": "P1", "question_sha256": "9a78890228cd79b791fad7478093c1213e62da87986035543ed7d759ba426e27"} -->
<a name="q089"></a>

## Q089

**Question:** When does summary_only avoid output arrays, and are public iterators one-pass?

**Short answer:** summary_only can omit specific result arrays, but it is not a universal one-pass public iterator or streaming guarantee.

**Explanation:** With summary_only=true, field_errors omits the absolute-error array and heat_residual omits residual values. Points/inputs and metadata may remain retained. Private deterministic reducers can reevaluate calculations; sampled_summary materializes non-array public iterables once to avoid double-consuming stateful or RNG sources and has no public memory keyword.

**Practical action:** Use summary_only when the documented summary suffices, and account separately for retained inputs/points. Keep predictor behavior deterministic when repeated diagnostic evaluation is possible, and inspect what the result actually retains.

**Scientific boundary:** Omitting output arrays does not release all source storage or certify a peak-memory bound. Sampled RMS/L2 summaries remain unweighted finite-sample evidence, not continuum error certificates.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Repository resource — docs/pinn_diagnostics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/pinn_diagnostics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q090", "category": "Memory and Performance", "priority": "P1", "question_sha256": "b835333d5a3aea3e097e8341aa2bccacd92575063df3325a78e9fbb5ea3b12df"} -->
<a name="q090"></a>

## Q090

**Question:** What provenance is intentionally omitted with source_retention=:descriptor?

**Short answer:** source_retention=:descriptor intentionally omits heavy source/provenance content instead of retaining a full trajectory representation.

**Explanation:** The trajectory-to-dataset default :retained can keep or deepcopy native source data through dataset ownership policy. The opt-in descriptor route stores a bounded detached origin and declares omissions: source object, context, original domain, unselected labels and selector callable. Selected numeric data and schema are still copied, and caller family/reference metadata can retain other content.

**Practical action:** Choose descriptor retention only when those omissions are acceptable, and separately preserve original scientific inputs needed for later reproduction. Inspect declared omissions and retain truthful reference/error and selector descriptions; use the capstone for the schema workflow.

**Scientific boundary:** The descriptor is not compression, a complete archived experiment or a persistent hash. It cannot reconstruct omitted data/closures, infer ancestry or guarantee that arbitrary caller metadata is small.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
