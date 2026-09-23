"""Structured symbolic and numerical mathematical analysis."""
module AnalyticMathLab

import Symbolics
import Roots
import ForwardDiff
import FiniteDiff
import Makie
import Makie: plot, surface, contour
import LinearAlgebra
import Unitful
import SciMLBase
import OrdinaryDiffEqTsit5

export AbstractAnalysis, FunctionAnalysis, analyze, evaluate
export CriticalPoint, CriticalPointAnalysis
export DerivativeComparison, compare_derivatives
export DerivativeConvergenceAnalysis, derivative_convergence
export RealExpression, @real_function
export PropertyResult, RealInterval, RealDomain, RealFunctionStudy, domain_contains
export PeriodicPointSet, PeriodicIntervalSet
export plot
export ScalarFieldAnalysis, MultivariateDomain, StationaryPoint
export gradient, hessian, directional_derivative, linearization, levelset
export surface, contour, gradientplot
export VectorFieldAnalysis, jacobian, divergence, curl, potential, vectorplot
export AutonomousSystem, DynamicalSystemAnalysis, equilibria, stability, nullclines
export FirstOrderODE, TrajectoryResult, trajectory, phaseplot, timeplot
export LagrangianSystem, LagrangianAnalysis
export HamiltonianSystem, HamiltonianAnalysis, hamilton_equations
export poisson_bracket, observable_derivative, force_from_potential
export legendre_transform
export MechanicsDynamics, dynamics, energy_drift, energyplot
export euler_lagrange, generalized_momenta, velocity_hessian, energy_function, cyclic_coordinates
export MechanicalLinearization, linearize_mechanics, NormalModeAnalysis, normal_modes
export cartesian_mass_matrix, modeplot
export AtomisticSnapshot, AtomisticTrajectoryView, atomistic_snapshot, atomistic_trajectory
export pair_distances
export AtomisticSystemAnalysis, mdcheck, inspect_particle
export PotentialAnalysis, analyze_potential, lennard_jones_analysis, potentialplot, forceplot
export RadialDistributionAnalysis, radial_distribution, coordination, mdplot
export SamplingInfo, sampling_info, ObservableSeries, observable_series, statistical_summary, running_statistics
export AutocorrelationAnalysis, autocorrelation, integrated_autocorrelation_time, correlated_mean
export BlockAnalysis, block_average, transient_analysis
export MeanSquaredDisplacement, mean_squared_displacement, diffusion_estimate
export VelocityAutocorrelation, velocity_autocorrelation, energy_diagnostics, momentum_diagnostics
export MDTrajectoryAnalysis, diagnose, timeseriesplot, autocorrelationplot, blockplot, msdplot, vacfplot

# Shared contracts and mechanisms: no dependency on studies or presentation.
include("core/contracts.jl")
include("core/expressions.jl")
include("core/exact_algebra.jl")

# Univariate result containers, inference, and specialized domains.
include("analysis.jl")
include("real_analysis.jl")
include("real_analysis_domain.jl")
include("real_analysis_transforms.jl")
include("real_analysis_periodic.jl")
include("real_analysis_display.jl")
include("multivariate_domain.jl")
include("multivariate_analysis.jl")
include("vector_fields/analysis.jl")
include("vector_fields/calculus.jl")
include("vector_fields/zeros.jl")
include("vector_fields/display.jl")
include("dynamical_systems/analysis.jl")
include("dynamical_systems/stability.jl")
include("dynamical_systems/display.jl")
include("dynamical_systems/integration.jl")
include("mechanics/core.jl")
include("mechanics/hamiltonian.jl")
include("mechanics/legendre.jl")
include("mechanics/bridge.jl")
include("mechanics/normal_modes.jl")
include("atomistic/core.jl")
include("atomistic/inspection.jl")
include("atomistic/potentials.jl")
include("atomistic/distributions.jl")
include("atomistic/modes.jl")
include("trajectory/statistics.jl")
include("trajectory/uncertainty.jl")
include("trajectory/transport.jl")
include("trajectory/analyst.jl")

# Numerical experiments consume reports, not real-function certificates.
include("numerical.jl")
include("symbolic.jl")
include("convergence.jl")

# Makie consumers load last; no backend is imported or activated here.
include("visualization/real.jl")
include("visualization/plots.jl")
include("visualization/scalar_fields.jl")
include("visualization/vector_fields.jl")
include("visualization/dynamical_systems.jl")
include("visualization/mechanics.jl")
include("visualization/potentials.jl")
include("visualization/atomistic.jl")
include("visualization/trajectory.jl")

end
