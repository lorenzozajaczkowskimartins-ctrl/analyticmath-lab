# M10C A mechanics — durable workstream evidence

## Gate 1: baseline + red (completed)
Recovered inspection reused; first new execution was bounded full normal modes at
n=40,150,600. Julia 1.12.7, Julia/BLAS threads=1. Process exit 1 is the intended
red gate: both new memory-budget assertions failed (unsupported keyword).
Logs and structured source/environment hashes: `$TMPDIR/m10c-mechanics-baseline.log`
and `m10c-mechanics-baseline.toml`. Baseline n=600 warmed repeats 0.183295 / 0.236863 s,
112,999,160 allocated bytes each, result 17,310,815 bytes; single dense payload
2,880,000 bytes, conservative workspace estimate 69,120,000 bytes. Direct generalized
residual and analytic fixed-end chain eigenvalues passed; max eigenvalue error
1.33e-15. No n>600 dense execution yet; no peak RSS measurement.

Finding: full result stores all modes and multiple dense square matrices even for
structured input. This is expected full-output complexity (L), with missing early
resource refusal (I); selecting few modes needs a distinct controlled algorithm (D).

## Gate 2: dense green, optional partial red → green (completed)
`m10c-mechanics-guard-green.log`: 2/2 passed, exit 0. Preflight now precedes
coefficient access and uses overflow-safe BigInt 24*8*n² numeric workspace
estimate, default 512 MiB; public full-mode result semantics unchanged.
`m10c-mechanics-partial-red.log`: missing controlled route assertion failed.
`m10c-mechanics-partial-green2.log`: optional chain comparisons passed, exit 0
(after correcting a main-guard parse typo recorded in `partial-green.log`).
Separate examples/scaling environment declares ArnoldiMethod 0.4 directly;
root Project/Manifest untouched. Existing installed public partialschur/partialeigen
backend reuses structured shift-inverse LU, no homegrown eigensolver. Chain H*v
is matrix-free; its inverse is structured tridiagonal, not a generic symbolic HVP.
Tests compare against dense full modes with nonuniform positive masses, negative
and numerical-zero eigenvalues, direct KΦ-MΦΛ and mass orthogonality. Irreducible
chain spectra are simple; no general repeated-eigenspace completeness claim.
Partial classification uses full operator norm bound, not truncated spectral max.

## Gate 3: same-size and larger ladder (completed)
`m10c-mechanics-ladder2.log` exited 0. CSV/TOML reports under output/scaling
include source/environment SHA256, Julia/BLAS=1, local CPU, process-lifetime RSS.
Dense n=600 rerun: 0.266491 s, 113,013,384 allocations, same eigenvalue error
1.33e-15; guard is not a dense speedup. Largest dense completed n=1200:
1.823054 s, 450,708,424 allocated bytes, 69,180,215-byte result, estimated numeric
workspace 276,480,000 bytes. n=3000/6000/10000/15000/30000 full solves refused;
no allocation or numerical result at those rungs. One 30000² Float64 Hessian alone
is 7,200,000,000 bytes; 24-payload full-mode estimate 172,800,000,000 bytes.
Partial n=600 k=4: 0.00024535 s / 395,504 allocated bytes / 19,604-byte result.
Largest partial completed n=30000 k=4: 0.01421637 s / 17,800,304 allocated bytes /
960,404-byte result / estimate 34,112,000 bytes, direct residual 1.01e-15.
Both analytic eigenvalues and orthogonality asserted independently. This measures
four modes, not a replacement for the full spectrum/reconstruction output.
RSS high-water reached 1,780,940,800 bytes including Julia/compiler/backend history;
512 MiB is the operation estimate budget, NOT a process RSS ceiling.

## Gate 4: bounded showcases and affected regressions (completed)
Credit-containment instruction honored: no further stress ladders or optional
extremes. `m10c-mechanics-showcases-regression.log` exited 0: symbolic n=5,10,20,
AML Lagrangian/EL/linearization/modal/dynamics n=3,5, structured chain ODE n=150,600;
M10A mechanics 51/51 and M10B linear algebra 90/90 passed. Existing dense zero,
negative, anchored degenerate-group, underflow and ill-conditioned-mass semantics
remain covered. No canonical test, final review, commit, push, tag or M10D run.
`m10c-mechanics-final-focused.log` exited 0: 56/56 focused checks (4 root guard,
52 optional partial checks) and 36 symbolic phase rows completed. Added unreadable
matrix of dimension typemax(Int) proves refusal before coefficient access without
allocating a giant matrix. Final `git diff --check` exit 0.

