# Proposed GitHub Wiki question inventory

Questions are scoped to actual AML contracts. This is an index/design, not finished Wiki prose. Technical reference destinations are proposed, not deployed links. Resource questions await the detailed refusal audit before marking answer-ready.

## Getting Started

- Q001 [P1] How do I install AML from this checkout? — `installation.md`; evidence: Project.toml:1-63; README.md:63-75
- Q002 [P1] What can I use after only using AnalyticMathLab? — `installation.md`; evidence: docs/m10d_user_research_hardening.md:8-36
- Q003 [P1] Why does the first import take time? — `installation.md`; evidence: docs/m10d_user_research_hardening.md:25-29
- Q004 [P1] Which example should I run first? — `installation.md`; evidence: notebooks/function_analysis.jl:1-22
- Q005 [P1] Do I need to force Julia or BLAS to one thread? — `installation.md`; evidence: docs/m10d_user_research_hardening.md:18-23

## Calculus and Symbolics

- Q006 [P1] Why did simplifying x/x lose the exclusion at zero? — `reference/scalar.md`; evidence: README.md:149-156
- Q007 [P1] Does evaluate enforce the original real domain? — `reference/scalar.md`; evidence: README.md:205-209
- Q008 [P1] Why are some exact roots unknown? — `reference/scalar.md`; evidence: README.md:166-179
- Q009 [P1] Does an empty stationary search prove there are no critical points? — `reference/scalar.md`; evidence: README.md:299-341
- Q010 [P1] Can I analyze a Julia function or a string? — `reference/scalar.md`; evidence: README.md:347-354

## Linear Algebra

- Q011 [P1] Does AML provide general-purpose matrix analysis? — `reference/modes.md`; evidence: README.md:439-444; docs/m10d_architecture_inventory.md:65
- Q012 [P1] Why does normal_modes take stiffness before mass? — `reference/modes.md`; evidence: docs/m10d_architecture_inventory.md:65
- Q013 [P1] Does sparse matrix input imply a sparse eigensolver? — `reference/modes.md`; evidence: docs/m10d_user_research_hardening.md:114-122
- Q014 [P1] What do zero, negative and degenerate modes mean? — `reference/modes.md`; evidence: test/normal_modes.jl; test/mode_contracts.jl
- Q015 [P1] Does a Hessian at a snapshot establish equilibrium? — `reference/modes.md`; evidence: docs/m10d_architecture_inventory.md:65

## Vector Calculus

- Q016 [P1] Can vector fields be rectangular maps? — `reference/vector.md`; evidence: README.md:548-550
- Q017 [P1] Why does curl return unknown outside supported dimensions? — `reference/vector.md`; evidence: README.md:550-552
- Q018 [P1] Why is zero curl not enough to certify a potential? — `reference/vector.md`; evidence: README.md:561-565
- Q019 [P1] How are numerical derivatives at a corner refused? — `reference/vector.md`; evidence: README.md:502-508; README.md:554-559
- Q020 [P1] Does linearization prove anything away from its base point? — `reference/vector.md`; evidence: docs/m10d_architecture_inventory.md:57-58

## Numerical Methods

- Q021 [P1] Are derivative comparison errors certified bounds? — `guides/precision.md`; evidence: README.md:106-111
- Q022 [P1] Why can a smaller finite-difference step be worse? — `guides/precision.md`; evidence: README.md:243-282
- Q023 [P1] What does missing relative error mean at a zero reference? — `guides/precision.md`; evidence: README.md:257-263
- Q024 [P1] Why is observed convergence order missing? — `guides/precision.md`; evidence: README.md:270-282
- Q025 [P1] Which tolerance accepts a stationary candidate? — `guides/precision.md`; evidence: README.md:324-340

## Differential Equations

- Q026 [P1] What does a successful trajectory solve establish? — `reference/dynamics.md`; evidence: README.md:602-609
- Q027 [P1] Can FirstOrderODE be passed directly to analyze? — `reference/dynamics.md`; evidence: docs/m10d_architecture_inventory.md:126-129
- Q028 [P1] Does saveat authorize interpolation in stored-data bridges? — `reference/dynamics.md`; evidence: examples/integration/one_system_many_methods.jl:97-108; docs/m10d_user_research_hardening.md:62-64
- Q029 [P1] Why are state and time converted to Float64? — `reference/dynamics.md`; evidence: docs/m10d_architecture_inventory.md:60
- Q030 [P1] Are domain callbacks rigorous boundary tracking? — `reference/dynamics.md`; evidence: README.md:607-609

