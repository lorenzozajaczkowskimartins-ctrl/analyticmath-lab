# Atomistic Computing

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q041 — Can I inspect particle data without Molly?](Atomistic-Computing#user-content-q041)
- [Q042 — Why does a Molly trajectory require explicit historical assertions?](Atomistic-Computing#user-content-q042)
- [Q043 — What happens when a Molly system has no stored loggers?](Atomistic-Computing#user-content-q043)
- [Q044 — What boundary and distance information is needed for RDF?](Atomistic-Computing#user-content-q044)
- [Q045 — Is analyze_potential an MD force engine?](Atomistic-Computing#user-content-q045)

<!-- aml-faq: {"id": "Q041", "category": "Atomistic Computing", "priority": "P1", "question_sha256": "e3b06174d0a41a4e72f3ffb05aa7031e61374fed92aedc8d03b8e68893504ba9"} -->
<a name="q041"></a>

## Q041

**Question:** Can I inspect particle data without Molly?

**Short answer:** Yes. Generic snapshots, lazy frame views and stored-data inspection are core AML operations; Molly is only an optional adapter.

**Explanation:** AtomisticSnapshot holds particle-major data and declared geometry. mdcheck reports what can be inferred from supplied fields, including missing or invalid information; construction is not an MD simulation or a complete data validator.

**Practical action:** Follow the base atomistics tutorial. Declare positions, particle order, masses/species and boundary information as needed; inspect mdcheck evidence before asking for pair geometry or observables.

**Scientific boundary:** Inspection cannot reconstruct a missing force field, energy history or physical clock. A snapshot accepted by the constructor does not certify a valid simulation.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Executable tutorial — atomistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/atomistics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q042", "category": "Atomistic Computing", "priority": "P1", "question_sha256": "354288a7f2bfdfb4fc72677329cb658ee12eca2572bad530139e242331150cff"} -->
<a name="q042"></a>

## Q042

**Question:** Why does a Molly trajectory require explicit historical assertions?

**Short answer:** The Molly adapter cannot recover historical boxes, masses, species or particle ordering from present System fields.

**Explanation:** The public trajectory route requires fixed_box=true as a caller assertion covering the selected history. It borrows stored logger frames and current fixed metadata. Matching counts and strides do not prove that coordinate and velocity loggers came from synchronized simulation calls.

**Practical action:** Use only histories for which those fixed-data and synchronization assertions are justified. Supply actual global frame times, and use supported CPU Array-backed standard loggers; record particle and coordinate conventions separately.

**Scientific boundary:** The assertion is USER_ASSUMPTION, not something AML proves. Molly local step numbering and logger stride do not establish elapsed physical time or periodic image history.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Repository resource — docs/atomistic.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/atomistic.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q043", "category": "Atomistic Computing", "priority": "P1", "question_sha256": "328ba19f0d0aca2352bd5c1db50dcc03116f3a18937766034b2b37932e137e8b"} -->
<a name="q043"></a>

## Q043

**Question:** What happens when a Molly system has no stored loggers?

**Short answer:** Without a stored coordinate logger, atomistic_trajectory cannot manufacture a trajectory from the current Molly state.

**Explanation:** The default empty logger container is handled as no logger; after the fixed-box prerequisite, the adapter requires a standard CoordinatesLogger and otherwise throws ArgumentError. A valid but empty coordinate logger instead supplies a zero-frame view. Historical velocities may be absent; present velocities are not substituted.

**Practical action:** Check which loggers were actually configured and whether they contain frames. Use atomistic_snapshot for the current state, or deliberately configure upstream logging for a future run; supply trustworthy times when history exists.

**Scientific boundary:** Past frames cannot be recovered by relabeling the current snapshot. Empty history is not proof that no motion occurred, and logging a new run is not reconstruction of the old run.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Repository resource — docs/atomistic.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/atomistic.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q044", "category": "Atomistic Computing", "priority": "P1", "question_sha256": "f70205b0737d2ab7e521857dd54be771a3d9026fb65f30ea115d08fc163c1db0"} -->
<a name="q044"></a>

## Q044

**Question:** What boundary and distance information is needed for RDF?

**Short answer:** RDF needs explicit bin edges and supported orthorhombic periodic geometry in two or three dimensions, with consistent distance and unit conventions.

**Explanation:** The supported normalization uses finite-particle pair counts and shell measures. The largest radius cannot exceed half the shortest box length. Species/frame selection changes the counted populations; an arbitrary open or unsupported boundary is not silently treated as a periodic box.

**Practical action:** Inspect the boundary, dimensions, positive box lengths, species selection and ordered edges before calling radial_distribution. Retain compatible length quantities and the actual distance convention; read status/notes if normalization or geometry is unavailable.

**Scientific boundary:** An RDF curve is not proof of equilibrium or structural phase identity. Avoid assuming a generic distance callback makes every geometry supported; omitting full pair output does not eliminate quadratic traversal.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Repository resource — docs/atomistic.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/atomistic.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q045", "category": "Atomistic Computing", "priority": "P1", "question_sha256": "952760d98d095440df50a427faed5f580fbce36f863dae2995cd77f85b9b3abb"} -->
<a name="q045"></a>

## Q045

**Question:** Is analyze_potential an MD force engine?

**Short answer:** No. analyze_potential analyzes a supplied radial symbolic potential; it is not an MD force engine.

**Explanation:** PotentialAnalysis stores energy and radial derivative evidence under positive-radius/domain assumptions. lennard_jones_analysis provides the supported radial model, not a neighbor-list integrator or an automatic interpretation of arbitrary atomistic interactions.

**Practical action:** Use these operations to inspect a declared radial expression, interval, parameters and cutoff semantics. For configured MD forces or simulation, use the explicitly chosen upstream engine and its own model contracts.

**Scientific boundary:** A radial derivative is not automatically a many-particle force field, and descriptive unit labels do not convert coefficients. AML does not infer missing interactions or historical forces.

**Related documentation:**

- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Executable tutorial — atomistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/atomistics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
