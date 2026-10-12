# Getting Started

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q001 — How do I install AML from this checkout?](Getting-Started#user-content-q001)
- [Q002 — What can I use after only using AnalyticMathLab?](Getting-Started#user-content-q002)
- [Q003 — Why does the first import take time?](Getting-Started#user-content-q003)
- [Q004 — Which example should I run first?](Getting-Started#user-content-q004)
- [Q005 — Do I need to force Julia or BLAS to one thread?](Getting-Started#user-content-q005)

<!-- aml-faq: {"id": "Q001", "category": "Getting Started", "priority": "P1", "question_sha256": "876423998e6630a73f16e8751b0cdff4c1c38a960ffea4a780a505ba0b8b6399"} -->
<a name="q001"></a>

## Q001

**Question:** How do I install AML from this checkout?

**Short answer:** Use a checkout and its declared project, a Git-URL consumer install, or local Pkg development; follow the README route matching your goal.

**Explanation:** The checkout route instantiates the committed environment. A consumer route installs the published repository revision, whereas local development registers your checkout in a separate environment. Symbolics must be a direct consumer dependency when that project imports it for symbolic examples.

**Practical action:** Open the linked README Installation section and copy its already-verified route. Use the documented Julia 1.12.7 runtime, keep the consumer Manifest, and run repository tutorial scripts from the checkout root.

**Scientific boundary:** AML is not claimed to be registered in General. Compatibility declares Julia 1.12; recorded verification is Julia 1.12.7 on Linux. Installation evidence is historical here and does not establish a cold-depot or all-platform guarantee.

**Related documentation:**

- [README installation / first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q002", "category": "Getting Started", "priority": "P1", "question_sha256": "5335c757c4eb0f19a7d65ad3473605217953d57934bafe8c2cf5c8ff4a69f9ee"} -->
<a name="q002"></a>

## Q002

**Question:** What can I use after only using AnalyticMathLab?

**Short answer:** The exported stored-data and analysis interfaces are available without loading an optional scientific-learning or Molly backend.

**Explanation:** Core is not dependency-free: AML uses its declared dependencies internally. Constructing symbolic expressions normally needs an explicit Symbolics import in your own project; statistical inspection of an already supplied scalar series does not need that symbolic setup.

**Practical action:** Start with the stored ObservableSeries/statistical_summary workflow or the linked base tutorial. Declare every package that your consumer project imports directly instead of relying on AML transitive dependencies.

**Scientific boundary:** An available constructor or result record is not scientific certification. Experimental datasets remain experimental even when their base constructors are callable.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)
- [Related repository resource — README.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q003", "category": "Getting Started", "priority": "P1", "question_sha256": "8cad1fe20519ea2379c85e97b5711bfaf100b55564acea3c040120e443cef88e"} -->
<a name="q003"></a>

## Q003

**Question:** Why does the first import take time?

**Short answer:** The first import can include package loading, dependency precompilation and compilation of Julia code.

**Explanation:** Startup work depends on the depot, cache state, versions, platform and subsequent specialization. Warm and cold environments are different measurements; AML composes substantial symbolic, numerical and visualization dependencies.

**Practical action:** Let the declared environment finish instantiation/precompilation, retain its Manifest and the complete error if loading fails. Compare later imports in the same environment rather than changing scientific limits to address startup cost.

**Scientific boundary:** There is no universal startup-time estimate or newly verified cold-depot result in this FAQ. A persistent loading error is different from ordinary compilation work.

**Related documentation:**

- [README installation / first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q004", "category": "Getting Started", "priority": "P1", "question_sha256": "88d4450da6bb4f914d9e8bccada8c2731ea4129af7bd338655531e7faa9d4a99"} -->
<a name="q004"></a>

## Q004

**Question:** Which example should I run first?

**Short answer:** Begin with the README Quick Start, then the scalar calculus tutorial.

**Explanation:** The scalar lesson connects a polynomial, its analytical derivatives, symbolic evaluation and numerical discrepancy checks. Its complete script initializes its own inputs; the integrated oscillator is a later multi-method investigation.

**Practical action:** Follow the README environment instructions and the calculus lesson command from the repository root. Use the tutorial index to progress to multivariate analysis, modes, ODEs and stored observations.

**Scientific boundary:** The nine tutorial scripts have M10D.6C execution evidence; they were not rerun for this Wiki. Numerical agreement in a tutorial is not a general proof of every API.

**Related documentation:**

- [README installation / first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q005", "category": "Getting Started", "priority": "P1", "question_sha256": "1383948b1a2312c251fe561bf69e0e94f620e3506d45addc9761b09d9ea0a777"} -->
<a name="q005"></a>

## Q005

**Question:** Do I need to force Julia or BLAS to one thread?

**Short answer:** Single Julia and BLAS threads are useful controlled-run choices, not universal package requirements.

**Explanation:** Thread settings affect scheduling and numerical/performance comparisons. Earlier bounded verification used controlled threading, but that does not establish that all other settings fail or that one-thread runs are bitwise reproducible everywhere.

**Practical action:** For reproducing a recorded gate, use its recorded thread settings and runtime. For a threading-specific defect, retain the version, project, settings and smallest supported example rather than assuming the thread count explains every failure.

**Scientific boundary:** No portable performance or bitwise-reproducibility guarantee follows from a thread setting. Do not modify internal limits to compensate for an unrelated environment failure.

**Related documentation:**

- [Threading and user-environment contract](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/m10d_user_research_hardening.md)
- [README installation / first experience](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
