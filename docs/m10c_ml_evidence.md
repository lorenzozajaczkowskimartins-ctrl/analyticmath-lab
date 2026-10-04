# M10C scientific-ML workstream evidence

Consolidation supplement (supersedes the relevant handoff gaps below): public
sized stateful generators were subsequently found to repeat side effects under
the length-trait optimization. Parent red log `m10c-consolidation-iterator-red.log`
records16 calls instead of4. Public non-array inputs now snapshot once; private
deterministic field/residual maps call `_sampled_summary_replayable` explicitly.
`m10c-final-focused.log` passed326 checks, including added generator regression;
100k/1m allocation confirmation remains320 bytes summary /976 field-summary.
Historical benchmark timings are retained, not presented as fresh measurements
of this mechanically equivalent array reduction after helper extraction.
Generalization scaling is closed by the parent bounded `generalization_scale.jl`
gate; see consolidated results for its actual exit and rows. No public PINN result
redesign, million-neural prediction, or extreme training is implied.

Baseline: `091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93`. This is a **partial workstream report**, not a milestone-complete claim. Stopped expansion on the user's credit-containment directive. No canonical suite, final review, commit, push, tag, GPU claim or M10D work performed here.

## Implemented and verified

- `sampled_summary`: mapped normalized reductions replace three full-size temporary arrays. Machine-float scratch allocation is bounded; arbitrary-precision arithmetic still allocates scalar BigFloat intermediates. Unknown-size iterators retain the materializing fallback. Stateful iterator and stateful-generator regressions pass.
- `field_errors(...; summary_only=true)`: returns `absolute=nothing`, no retained difference/absolute vectors; default result contract unchanged. Float32, Float64, BigFloat, rational, overflow, subnormal and invalid-input contracts verified through focused M10C/M10B tests.
- ScientificModel Lux/DeepONet `predict(...; batch_size=...)`: bounds query activation width, retaining the required O(N) output. Explicit opt-in is valid for query-independent networks, NOT arbitrary networks coupling query columns. PINN prediction forwards the same keyword through the single-line core wrapper change in `src/scientific_ml/pinn.jl`.
- `heat_residual(...; summary_only=true)`: no retained residual vector; deterministic repeated AD evaluation trades increased work/cumulative allocation for reduced live storage.
- Internal PINN `_sample_residual(...; summary_only=true)`: scaled online moments over fixed-size NeuralPDE residual blocks; padding is excluded. Verified against full output at 17 and 10,000 points. This is internal only; public `analyze_pinn` still retains full residual values.

## Break → harden → same-size → larger

Original preserved M10C test SHA256: `f86d82864dd1f37fe8d537201a79c6b0f6b708999814e28e6f741a383d3b6b3b`. Original assertions were not weakened or removed; residual/stateful tests were added.

At 100,000 existing Float64 inputs, warmed baseline summary allocated **2,400,536 B**, and baseline full field_errors **6,401,520 B**. RED exited 1 with the expected allocation assertion and missing `summary_only` keyword. After the fix, existing-input summary allocated **320 B**, summary-only errors **976 B**, at both **100,000 and 1,000,000** values. These are kernel allocations, not RSS. The structured million-query report below additionally allocates its input arrays inside each measured call, explaining its O(N) total allocated bytes.

Batch prediction at 10,000 queries: surrogate unsplit 6,082,368 B / chunked 8,871,792 B; DeepONet unsplit 7,042,312 B / chunked 9,821,512 B. **Cumulative allocation increased** due to repeated dispatch/normalization/classification. Chunking bounds live activation shapes, not total allocation; no isolated peak-RSS reduction was measured. Small split/unsplit numerical oracles passed for chunk sizes 1, 2, 5 and 20, plus 10k queries at chunk 128.

PINN residuals, backend batch=2, 10k points: full 0.00251853 s / 5,165,432 B allocated / 107,968 B result capacity; summary 0.004862605 s / 7,035,872 B allocated / 56 B result. At 17 points: full 0.000146567 s / 12,864 B / 312 B result; summary 0.00005622 s / 16,112 B / 56 B result. These timings are local single warmed observations; summaries reduce retained values, not AD/backend cumulative allocation. PINN split/unsplit prediction passed at chunk sizes 1,4,17,32.

## Executed CPU training characterization

