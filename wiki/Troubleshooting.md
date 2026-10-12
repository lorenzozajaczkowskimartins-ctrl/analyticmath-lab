# Troubleshooting

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q081 — Why is analyze not defined for my input type?](Troubleshooting#user-content-q081)
- [Q082 — Why is transform ambiguous after importing another library?](Troubleshooting#user-content-q082)
- [Q083 — Why is a plot region blank even though sampling looks finite?](Troubleshooting#user-content-q083)
- [Q084 — Can I fix a refusal by changing an internal constant?](Troubleshooting#user-content-q084)
- [Q085 — What must I retain before mutating a borrowed array?](Troubleshooting#user-content-q085)

<!-- aml-faq: {"id": "Q081", "category": "Troubleshooting", "priority": "P0", "question_sha256": "3c2d09eb53624d87f7eb19fda9562ef913c0d6ca60f1f6f214420bc10a094ac0"} -->
<a name="q081"></a>

## Q081

**Question:** Why is analyze not defined for my input type?

**Short answer:** analyze has specific input contracts, not a universal method for every object or every AbstractAnalysis subtype.

**Explanation:** Unsupported dispatch can mean a wrong representation rather than invalid numerical data. FirstOrderODE is an integration input, strings/closures are not general scalar symbolic expressions, and extension-dependent inputs require the relevant optional route. An existing report can also be the output rather than a new analyze input.

**Practical action:** Check the public input type, ordered shape and analyze overload table, then use the correct constructor or operation; for FirstOrderODE use trajectory. Distinguish missing extension, invalid prerequisites, unknown evidence and resource refusal using the boundary guide. Report a defect only when a small documented supported input still fails, including the complete error and environment.

**Scientific boundary:** Do not add an internal fallback or bypass validation. The detailed refusal decision trees remain future M10D.6G work, not a handbook linked here.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Technical reference source — dynamics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/dynamics.md)
- [Technical reference source — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/index.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q082", "category": "Troubleshooting", "priority": "P0", "question_sha256": "f8e16cf6f66d4b83073d3fe9b9d7212e1da256878db3e9be810e99293553b0b6"} -->
<a name="q082"></a>

## Q082

**Question:** Why is transform ambiguous after importing another library?

**Short answer:** Ambiguous transform names can result from multiple imported packages exporting the same name, not from broken AML scaling.

**Explanation:** Libraries such as Lux or NeuralOperators may expose their own transform. Unqualified name resolution does not establish which operation you intended; AML affine scaling also requires its documented feature-row layout.

**Practical action:** Choose the AML-qualified transform name when using an AML AffineScaling and verify feature rows/query columns. Use the dataset reference for the accepted arrays; report a defect only if the qualified supported call fails after shape/data prerequisites are satisfied.

**Scientific boundary:** Qualification resolves the name collision, not incorrect units, splits or scaling assumptions. No internal constant or optional-backend substitution is an appropriate repair.

**Related documentation:**

- [Technical reference source — datasets](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/datasets.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q083", "category": "Troubleshooting", "priority": "P0", "question_sha256": "71d921bc72813f3194db11044d25fee72a85001a18b205621c38f4674a213616"} -->
<a name="q083"></a>

## Q083

**Question:** Why is a plot region blank even though sampling looks finite?

**Short answer:** A finite sample value is not enough to guarantee a rendered region: domain masks and renderer representation checks are separate.

**Explanation:** Scalar-field views conservatively mask supported domain restrictions; vectorplot checks the rendered Float32 anchor against known membership. Original restrictions can survive symbolic cancellation, and a figure/display backend problem differs from a mathematically excluded region. Glyph shafts are not certified domain-contained paths.

**Practical action:** Check the report type/dimensions, actual ordered plotting bounds and original domain, then compare public evaluate/domain information with the intended rendered location. Confirm explicit backend selection and inspect the plot contract. If a small documented valid-domain case remains incorrectly blank, retain the figure settings, domain/evidence and environment in a defect report.

**Scientific boundary:** Do not disable validation to fill a blank area or infer domain validity from finite callable samples. Unknown scientific evidence, excluded data and rendering defects require different diagnoses.

**Related documentation:**

- [Technical reference source — plots](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/plots.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q084", "category": "Troubleshooting", "priority": "P0", "question_sha256": "342d4893837d73456d4743b1eb34cb1bf8dbbb1fb764330b455ee84607cea08b"} -->
<a name="q084"></a>

## Q084

**Question:** Can I fix a refusal by changing an internal constant?

**Short answer:** Changing an internal constant is not a supported way to recover from a refusal.

**Explanation:** Refusals can protect domain, precision, shape, exact-algebra work or resource assumptions. Increasing an internal ceiling does not supply a missing algorithm or make the result scientifically valid; documented public budgets affect only their stated operations.

**Practical action:** Identify the exact operation and refusal, inspect the boundary/resource table and use a supported keyword only when its prerequisites and resource assessment justify it. Reduce or reformulate a model explicitly, or report a defect when supported inputs are incorrectly rejected. See [symbolic versus dense limits](Memory-and-Performance#user-content-q066).

**Scientific boundary:** There is no global limit override, generic partial solver or promised recovery for every input. Detailed refusal decision trees remain reserved for M10D.6G; no nonexistent handbook is assumed.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Repository resource — reports/m10d6/resource_controls.json](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/reports/m10d6/resource_controls.json)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q085", "category": "Troubleshooting", "priority": "P0", "question_sha256": "648f98f9bd18ca22ad32c05783413d8697e49351690bef7efbe9bcf99e7c926d"} -->
<a name="q085"></a>

## Q085

**Question:** What must I retain before mutating a borrowed array?

**Short answer:** Before mutation, preserve the scientific input and its associated times, order, units and provenance; a borrowed array is not an owned snapshot.

**Explanation:** ObservableSeries and generic AtomisticSnapshot borrow data by default, and lazy views can expose source mutations. An immutable outer record does not make its arrays immutable. AtomisticSnapshot copy_data=true copies selected particle/boundary fields, not every provenance object, time, energy or distance closure; scientific_metadata can also borrow payloads.

**Practical action:** Treat borrowed data as read-only during analysis and choose the documented copying policy before changing backing data. Retain a deliberate independent dataset including contextual metadata when a fixed experiment is needed; check lengths and ordering if a source was modified. Report a defect only when the documented ownership behavior is violated.

**Scientific boundary:** Already computed reports need not update after mutation, while lazy series may change. A partial copying policy or detached origin descriptor does not preserve every heavy source object or guarantee reproducibility.

**Related documentation:**

- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Technical reference source — atomistic](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/atomistic.md)
- [Executable tutorial — index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
