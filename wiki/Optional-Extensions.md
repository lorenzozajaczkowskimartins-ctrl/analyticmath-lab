# Optional Extensions

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q076 — Which exact packages activate each optional extension?](Optional-Extensions#user-content-q076)
- [Q077 — Why does a plain Lux surrogate require NeuralOperators?](Optional-Extensions#user-content-q077)
- [Q078 — Can I import AML before its optional backends?](Optional-Extensions#user-content-q078)
- [Q079 — Will AML choose an available backend automatically?](Optional-Extensions#user-content-q079)
- [Q080 — Does AML import activate CairoMakie?](Optional-Extensions#user-content-q080)

<!-- aml-faq: {"id": "Q076", "category": "Optional Extensions", "priority": "P0", "question_sha256": "0734656aeb56958a431e9308e4bdd149b96903527c873b176054d12918184350"} -->
<a name="q076"></a>

## Q076

**Question:** Which exact packages activate each optional extension?

**Short answer:** Each extension requires AML and every declared trigger package to be loaded; installation alone is not activation.

**Explanation:** The current Project.toml declares the following exact trigger sets. These are activation requirements, not automatic backend choices or scientific model validators.

| Integration | All required triggers |
|---|---|
| Molly adapter | Molly |
| Inference fitting | Optimization |
| Learned dynamics | Lux, Optimization |
| Surrogate/operator learning | Lux, Optimization, NeuralOperators |
| PINNs | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface |

**Practical action:** Choose the relevant declared example environment and load all its trigger packages before calling that extension-backed route. Check the boundary table and missing-extension message; do not install every optional stack as a routine FAQ diagnostic.

**Scientific boundary:** Loaded triggers do not guarantee an accepted network/layout, optimizer convergence or valid physical model. ML interfaces remain experimental; [plain Lux surrogates](Optional-Extensions#user-content-q077) still require NeuralOperators.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Repository resource — Project.toml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/Project.toml)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q077", "category": "Optional Extensions", "priority": "P0", "question_sha256": "e58e4cc5ca4cd04d74283cd4d9ceeaf6fe3cd9248f5de6221cb5eabc51d9e6c4"} -->
<a name="q077"></a>

## Q077

**Question:** Why does a plain Lux surrogate require NeuralOperators?

**Short answer:** The audited plain Lux surrogate route shares the extension whose declared triggers include NeuralOperators.

**Explanation:** AnalyticMathLabSurrogateExt activates only with Lux, Optimization and NeuralOperators. The trigger is required even when your chosen network is an ordinary coordinate surrogate rather than a neural operator; AML does not select another route merely because Lux is present.

**Practical action:** Use the documented operators environment and full trigger set for this route, then check the learning_model schema, RNG and normalization requirements. If the package set is unavailable, report the missing extension rather than changing root dependencies or constructing an internal model.

**Scientific boundary:** Extension loading does not validate a network or guarantee operator compatibility. Do not infer general neural-operator or plain-Lux support outside the audited contracts.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q078", "category": "Optional Extensions", "priority": "P0", "question_sha256": "aaabc7c0f0b3d142fe121717943ebe069d7a5442c9992c182b0d04e6b32db144"} -->
<a name="q078"></a>

## Q078

**Question:** Can I import AML before its optional backends?

**Short answer:** Yes. AML can be imported first; an extension becomes available after all its trigger packages and AML are loaded.

**Explanation:** Julia extension activation depends on the complete loaded trigger set, not a requirement that AML always be imported last. Base forward analysis, stored diagnostics and extension-backed construction can have different dependency needs.

**Practical action:** Load the exact packages for your chosen route in its declared environment, then follow the public constructor. If activation still appears missing, record loaded package versions, environment and the exact error from a small supported case.

**Scientific boundary:** Historical load-order verification is not a new optional-backend execution here. Installation or import order does not guarantee every upstream version, network state or runtime is supported.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q079", "category": "Optional Extensions", "priority": "P0", "question_sha256": "74cda2c3c462ace70661db85f024244505146299758f9c667128802ec43bbac3"} -->
<a name="q079"></a>

## Q079

**Question:** Will AML choose an available backend automatically?

**Short answer:** No. AML does not automatically choose or substitute an available scientific-learning backend.

**Explanation:** The documented routes have explicit extension triggers, model/data layouts and optimizer/AD requirements. Having another backend installed does not make it interchangeable with the selected PINN, surrogate or learned-dynamics route.

**Practical action:** Choose a documented route deliberately, load all its triggers, and declare the required model, RNG, normalization and optimizer controls. Read the relevant contract when a constructor reports missing or unsupported prerequisites.

**Scientific boundary:** Backend availability is not scientific validity, convergence or automatic GPU transfer. An unavailable capability is not fixed by inventing a fallback.

**Related documentation:**

- [Technical reference source — scientific-ml](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scientific-ml.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q080", "category": "Optional Extensions", "priority": "P0", "question_sha256": "c354e94fcd13313636827f605debe066d2cf870f6ce25af09d954615bd52298f"} -->
<a name="q080"></a>

## Q080

**Question:** Does AML import activate CairoMakie?

**Short answer:** No. Importing AML does not activate CairoMakie or select a rendering backend.

**Explanation:** AML scientific views construct Makie figures from stored results and may sample stored callables. Rendering, showing or saving requires an explicitly chosen backend in the caller environment; dependency availability is different from backend activation.

**Practical action:** Follow the existing README visualization workflow for the explicit CairoMakie choice, or a supported chosen Makie backend workflow. Declare packages imported directly by your consumer; separate figure construction errors from rendering/display configuration.

**Scientific boundary:** A rendered image is not new scientific analysis or a validity certificate. AML does not automatically choose a renderer, recompute missing results or guarantee every display environment.

**Related documentation:**

- [README explicit rendering workflow](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md)
- [Technical reference source — plots](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/plots.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