Architecture: Float64 CPU Lux `2 → width(tanh) → width(tanh) → 1`, deterministic Xoshiro(1042), batch manufactured target `x1 - 2*x2`, Adam(1e-3), Zygote gradient. Small: width16, batch32, **337 parameters**; local: width128, batch256, **17,025 parameters**. Both completed forward, backward, optimizer-state construction, optimizer update, and three actual gradient/update steps per measurement. A central finite-difference parameter component independently checks the gradient (errors below 7e-11). Local parameter object 136,248 B; gradient 136,248 B; Adam state 272,552 B. Optimizer-step timing includes objective evaluation and uses the measured fixed gradient; the separate three-step row recomputes gradients.

The first setup/gradient oracle compiles before harness measurement and is **not timed separately**; harness warmup timings are separate but are not full cold-start costs. Three optimization steps are only computational observations, never scientific convergence evidence. No large training or GPU execution occurred.

Before the containment message arrived, an explicit extreme **preflight only** was requested: 268,517,377 estimated parameters, 34,367,602,784 B workspace. It was refused against the 536,870,912 B workload budget **before Lux model/setup allocation**. This is not an executed extreme model. Small/local reports were preserved before the refusal report overwrote the default filename.

## Machine and safety

Julia 1.12.7; CPU 13th Gen Intel Core i7-1355U; Julia threads=1; BLAS threads=1. Workload estimated-storage budget 512 MiB; harness budget120 seconds per measured workload (cooperative); external timeout360 seconds per process, TERM then KILL after10 seconds; all Julia jobs serialized with the shared flock. The budget is **not a process-RSS cap**: package/JIT process high-water RSS was about 1.3–1.6 GB. No OOM occurred. Estimates are workload payload/workspace, not allocator totals or exact peak guarantees. No new dependencies installed. Optional environment manifests were reused. Package precompilation emitted existing-version-loaded warnings but gates completed.

## Copy/materialization audit

| Path | Classification and disposition |
|---|---|
| PINNPoints coordinate conversion | Intentional owned, checked Float64 snapshot; O(N), measured to 1M. |
| ScientificSample coordinates/input/values | Ownership snapshot intentional. `copy(x)`/`copy(y)` after checked broadcast is a redundant second copy candidate; not isolated/measured or changed in this bounded workstream. |
| ScientificDataset sample container | Shallow sample-reference vector intentional; metadata/domain/sensor deepcopies intentional schema snapshots. Pairwise duplicate-query overlap checks may materialize tuples; no new algorithm claimed. |
| fit_scaling | Concatenates training arrays; potential avoidable O(N) temporary. Measured as part of combined data operation, not isolated/fixed. |
| AffineScaling transform | Three broadcast temporaries plus output remain; stable overflow arithmetic preserved. Combined million-query data rung measured, no unproven mechanical rewrite. |
| field_errors / sampled_summary | Proven unnecessary materialization fixed (ledger classes A/E/F); full absolute output intentionally remains O(N). |
| GeneralizationAnalysis | Case predictions/references intentionally retained under existing result contract; group `vcat` copies and per-coordinate temporary arrays remain. **Not scaled/measured or optimized here.** |
| Lux prediction | Repeat/vcat/scaling arrays required by current coordinate-network representation; bounded per requested chunk. Output required O(N). DeepONet repeats small branch evaluation per chunk. |
| PINN prediction | Checked CPU Float64 coordinate/output copies intentional; bounded chunk copies replace giant activation request. |
| NeuralPDE residual | Backend fixed collocation block and SII state snapshots intentional. Summary path removes growing retained values; backend allocations remain. |
| training_data | Explicit owned training-only batch snapshot prevents held-out leakage; full-batch backend remains. No minibatch training redesign. |

## Exact remaining scope / acceptance gaps

1. Section39 GeneralizationAnalysis scaling was audited but **not exercised at 10k/100k/1M**; no summary-only/chunk forwarding added to its public analyzer.
2. Section42 public PINN `analyze_pinn` does **not** expose internal residual summary-only mode; public heat_residual does. Public PINN reference analysis still stores predictions/reference/error arrays under its existing contract.
3. Million-query data/field analysis actually completed; million-query **neural prediction** was not executed (10k optional prediction was). No claim that these are equivalent workloads.
4. New practical maximum beyond the completed 1M data /10k optional residual/query /17,025-parameter CPU cases is unmeasured. No 100k/1M optional collocation, stress-tier training, or extreme training executed.
5. No isolated peak-RSS or allocation attribution for fit_scaling, AffineScaling, ScientificDataset, or GeneralizationAnalysis. No new figure generated by this workstream. Structured data are retained for parent plotting/report integration.
6. Cold model/setup/gradient compilation not separately measured. Do not infer cold-start latency from warmed rows.
7. Canonical/finalization work belongs to parent. Current focused gates are valid; do not repeat them merely to regenerate equivalent evidence. Last production changes after gates are docstrings only; last test-only addition (stateful iterators) passed without a source change.

