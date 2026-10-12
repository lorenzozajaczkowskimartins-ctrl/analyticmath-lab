# Calculus and Symbolics

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q006 — Why did simplifying x/x lose the exclusion at zero?](Calculus-and-Symbolics#user-content-q006)
- [Q007 — Does evaluate enforce the original real domain?](Calculus-and-Symbolics#user-content-q007)
- [Q008 — Why are some exact roots unknown?](Calculus-and-Symbolics#user-content-q008)
- [Q009 — Does an empty stationary search prove there are no critical points?](Calculus-and-Symbolics#user-content-q009)
- [Q010 — Can I analyze a Julia function or a string?](Calculus-and-Symbolics#user-content-q010)

<!-- aml-faq: {"id": "Q006", "category": "Calculus and Symbolics", "priority": "P1", "question_sha256": "b407702a5df53c650371909ed934860d4acec4d5eec8c5835b7f11518d8e8b35"} -->
<a name="q006"></a>

## Q006

**Question:** Why did simplifying x/x lose the exclusion at zero?

**Short answer:** Cancellation can turn x/x into 1 and erase the original exclusion at zero.

**Explanation:** Domain reasoning needs the original expression syntax, not only its simplified value. RealExpression and @real_function support capture before simplification; erased restrictions cannot reliably be reconstructed afterward.

**Practical action:** Use the captured-original workflow in the calculus tutorial and keep the intended ordered variables. If supplying original syntax explicitly, make sure it genuinely describes the expression being analyzed.

**Scientific boundary:** Matching caller-supplied original syntax is a trusted assertion, not a universal equivalence proof. Numerical evaluation of a simplified callable does not automatically enforce the original domain.

**Related documentation:**

- [Technical reference source — core](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/core.md)
- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q007", "category": "Calculus and Symbolics", "priority": "P1", "question_sha256": "0fe7b6c007017171cd78ca1490e15e19ba9e14e29af04281a404045bde1898ff"} -->
<a name="q007"></a>

## Q007

**Question:** Does evaluate enforce the original real domain?

**Short answer:** Not uniformly: FunctionAnalysis evaluation does not automatically enforce its stored original real domain.

**Explanation:** The univariate route evaluates cached callables, including their simplification/NaN behavior. Other overloads have different checks: multivariate/vector routes reject known exclusions and nonfinite data, while PotentialAnalysis has radius-domain semantics.

**Practical action:** Inspect the relevant evaluate overload and use domain_contains on the stored domain when membership matters. Treat its nothing result as unresolved, not permission or rejection.

**Scientific boundary:** A successful value is not a domain certificate or proof of smoothness. Do not transfer the scalar callable behavior to every evaluate overload.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q008", "category": "Calculus and Symbolics", "priority": "P1", "question_sha256": "46defb1331379fdf80d4d027a27555bc155fba4f471ea119b2139bbb4863ed02"} -->
<a name="q008"></a>

## Q008

**Question:** Why are some exact roots unknown?

**Short answer:** Exact-root evidence is bounded to supported expression classes and resource limits.

**Explanation:** Unsupported symbolic forms, unresolved irrational roots or bounded exact-algebra work can leave the result unknown. This differs from an established statement that no roots exist; numerical search and exact reasoning are separate evidence paths.

**Practical action:** Read the result status, method and notes. Use the scalar tutorial to compare a supported expression with an analytical reference, and label any bounded numerical search as heuristic.

**Scientific boundary:** Changing internal exact-algebra limits is not a supported recovery. Unknown roots do not prove absence, and numerical candidates do not become exact solutions merely by agreeing to a tolerance.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q009", "category": "Calculus and Symbolics", "priority": "P1", "question_sha256": "545239e7ffcffb151a08db04d9ba798c7a2657af7a9654f2f3b313f686941341"} -->
<a name="q009"></a>

## Q009

**Question:** Does an empty stationary search prove there are no critical points?

**Short answer:** No. An empty heuristic candidate list is not a proof of no critical points.

**Explanation:** A bounded numerical search can miss points or reject candidates by residual/domain checks. Omitted search bounds can also mean a diagnostic was not requested. Some supported exact classes have stronger, explicitly scoped completeness evidence.

**Practical action:** Check whether search was requested, what interval/bounds were used, and the stored search status, residual threshold and rejection notes. Compare with an independently derived derivative where practical.

**Scientific boundary:** Do not relabel heuristic or unrequested searches as complete. A small derivative residual is not a certified bound on the stationary-point location.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q010", "category": "Calculus and Symbolics", "priority": "P1", "question_sha256": "30ad7a7d2ac6028f9ffcb36c30b43e434023666e3f905d0904d6f91cb14f3a1e"} -->
<a name="q010"></a>

## Q010

**Question:** Can I analyze a Julia function or a string?

**Short answer:** Not as arbitrary scalar symbolic inputs: the documented scalar route takes a symbolic expression or supported constant and declared symbolic variable(s).

**Explanation:** A Julia closure or string is not automatically converted into a symbolic expression with original-domain evidence. Captured-expression dispatch follows its evaluated symbolic payload; it is not a general string parser.

**Practical action:** Declare the expression with the Symbolics workflow in the calculus tutorial. If your object is an out-of-place ODE right-hand-side callback, use the FirstOrderODE/trajectory route instead of requesting symbolic analyze dispatch.

**Scientific boundary:** Do not evaluate untrusted strings or expect a universal analyze input converter. An unsupported dispatch is not by itself a scientific runtime defect.

**Related documentation:**

- [Technical reference source — scalar](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/scalar.md)
- [Executable tutorial — calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md)

**Evidence:** SOURCE_SUPPORTED. Linked tutorial executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
