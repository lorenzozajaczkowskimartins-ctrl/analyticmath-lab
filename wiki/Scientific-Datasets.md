# Scientific Datasets

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q051 — Which dataset fields must I declare explicitly?](Scientific-Datasets#user-content-q051)
- [Q052 — Why must scalar targets be reshaped for scaling?](Scientific-Datasets#user-content-q052)
- [Q053 — How do I avoid train/validation normalization leakage?](Scientific-Datasets#user-content-q053)
- [Q054 — Does a reference kind label certify its quality?](Scientific-Datasets#user-content-q054)
- [Q055 — Does a numerical trajectory become analytical ground truth when converted?](Scientific-Datasets#user-content-q055)

<!-- aml-faq: {"id": "Q051", "category": "Scientific Datasets", "priority": "P1", "question_sha256": "966d3eadfd4be805f790f5558b75de30ce09c61556a3acac8854cc4506b1430e"} -->
<a name="q051"></a>

## Q051

**Question:** Which dataset fields must I declare explicitly?

**Short answer:** Declare sample identity, ordered input/query data and split, then the dataset kind, family, ordered names, domain, reference, units, grid and RNG description.

**Explanation:** ScientificSample stores coordinate rows by query columns and scalar target values. ScientificDataset distinguishes surrogate and operator inputs; fixed sensors are relevant to the operator route. These experimental constructors enforce stated shape/schema prerequisites, not the truth of scientific declarations.

**Practical action:** Follow the capstone schema and dataset contracts, using unique IDs and supported explicit splits. Numerical references must record solver, algorithm, tolerances, grid, span, parameters and unknown or justified estimated error; do not invent analytical truth.

**Scientific boundary:** Domain bounds are descriptive, not a validity certificate. A parameter hidden in an ODE closure is a caller assertion unless genuinely recorded; no split, reference quality or physical identity is automatically inferred.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q052", "category": "Scientific Datasets", "priority": "P1", "question_sha256": "5aba84ed26aca2dc65b725a5735ee532d372f076f0a32671e9883cf45d04b9a9"} -->
<a name="q052"></a>

## Q052

**Question:** Why must scalar targets be reshaped for scaling?

**Short answer:** Output scaling expects feature rows, so many scalar query targets must be represented as one row with one column per query.

**Explanation:** A sample target vector indexes scalar values across queries, whereas transform accepts a vector as one feature vector or a matrix as feature rows by observations. It does not infer which axis means queries from your intent.

**Practical action:** Use the documented outputs scaling and provide a one-row matrix for a batch of scalar targets; preserve query order. Inspect the fitted feature count and qualify AnalyticMathLab.transform if another imported library exports the same name.

**Scientific boundary:** Reshaping changes representation, not physical units, reference quality or precision. A shape that passes validation does not establish the correct coordinate/target correspondence.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q053", "category": "Scientific Datasets", "priority": "P1", "question_sha256": "0120cd7e2818353259cfb7f09b607f0f5cd4d25a269a78dd617fffcfda8884bb"} -->
<a name="q053"></a>

## Q053

**Question:** How do I avoid train/validation normalization leakage?

**Short answer:** Assign scientifically meaningful splits before fitting scaling; fit_scaling uses only samples marked as training.

**Explanation:** The affine scaler records the training IDs and fits training extrema, not all validation/extrapolation data. A wrongly assigned split still leaks information even though the implementation obeys its contract.

**Practical action:** Check sample IDs and split labels, fit inputs/coordinates/outputs on the assembled training dataset, and reuse those fitted scales for held-out queries. Do not refit on a validation set simply to improve reported errors.

**Scientific boundary:** Train-only normalization does not guarantee independent splits, prevent every form of leakage or prove generalization. Caller-defined roles and reference independence require separate justification.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q054", "category": "Scientific Datasets", "priority": "P1", "question_sha256": "bac3c85a5d1079005ac21f6f706e1b873dad427f45ae1753e7818e2162f891fa"} -->
<a name="q054"></a>

## Q054

**Question:** Does a reference kind label certify its quality?

**Short answer:** No. A reference kind labels the declared source of targets; it is not scientific certification.

**Explanation:** Dataset validation checks supported descriptions and required context. Metadata can make a reference available for inspection without proving that a callable is analytical, independent or accurate. Numerical solver settings are not certified error bounds.

**Practical action:** Inspect the reference description, origin, numerical controls and error declaration. Compare against an independently justified analytical oracle when possible, keeping reference discrepancy separate from model error and uncertainty.

**Scientific boundary:** Unknown reference error is not zero. Changing a kind label cannot promote numerical targets to analytical truth or create recorded ancestry.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q055", "category": "Scientific Datasets", "priority": "P1", "question_sha256": "84e76a7b97ac0cd8f8193c24874322a0c84c7da438be0ef01231cca64a88695e"} -->
<a name="q055"></a>

## Q055

**Question:** Does a numerical trajectory become analytical ground truth when converted?

**Short answer:** No. Converting a numerical trajectory to ScientificDataset preserves numerical target meaning.

**Explanation:** The bridge selects stored times and an explicitly chosen scalar observable under a schema. It checks source completion and retains numerical reference context; it does not derive an analytical solution or interpolate new truth.

**Practical action:** Use the capstone to record solver controls, state/parameter ordering and selected quantity. Keep the independent modal oracle as a separate reference, and state whether numerical error is unknown or estimated with a justified method.

**Scientific boundary:** Conversion, copying or descriptor retention cannot improve epistemic strength. An analytical oracle for the same model need not share recorded derivation ancestry with the trajectory.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