The final symbolic rerun corrected a measurement detail: simplification repeats
always receive the original differentiated object, not the previously simplified
result. Initial symbolic runs exposed benchmark-only issues: substitution needs
`fold=Val(true)` and symbolic `abs2` creates unsupported syntax in AML's smooth-domain
check; the real polynomial now uses explicit square. No AML domain check was bypassed.

### Largest completed local workloads

| Path | Completed n | Warmed seconds | Allocated bytes | Result bytes | Oracle |
|---|---:|---:|---:|---:|---|
| Dense full modes | 1200 | 1.823054 | 450708424 | 69180215 | eigenvalues 1.78e-15; direct residual asserted |
| Partial four modes | 30000 | 0.01421637 | 17800304 | 960404 | direct residual 1.01e-15; orthogonality and exact chain eigenvalues |
| AML EL analysis | 5 | 0.03580517 | 15415640 | 31494 | established accelerations; extracted M/K |
| AML symbolic dynamics | 5 | 0.00171191 | 1775680 | 71206 | analytic mode trajectory error 6.25e-12 |
| Matrix-free chain ODE | 600 | 0.00032273 | 215920 | 183936 | relative state error 7.29e-11; energy drift <1e-7; five states |
| Symbolic Hessian differentiation | 20 | 0.00134316 | 462408 | 33528 | generated H=K+3diag(q²) |
| Symbolic Hessian simplification | 20 | 0.00118200 | 564568 | 33528 | sampled exact polynomial oracle |
| Symbolic Jacobian differentiation | 20 (40 states) | 0.00038927 | 153776 | 43168 | mechanical block Jacobian |
| Symbolic Jacobian simplification | 20 (40 states) | 0.00125109 | 574168 | 43168 | generated block oracle |
| AD dense Hessian | 20 | 0.00006763 | 415808 | 3248 | same H oracle |
| AD dense Jacobian | 20 (40 states) | 0.00001092 | 77664 | 12848 | same block oracle |
| AML scalar analysis | 20 | 0.00970054 | 6875720 | 134102 | public Hessian evaluated against H oracle |

Hessian/Jacobian generated-callable construction at n=20: 0.00050005/0.00158207 s;
first invocation compilation+execution 0.06138393/0.11282661 s; warmed evaluation
0.00016346/0.02519639 s. Two repeats are descriptive, not reliable microbenchmark
rankings (the Jacobian warmed sample is visibly noisy). Printed-expression length
proxy: energy 478 chars, Hessian 1072, Jacobian 3474 at n=20. Explicit containers
retain 400/1600 derivative entries, including zero blocks; no generic sparse symbolic
machinery introduced. Symbolic preprocessing dominates numeric modal solve already
at n=5 (0.0358 s EL versus 0.000243 s full modes); no pathological-growth boundary
was established with these bounded runs. Memory estimates are family-specific
numeric/graph allowances, not generic symbolic or peak-RSS guarantees.

Reports: `output/scaling/{when_dense_dies,partial_modes,mass_spring_mechanics,
symbolic_mechanics_scaling}.{csv,toml}`. Row counts verified in code: respectively
17 (12 completed, 5 refused), 5 completed, 14 completed, 36 completed. Output
artifacts are local/ignored; tables here preserve lightweight durable evidence.
Metadata distinguishes operation storage estimates, total allocation, output
summarysize and process-lifetime RSS (showcase process reached 2,033,778,688 bytes).

### Commands, exits and provenance
All Julia invocations used this serialization/deadline prefix; lock wait is outside
timeout, no concurrent heavy job launched by this workstream:

```sh
flock /home/lorenzozm/.hermes/cache/scratch/m10c-julia.lock \
  timeout --signal=TERM --kill-after=10s 300s \
  env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 [EXTRA_ENV] \
  julia +release --startup-file=no [ARGS]
```

Workdir `/home/lorenzozm/PROJETOS/analyticmath-lab`; logs all under
`/home/lorenzozm/.hermes/cache/scratch/` with prefix `m10c-mechanics-`.