## Reproduction and gate exits

All commands start with this exact prefix (root repository working directory):

```sh
flock /home/lorenzozm/.hermes/cache/scratch/m10c-julia.lock timeout --signal=TERM --kill-after=10s 360s env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1
```

Append `julia +release --startup-file=no` and the arguments below; per-command ENV assignments shown belong before `julia`.

| Log (`scratch/m10c-ml-*`) | Command suffix / environment | Exit, actual outcome |
|---|---|---|
| red.log | `--project=. -e 'using AnalyticMathLab; x=fill(3.,100_000); y=fill(1.,100_000); sampled_summary(x); field_errors(x,y); println("baseline_summary_bytes=",@allocated(sampled_summary(x))); println("baseline_errors_bytes=",@allocated(field_errors(x,y))); include("test/m10c_chunking.jl")'` | 1, expected RED |
| green.log | `--project=. -e 'using AnalyticMathLab; include("test/m10c_chunking.jl"); include("test/m10b_diagnostics.jl"); for n in (100_000,1_000_000); x=fill(3.,n); y=fill(1.,n); sampled_summary(x); field_errors(x,y;summary_only=true); println((n=n,summary=@allocated(sampled_summary(x)),errors=@allocated(field_errors(x,y;summary_only=true)))); end'` | 0; 15 M10C +128 M10B |
| chunk-red.log | `--project=examples/operators -e 'include("examples/scaling/optional_scaling_gate.jl"); try OptionalScalingGate.main() catch e; showerror(stdout,e); end; include("test/m10c_chunking.jl")'` | 1, expected missing batch/summary keyword RED; prior parse typo fixed before this RED |
| chunk-green.log | `--project=examples/operators -e 'include("examples/scaling/optional_scaling_gate.jl"); OptionalScalingGate.main(); include("test/m10c_chunking.jl"); include("test/m10b_diagnostics.jl"); include("test/surrogate_diagnostics.jl"); include("examples/operators/m10a_gate.jl"); include("examples/operators/m10b_gate.jl")'` | 0; batching14, core18, M10B128, M9D15, M10A43, optional M10B20 |
| million.log | `AML_SCALE_LEVEL=1`, `--project=. examples/scaling/million_query_analysis.jl` | 0; all14 rows completed |
| training-small.log | `AML_SCALE_LEVEL=0`, `--project=examples/operators examples/scaling/ml_training_stress.jl` | 0; all5 rows completed |
| training-local.log | `AML_SCALE_LEVEL=1`, same script | 0; all5 rows completed |
| pinn-red.log / pinn-green.log | `AML_PINN_SCALE=1`, `--project=examples/pinn examples/scaling/optional_scaling_gate.jl` | 1 expected RED /0 GREEN; 15 M10B +13 M10C |
| training-refusal.log | `AML_SCALE_LEVEL=3 AML_EXTREME=1 AML_ML_TRAIN=1`, `--project=examples/operators examples/scaling/ml_training_stress.jl` | 0; refusal only, no model allocation |
| iterator-red.log | `--project=. test/m10c_chunking.jl` | 0, name notwithstanding: existing stateful fallback already correct; 20/20 assertions, no implementation change |

Level0/1/2/3 separate safe/local/stress/extreme paths. Training2+ additionally requires AML_ML_TRAIN=1, extreme requires AML_EXTREME=1. These manual examples are not wired into canonical CI by this workstream.

## Durable structured measurements

These copy the actual generated CSVs, preserving completed/refused status. `allocated_bytes` includes inputs where created inside the timed closure; `result_bytes` may include borrowed points and vector capacity. Full source/runtime metadata remain in corresponding local TOMLs.

### million_query_analysis.csv