## Mechanics and Dynamics

- Q031 [P1] Which coordinate and momentum order does AML use? — `reference/mechanics.md`; evidence: docs/m10d_architecture_inventory.md:61-62
- Q032 [P1] When can AML establish a Legendre transform? — `reference/mechanics.md`; evidence: docs/m10d_architecture_inventory.md:63
- Q033 [P1] Does sampled energy drift prove conservation? — `reference/mechanics.md`; evidence: examples/integration/one_system_plots.jl:20-29
- Q034 [P1] Why do imaginary eigenvalues not decide nonlinear stability? — `reference/mechanics.md`; evidence: README.md:602-606
- Q035 [P1] How do I compare analytical and numerical descriptions of one system? — `reference/mechanics.md`; evidence: examples/integration/one_system_many_methods.jl:111-201

## Trajectories

- Q036 [P1] How do I select a stored component without guessing physical identity? — `reference/statistics.md`; evidence: docs/m10d_user_research_hardening.md:62-64
- Q037 [P1] Is saved sample spacing the integrator time step? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:70
- Q038 [P1] Are stored trajectory frames copied or lazy? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:66
- Q039 [P1] Why does comparing two stored results refuse missing context? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:76
- Q040 [P1] Does diagnose recompute missing analyses? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:75

## Atomistic Computing

- Q041 [P1] Can I inspect particle data without Molly? — `reference/atomistics.md`; evidence: test/stranger/atomistic.jl
- Q042 [P1] Why does a Molly trajectory require explicit historical assertions? — `reference/atomistics.md`; evidence: docs/m10d_user_research_hardening.md:65-69
- Q043 [P1] What happens when a Molly system has no stored loggers? — `reference/atomistics.md`; evidence: docs/m10d_user_research_hardening.md:65-69
- Q044 [P1] What boundary and distance information is needed for RDF? — `reference/atomistics.md`; evidence: docs/m10d_architecture_inventory.md:69
- Q045 [P1] Is analyze_potential an MD force engine? — `reference/atomistics.md`; evidence: docs/m10d_architecture_inventory.md:68

## Statistics

- Q046 [P1] Why does a moment summary not report an IID standard error? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:71
- Q047 [P1] Do blocking and autocorrelation prove stationarity? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:72-73
- Q048 [P1] Why are missing or nonfinite observations not silently filtered? — `reference/statistics.md`; evidence: docs/m10d_user_research_hardening.md:56-61
- Q049 [P1] Why does diffusion require physical time and an explicit fit window? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:74
- Q050 [P1] Does comparing compatible runs establish independence? — `reference/statistics.md`; evidence: docs/m10d_architecture_inventory.md:76

## Scientific Datasets

- Q051 [P1] Which dataset fields must I declare explicitly? — `reference/datasets.md`; evidence: docs/m10d_user_research_hardening.md:47-50
- Q052 [P1] Why must scalar targets be reshaped for scaling? — `reference/datasets.md`; evidence: docs/m10d_user_research_hardening.md:51-55
- Q053 [P1] How do I avoid train/validation normalization leakage? — `reference/datasets.md`; evidence: docs/m10d_architecture_inventory.md:83
- Q054 [P1] Does a reference kind label certify its quality? — `reference/datasets.md`; evidence: src/scientific_metadata.jl:114-124
- Q055 [P1] Does a numerical trajectory become analytical ground truth when converted? — `reference/datasets.md`; evidence: examples/integration/one_system_many_methods.jl:81-95

## Scientific Machine Learning

- Q056 [P1] Does low PINN loss establish PDE correctness? — `reference/learning.md`; evidence: README.md:26-40
- Q057 [P1] Why does the learning model require explicit RNG provenance? — `reference/learning.md`; evidence: docs/m10d_user_research_hardening.md:98-102
- Q058 [P1] Are learned corrections symbolic discoveries? — `reference/learning.md`; evidence: README.md:41-47
- Q059 [P1] What does the one-step oscillator learning example demonstrate? — `reference/learning.md`; evidence: examples/integration/one_system_learning.jl:52-85
- Q060 [P1] Is local sensitivity the same as global identifiability? — `reference/learning.md`; evidence: README.md:41-46