| Log suffix | Extra env / arguments after prefix | Exit |
|---|---|---:|
| baseline.log | `--project=. /home/lorenzozm/.hermes/cache/scratch/m10c-mechanics-baseline.jl` | 1 expected red after successful baseline |
| guard-green.log | `--project=. -e 'include("test/m10c_partial_modes.jl")'` | 0 |
| environment.log | `JULIA_PKG_PRECOMPILE_AUTO=0 --project=examples/scaling -e 'using Pkg; Pkg.develop(path="."); Pkg.resolve()'` (root manifest copied to separate environment first) | 0 |
| partial-red.log | `AML_PARTIAL_TEST=1 --project=examples/scaling -e 'include("test/m10c_partial_modes.jl")'` | 1 expected missing route |
| partial-green.log | same optional command | 1 main-guard parse typo |
| partial-green2.log | same optional command | 0 |
| ladder.log | next row command | 1 invalid docstring on using statement |
| ladder2.log | `AML_SCALE_LEVEL=1 --project=examples/scaling -e 'include("examples/scaling/when_dense_dies.jl"); when_dense_dies_main(); include("examples/scaling/partial_modes.jl"); partial_modes_main()'` | 0 |
| symbolic.log | `AML_SCALE_LEVEL=1 --project=examples/scaling examples/scaling/symbolic_mechanics_scaling.jl` | 1 benchmark substitution (no rung complete) |
| symbolic2.log | same symbolic command | 1 benchmark abs2/smooth-domain (no rung complete) |
| showcases-regression.log | `--project=examples/scaling -e 'include("examples/scaling/symbolic_mechanics_scaling.jl"); symbolic_mechanics_main(); include("examples/scaling/mass_spring_mechanics.jl"); mass_spring_mechanics_main(); include("test/m10a_mechanics.jl"); include("test/m10b_linear_algebra.jl")'` | 0 |
| final-focused.log | `AML_PARTIAL_TEST=1 --project=examples/scaling -e 'include("test/m10c_partial_modes.jl"); include("examples/scaling/symbolic_mechanics_scaling.jl"); symbolic_mechanics_main()'` | 0 |

Baseline source SHA256 `f5e3ed0fbba81b6d9cd65b32c9e8670386e78f098a8091b80a67f8bd8d4dec53`.
Root environment unchanged from baseline. Each result TOML snapshots exact sources
and environments at that run; later files added by other workstreams need not match
an earlier report's global snapshot. Final owned source/environment hashes:

```text
src/mechanics/normal_modes.jl cb0505f57a588b4d8be4554e247465da02a272d647dfa44b263191455aee8f17
test/m10c_partial_modes.jl fe466ece3fea305de397b8db7f09faf8a4573dd55d02086875cd41a89d8f385e
examples/scaling/partial_modes.jl ec972c16fe1a6a6525dc611781012ec17f2b0933bebc653d54ee406436189697
examples/scaling/when_dense_dies.jl ed2b21d093f64c485f13d60a01f448a74b1a94d275229098ca4abb60df89641b
examples/scaling/symbolic_mechanics_scaling.jl bf2025fdf07181ed2f53852f74e63005a96be480a73837de0bc913d1d684a044
examples/scaling/mass_spring_mechanics.jl 7644bd2ea03634efc88775e269329e617a941f4169a055bcbc7071735b641941
examples/scaling/Project.toml e12d067e7ecde22cb3413a218467c8719f2e5f30820943826056b6e82ec447e1
examples/scaling/Manifest.toml f9cef0289cc9ca7b2974ae377d13af9d61ea0d1a93f9ffa04fdfaa13e969993a
Project.toml 0510651309bdebacd958aa84cab26f40d0182571f1b42e037b8d013a8f513ded
Manifest.toml 917e1c48212f5f54267dbda5650adfae9e314390695d5a67cdb75f5c577c7c72
```

### Remaining scope / exact handoff
- Parent must integrate root guard test in shared runner (4 tests); optional small
  partial comparison requires separate scaling environment and AML_PARTIAL_TEST=1.
- No new source include/export is needed. Partial algorithm is an explicitly
  controlled example route, not a new public generic partial_modes API.
- Full dense >1200 was refused, not executed. Symbolic 50/100 tiers and structured
  ODE 3000 tier are script-supported, unexecuted; no more ladders under containment.
- No generic sparse SPD generalized eigenproblem, arbitrary HVP, degenerate partial
  eigenspace completeness, or hardware-independent performance claim is made.
- General-purpose figure generation and consolidated inventory/ledger/results are
  parent-owned; this workstream produced structured tables, not rendered figures.
- Canonical suite/final review/publication are parent-owned and intentionally not run.
- Current A implementation and bounded verification complete; no pending Julia job.