```csv
name,n,estimated_bytes,algorithm,elapsed_seconds,allocated_bytes,result_bytes,output_count,correctness_metric,warmup_seconds,repeats_completed,rss_highwater_bytes,status
"field_full","10000","960000","retained absolute errors","7.78245e-5","321232","80128","10000","0.0","0.000113118","2","1302208512","completed"
"field_summary","10000","960000","fused normalized reductions; no error arrays","0.000115443","161120","80","1","0.0","9.2995e-5","2","1302470656","completed"
"sampled_summary","10000","960000","normalized mapped reductions","3.1019e-5","80392","56","1","0.0","2.8104e-5","2","1302601728","completed"
"scientific_data_scaling","10000","960000","owned Float64 snapshots and affine normalization","0.0012005335","3526064","320632","10000","0.0","1.074497149","2","1382195200","completed"
"field_full","100000","9600000","retained absolute errors","0.0011647530000000001","3201232","800128","100000","0.0","0.001002939","2","1382195200","completed"
"field_summary","100000","9600000","fused normalized reductions; no error arrays","0.001090354","1601120","80","1","0.0","0.001088274","2","1382195200","completed"
"sampled_summary","100000","9600000","normalized mapped reductions","0.0003299905","800392","56","1","0.0","0.000330845","2","1382195200","completed"
"scientific_data_scaling","100000","9600000","owned Float64 snapshots and affine normalization","0.0120961775","35206064","3200632","100000","0.0","0.012791465","2","1388974080","completed"
"field_full","1000000","96000000","retained absolute errors","0.0628566935","32011744","8000128","1000000","0.0","0.014613504","2","1461194752","completed"
"field_summary","1000000","96000000","fused normalized reductions; no error arrays","0.0124200855","16001120","80","1","0.0","0.012328747","2","1461194752","completed"
"sampled_summary","1000000","96000000","normalized mapped reductions","0.0038069035","8000392","56","1","0.0","0.003700467","2","1461194752","completed"
"scientific_data_scaling","1000000","96000000","owned Float64 snapshots and affine normalization","0.38340010950000003","352006064","32000632","1000000","0.0","0.575273159","2","1554526208","completed"
"heat_residual_full","10000","1280000","ForwardDiff coordinate gradient/Hessian; sampled not continuum","0.006824399","12561384","240465","10000","0.0","0.554162833","2","1554526208","completed"
"heat_residual_summary","10000","1280000","ForwardDiff coordinate gradient/Hessian; sampled not continuum","0.0553460905","61921424","160417","1","0.0","0.189763497","2","1554526208","completed"
```

### ml_training_stress_small.csv

```csv
name,n,estimated_bytes,algorithm,elapsed_seconds,allocated_bytes,result_bytes,output_count,correctness_metric,warmup_seconds,repeats_completed,rss_highwater_bytes,status
"forward","337","97888","CPU Float64 Lux dense tanh forward","1.87635e-5","8992","304","32","0.0","3.033e-5","2","1576267776","completed"
"backward","337","97888","Zygote gradient; independent central-difference component oracle","0.00023589599999999998","81088","2744","337","6.975814370591138e-11","0.000444848","2","1576267776","completed"
"optimizer_state","337","97888","Adam state construction; storage measured independently","4.92e-7","6048","5544","337","0.0","5.602e-6","2","1576267776","completed"
"optimizer_step","337","97888","Adam update with fixed measured gradient; includes objective check","2.16505e-5","10640","8","337","0.0","0.243796914","2","1576267776","completed"
"training_three_steps","337","97888","3 CPU Adam steps; computational observation, NOT scientific convergence","0.00023369949999999998","265448","24","3","5.975211753356926","0.000578273","2","1576267776","completed"
```

### ml_training_stress_local.csv

```csv
name,n,estimated_bytes,algorithm,elapsed_seconds,allocated_bytes,result_bytes,output_count,correctness_metric,warmup_seconds,repeats_completed,rss_highwater_bytes,status
"forward","17025","5828704","CPU Float64 Lux dense tanh forward","0.000676456","526888","2096","256","0.0","0.000666832","2","1516392448","completed"
"backward","17025","5828704","Zygote gradient; independent central-difference component oracle","0.001902679","2708328","136248","17025","3.573672607837253e-11","0.001730755","2","1516392448","completed"
"optimizer_state","17025","5828704","Adam state construction; storage measured independently","7.872200000000001e-5","273056","272552","17025","0.0","9.312e-5","2","1516392448","completed"
"optimizer_step","17025","5828704","Adam update with fixed measured gradient; includes objective check","0.0008982549999999999","530336","8","17025","0.0","0.200515429","2","1516392448","completed"
"training_three_steps","17025","5828704","3 CPU Adam steps; computational observation, NOT scientific convergence","0.0293898535","9067376","24","3","0.6284136164470074","0.007573903","2","1517568000","completed"
```

