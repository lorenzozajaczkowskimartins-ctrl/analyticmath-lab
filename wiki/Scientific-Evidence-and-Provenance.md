# Scientific Evidence and Provenance

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q071 — What do value, status, method and notes mean?](Scientific-Evidence-and-Provenance#user-content-q071)
- [Q072 — Is unknown evidence the same as false or zero?](Scientific-Evidence-and-Provenance#user-content-q072)
- [Q073 — Does provenance identity affect scientific value equality?](Scientific-Evidence-and-Provenance#user-content-q073)
- [Q074 — Can I use an origin token as a persistent reproducibility hash?](Scientific-Evidence-and-Provenance#user-content-q074)
- [Q075 — Why is ancestry unavailable on an isolated PropertyResult?](Scientific-Evidence-and-Provenance#user-content-q075)

<!-- aml-faq: {"id": "Q071", "category": "Scientific Evidence and Provenance", "priority": "P0", "question_sha256": "f1b1f4aa0d14f26f760626e0e6b35948d0d780f42be24d40b119ff1c65c3a529"} -->
<a name="q071"></a>

## Q071

**Question:** What do value, status, method and notes mean?

**Short answer:** PropertyResult contains exactly four fields: value, status, method and notes; interpret them together for the particular claim.

**Explanation:** value is the payload, status is scoped evidence, method identifies the recorded route, and notes explain assumptions or limitations. :established applies only to the stated claim under its assumptions; :heuristic denotes approximate evidence; :unknown leaves the claim unavailable or unresolved. Raw construction does not validate mathematical truth or enforce a universal status vocabulary.

**Practical action:** Read the operation contract before consuming the payload, and preserve notes and method when reporting a conclusion. Separate an execution status, compatibility decision or search status from the evidence classification of a mathematical claim.

**Scientific boundary:** There are no hidden certification fields, automatic uncertainty estimates or universal confidence scores. A numerical residual is not a certified mathematical error bound.

**Related documentation:**

- [Technical reference source — core](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/core.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q072", "category": "Scientific Evidence and Provenance", "priority": "P0", "question_sha256": "dcd48997128a198b5c9deffa2d90f06c98aeaea3e611e3519f73a0775729e1a0"} -->
<a name="q072"></a>

## Q072

**Question:** Is unknown evidence the same as false or zero?

**Short answer:** No. Unknown evidence is neither false nor zero, and unavailable output is not necessarily a failed calculation.

**Explanation:** A result can be unsupported, outside a bounded exact class, unrequested, partially computed or missing needed scientific context. Those cases differ from an established negative claim or a completed numerical value equal to zero.

**Practical action:** Inspect status, method, notes and the requested options. Supply missing justified prerequisites or request a supported diagnostic explicitly; if the required capability is absent, retain unknown instead of inventing a value.

**Scientific boundary:** Do not replace nothing or unknown with zero, infer nonexistence from an empty heuristic search, or label every unavailable diagnostic a runtime defect.

**Related documentation:**

- [Technical reference source — core](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/core.md)
- [Technical boundary source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q073", "category": "Scientific Evidence and Provenance", "priority": "P0", "question_sha256": "cd9cadb30a35b46ec30e34e9a8db75918adde2a32c7fd5cb6d874c6c80f1ee1d"} -->
<a name="q073"></a>

## Q073

**Question:** Does provenance identity affect scientific value equality?

**Short answer:** Provenance identity and scientific value equality are separate; equal scientific values need not have the same source identity.

**Explanation:** AML deliberately preserves PropertyResult four-field leaves without adding hidden origin storage. Source-bearing reports can record derivation context, but a process-local origin token is not a numerical-value field or an equality certificate.

**Practical action:** Compare the operation-specific scientific payload and evidence for value agreement. Inspect recorded ancestry separately through qualified experimental AnalyticMathLab.scientific_origin; use AnalyticMathLab.scientific_metadata only on its documented supported types.

**Scientific boundary:** Equal values do not prove common ancestry, independence or identical experiments. Metadata availability is not scientific correctness; borrowed metadata should be treated as read-only.

**Related documentation:**

- [Technical reference source — evidence](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/evidence.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q074", "category": "Scientific Evidence and Provenance", "priority": "P0", "question_sha256": "f020741ba1cdf53e4fb1d912c45e6e37834b2edcc25cc1309cc56ebcff80d7a2"} -->
<a name="q074"></a>

## Q074

**Question:** Can I use an origin token as a persistent reproducibility hash?

**Short answer:** No. Origin tokens are process-local object identities, not persistent reproducibility hashes.

**Explanation:** The qualified experimental AnalyticMathLab.scientific_origin returns a detached bounded descriptor of recorded ancestry. Tokens identify objects within the originating process; truncation and missing links are explicit, and content is not cryptographically hashed.

**Practical action:** For reproducibility, separately retain the repository revision, environment, model/data declarations, RNG provenance and relevant original files. If durable content identity is needed, use an independently defined file/data hash policy, not the origin token.

**Scientific boundary:** A serialized token does not gain persistent identity semantics. An independent analytical reference for the same model need not share recorded ancestry with a numerical trajectory.

**Related documentation:**

- [Technical reference source — evidence](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/evidence.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q075", "category": "Scientific Evidence and Provenance", "priority": "P0", "question_sha256": "57924d094a1e4c27edcba60ae0a99c49652d968cfb81a82fa71d6829d5728eaa"} -->
<a name="q075"></a>

## Q075

**Question:** Why is ancestry unavailable on an isolated PropertyResult?

**Short answer:** An isolated PropertyResult can have unknown ancestry because its four fields do not store source lineage.

**Explanation:** The qualified experimental scientific_origin leaf route explicitly returns unknown availability. scientific_metadata can still describe scoped claims or method while leaving absent provenance unresolved; known metadata means present, not proven. Missing parents are not reconstructed from equal values or surrounding mathematical meaning.

**Practical action:** Retain the source-bearing analysis or series alongside leaves when derivation context matters, and inspect its recorded origin through AnalyticMathLab.scientific_origin. Keep the original claim and notes instead of inserting invented parents into a leaf.

**Scientific boundary:** Independent references, equal arrays or recognizable equations do not establish ancestry. Unknown lineage is intentional, not automatically a failed calculation or provenance defect.

**Related documentation:**

- [Technical reference source — evidence](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/evidence.md)
- [Executable tutorial — one-system-many-methods](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/one-system-many-methods.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