## Units and Precision

- Q061 [P0] Does a unit string convert numerical data? — `guides/units.md`; evidence: docs/m10d_user_research_hardening.md:114-128
- Q062 [P0] Can compatible Unitful lengths be combined in statistics? — `guides/units.md`; evidence: docs/m10d_user_research_hardening.md:56-61
- Q063 [P0] Why is unknown unit metadata not dimensionless? — `guides/units.md`; evidence: docs/m10d_architecture_inventory.md:37-39
- Q064 [P0] Which paths really preserve BigFloat precision? — `guides/units.md`; evidence: docs/m10d_user_research_hardening.md:116-122; test/m10b_types.jl
- Q065 [P0] Are complex inputs or integers supported everywhere? — `guides/units.md`; evidence: docs/m10d_user_research_hardening.md:116-122

## Memory and Performance

- Q066 [P0] Why was my 3000 x 3000 Hessian rejected, and what can I do? — `guides/resource-limits.md`; evidence: README.md:510-518; src/multivariate_analysis.jl
- Q067 [P0] Is there a global AML memory-budget setter? — `guides/resource-limits.md`; evidence: src/AnalyticMathLab.jl:15-67; examples/scaling/harness.jl
- Q068 [P0] Does a dense matrix size estimate include temporary storage? — `guides/resource-limits.md`; evidence: src/mechanics/normal_modes.jl; examples/scaling/when_dense_dies.jl
- Q069 [P0] Which limits are internal rather than public configuration? — `guides/resource-limits.md`; evidence: src/core/exact_algebra.jl; src/mechanics/normal_modes.jl
- Q070 [P0] Are maintainer scaling scripts supported matrix-free APIs? — `guides/resource-limits.md`; evidence: docs/m10d_architecture_inventory.md:162-178; examples/scaling/partial_modes.jl

## Scientific Evidence and Provenance

- Q071 [P0] What do value, status, method and notes mean? — `reference/evidence.md`; evidence: docs/m10d_architecture_inventory.md:40-42; src/core/contracts.jl
- Q072 [P0] Is unknown evidence the same as false or zero? — `reference/evidence.md`; evidence: README.md:135-139
- Q073 [P0] Does provenance identity affect scientific value equality? — `reference/evidence.md`; evidence: test/m10d_value_compatibility.jl; docs/m10d_semantics_results.md
- Q074 [P0] Can I use an origin token as a persistent reproducibility hash? — `reference/evidence.md`; evidence: src/scientific_metadata.jl:12-22
- Q075 [P0] Why is ancestry unavailable on an isolated PropertyResult? — `reference/evidence.md`; evidence: src/scientific_metadata.jl:52-59

## Optional Extensions

- Q076 [P0] Which exact packages activate each optional extension? — `extensions/index.md`; evidence: Project.toml:19-33
- Q077 [P0] Why does a plain Lux surrogate require NeuralOperators? — `extensions/index.md`; evidence: docs/m10d_user_research_hardening.md:89-96
- Q078 [P0] Can I import AML before its optional backends? — `extensions/index.md`; evidence: test/m10d_user_optional.jl:1-29; docs/m10d_user_research_results.md:73-92
- Q079 [P0] Will AML choose an available backend automatically? — `extensions/index.md`; evidence: docs/m10d_user_research_hardening.md:89-96
- Q080 [P0] Does AML import activate CairoMakie? — `extensions/index.md`; evidence: src/AnalyticMathLab.jl:4-13; docs/m10d_user_research_hardening.md:31-36

## Troubleshooting

- Q081 [P0] Why is analyze not defined for my input type? — `troubleshooting/index.md`; evidence: docs/m10d_architecture_inventory.md:112-133
- Q082 [P0] Why is transform ambiguous after importing another library? — `troubleshooting/index.md`; evidence: docs/m10d_user_research_hardening.md:51-55
- Q083 [P0] Why is a plot region blank even though sampling looks finite? — `troubleshooting/index.md`; evidence: README.md:482-493; README.md:567-570
- Q084 [P0] Can I fix a refusal by changing an internal constant? — `troubleshooting/index.md`; evidence: docs/m10d_architecture_inventory.md:8-17; README.md:510-518
- Q085 [P0] What must I retain before mutating a borrowed array? — `troubleshooting/index.md`; evidence: docs/m10d_user_research_hardening.md:71-74

