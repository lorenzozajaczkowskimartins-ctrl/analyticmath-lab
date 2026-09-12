"""Structured symbolic and numerical mathematical analysis."""
module AnalyticMathLab

import Symbolics
import Roots
import ForwardDiff
import FiniteDiff
import Makie
import Makie: plot

export AbstractAnalysis, FunctionAnalysis, analyze, evaluate
export CriticalPoint, CriticalPointAnalysis
export DerivativeComparison, compare_derivatives
export DerivativeConvergenceAnalysis, derivative_convergence
export plot

include("analysis.jl")
include("symbolic.jl")
include("numerical.jl")
include("convergence.jl")
include("visualization.jl")

end
