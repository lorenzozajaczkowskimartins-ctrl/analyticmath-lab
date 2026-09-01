"""Classe base abstrata para funções matemáticas de uma variável.

Define a interface comum que tipos concretos (``SymbolicFunction``,
adaptadores de ``Polynomial``, etc.) devem implementar ou estender.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

import sympy as sp
from sympy.core.expr import Expr


class MathFunction(ABC):
    """Representação abstrata de uma função real f(x)."""

    variable: str
    symbol: sp.Symbol
    expr: Expr

    @abstractmethod
    def evaluate(self, value: int | float | complex | sp.Basic) -> Any:
        """Avalia a função em um ponto."""

    def domain(self) -> Any:
        """Retorna o domínio real da função."""
        raise NotImplementedError("domain() ainda não implementado para este tipo de função.")

    def roots(self) -> Any:
        """Retorna raízes ou conjunto solução de f(x) = 0."""
        raise NotImplementedError("roots() ainda não implementado para este tipo de função.")

    def derivative(self, order: int = 1) -> MathFunction:
        """Retorna a derivada de ordem ``order``."""
        raise NotImplementedError("derivative() ainda não implementado para este tipo de função.")

    def integral(self) -> Any:
        """Retorna integral indefinida ou objeto de integral."""
        raise NotImplementedError("integral() ainda não implementado para este tipo de função.")

    def limits(self) -> Any:
        """Retorna informações de limites relevantes."""
        raise NotImplementedError("limits() ainda não implementado para este tipo de função.")

    def sign_table(self) -> Any:
        """Constrói tabela de sinais quando aplicável."""
        raise NotImplementedError("sign_table() ainda não implementado para este tipo de função.")

    def solve_inequality(self, operator: str) -> Any:
        """Resolve inequações f(x) operador 0."""
        raise NotImplementedError(
            "solve_inequality() ainda não implementado para este tipo de função."
        )

    def critical_points(self) -> Any:
        """Analisa pontos críticos."""
        raise NotImplementedError(
            "critical_points() ainda não implementado para este tipo de função."
        )

    def concavity(self) -> Any:
        """Analisa concavidade e pontos de inflexão."""
        raise NotImplementedError("concavity() ainda não implementado para este tipo de função.")

    def asymptotes(self) -> Any:
        """Determina assíntotas."""
        raise NotImplementedError("asymptotes() ainda não implementado para este tipo de função.")

    def report(self) -> Any:
        """Gera relatório explicativo da análise."""
        raise NotImplementedError("report() ainda não implementado para este tipo de função.")
