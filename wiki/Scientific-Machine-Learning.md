# Scientific Machine Learning

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q056 — Does low PINN loss establish PDE correctness?](Scientific-Machine-Learning#user-content-q056)
- [Q057 — Why does the learning model require explicit RNG provenance?](Scientific-Machine-Learning#user-content-q057)
- [Q058 — Are learned corrections symbolic discoveries?](Scientific-Machine-Learning#user-content-q058)
- [Q059 — What does the one-step oscillator learning example demonstrate?](Scientific-Machine-Learning#user-content-q059)
- [Q060 — Is local sensitivity the same as global identifiability?](Scientific-Machine-Learning#user-content-q060)

<!-- aml-faq: {"id": "Q056", "category": "Scientific Machine Learning", "priority": "P1", "question_sha256": "5cc233deabf635549c1c92b008830a7d8655b8b160a6aaa8613391bbafae31c9"} -->
<a name="q056"></a>

## Q056

**Question:** Does low PINN loss establish PDE correctness?

**Short answer:** No. Low PINN training loss is optimizer evidence, not a proof that the PDE solution is correct.

**Explanation:** Loss reflects a specified network, discretization, sampled points and component weighting. Residual diagnostics describe sampled equations and boundary/initial quantities under their own contracts; they are not continuum norms or certified solution-error bounds.

**Practical action:** Inspect loss components and explicit coordinate order, then compare predictions with an independent reference on justified diagnostic points. Read the PINN diagnostic contracts and check extension activation before expecting trained-result recomputation.

**Scientific boundary:** Optimizer termination, small residuals and sampled agreement do not prove global PDE correctness, uniqueness, stability or generalization. This optional route is experimental.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — docs/pinn_diagnostics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/pinn_diagnostics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q057", "category": "Scientific Machine Learning", "priority": "P1", "question_sha256": "3d9543c23d6ed2c4b6386c944954e3c14128a34f9ff675d7b275d3851e233b3d"} -->
<a name="q057"></a>

## Q057

**Question:** Why does the learning model require explicit RNG provenance?

**Short answer:** learning_model requires both an explicit RNG and rng_provenance because initialization and its recorded origin are different inputs.

**Explanation:** The experimental learning contract cannot infer a seed from arbitrary RNG state. Dataset RNG metadata describes the data; it does not automatically describe network setup or later stochastic operations.

**Practical action:** Supply a reproducible RNG choice and truthful initialization provenance, alongside the required normalization choice. Record dependency versions, data splits, model, optimizer and AD choices when comparing runs.

**Scientific boundary:** A recorded seed does not guarantee bitwise cross-platform reproduction, deterministic arbitrary stateful networks or statistical independence. No automatic backend or RNG recovery is implied.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — docs/surrogates.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/surrogates.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q058", "category": "Scientific Machine Learning", "priority": "P1", "question_sha256": "2d2980c5b523e0354e20bac0c926dc18a341eb0a5c9ab5075b77a2e09ab10dac"} -->
<a name="q058"></a>

## Q058

**Question:** Are learned corrections symbolic discoveries?

**Short answer:** No. A learned UDE correction is a numerical model component, not a discovered symbolic law.

**Explanation:** UDEProblem adds a caller-defined learned correction to known dynamics under explicit parameter/network/layout assumptions. Training optimizes a finite objective; it does not convert network weights into an established analytical identity.

**Practical action:** Compare the correction and resulting trajectories against declared references on relevant states/times. Keep known physics, learned component and extrapolation scope separately labeled; use the learned-dynamics contracts for the supported construction.

**Scientific boundary:** Low objective value does not prove identifiability, conservation or validity outside the data. Symbolic discovery is an UNAVAILABLE_CAPABILITY in this route, not a failed training result.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — docs/learned_dynamics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/learned_dynamics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q059", "category": "Scientific Machine Learning", "priority": "P1", "question_sha256": "949c7b81ca6a6cff7b2cb40f2a97ccb2932b3461e08a29a750ae7aca0ed3f00c"} -->
<a name="q059"></a>

## Q059

**Question:** What does the one-step oscillator learning example demonstrate?

**Short answer:** The one-step example demonstrates an end-to-end experimental surrogate pipeline, not an accurate oscillator replacement.

**Explanation:** It assembles explicit amplitude cases, training/interpolation/extrapolation roles and numerical references, initializes one affine coordinate network and performs one Adam step. Analytical-oracle discrepancies remain separate from numerical-target discrepancies; the comparison bound is deliberately loose.

**Practical action:** Read the existing one_system_learning.jl and its documented operators environment before choosing to run optional work. Inspect the declared cases, seed, splits and reference context rather than treating a completed pipeline as trained accuracy.

**Scientific boundary:** Its previous bounded execution is HISTORICAL_VERIFICATION, not rerun here. One optimizer step does not establish convergence, generalization, discovered mechanics or a physically valid surrogate.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — docs/m10d_one_system_many_methods.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/m10d_one_system_many_methods.md)
- [Repository resource — examples/integration/one_system_learning.jl](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/examples/integration/one_system_learning.jl)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q060", "category": "Scientific Machine Learning", "priority": "P1", "question_sha256": "78553020e157e74d47b73482a5e6ed373ffbf5411d5b4ff01a89c16de1be8aa3"} -->
<a name="q060"></a>

## Q060

**Question:** Is local sensitivity the same as global identifiability?

**Short answer:** No. local_sensitivity measures local observation-response structure near the supplied parameters, not global identifiability.

**Explanation:** Its Jacobian and weighted SVD/rank depend on the observation design, parameter scales and tolerances. Collinearity is a local diagnostic; rank deficiency, infinite condition measures or undefined zero-column cosines have their documented meanings.

**Practical action:** Inspect parameter/observation order, scales and rank thresholds. Compare scientifically justified designs or parameter neighborhoods, and use separate structural/statistical analysis when global identifiability or posterior uncertainty is required.

**Scientific boundary:** Local rank cannot establish uniqueness over the whole parameter domain or posterior correlations. Sensitivity evidence is heuristic and does not certify inference accuracy.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Repository resource — docs/parameter_inference.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/parameter_inference.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
