# Trajectories

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q036 — How do I select a stored component without guessing physical identity?](Trajectories#user-content-q036)
- [Q037 — Is saved sample spacing the integrator time step?](Trajectories#user-content-q037)
- [Q038 — Are stored trajectory frames copied or lazy?](Trajectories#user-content-q038)
- [Q039 — Why does comparing two stored results refuse missing context?](Trajectories#user-content-q039)
- [Q040 — Does diagnose recompute missing analyses?](Trajectories#user-content-q040)

<!-- aml-faq: {"id": "Q036", "category": "Trajectories", "priority": "P1", "question_sha256": "6a08f4993e170b39cb76a4d0f842769f43b1ead02169f465df97662ff248fbd4"} -->
<a name="q036"></a>

## Q036

**Question:** How do I select a stored component without guessing physical identity?

**Short answer:** Choose a component index, a unique recorded label or an explicit documented observable selector.

**Explanation:** Generic state coordinates do not tell AML which variable is position, velocity, energy or particle identity. The stored trajectory adapter preserves the selection context supplied through its public contract.

**Practical action:** Inspect the path labels and actual saved state order, then select the observable explicitly with observable_series. Verify the resulting name, samples and times against your intended quantity.

**Scientific boundary:** A matching index or label is not an inferred physical identity or unit certificate. Do not silently permute coordinates to make datasets agree.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q037", "category": "Trajectories", "priority": "P1", "question_sha256": "e0012ec7f00e68607e7ea06105365f05620a653a832a84129156aeb2572b5c3f"} -->
<a name="q037"></a>

## Q037

**Question:** Is saved sample spacing the integrator time step?

**Short answer:** No. Saved sample spacing describes stored observations, not the solver internal timestep.

**Explanation:** Adaptive integration and requested observation stops can coexist in retained history. Sampling metadata describes those actual saved times; it does not reconstruct every internal step or infer physical seconds from an index.

**Practical action:** Inspect saved times and sampling_info, and check regularity before using correlation/transport routines that require it. Preserve the declared clock when selecting an observable.

**Scientific boundary:** A regular stored grid is not proof of fixed-step integration or statistical independence. Unknown time units are not automatically physical time.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q038", "category": "Trajectories", "priority": "P1", "question_sha256": "a4113aa6b6c86e111f100241742d9cabb20ef77df99c919ae380ae0d6795375a"} -->
<a name="q038"></a>

## Q038

**Question:** Are stored trajectory frames copied or lazy?

**Short answer:** AtomisticTrajectoryView is a lazy indexed view; copying and backing mutation depend on the declared adapter/ownership policy.

**Explanation:** The view retains its getframe closure, times and provenance rather than collecting all history by default. Native backing changes can remain visible; other scientific records have different copy contracts.

**Practical action:** Read the view and snapshot ownership entries before retaining frames or changing source arrays. Take deliberate snapshots/copies when a fixed analysis dataset is needed, and verify particle/time ordering.

**Scientific boundary:** A read-only view convention is not deep immutability. Laziness does not guarantee no allocation by frame conversion or downstream analysis.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q039", "category": "Trajectories", "priority": "P1", "question_sha256": "56bb6ba08006674bb61551aafd2884aa3e741cff56df9a1ac42c8a15fcb45ebf"} -->
<a name="q039"></a>

## Q039

**Question:** Why does comparing two stored results refuse missing context?

**Short answer:** Comparison can withhold evidence when required units, identity, selection or time-window context is missing.

**Explanation:** Equal array sizes or values do not establish scientific comparability. ComparisonInput provides an explicit context wrapper; the comparison does not reconstruct missing analyses or infer parent identity from content equality.

**Practical action:** Inspect compatibility status/notes and provide truthful selector, source, units and window information through the supported wrapper. Report unknown compatibility if the missing prerequisites cannot be justified.

**Scientific boundary:** Adding metadata does not certify its truth or establish statistical independence. Missing context is not automatically an implementation defect.

**Related documentation:**

- [Technical reference source — comparison](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/comparison.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q040", "category": "Trajectories", "priority": "P1", "question_sha256": "45655d3c5e86f63b2d8ab9fa37bc050df03924065049d71ba56f48561923211e"} -->
<a name="q040"></a>

## Q040

**Question:** Does diagnose recompute missing analyses?

**Short answer:** Stored-report diagnose composes existing evidence; it does not silently compute absent analyses.

**Explanation:** For MDTrajectoryAnalysis it summarizes retained fields. The view convenience route is different: it performs the requested analysis first. Unrequested correlation, transient or transport diagnostics are not failed calculations.

**Practical action:** Check whether your argument is a stored report or a frame view and which opt-ins were requested. Run the explicit supported analysis when a missing diagnostic is genuinely needed.

**Scientific boundary:** A composed diagnostic is not a universal simulation-validity score, and the absence of a result is not necessarily numerical failure.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
