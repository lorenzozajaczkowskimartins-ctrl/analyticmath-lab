# Units and Precision

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q061 — Does a unit string convert numerical data?](Units-and-Precision#user-content-q061)
- [Q062 — Can compatible Unitful lengths be combined in statistics?](Units-and-Precision#user-content-q062)
- [Q063 — Why is unknown unit metadata not dimensionless?](Units-and-Precision#user-content-q063)
- [Q064 — Which paths really preserve BigFloat precision?](Units-and-Precision#user-content-q064)
- [Q065 — Are complex inputs or integers supported everywhere?](Units-and-Precision#user-content-q065)

<!-- aml-faq: {"id": "Q061", "category": "Units and Precision", "priority": "P0", "question_sha256": "b62ff7fbf667fed43f7a80d8341943a9f70f03160a4e3337f401b6417e920b7d"} -->
<a name="q061"></a>

## Q061

**Question:** Does a unit string convert numerical data?

**Short answer:** No. A unit string records a description; it does not convert or nondimensionalize numeric arrays.

**Explanation:** Dataset and other metadata labels are caller declarations. Supported Unitful arithmetic carries dimensions where that operation permits quantities, while checked Float64 sample/ODE/modal boundaries have distinct contracts.

**Practical action:** Convert or nondimensionalize data deliberately using a justified upstream unit workflow before entering a numeric-only route. Keep names, units and scales aligned with every selected coordinate and target.

**Scientific boundary:** Changing a label cannot make incompatible values comparable or turn unknown units into dimensionless ones. Automatic unit conversion is not a general AML capability.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q062", "category": "Units and Precision", "priority": "P0", "question_sha256": "7fe70f8a17f74c707c83454b015cfe62c46c93b57332b2c68d99ab9cbf6aa482"} -->
<a name="q062"></a>

## Q062

**Question:** Can compatible Unitful lengths be combined in statistics?

**Short answer:** Yes, supported real statistical observations can combine compatible Unitful lengths; incompatible dimensions are not silently stripped.

**Explanation:** Compatible quantities follow their arithmetic units, including squared units for variance. Generic moment summaries do not infer physical meaning from plain numbers; mixed known and unknown-unit observations can be rejected.

**Practical action:** Keep a consistently dimensioned scalar series and inspect its mean, variance and available units. Use the trajectory statistics contracts and retain associated times; declare Unitful directly in a consumer that imports it.

**Scientific boundary:** Unit compatibility does not prove correct calibration, stationarity or uncertainty. This statistical support does not imply all learning, sample or ODE APIs accept dimensioned inputs.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q063", "category": "Units and Precision", "priority": "P0", "question_sha256": "4ab8361afe4b9ffe669f6d59856a25c9cf1e7c1587a53fb4a422186351583d6c"} -->
<a name="q063"></a>

## Q063

**Question:** Why is unknown unit metadata not dimensionless?

**Short answer:** Unknown units mean missing dimensional knowledge, not an established dimensionless quantity.

**Explanation:** Plain numeric values can represent scaled positions, energies or genuine dimensionless numbers. Metadata inspection and comparison retain that distinction rather than assigning physical meaning from storage type.

**Practical action:** Inspect original measurement/model conventions and supply truthful units or an explicit dimensionless declaration where supported. Leave compatibility unknown if the needed dimensional context cannot be justified.

**Scientific boundary:** A label is a USER_ASSUMPTION, not a conversion or proof. Equal arrays with unknown units are not automatically scientifically comparable.

**Related documentation:**

- [Technical reference source — comparison](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/comparison.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q064", "category": "Units and Precision", "priority": "P0", "question_sha256": "b8ef7d6a65d1a91a4012d9c853b7796eba6532803f6eedd90a36f7d868ae6c17"} -->
<a name="q064"></a>

## Q064

**Question:** Which paths really preserve BigFloat precision?

**Short answer:** Supported generic scalar expression evaluation can preserve BigFloat arithmetic; this is not a library-wide high-precision guarantee.

**Explanation:** The generated scalar callable follows supported operations and input types. Public trajectories, ScientificSample/scaling, normal modes and learning have checked Float64 boundaries. sampled_summary also promotes supported real samples, but derivative_convergence uses a Float64 sampling grid.

**Practical action:** Read the exact overload contract and inspect resulting types at each stage before claiming precision preservation. Construct high-precision inputs without first rounding through machine floats; choose a separate suitable workflow when the documented route converts to Float64.

**Scientific boundary:** BigFloat at one stage does not recover precision already lost in data/constants or converted downstream. Checked representability prevents specified failures, not all rounding or certified numerical accuracy.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [README — installation and first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q065", "category": "Units and Precision", "priority": "P0", "question_sha256": "dc4da8fb5af2804f6039a2693fbd185c8e9f1909fd2cc9f9b7e05825052e1125"} -->
<a name="q065"></a>

## Q065

**Question:** Are complex inputs or integers supported everywhere?

**Short answer:** No. Numeric type support is operation-specific; scalar arithmetic support does not imply universal complex or integer support.

**Explanation:** Supported symbolic polynomial callables can evaluate generic numeric types, while real-domain multivariate/statistical operations require real data. Normal modes do not support arbitrary complex coefficients. Integer moments use floating arithmetic, and machine-integer evaluation can overflow.

**Practical action:** Check the input and numerical limitations of the intended overload before converting data. Use a supported real representation only when scientifically justified, and inspect output types and unknown/refusal notes rather than silently dropping imaginary parts.

**Scientific boundary:** Accepted integers do not establish exact arithmetic, and accepted complex scalar values do not certify a real-domain interpretation. Do not extrapolate one overload to the entire package.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [README — installation and first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
