# Mechanics and Dynamics

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q031 — Which coordinate and momentum order does AML use?](Mechanics-and-Dynamics#user-content-q031)
- [Q032 — When can AML establish a Legendre transform?](Mechanics-and-Dynamics#user-content-q032)
- [Q033 — Does sampled energy drift prove conservation?](Mechanics-and-Dynamics#user-content-q033)
- [Q034 — Why do imaginary eigenvalues not decide nonlinear stability?](Mechanics-and-Dynamics#user-content-q034)
- [Q035 — How do I compare analytical and numerical descriptions of one system?](Mechanics-and-Dynamics#user-content-q035)

<!-- aml-faq: {"id": "Q031", "category": "Mechanics and Dynamics", "priority": "P1", "question_sha256": "154145512b7fd8fd10f69e23266880a649e847dfa5cd1aec0447e1795ec84fc7"} -->
<a name="q031"></a>

## Q031

**Question:** Which coordinate and momentum order does AML use?

**Short answer:** The declared variable order is part of the model: Lagrangian state order uses coordinates then velocities; canonical Hamiltonian order uses coordinates then momenta.

**Explanation:** Canonical momentum follows from the Lagrangian and may involve a mass matrix or a more general relation. It is not silently identical to generalized velocity.

**Practical action:** Keep coordinate/velocity/momentum names ordered and consistent across energies, derivatives, transformations and numerical initial states. Follow the mechanics tutorial before comparing Hamiltonian and Lagrangian states.

**Scientific boundary:** Names and matching dimensions do not establish a valid physical constitutive relation or unit conversion. Raw constructors do not certify supplied equations.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/mechanics.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q032", "category": "Mechanics and Dynamics", "priority": "P1", "question_sha256": "0d7498a3b67f980e88b33e20298528f73d9d7ed6afd160aefefcd0eeeec99fba"} -->
<a name="q032"></a>

## Q032

**Question:** When can AML establish a Legendre transform?

**Short answer:** The supported route establishes a verified regular affine momentum–velocity inversion with the documented conservative prerequisites.

**Explanation:** It is not a universal nonlinear inverse or a constrained/dissipative-to-conservative transformation. Unsupported scientific inversion can return an unknown PropertyResult rather than fabricate a Hamiltonian.

**Practical action:** Analyze the declared Lagrangian, inspect regularity and force/Rayleigh assumptions, and inspect the Legendre result status before using its HamiltonianAnalysis value. Retain original-domain restrictions and canonical ordering.

**Scientific boundary:** Nonzero assumptions are not positivity assumptions. An unknown transformation is not proof that no mathematical transformation exists outside the supported class.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/mechanics.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q033", "category": "Mechanics and Dynamics", "priority": "P1", "question_sha256": "fa0974db3f60239f792c795d7c74905ea53f15114c54e134754aa9cd8a7464fb"} -->
<a name="q033"></a>

## Q033

**Question:** Does sampled energy drift prove conservation?

**Short answer:** No. Small sampled energy drift is useful numerical evidence, not a conservation proof.

**Explanation:** The bridge evaluates energy along a matching stored trajectory and records model/source compatibility. Samples can miss behavior, and numerical integration can introduce drift even when a symbolic conservation claim is established under its own assumptions.

**Practical action:** Inspect the source match, saved times and drift metric. Compare a declared analytical conservation identity with numerical drift as separate evidence, retaining solver controls and the tested interval.

**Scientific boundary:** A flat plotted curve or small drift does not certify exact conservation, global accuracy or behavior outside the sampled interval.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q034", "category": "Mechanics and Dynamics", "priority": "P1", "question_sha256": "540e1de201376153f2279e4a4777ff06877bf91e41afc91d04bc7f2542599240"} -->
<a name="q034"></a>

## Q034

**Question:** Why do imaginary eigenvalues not decide nonlinear stability?

**Short answer:** Purely imaginary eigenvalues generally leave nonlinear stability undecided.

**Explanation:** A Jacobian describes local first-order behavior. Nonhyperbolic nonlinear terms can matter; AML keeps its scoped exact/heuristic/unknown stability evidence separate from a diagnostic Float64 eigenspectrum. Supported special affine cases are not a blanket rule for nonlinear systems.

**Practical action:** Read the local stability result and its assumptions, not only eigenvalue signs. State equilibrium/domain validity and use an independently justified nonlinear argument when one is required.

**Scientific boundary:** A local spectral observation does not establish a global basin, periodic orbit or nonlinear center. Unknown is not instability or stability.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q035", "category": "Mechanics and Dynamics", "priority": "P1", "question_sha256": "f6eced31e43c5692c7ba7021584ab8179ce2e9cf24863192750ac074a6741212"} -->
<a name="q035"></a>

## Q035

**Question:** How do I compare analytical and numerical descriptions of one system?

**Short answer:** Use one declared model, preserve variable/unit ordering, and compare each method against an independently justified reference.

**Explanation:** The coupled-oscillator capstone connects potential derivatives, mechanics, linearization, modes, Hamiltonian formulation, ODE samples and stored data. Its analytical state oracle and its numerical source ancestry are separate notions.

**Practical action:** Follow the guided capstone and unchanged canonical script. Check model parameters, state ordering, comparison metric/tolerance and result provenance before calling two descriptions consistent.

**Scientific boundary:** Historical M10D.6C comparisons are not new executions here. Same-model agreement does not imply recorded common ancestry or global certification.

**Related documentation:**

- [Technical reference source — mechanics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/mechanics.md)
- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
