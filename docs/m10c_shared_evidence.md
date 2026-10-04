# M10C shared harness, statistics and atomistic evidence

These are local measurements, not general speed rankings. Julia 1.12.7;
Intel i7-1355U; 16,433,725,440 bytes RAM observed at recovery; Julia/BLAS threads 1;
default estimate budget 536,870,912 bytes, cooperative wall budget 120 seconds.
All Julia jobs use the common scratch `m10c-julia.lock` and external timeout.

## Recovery and executed gates

Existing harness test was reused unchanged: `m10c-harness-red.log` failed because
harness.jl was missing; after implementation `m10c-harness-green.log` passed 21.
New `m10c-streaming-red.log` failed for missing helper; green passed 16.
`m10c-atomistic-red.log` measured baseline and failed missing byte preflight;
`m10c-atomistic-allocation-red.log` measured 256 bytes for one warmed tuple distance
and failed the <128-byte regression. Logs are in `~/.hermes/cache/scratch/`.

`m10c-atomistic-green.log` exited 0:
- M10C atomistic: 10 checks (then a redundant same-process inclusion, not extra unique tests).
- affected M10A M8: 290 checks.
- affected M10B atomistic: 49+33+4+60 checks.
- M10B statistics: 419 checks.

Command: `flock ~/.hermes/cache/scratch/m10c-julia.lock timeout --signal=TERM --kill-after=10s 300s env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --startup-file=no --project=. -e 'include("test/m10c_atomistic_scale.jl"); include("test/m10a_atomistic_statistics.jl"); include("test/m10b_atomistic.jl"); include("test/m10b_statistics.jl"); include("/home/lorenzozm/.hermes/cache/scratch/m10c-atomistic-baseline.jl")'`.

## Statistics: inspected risk disproved, no production rewrite

Existing M10B `_ts_moments` already provides constant auxiliary storage for lazy
vectors. Baseline (`m10c-statistics-baseline.log`): range input 100,000 / 1,000,000
observations allocated 784 bytes at both sizes, warmed 0.000521477 / 0.00535215 s.
There is no measured per-sample boxing defect in this tested Float64 route.
Preserve the existing robust sample-variance recurrence instead of replacing it.

The example adds a lazy vector and deadline-aware iterator around that existing
kernel. No per-sample history is retained; deadline checks happen once per chunk.
Requested and consumed counts are separate; timeout summarizes only the consumed
prefix. No independent-sample standard error is invented.

Local example (`m10c-million_sample_statistics-local-v2.log`, exit 0):

| observations | lazy allocated bytes | stored-path allocated bytes | lazy warmed seconds | sample variance absolute error |
|---|---:|---:|---:|---:|
| 100000 | 864 | 801080 | 0.000586192 | 1.5321e-14 |
| 1000000 | 864 | 8004584 | 0.005879646 | 1.9456e-12 |

Largest completed stream so far: 1,000,000. 10^10 was NOT completed or benchmarked.
The focused test constructs a lazy 10^10 request under explicit opt-in and an
already-expired eps()-second deadline; this verifies bounded refusal/termination,
not a completed extreme workload. The CLI supports --samples, --chunk-size and
--max-seconds. Requests >=10^8 require AML_EXTREME=1.

Full running means are intentionally O(N) output. BlockAnalysis retains block
means and materializes scalar observations. ACF uses O(N+lags) storage and
O(N*lags) work with full-sample centering. The local example measures only a
10,000-sample prefix for those contracts; it does not relabel them as streaming
extreme estimators or extrapolate their scientific results.

## Atomistic: measured copies and explicit-output boundary

Root cause: `_at_distance` collected both fixed-dimension tuples, then allocated
their difference for every pair. Keep tuple subtraction as a tuple; retain
LinearAlgebra.norm and all existing boundary/backend semantics. The shared helper
also serves coordination and RDF. Vector inputs retain their prior behavior.
Add a byte-estimate preflight alongside existing max_pairs; refusal reports N,
pair count, estimated bytes and bounded-output alternatives. The 64-byte/pair
estimate plus index arrays is a fixed-width output estimate, not a guarantee for
arbitrary-precision values, allocator overhead or peak RSS.

| N | pairs | before allocated | after allocated | same-size result bytes |
|---:|---:|---:|---:|---:|
| 100 | 4950 | 1709336 | 680064 | 196569 |
| 500 | 124750 | 45405288 | 19454688 | 5189993 |

Local larger rerun (`m10c-large_atomistic_geometry-local-v2.log`, exit 0):
N=1000, 499500 explicit pairs, 0.0407022885 warmed seconds, 69198032 allocated bytes,
16674225 result bytes. Coordination at the same N retained 16286 bytes, traversing
all pairs (still quadratic work), and matched endpoint count1/interior count2.

Geometry inputs with 10,000 and 100,000 particles were created, but their explicit
pair outputs were REFUSED BY GUARDRAIL before distance traversal. The respective
harness output estimates were 3,200,320,000 and 320,003,200,000 bytes. These are
ESTIMATED sizes, not allocated pair collections. No neighbor/force engine added.

## Artifacts and remaining integration

Machine-readable completed rows: `output/scaling/statistics.csv`, `atomistic.csv`;
companion TOML includes environment and source SHA-256 snapshots. RSS is process
lifetime high-water RSS, never called per-operation allocation/peak.
Initial statistics script failed to parse its unparenthesized @__FILE__ main guard;
that script-only failure was fixed in all four sibling wrappers before any work
executed. Original failure log retained.

Shared harness deadline is cooperative between function calls. External timeout
is required to bound a noncooperative backend. Completed CSV/TOML checkpoints are
atomically replaced after each rung. Do not interpret compilation or lock waiting
as warmed kernel time.

Pending: integrate small tests in canonical runner, report/figure inspection,
final source-identity validation and final verification. Credit containment is
active: no optional extreme run, no giant training, no speculative extra ladder.
