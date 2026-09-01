"""Raízes de funções simbólicas."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any

import sympy as sp
from sympy import S, solve, solveset

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction


@dataclass
class RootsResult:
    """Resultado da busca de raízes de f(x) = 0."""

    roots: list[Any] = field(default_factory=list)
    real_roots: list[Any] = field(default_factory=list)
    explanation: str = ""
    exact_available: bool = False


def find_roots(function: SymbolicFunction) -> RootsResult:
    """Resolve f(x) = 0 simbolicamente quando possível."""
    symbol = function.symbol
    expr = function.expr

    try:
        real_solution_set = solveset(expr, symbol, domain=S.Reals)
        all_solutions = solve(expr, symbol)

        if isinstance(all_solutions, dict):
            roots = list(all_solutions.values())
        elif isinstance(all_solutions, list):
            roots = all_solutions
        elif all_solutions is None or all_solutions is S.EmptySet:
            roots = []
        else:
            roots = [all_solutions]

        real_roots = _extract_real_roots(real_solution_set, roots)
        exact_available = bool(roots) or real_solution_set not in (S.EmptySet, S.Reals)

        if real_solution_set is S.EmptySet:
            explanation = "Não há raízes reais."
        elif roots:
            explanation = "Raízes encontradas simbolicamente com SymPy."
        else:
            explanation = (
                "Solução real representada como conjunto simbólico; "
                "nem todas as raízes puderam ser listadas explicitamente."
            )

        return RootsResult(
            roots=roots,
            real_roots=real_roots,
            explanation=explanation,
            exact_available=exact_available,
        )
    except Exception as exc:
        return RootsResult(
            roots=[],
            real_roots=[],
            explanation=f"Não foi possível resolver f(x) = 0 simbolicamente: {exc}",
            exact_available=False,
        )


def _extract_real_roots(real_solution_set: Any, fallback_roots: list[Any]) -> list[Any]:
    if hasattr(real_solution_set, "is_FiniteSet") and real_solution_set.is_FiniteSet:
        return list(real_solution_set)

    real_roots: list[Any] = []
    for root in fallback_roots:
        if sp.im(root).equals(0):
            real_roots.append(root)
    return real_roots
