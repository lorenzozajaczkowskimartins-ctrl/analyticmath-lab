# Public reference index

Coverage is checked against exports.json, not heading counts: **177 explicit
exports (130 PUBLIC_STABLE, 47 PUBLIC_EXPERIMENTAL)** and **two separately
qualified experimental interfaces**. Type, constructor, abstract-marker, macro
and function contracts are distinguished using actual binding inspection.

Read [API boundaries](@ref api-boundaries) before interpreting status, domains,
units, resource estimates or raw result constructors. Each name below has exactly
one primary entry. Shared generics preserve distinct overload inputs, output
shapes, keyword controls and extension requirements; cross-family links do not
create a second owner.

## Family ownership and public symbols

| Family | Primary reference owner | Explicit exports |
|---|---|---|
| F01: Evidence and analysis markers | [core.md](core.md) | [AbstractAnalysis](@ref api-AbstractAnalysis), [PropertyResult](@ref api-PropertyResult) |
| F02: Original-expression capture | [core.md](core.md) | [RealExpression](@ref api-RealExpression), [@real_function](@ref api-macro-real-function) |
| F03: Scalar function analysis | [scalar.md](scalar.md) | [FunctionAnalysis](@ref api-FunctionAnalysis), [analyze](@ref api-analyze), [evaluate](@ref api-evaluate), [CriticalPoint](@ref api-CriticalPoint), [CriticalPointAnalysis](@ref api-CriticalPointAnalysis) |
| F04: Real domains and exact studies | [scalar.md](scalar.md) | [RealInterval](@ref api-RealInterval), [RealDomain](@ref api-RealDomain), [RealFunctionStudy](@ref api-RealFunctionStudy), [domain_contains](@ref api-domain-contains), [PeriodicPointSet](@ref api-PeriodicPointSet), [PeriodicIntervalSet](@ref api-PeriodicIntervalSet) |
| F05: Derivative evidence | [derivatives.md](derivatives.md) | [DerivativeComparison](@ref api-DerivativeComparison), [compare_derivatives](@ref api-compare-derivatives), [DerivativeConvergenceAnalysis](@ref api-DerivativeConvergenceAnalysis), [derivative_convergence](@ref api-derivative-convergence) |
| F06: Multivariate scalar fields | [derivatives.md](derivatives.md) | [ScalarFieldAnalysis](@ref api-ScalarFieldAnalysis), [MultivariateDomain](@ref api-MultivariateDomain), [StationaryPoint](@ref api-StationaryPoint), [gradient](@ref api-gradient), [hessian](@ref api-hessian), [directional_derivative](@ref api-directional-derivative), [linearization](@ref api-linearization), [levelset](@ref api-levelset) |
| F07: Vector calculus | [vector.md](vector.md) | [VectorFieldAnalysis](@ref api-VectorFieldAnalysis), [jacobian](@ref api-jacobian), [divergence](@ref api-divergence), [curl](@ref api-curl), [potential](@ref api-potential) |
| F08: Autonomous systems | [dynamics.md](dynamics.md) | [AutonomousSystem](@ref api-AutonomousSystem), [DynamicalSystemAnalysis](@ref api-DynamicalSystemAnalysis), [equilibria](@ref api-equilibria), [stability](@ref api-stability), [nullclines](@ref api-nullclines) |
| F09: Numerical ODE trajectories | [dynamics.md](dynamics.md) | [FirstOrderODE](@ref api-FirstOrderODE), [TrajectoryResult](@ref api-TrajectoryResult), [trajectory](@ref api-trajectory) |
| F10: Lagrangian mechanics | [mechanics.md](mechanics.md) | [LagrangianSystem](@ref api-LagrangianSystem), [LagrangianAnalysis](@ref api-LagrangianAnalysis), [euler_lagrange](@ref api-euler-lagrange), [generalized_momenta](@ref api-generalized-momenta), [velocity_hessian](@ref api-velocity-hessian), [energy_function](@ref api-energy-function), [cyclic_coordinates](@ref api-cyclic-coordinates) |
| F11: Hamiltonian mechanics | [mechanics.md](mechanics.md) | [HamiltonianSystem](@ref api-HamiltonianSystem), [HamiltonianAnalysis](@ref api-HamiltonianAnalysis), [hamilton_equations](@ref api-hamilton-equations), [poisson_bracket](@ref api-poisson-bracket), [observable_derivative](@ref api-observable-derivative), [force_from_potential](@ref api-force-from-potential) |
| F12: Legendre transformation | [mechanics.md](mechanics.md) | [legendre_transform](@ref api-legendre-transform) |
| F13: Mechanics-to-dynamics bridge | [mechanics.md](mechanics.md) | [MechanicsDynamics](@ref api-MechanicsDynamics), [dynamics](@ref api-dynamics), [energy_drift](@ref api-energy-drift) |
| F14: Linearization and normal modes | [mechanics.md](mechanics.md) | [MechanicalLinearization](@ref api-MechanicalLinearization), [linearize_mechanics](@ref api-linearize-mechanics), [NormalModeAnalysis](@ref api-NormalModeAnalysis), [normal_modes](@ref api-normal-modes), [cartesian_mass_matrix](@ref api-cartesian-mass-matrix) |
| F15: Stored atomistic inputs and adapters | [atomistic.md](atomistic.md) | [AtomisticSnapshot](@ref api-AtomisticSnapshot), [AtomisticTrajectoryView](@ref api-AtomisticTrajectoryView), [atomistic_snapshot](@ref api-atomistic-snapshot), [atomistic_trajectory](@ref api-atomistic-trajectory) |
| F16: Snapshot inspection and pair geometry | [atomistic.md](atomistic.md) | [pair_distances](@ref api-pair-distances), [AtomisticSystemAnalysis](@ref api-AtomisticSystemAnalysis), [mdcheck](@ref api-mdcheck), [inspect_particle](@ref api-inspect-particle) |
| F17: Supplied radial potentials | [atomistic.md](atomistic.md) | [PotentialAnalysis](@ref api-PotentialAnalysis), [analyze_potential](@ref api-analyze-potential), [lennard_jones_analysis](@ref api-lennard-jones-analysis) |
| F18: Distribution and coordination analysis | [atomistic.md](atomistic.md) | [RadialDistributionAnalysis](@ref api-RadialDistributionAnalysis), [radial_distribution](@ref api-radial-distribution), [coordination](@ref api-coordination) |
| F19: Sampling and observables | [statistics.md](statistics.md) | [SamplingInfo](@ref api-SamplingInfo), [sampling_info](@ref api-sampling-info), [ObservableSeries](@ref api-ObservableSeries), [observable_series](@ref api-observable-series) |
| F20: Descriptive moments | [statistics.md](statistics.md) | [statistical_summary](@ref api-statistical-summary), [running_statistics](@ref api-running-statistics) |
| F21: Correlation-aware analysis | [statistics.md](statistics.md) | [AutocorrelationAnalysis](@ref api-AutocorrelationAnalysis), [autocorrelation](@ref api-autocorrelation), [integrated_autocorrelation_time](@ref api-integrated-autocorrelation-time), [correlated_mean](@ref api-correlated-mean) |
| F22: Blocking and transient evidence | [statistics.md](statistics.md) | [BlockAnalysis](@ref api-BlockAnalysis), [block_average](@ref api-block-average), [transient_analysis](@ref api-transient-analysis) |
| F23: Particle transport | [transport.md](transport.md) | [MeanSquaredDisplacement](@ref api-MeanSquaredDisplacement), [mean_squared_displacement](@ref api-mean-squared-displacement), [diffusion_estimate](@ref api-diffusion-estimate), [VelocityAutocorrelation](@ref api-VelocityAutocorrelation), [velocity_autocorrelation](@ref api-velocity-autocorrelation) |
| F24: Stored trajectory diagnostics | [statistics.md](statistics.md) | [energy_diagnostics](@ref api-energy-diagnostics), [momentum_diagnostics](@ref api-momentum-diagnostics), [MDTrajectoryAnalysis](@ref api-MDTrajectoryAnalysis), [diagnose](@ref api-diagnose) |
| F25: Compatibility-gated comparisons | [comparison.md](comparison.md) | [ComparisonInput](@ref api-ComparisonInput), [ComparisonCompatibility](@ref api-ComparisonCompatibility), [ObservableComparison](@ref api-ObservableComparison), [compare](@ref api-compare), [MDTrajectoryComparison](@ref api-MDTrajectoryComparison), [compare_runs](@ref api-compare-runs) |
| F26: PINN construction and training | [scientific-ml.md](scientific-ml.md) | [PINNProblem](@ref api-PINNProblem), [PINNTrainingResult](@ref api-PINNTrainingResult), [PINNHistory](@ref api-PINNHistory), [pinn_network](@ref api-pinn-network), [pinn_problem](@ref api-pinn-problem), [train](@ref api-train), [predict](@ref api-predict), [pinn_inspect](@ref api-pinn-inspect) |
| F27: Sampled PINN diagnostics | [scientific-ml.md](scientific-ml.md) | [PINNPoints](@ref api-PINNPoints), [PINNAnalysis](@ref api-PINNAnalysis), [sampled_summary](@ref api-sampled-summary), [loss_breakdown](@ref api-loss-breakdown) |
| F28: Parameter inference | [scientific-ml.md](scientific-ml.md) | [ObservationSet](@ref api-ObservationSet), [InferenceParameters](@ref api-InferenceParameters), [ParameterInferenceProblem](@ref api-ParameterInferenceProblem), [inference_predict](@ref api-inference-predict), [inference_objective](@ref api-inference-objective), [local_sensitivity](@ref api-local-sensitivity), [ParameterInferenceResult](@ref api-ParameterInferenceResult), [infer_parameters](@ref api-infer-parameters) |
| F29: Distance-observation bridge | [scientific-ml.md](scientific-ml.md) | [distance_observations](@ref api-distance-observations) |
| F30: Learned dynamics | [scientific-ml.md](scientific-ml.md) | [DerivativeData](@ref api-DerivativeData), [TrajectoryData](@ref api-TrajectoryData), [HamiltonianNN](@ref api-HamiltonianNN), [UDEProblem](@ref api-UDEProblem), [DynamicsTrainingResult](@ref api-DynamicsTrainingResult), [learned_energy](@ref api-learned-energy), [learned_vector_field](@ref api-learned-vector-field), [learned_correction](@ref api-learned-correction), [dynamics_objective](@ref api-dynamics-objective), [aligned_energy](@ref api-aligned-energy) |
| F31: Scientific datasets | [datasets.md](datasets.md) | [ScientificSample](@ref api-ScientificSample), [ScientificDataset](@ref api-ScientificDataset), [classify_query](@ref api-classify-query) |
| F32: Train-only affine scaling | [datasets.md](datasets.md) | [AffineScaling](@ref api-AffineScaling), [fit_scaling](@ref api-fit-scaling), [transform](@ref api-transform), [inverse_transform](@ref api-inverse-transform) |
| F33: Scientific surrogate and operator learning | [scientific-ml.md](scientific-ml.md) | [ScientificModel](@ref api-ScientificModel), [ScientificLearningResult](@ref api-ScientificLearningResult), [learning_model](@ref api-learning-model), [training_data](@ref api-training-data), [learning_objective](@ref api-learning-objective) |
| F34: Generalization and sampled physics | [scientific-ml.md](scientific-ml.md) | [field_errors](@ref api-field-errors), [heat_residual](@ref api-heat-residual), [benchmark_queries](@ref api-benchmark-queries), [GeneralizationAnalysis](@ref api-GeneralizationAnalysis) |
| F35: Scientific views | [plots.md](plots.md) | [plot](@ref api-plot), [surface](@ref api-surface), [contour](@ref api-contour), [gradientplot](@ref api-gradientplot), [vectorplot](@ref api-vectorplot), [phaseplot](@ref api-phaseplot), [timeplot](@ref api-timeplot), [energyplot](@ref api-energyplot), [modeplot](@ref api-modeplot), [potentialplot](@ref api-potentialplot), [forceplot](@ref api-forceplot), [mdplot](@ref api-mdplot), [timeseriesplot](@ref api-timeseriesplot), [autocorrelationplot](@ref api-autocorrelationplot), [blockplot](@ref api-blockplot), [msdplot](@ref api-msdplot), [vacfplot](@ref api-vacfplot), [comparisonplot](@ref api-comparisonplot), [differenceplot](@ref api-differenceplot), [lossplot](@ref api-lossplot), [residualplot](@ref api-residualplot), [errorplot](@ref api-errorplot), [collocationplot](@ref api-collocationplot), [losscomponentsplot](@ref api-losscomponentsplot), [pinnplot](@ref api-pinnplot), [parameterfitplot](@ref api-parameterfitplot) |
| F36: INTERNAL | [Boundary guide](@ref api-boundaries) | No public primary entries; internal constructors are not promoted |

