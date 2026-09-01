"""Domínio real de funções simbólicas."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Any

import sympy as sp
from sympy import S

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction


@dataclass
class RealDomainResult:
    """Resultado da determinação do domínio real."""

    domain: Any
    variable: str
    explanation: str


def find_real_domain(function: SymbolicFunction) -> RealDomainResult:
    """Determina o domínio real de ``function`` usando SymPy."""
    try:
        from sympy.calculus.util import continuous_domain

        domain = continuous_domain(function.expr, function.symbol, S.Reals)
        explanation = (
            f"Domínio real obtido via continuous_domain, aplicado a f({function.variable})."
        )
    except Exception as exc:
        domain = S.Reals
        explanation = (
            "Não foi possível determinar o domínio automaticamente; "
            f"assumindo Reals. Detalhe: {exc}"
        )

    return RealDomainResult(
        domain=domain,
        variable=function.variable,
        explanation=explanation,
    )
