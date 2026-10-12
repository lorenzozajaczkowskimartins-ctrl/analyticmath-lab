# Vector Calculus

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q016 — Can vector fields be rectangular maps?](Vector-Calculus#user-content-q016)
- [Q017 — Why does curl return unknown outside supported dimensions?](Vector-Calculus#user-content-q017)
- [Q018 — Why is zero curl not enough to certify a potential?](Vector-Calculus#user-content-q018)
- [Q019 — How are numerical derivatives at a corner refused?](Vector-Calculus#user-content-q019)
- [Q020 — Does linearization prove anything away from its base point?](Vector-Calculus#user-content-q020)

<!-- aml-faq: {"id": "Q016", "category": "Vector Calculus", "priority": "P1", "question_sha256": "732e6b04ff60a12de8abcc38e8c6421ae0dc5d03926faa72cb8e69147c9a8fd7"} -->
<a name="q016"></a>

## Q016

**Question:** Can vector fields be rectangular maps?

**Short answer:** Yes. VectorFieldAnalysis supports independently ordered input variables and output components, so the map can be rectangular.

**Explanation:** For m components and n coordinates, the Jacobian has m rows and n columns. The documented dimension guards apply to both collections; square-field operations have additional requirements.

**Practical action:** Declare the component list and ordered variable collection explicitly. Check the Jacobian shape against those two lengths and consult the vector reference rather than the scalar analyze entry alone.

**Scientific boundary:** Rectangular maps do not automatically support curl, divergence or AutonomousSystem construction. Array shape agreement does not establish smoothness or physical coordinate meaning.

**Related documentation:**

- [Technical reference source — vector](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/vector.md)
- [Executable tutorial — vector-calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/vector-calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q017", "category": "Vector Calculus", "priority": "P1", "question_sha256": "9910781b5f352cd3c72607bc6d27f3315c947b1efcd5bb6c7997cdcd86d50b8e"} -->
<a name="q017"></a>

## Q017

**Question:** Why does curl return unknown outside supported dimensions?

**Short answer:** AML stores supported curl evidence for square two- and three-dimensional fields; other shapes/dimensions yield unknown/unsupported evidence.

**Explanation:** The planar result is a scalar circulation derivative, while the three-dimensional result is a vector. These are different mathematical objects, not one operation that can be extended to every rectangular map by returning zeros.

**Practical action:** Check component and variable counts, then inspect curl status and notes. Use the vector-calculus tutorial for the planar convention and retain unknown if your case lies outside the documented route.

**Scientific boundary:** Unknown curl is not zero curl or a statement that the field is irrotational. Formal differential evidence does not establish global topology.

**Related documentation:**

- [Technical reference source — vector](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/vector.md)
- [Executable tutorial — vector-calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/vector-calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q018", "category": "Vector Calculus", "priority": "P1", "question_sha256": "264e60b5f87c82626f7e687df1077f1cbc70a2612b06a0a5d6c338454bb9a894"} -->
<a name="q018"></a>

## Q018

**Question:** Why is zero curl not enough to certify a potential?

**Short answer:** Zero curl alone does not establish a global potential on an arbitrary domain.

**Explanation:** Local differential identities and global conservative-field claims differ, particularly on domains with holes. AML potential construction is restricted to supported polynomial/original-domain cases and directly checks the candidate derivatives.

**Practical action:** Inspect the potential result status/method/notes and the original domain. If no supported candidate is established, use an independently justified potential or a separate mathematical argument rather than interpreting zero curl as success.

**Scientific boundary:** An unknown potential does not prove nonexistence. A local identity is not a global theorem without the necessary domain assumptions.

**Related documentation:**

- [Technical reference source — vector](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/vector.md)
- [Executable tutorial — vector-calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/vector-calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q019", "category": "Vector Calculus", "priority": "P1", "question_sha256": "c51526648882ffb60b73fe495338af5ca569a937411406db8384c544a7f7bc21"} -->
<a name="q019"></a>

## Q019

**Question:** How are numerical derivatives at a corner refused?

**Short answer:** Checked numerical multivariate derivatives require a supported open smooth neighborhood, not just a finite simplified value.

**Explanation:** Original sqrt/abs restrictions or corners can survive cancellation and make the required neighborhood unavailable. Formal derivative expressions and numeric point queries therefore have different evidence contracts.

**Practical action:** Retain original syntax, check the point and ordered coordinates, and distinguish the formal gradient/Hessian/Jacobian from a checked numerical query. Select a justified smooth point or report the domain limitation.

**Scientific boundary:** Do not bypass the smoothness guard with an internal constant or relabel a corner as smooth. This behavior does not imply FunctionAnalysis scalar evaluation has the same checks.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Technical reference source — vector](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/vector.md)
- [Executable tutorial — vector-calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/vector-calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q020", "category": "Vector Calculus", "priority": "P1", "question_sha256": "0812a5f6db4a7b0f595b339271dec5b002a46b0884221f50902fb8c777ac71ef"} -->
<a name="q020"></a>

## Q020

**Question:** Does linearization prove anything away from its base point?

**Short answer:** No. The returned affine approximation is local to its declared base point.

**Explanation:** It uses the value and gradient/Jacobian at that point under the supported smooth-neighborhood condition. It is not a certified remainder estimate or the same operation as second-order mechanical linearization.

**Practical action:** State the base point and coordinate order, and compare the approximation with the original function over a scientifically justified nearby range if needed. Use the multivariate tutorial and the exact linearization contract.

**Scientific boundary:** No global error bound, basin of attraction or nonlinear stability result follows from the local affine expression.

**Related documentation:**

- [Technical reference source — derivatives](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/derivatives.md)
- [Executable tutorial — multivariate](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/multivariate.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
