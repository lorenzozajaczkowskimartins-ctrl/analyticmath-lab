# Linear Algebra

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q011 — Does AML provide general-purpose matrix analysis?](Linear-Algebra#user-content-q011)
- [Q012 — Why does normal_modes take stiffness before mass?](Linear-Algebra#user-content-q012)
- [Q013 — Does sparse matrix input imply a sparse eigensolver?](Linear-Algebra#user-content-q013)
- [Q014 — What do zero, negative and degenerate modes mean?](Linear-Algebra#user-content-q014)
- [Q015 — Does a Hessian at a snapshot establish equilibrium?](Linear-Algebra#user-content-q015)

<!-- aml-faq: {"id": "Q011", "category": "Linear Algebra", "priority": "P1", "question_sha256": "55cfe0f025407b50c7c3587e2d6a832b69f50439ec207b1f0ba05b86ac97701c"} -->
<a name="q011"></a>

## Q011

**Question:** Does AML provide general-purpose matrix analysis?

**Short answer:** AML offers specific matrix-based scientific operations, not a general-purpose matrix-analysis service.

**Explanation:** The direct normal_modes route solves the mass/stiffness generalized eigenproblem under its stated shape, symmetry, positivity, precision and resource contracts. Other matrices do not acquire physical meaning merely by being accepted as arrays.

**Practical action:** Use Julia LinearAlgebra or another appropriate numerical library for general matrix work. Use AML normal modes when K and M actually describe the declared small linear mechanical model.

**Scientific boundary:** A matrix eigenspectrum is not automatically a validated mechanical model or equilibrium certificate. AML has no generic partial-spectrum or matrix-free public substitute.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q012", "category": "Linear Algebra", "priority": "P1", "question_sha256": "932bc5b081f478185c0dd8f40bfba284e3e48583bff91c4eafa4692af0eb4a22"} -->
<a name="q012"></a>

## Q012

**Question:** Why does normal_modes take stiffness before mass?

**Short answer:** The supported positional order is stiffness K first, mass M second.

**Explanation:** For constant coefficients, the normal-mode relation is K a = omega squared M a. The returned mode normalization uses the mass matrix, so exchanging the arguments changes the problem rather than merely changing notation.

**Practical action:** Keep coordinate ordering consistent across K, M and equilibrium metadata, and follow the normal-modes tutorial. Inspect squared frequencies, classifications and mass normalization together.

**Scientific boundary:** Generalized mass normalization need not be ordinary Euclidean normalization. Correct argument order alone does not establish that the matrices come from a valid physical linearization.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q013", "category": "Linear Algebra", "priority": "P1", "question_sha256": "fe10059f7193732391e2582c8e6be1fbafa6230f267f320fe6a449e544b95973"} -->
<a name="q013"></a>

## Q013

**Question:** Does sparse matrix input imply a sparse eigensolver?

**Short answer:** No. Sparse representation does not select a sparse eigensolver in this route.

**Explanation:** Direct normal_modes performs dense Float64 full-spectrum work and uses its scoped byte-estimate preflight. Upstream mechanical or snapshot adapters can allocate before that guard.

**Practical action:** Check the actual matrix size and direct-method budget before choosing the route. If only a few modes are needed at large scale, use an appropriate external solver; clearly record that this is outside AML public partial-spectrum functionality.

**Scientific boundary:** A sparse input is not a memory or peak-RSS guarantee. Do not treat maintainer chain/scaling experiments as a generic supported alternative.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q014", "category": "Linear Algebra", "priority": "P1", "question_sha256": "b323f4470af11df775f7672d275fc17dc539b9aa40068d0a114ffd55378e50b0"} -->
<a name="q014"></a>

## Q014

**Question:** What do zero, negative and degenerate modes mean?

**Short answer:** Zero, negative and degenerate squared frequencies describe different local modal situations, subject to stored tolerance-based classification.

**Explanation:** Zero modes can indicate neutral directions in the declared linear model. Negative squared frequencies indicate an unstable linear direction and can leave real frequencies unavailable. Degenerate eigenspaces have nonunique bases.

**Practical action:** Inspect the stored eigenvalues, frequency availability and classifications, not just mode-vector columns. Preserve mass normalization and compare invariant subspaces when degeneracy makes individual vectors nonunique.

**Scientific boundary:** Tolerance-classified zeros are not exact identities, and local linear modes do not prove global nonlinear stability. An unavailable real frequency is not a zero frequency.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q015", "category": "Linear Algebra", "priority": "P1", "question_sha256": "62ebb263b6207d3d2cbbfd92e0ec34743b94d3d2085d1ba02e4746d0379059d5"} -->
<a name="q015"></a>

## Q015

**Question:** Does a Hessian at a snapshot establish equilibrium?

**Short answer:** No. A supplied Hessian at a snapshot does not establish mechanical equilibrium.

**Explanation:** Curvature information and force balance are different prerequisites. The atomistic adapter consumes caller-supplied coefficients and masses with explicit coordinate/unit conventions; it does not discover a force field or prove the configuration is stationary.

**Practical action:** Check equilibrium independently under your declared interaction model, then verify Hessian/mass ordering and scale conventions before interpreting modes. Use the atomistics and normal-modes tutorials for the supported small workflows.

**Scientific boundary:** A configuration or accepted Hessian is not a validated equilibrium. Unsupported or unstable mode evidence must not be promoted to a physical certification.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Executable tutorial — atomistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/atomistics.md)
- [Executable tutorial — normal-modes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/normal-modes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
