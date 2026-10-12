# Differential Equations

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q026 — What does a successful trajectory solve establish?](Differential-Equations#user-content-q026)
- [Q027 — Can FirstOrderODE be passed directly to analyze?](Differential-Equations#user-content-q027)
- [Q028 — Does saveat authorize interpolation in stored-data bridges?](Differential-Equations#user-content-q028)
- [Q029 — Why are state and time converted to Float64?](Differential-Equations#user-content-q029)
- [Q030 — Are domain callbacks rigorous boundary tracking?](Differential-Equations#user-content-q030)

<!-- aml-faq: {"id": "Q026", "category": "Differential Equations", "priority": "P1", "question_sha256": "835ab53c570837de1d5eee3d234599a563d67d0ec8a2b2741843c23c78c8d4c8"} -->
<a name="q026"></a>

## Q026

**Question:** What does a successful trajectory solve establish?

**Short answer:** A successful, completed solve records numerical execution over the requested span under the declared controls.

**Explanation:** TrajectoryResult retains native solution data and diagnostics. A native failure such as an iteration limit can leave partial numerical output, while invalid domain/state data may instead throw before a usable path is returned.

**Practical action:** Check diagnostics.success together with completed and retcode, then compare retained states against an independent analytical reference or justified numerical study. The ODE tutorial demonstrates a bounded cosine/sine reference comparison.

**Scientific boundary:** Solver success and requested tolerances are not a rigorous global error bound. The tutorial comparison is historical evidence here, not a new solve.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q027", "category": "Differential Equations", "priority": "P1", "question_sha256": "1bec992ee1f083bc1f1c8ce302033411e81de6b1e0a8e484105d3fe762b2755d"} -->
<a name="q027"></a>

## Q027

**Question:** Can FirstOrderODE be passed directly to analyze?

**Short answer:** No supported direct analyze method is provided for FirstOrderODE.

**Explanation:** That type stores an out-of-place right-hand side, dimension, labels and domain for numerical integration. Structural equilibrium/stability analysis instead uses the documented AutonomousSystem representation; a callback alone does not supply its symbolic field contract.

**Practical action:** Use trajectory for a FirstOrderODE initial-value problem. If you need structural analysis, formulate a supported ordered square symbolic field and AutonomousSystem instead. Read the dynamics reference and ODE tutorial before changing dispatch.

**Scientific boundary:** Do not assume a universal analyze converter or treat unsupported input as a numerical solver defect. FirstOrderODE construction itself does not analyze equilibria.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q028", "category": "Differential Equations", "priority": "P1", "question_sha256": "2c5011c3ff61154eaa275d56aa24b3bc615efdf3ba16e2b5156f6b7aff414ea7"} -->
<a name="q028"></a>

## Q028

**Question:** Does saveat authorize interpolation in stored-data bridges?

**Short answer:** No. Requested observation timing does not authorize interpolation in a stored-data adapter.

**Explanation:** The native trajectory can retain adaptive steps in addition to saveat stops and supports its own dense interpolation. observable_series and dataset bridges operate on their documented stored samples; those contracts do not infer an interpolation policy from saveat.

**Practical action:** Inspect the actual saved times and selector output. Use stored observations for the bridge, or explicitly design and document a separate resampling/interpolation operation when your scientific workflow needs it.

**Scientific boundary:** saveat is not a global memory-retention control or an exclusively uniform-grid promise. Interpolated values are numerical approximations, not newly established analytical truth.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q029", "category": "Differential Equations", "priority": "P1", "question_sha256": "407aedb923db8c767600804a37daba5ef72af740cbc1a584e3ef51d49ff7065b"} -->
<a name="q029"></a>

## Q029

**Question:** Why are state and time converted to Float64?

**Short answer:** The public integration route has an explicit checked Float64 state/time boundary.

**Explanation:** It copies/converts initial data and checks dimensions, finiteness and representability at initial/RHS stages. This can round higher-precision input; rejecting overflow/nonzero underflow is not the same as preserving every digit.

**Practical action:** Inspect the numerical boundary before choosing a precision-sensitive model. Record the actual converted state, time span, algorithm and tolerances; use a separate appropriate workflow if genuine high-precision integration is required.

**Scientific boundary:** BigFloat inputs do not make this trajectory solver arbitrary precision. Private scalable or in-place experiments do not override the public state/precision contract.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q030", "category": "Differential Equations", "priority": "P1", "question_sha256": "a7cef4d503ecbeab6dfd34667ca5505ed49bd02dcf3086394c19c7205537aebc"} -->
<a name="q030"></a>

## Q030

**Question:** Are domain callbacks rigorous boundary tracking?

**Short answer:** No. Domain callbacks check evaluated stages, not a certified continuous boundary trajectory.

**Explanation:** The predicate must return exactly true at the checked initial/RHS evaluations. A rejected or unresolved stage can fail fast; this is not event localization, a containment proof for the interpolant or a rigorous between-step monitor.

**Practical action:** State the domain predicate and inspect the error/diagnostics. If rigorous boundary localization is required, select a separately justified solver/event workflow rather than bypassing AML validation.

**Scientific boundary:** Accepted stages do not prove that every intermediate state stays in the domain. A domain exception is different from a partial solver return.

**Related documentation:**

- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Executable tutorial — odes](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/odes.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
