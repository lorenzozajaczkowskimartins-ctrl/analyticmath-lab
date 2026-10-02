# M10A M8 inventory

The recovered `test/m10a_atomistic_statistics.jl` was coherent and is retained
unchanged. It passes 290 assertions without Molly or another optional stack.
All rows below refer to named testsets in that file.

| Subsystem / object | Mathematical obligation | Independent oracle | Tolerance / exactness | Status / regression | Finding / limitation |
|---|---|---|---|---|---|
| Geometry / pair distances | Symmetry, self zero, unordered pair population, 2D/3D order | 3–4–5 coordinates, direct Euclidean norm; explicit pair list | Exact pair/index/zero assertions, default Float64 `≈` for distances | Verified: Geometry | Private distance primitive used only for self-distance, absent from public unordered pair enumeration |
| Geometry / periodic distances and RDF | Multi-box minimum image; dimensional shells | 29→-1 in length 10; annulus volumes and 3D spherical shells | Float64 `≈`; exact populations | Verified: Geometry | Supported orthorhombic boundaries only; unsupported dimensions/boundaries return unknown |
| LJ potential | 4ε[(σ/r)^12-(σ/r)^6]; F=-dV/dr; rmin=2^(1/6)σ, Vmin=-ε, curvature | Explicit scalar formula and independent AD of it | V/F 1e-11 relative +1e-12 absolute; equilibrium force 1e-10; curvature AD 1e-10 relative | Verified: LJ formula/sign | Repulsive/attractive regions tested; no cutoff or many-body claim |
| Atomistic modes | Particle-major Cartesian masses, equilibrium order, residual, translations | Explicit spring-block K and diag(2,2,3,3); λ=(0,0,2.5,2.5); direct residual and translation projector | Residual <1e-11; orthogonality/projector 1e-12 | Verified: Cartesian mode bridge | Caller Hessian equilibrium remains not verified; translation claim justified only by this constructed spring fixture |
| Moments / running statistics | Mean, sample variance, prefix values | [1,2,3,4], mean 5/2 and variance 5/3 | Exact rational-derived values or Float64 `≈` | Verified: Hand moments | Missing/constant data do not manufacture uncertainty |
| Correlation / IAT / ESS | Biased N vs unbiased N-lag covariance; window and clamping; ESS | Hand autocovariances, τ=3/4 samples, ESS=8/3, SEM=sqrt(5/8) | Exact discrete metadata; Float64 `≈`, cancellation 1e-14 | Verified: Hand moments | Finite descriptive estimates, not stationarity/mixing certificates |
| Blocking | Block means, discarded tails, counts, variance/SEM | [1,2,3,4,99] with block sizes 2 and 3 | Exact arrays | Verified: Hand moments | Discard is explicit; too few blocks give unavailable uncertainty |
| Time metadata | stride is not dt; missing timestamps stay missing; index time not physical time | Explicit interval 0.5 vs dt=0.1 and stride=5; unknown and irregular clocks | Exact metadata/exception assertions | Verified: Time honesty | IAT/VACF require regular physical or explicitly declared index time; no fabricated timestamps |
| MSD / VACF | Displacement and pair/origin averages | Hand two-particle frames: MSD=(0,2.5,10), VACF=(35/3,10,15/2) | Float64 `≈`; exact counts/time | Verified: Time honesty | Single-origin MSD; irregular-time MSD is allowed at explicit elapsed times, stationary-lag VACF is refused |
| Mechanical observations | K=Σmv²/2, E=K+V, momentum, COM, temperature | Unequal masses and Unitful fixture: K=7J,V=-3J,E=4J, P=(0,4), COM=(4/3,0); T=2K/(dof kB) | Exact where representable, otherwise unit-aware `≈` | Verified: Mechanical observations | Temperature requires both caller DOF and Boltzmann constant; neither is inferred |
| NVE / diagnostics | Conservation expectation only for total energy; false is not proof of nonconservation | All nine energy-kind/ensemble combinations plus constant kinetic series | Exact boolean semantics; explicit deviation/slope arithmetic | Verified: Mechanical observations | Existing fix `1bb7897` protected, not rediscovered as a new source bug |
| Comparison | Stored difference B-A; independent uncertainty only with assumptions | Shifted hand series and sqrt(SEM_A²+SEM_B²) | Exact sign; Float64 `≈` uncertainty | Verified: Stored B-A | Self-comparison and incompatible uncertainty windows do not imply independent uncertainty |
| Comparison refusal | Incompatible units, grids, shapes, clocks, coordinate conventions, estimators | Deliberately incompatible pairs; assert no difference value | Exact compatibility checks and `nothing` | Verified: Stored B-A | No automatic truncation, interpolation, alignment or resampling |

Default Float64 `≈` is used only for small well-scaled hand fixtures, not as a
universal scientific error bound. Numeric-type stress and large trajectories are
M10B/C, not this audit. See `m10a_audit.md` for the overall ledger.