### ml_training_stress.csv

```csv
name,n,estimated_bytes,algorithm,elapsed_seconds,allocated_bytes,result_bytes,output_count,correctness_metric,warmup_seconds,repeats_completed,rss_highwater_bytes,status
"model_preflight","268517377","34367602784","CPU dense Lux + Adam; refused before model allocation","0.0","0","0","0","0.0","0.0","0","1322549248","refused_by_guardrail"
```

## SHA256 provenance

Final workstream sources (docstrings added after numerical verification):

```text
24b5c703d6ed875df403efde6423008e2e441c5e1b7423466139c1b64d595b55  src/scientific_ml/diagnostics.jl
6afd5d8d6f60b7fd4358fea619e13e14b31ca0ec9d454d184c109b1fdcb7c7e0  src/scientific_ml/surrogates.jl
bbc051ea6f70cc0ad73197d02dbe197ada8457453d676a8c928c015679a0c6eb  src/scientific_ml/generalization.jl
5346a375d0869f0236ec66dede5b668e9d572de58b78761a5ab35723622aa6dd  src/scientific_ml/pinn.jl
80e0e261fbf026f63079c5cc81e76860d86bb3d1334bb7043a2ab0e70d063092  ext/AnalyticMathLabSurrogateExt.jl
edf33f447607c8d8721826b2f1aaf15c2b7e08aff42d2c9a983e3bad6682158c  ext/AnalyticMathLabPINNExt.jl
147d970bfc7acd1d02a1fe0c9f570aceab17c7f8f8a5d06b98e30690b130f925  ext/pinn_diagnostics.jl
e3513d89906e56931ffb7d2e055dff582694976e6970b68cb0afb25359f54957  test/m10c_chunking.jl
2d1c7007421ce5fa48d7898e0ca7d44da2970e2a5c5026e1c73ae1d90421f460  examples/scaling/million_query_analysis.jl
a983a43af18a587c82379969b5450c26e6e520336cbcad0eb1fe092ba560b72b  examples/scaling/ml_training_stress.jl
7019c769ea9f163f9b2427fe09c60f00ea7d9474c81011a4945e447a88097d33  examples/scaling/optional_scaling_gate.jl
62ea063ddeafcb0d87d2aa96903e9f1f8c1c2018865b6ed33da09e2189d4f55f  examples/operators/Project.toml
380597a73ba74dcb5fe95be544244a04c03c20aab9570635215fda4d8e10bf50  examples/operators/Manifest.toml
349098d31323e5c511c98db60f0583a441b550872ca9175f26294601811681e8  examples/pinn/Project.toml
a9365be167ede34e5326977808511cc58fe9004b04b6dac405c7c15d72c8c4dd  examples/pinn/Manifest.toml
```

Raw log hashes (local scratch, not required as permanent external artifacts):

```text
5045478a947ef2004777f4a4fc1e962618c2f12190280d1bc6294f92d709d846  m10c-ml-chunk-green.log
2251bd187e525fad9b5bf18dd866291e72e87847690877a39d20d353dd65520a  m10c-ml-chunk-red.log
5099c8dc14989b1b618ab41c7a5831c9f68b538df11a6df47122e87c34897e5b  m10c-ml-green.log
6461dbd9dcb267ca1d826a7de450ea6f7e927cbaeeeee8b174b8ad6991717959  m10c-ml-iterator-red.log
c152725455e9612b111b6997e6f04c374740f591b491a363f2dd7245610745d4  m10c-ml-million.log
b01ac763fe5b34a1fb7336d67de55cc2852ffb9fdc72df8172121ad034a5a612  m10c-ml-pinn-green.log
f99231d11680ec3b2d74f4d9c68782e7ab78e16d7f0b9f80d87cb0add83caeca  m10c-ml-pinn-red.log
7e1194b7ab33b74c2d0f5013cb086964eb95bf445dee74c2f5e8a9bed8a3b468  m10c-ml-red.log
2872d38d41f0f07b42e5ddc3af7c4d4e31f8bf43381034059de91e4a4cf4a1f5  m10c-ml-training-local.log
ff7e0af0c23b5cbd98cc0bf111ec62da35f5fed0ae30377ac53f1290c7859d1d  m10c-ml-training-refusal.log
4cafc2bf11f7b8127673694a2a425c51f561be6be67febff26b41d40b550b047  m10c-ml-training-small.log
```
