# Statistics

[Home](Home) · [All 90 questions](FAQ-Index)

Answers describe supported contracts, not a complete signature manual. Technical reference links open repository source, not a deployed Documenter site. Tutorial execution evidence is historical unless explicitly stated otherwise.

## Questions on this page

- [Q046 — Why does a moment summary not report an IID standard error?](Statistics#user-content-q046)
- [Q047 — Do blocking and autocorrelation prove stationarity?](Statistics#user-content-q047)
- [Q048 — Why are missing or nonfinite observations not silently filtered?](Statistics#user-content-q048)
- [Q049 — What time scale and fit-window assumptions are needed to interpret a diffusion estimate?](Statistics#user-content-q049)
- [Q050 — Does comparing compatible runs establish independence?](Statistics#user-content-q050)

<!-- aml-faq: {"id": "Q046", "category": "Statistics", "priority": "P1", "question_sha256": "8387b726bf71fa58f1ee7f9611da9d442aede94428f03748584c7ac44a718c31"} -->
<a name="q046"></a>

## Q046

**Question:** Why does a moment summary not report an IID standard error?

**Short answer:** A moment summary deliberately leaves standard_error unavailable because descriptive moments do not establish independent identically distributed observations.

**Explanation:** statistical_summary reports count, mean, sample variance, standard deviation and extrema as heuristic finite-sample evidence. Standard deviation measures fluctuation, not uncertainty of the mean; a singleton has no sample variance.

**Practical action:** Use the trajectory tutorial to inspect the stored series and sampling. If mean uncertainty is needed, consider the public correlation-aware or blocking analyses with justified stationarity, window and effective-sample assumptions.

**Scientific boundary:** Unavailable standard error is not zero uncertainty. Neither a long series nor a successful moment calculation proves independence, stationarity or equilibration.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q047", "category": "Statistics", "priority": "P1", "question_sha256": "c35ba9a28771fa61ed5d2544d46ee9447ae74dd2cf58ebf366e48a15229d9237"} -->
<a name="q047"></a>

## Q047

**Question:** Do blocking and autocorrelation prove stationarity?

**Short answer:** No. Blocking and autocorrelation provide finite-sample diagnostics under assumptions; they do not prove stationarity.

**Explanation:** block_average uses complete nonoverlapping blocks, reports discarded tails and does not automatically choose an independence plateau. Integrated autocorrelation time uses a declared or supported heuristic window; unavailable tails do not trigger an IID fallback.

**Practical action:** Inspect block-size dependence, available lag range and recorded window/assumptions. Compare early and late behavior, and explicitly select a justified analysis interval rather than assuming the package removes a transient.

**Scientific boundary:** Estimated effective sample size is not a count of independent experiments. A plateau, decaying correlation or absent transient warning is not a stationarity theorem.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q048", "category": "Statistics", "priority": "P1", "question_sha256": "8cecd15f29a66508de0f0574e6e627b9d5867e11a57e8da6b1fe7844dcda41f3"} -->
<a name="q048"></a>

## Q048

**Question:** Why are missing or nonfinite observations not silently filtered?

**Short answer:** AML does not silently remove missing, nonfinite or non-real observations because that would change the series being analyzed.

**Explanation:** The supported missing policy rejects rather than filters; statistical operations can return unknown numerical evidence for invalid observations. Mixed or incompatible units can throw instead. Silent deletion would change counts, time spacing and correlation meaning.

**Practical action:** Check values, associated times, lengths and units before analysis. If cleaning is scientifically justified, create an explicit selected series with matching times and recorded selection decisions; never preserve an old regularity claim after dropping samples.

**Scientific boundary:** Unknown is not zero or an imputed observation. Cleaning is a USER_ASSUMPTION and does not repair a simulation, establish stationarity or preserve lag semantics automatically.

**Related documentation:**

- [Technical reference source — statistics](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/statistics.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q049", "category": "Statistics", "priority": "P1", "question_sha256": "91acbe72c5411915eab5599677c04a97ed0724a2588818081686a8f1084753ee"} -->
<a name="q049"></a>

## Q049

**Question:** What time scale and fit-window assumptions are needed to interpret a diffusion estimate?

**Short answer:** An eligible index-time MSD can be fitted numerically, but a physical diffusion coefficient needs a justified physical time scale and a defensible diffusive fit window.

**Explanation:** diffusion_estimate has no universal physical-time-only refusal. It fits a caller-selected inclusive window with at least three finite points and positive time span, returning slope, intercept, residuals and RMS. Without a window there is no fit. Per-index slope is not automatically a physical coefficient.

**Practical action:** Supply truthful saved-frame times or document the mapping from index-time to physical time. Verify fixed particle identity/order and open or trustworthy unwrapped coordinates; AML does not unwrap data. Justify a diffusive window and inspect fit residuals and slope rather than selecting a convenient line.

**Scientific boundary:** Numerical acceptance does not prove diffusion, independence or physical interpretability. Correlated MSD residuals do not receive invented independent-residual uncertainty estimates; a positive or zero fitted slope is not a transport certificate.

**Related documentation:**

- [Technical reference source — transport](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/transport.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)
- [Repository resource — docs/trajectory_statistics.md](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/trajectory_statistics.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

<!-- aml-faq: {"id": "Q050", "category": "Statistics", "priority": "P1", "question_sha256": "c031f39c0b300a4ed277aa313b6f629516c474927f7051c32eb38deede7ed03d"} -->
<a name="q050"></a>

## Q050

**Question:** Does comparing compatible runs establish independence?

**Short answer:** No. Compatibility establishes whether the declared quantities can be compared, not whether runs are independent.

**Explanation:** compare_runs checks recorded context such as observable selection, units, sampling and source meaning. Equal layouts, distinct identities or matching time windows are not statistical independence evidence.

**Practical action:** Inspect compatibility and comparison notes, and separately document initial conditions, RNG choices, shared data and any independence assumptions. Report descriptive differences as such when inferential prerequisites are unavailable.

**Scientific boundary:** A numerical difference or agreement is not a significance test, uncertainty bound or proof of reproducibility across independent experiments. Missing compatibility remains unknown rather than implicitly true.

**Related documentation:**

- [Technical reference source — comparison](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/comparison.md)
- [Executable tutorial — trajectories](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/trajectories.md)

**Evidence:** SOURCE_SUPPORTED. Scientific declarations are USER_ASSUMPTION where stated; linked executions are HISTORICAL_VERIFICATION, not new Wiki runs.

---

[Return to the FAQ index](FAQ-Index) · [Wiki home](Home)
