"""Análise geral de funções reais de uma variável."""

from analyticmath.functions.analysis_context import FunctionAnalysisContext
from analyticmath.functions.asymptotes import (
    AsymptoteAnalysis,
    HorizontalAsymptote,
    ObliqueAsymptote,
    VerticalAsymptote,
    analyze_asymptotes,
    format_asymptote_analysis,
)
from analyticmath.functions.base import MathFunction
from analyticmath.functions.concavity import (
    ConcavityAnalysis,
    InflectionPoint,
    analyze_concavity,
    classify_inflection_point,
    format_concavity_analysis,
    format_inflection_point,
)
from analyticmath.functions.continuity import (
    ContinuityAnalysis,
    Discontinuity,
    analyze_continuity,
    classify_discontinuity,
    find_discontinuity_candidates,
    format_continuity_analysis,
    format_discontinuity,
)
from analyticmath.functions.critical_points import (
    FunctionCriticalPoint,
    FunctionCriticalPointAnalysis,
    analyze_function_critical_points,
    classify_function_critical_point,
    format_function_critical_point,
    format_function_critical_point_analysis,
)
from analyticmath.functions.domain import RealDomainResult, find_real_domain
from analyticmath.functions.inequalities import (
    FunctionInequalitySolution,
    FunctionSolutionInterval,
    format_function_inequality_solution,
    format_function_solution_interval,
    solve_function_inequality,
)
from analyticmath.functions.limits import LimitResult, limit_at, limit_at_infinity
from analyticmath.functions.report import (
    FunctionAnalysisReport,
    FunctionReportSection,
    format_function_report,
    generate_function_report,
)
from analyticmath.functions.roots import RootsResult, find_roots
from analyticmath.functions.sign_table import (
    FunctionCriticalSignPoint,
    FunctionSignInterval,
    FunctionSignTable,
    build_function_sign_table,
    format_function_sign_table,
)
from analyticmath.functions.symbolic_function import SymbolicFunction

__all__ = [
    "MathFunction",
    "SymbolicFunction",
    "RealDomainResult",
    "RootsResult",
    "LimitResult",
    "VerticalAsymptote",
    "HorizontalAsymptote",
    "ObliqueAsymptote",
    "AsymptoteAnalysis",
    "Discontinuity",
    "ContinuityAnalysis",
    "ConcavityAnalysis",
    "InflectionPoint",
    "FunctionCriticalPoint",
    "FunctionCriticalPointAnalysis",
    "FunctionSignInterval",
    "FunctionCriticalSignPoint",
    "FunctionSignTable",
    "FunctionSolutionInterval",
    "FunctionInequalitySolution",
    "FunctionReportSection",
    "FunctionAnalysisReport",
    "FunctionAnalysisContext",
    "find_real_domain",
    "generate_function_report",
    "format_function_report",
    "solve_function_inequality",
    "format_function_solution_interval",
    "format_function_inequality_solution",
    "find_roots",
    "limit_at",
    "limit_at_infinity",
    "analyze_asymptotes",
    "format_asymptote_analysis",
    "analyze_continuity",
    "analyze_concavity",
    "classify_inflection_point",
    "format_concavity_analysis",
    "format_inflection_point",
    "analyze_function_critical_points",
    "classify_function_critical_point",
    "format_function_critical_point",
    "format_function_critical_point_analysis",
    "find_discontinuity_candidates",
    "classify_discontinuity",
    "format_discontinuity",
    "format_continuity_analysis",
    "build_function_sign_table",
    "format_function_sign_table",
]
