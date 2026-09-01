"""AnalyticMath Lab — motor de matemática analítica com relatórios explicativos."""

__version__ = "0.1.0"

from analyticmath.functions import (
    MathFunction,
    SymbolicFunction,
    find_real_domain,
    find_roots,
    limit_at,
    limit_at_infinity,
)

__all__ = [
    "__version__",
    "MathFunction",
    "SymbolicFunction",
    "find_real_domain",
    "find_roots",
    "limit_at",
    "limit_at_infinity",
]
