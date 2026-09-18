"""Structured symbolic and numerical mathematical analysis."""
module AnalyticMathLab

import Symbolics
import Roots
import ForwardDiff
import FiniteDiff
import Makie
import Makie: plot, surface, contour
import LinearAlgebra
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

end
