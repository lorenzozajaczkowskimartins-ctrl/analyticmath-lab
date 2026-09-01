"""Módulo de polinômios — primeiro domínio funcional do AnalyticMath Lab."""

from analyticmath.polynomial.critical_points import (
    CriticalPoint,
    CriticalPointAnalysis,
    analyze_critical_points,
    classify_critical_point,
    format_critical_point,
    format_critical_point_analysis,
)
from analyticmath.polynomial.inequalities import (
    PolynomialInequalitySolution,
    SolutionInterval,
    format_inequality_solution,
    format_solution_interval,
    solve_polynomial_inequality,
)
from analyticmath.polynomial.polynomial import Polynomial
from analyticmath.polynomial.sign_table import (
    RootSignInfo,
    SignInterval,
    SignTable,
    build_sign_table,
    format_sign_table_text,
)

__all__ = [
    "Polynomial",
    "SignInterval",
    "SignTable",
    "RootSignInfo",
    "build_sign_table",
    "format_sign_table_text",
    "SolutionInterval",
    "PolynomialInequalitySolution",
    "solve_polynomial_inequality",
    "format_solution_interval",
    "format_inequality_solution",
    "CriticalPoint",
    "CriticalPointAnalysis",
    "analyze_critical_points",
    "classify_critical_point",
    "format_critical_point",
    "format_critical_point_analysis",
]
