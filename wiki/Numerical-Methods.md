# Numerical Methods

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q021 — Are derivative comparison errors certified bounds?](Numerical-Methods#user-content-q021)
- [Q022 — Why can a smaller finite-difference step be worse?](Numerical-Methods#user-content-q022)
- [Q023 — What does missing relative error mean at a zero reference?](Numerical-Methods#user-content-q023)
- [Q024 — Why is observed convergence order missing?](Numerical-Methods#user-content-q024)
- [Q025 — Which tolerance accepts a stationary candidate?](Numerical-Methods#user-content-q025)

<!-- aml-faq: {"id": "Q021", "category": "Numerical Methods", "priority": "P1", "question_sha256": "b17f7f5ecd4ad1230c681e9748f9d81097ffceeb06b179ac9d5efbb0c5ca0725"} -->
<a name="q021"></a>

## Q021

**Question:** Are derivative comparison errors certified bounds?

**Short answer:** The reported comparisons are discrepancies relative to a specified derivative reference, not certified mathematical error bounds.

**Explanation:** Symbolic, automatic-differentiation and finite-difference routes can agree or disagree under different numerical assumptions. A reference value may itself have approximation or evaluation limitations.

**Practical action:** Inspect which reference/method was used and the absolute/relative discrepancies. For verification, choose a function with an independently derived derivative and compare at a valid point, as in the calculus tutorial.

**Scientific boundary:** Agreement is evidence for that experiment, not proof of global accuracy. A discrepancy should not be presented as an uncertainty estimate or universal tolerance guarantee.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q022", "category": "Numerical Methods", "priority": "P1", "question_sha256": "478903083e938583d3e10532c1f0ad73ba515c021228047eab5751e2cc69cda9"} -->
<a name="q022"></a>

## Q022

**Question:** Why can a smaller finite-difference step be worse?

**Short answer:** A smaller finite-difference step can amplify roundoff or make the displaced floating-point points indistinguishable.

**Explanation:** Truncation error can improve as the step shrinks while subtraction cancellation worsens. derivative_convergence samples a finite Float64 grid; some step/point combinations are refused rather than pretending the difference remains informative.

**Practical action:** Inspect the sampled discrepancy curve and the stored best sample, retaining the tested range and method. Use a smooth stencil, representable displacements and the declared hmin/hmax controls; do not assume the smallest sample is best.

**Scientific boundary:** The sampled minimum is not a globally optimal step or a certified true-error estimate. This experiment is not arbitrary-precision differentiation.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q023", "category": "Numerical Methods", "priority": "P1", "question_sha256": "3eacedfcc4f89e23c0291a0010e9246f634c9a84417042ee49fe8762150d60aa"} -->
<a name="q023"></a>

## Q023

**Question:** What does missing relative error mean at a zero reference?

**Short answer:** Missing relative discrepancy means that normalization was unavailable, not that the discrepancy is zero.

**Explanation:** At a zero reference, dividing by its magnitude is undefined; the convergence route also withholds relative output when its arithmetic cannot be represented safely. Absolute discrepancy can still be meaningful.

**Practical action:** Report the absolute discrepancy and the reason the relative result is nothing. If a different normalization is scientifically needed, state and justify it explicitly rather than silently replacing the missing value.

**Scientific boundary:** A chosen scale does not become statistical uncertainty or a certified bound. Never replace unavailable relative evidence with zero.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q024", "category": "Numerical Methods", "priority": "P1", "question_sha256": "e393f54757c2ea22b6cbe77a05c18d9d72c0844647ee583471facdffb56d6b9d"} -->
<a name="q024"></a>

## Q024

**Question:** Why is observed convergence order missing?

**Short answer:** The sampled grid may not contain the supported stable-slope window needed for an observed order.

**Explanation:** The convergence implementation uses an early stable positive-slope window before a plateau, increase or zero discrepancy; it does not search every later regime or infer order from the method name alone.

**Practical action:** Inspect the stored steps, discrepancies and notes. Change the declared sampling range only when a smooth, representable stencil and an independent derivative reference justify the experiment.

**Scientific boundary:** Missing order is not order zero, and a sampled observed order is not an asymptotic proof or universal software guarantee.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q025", "category": "Numerical Methods", "priority": "P1", "question_sha256": "5eab1e6c87a67122a60b84c1543c36133b37a46412a1ae851d2daf1fe76747c0"} -->
<a name="q025"></a>

## Q025

**Question:** Which tolerance accepts a stationary candidate?

**Short answer:** Numerical candidate acceptance uses the declared absolute tolerance plus relative tolerance times the caller-provided residual scale.

**Explanation:** The residual threshold is residual_tolerance + residual_rtol * residual_scale. For scalar search the check concerns the derivative residual, not the distance to a true stationary point; field/vector routes retain their own residual conventions.

**Practical action:** Inspect the recorded effective threshold and rejected candidates. Choose finite supported controls and a positive residual scale in the appropriate residual units, then consult the scalar/field overload rather than assuming all tolerances mean the same thing.

**Scientific boundary:** Residual acceptance is not a certified location bound, completeness proof or classification theorem. Classification tolerances are distinct from search acceptance.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