## Qualified experimental inspection

- [AnalyticMathLab.scientific_metadata](@ref api-qualified-scientific-metadata) — qualified, not an export.
- [AnalyticMathLab.scientific_origin](@ref api-qualified-scientific-origin) — qualified, not an export.

## Shared-generic overload maps

[analyze](@ref dispatch-analyze), [evaluate](@ref dispatch-evaluate), [loss_breakdown](@ref dispatch-loss_breakdown), [normal_modes](@ref dispatch-normal_modes), [observable_series](@ref dispatch-observable_series), [plot](@ref dispatch-plot), [predict](@ref dispatch-predict), [train](@ref dispatch-train).

## How to read a contract

A declaration block preserves audited source signatures/defaults. Backend control
or private helper context explains forwarding; it is not a supported standalone
AML entrypoint. kwargs forwarding is not a promise of arbitrary native keyword
support. Each dispatch contract states input, output, refusal, numerical, unit,
ownership and dependency behavior. Raw type constructors do not certify fields.

Every entry is STATIC_API_AUDIT / SOURCE_INSPECTED. Source hashes reconcile the
prior audit with the unchanged implementation. Docstring presence is separately
recorded; 141 module-local registered bindings among 179 inspected names is not
complete docstring coverage. The manual, not indiscriminate autodocs, supplies
complete symbol coverage. Candidate test locations are not new executions.
No optional training or new scientific examples are run by the build.

## Reused scientific material

Tutorials and historical reports remain canonical outside docs/src. The local
site links selected raw resources with checkout-identical bytes; these are not
rendered Documenter tutorial pages or deployment promises. The normal-mode,
ODE, geometry and capstone analytical checks remain M10D.6C evidence here.

```@raw html
<p>Repository resources: <a href="../repository/reports/m10d6/api.json">reports/m10d6/api.json</a>; <a href="../repository/reports/m10d6/documentation_architecture_reconciled.md">reports/m10d6/documentation_architecture_reconciled.md</a>; <a href="../repository/reports/m10d6/exports.json">reports/m10d6/exports.json</a>; <a href="../repository/reports/m10d6/qualified_api.json">reports/m10d6/qualified_api.json</a>; <a href="../repository/reports/m10d6/tutorial_implementation_report.md">reports/m10d6/tutorial_implementation_report.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```
