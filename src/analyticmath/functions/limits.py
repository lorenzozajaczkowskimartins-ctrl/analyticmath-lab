"""Limites de funções simbólicas."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import limit, oo

from analyticmath.utils.errors import ValidationError

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

Direction = Literal["+-", "+", "-"]
InfinityDirection = Literal["+", "-"]


@dataclass
class LimitResult:
    """Resultado de um cálculo de limite."""

    value: Any
    point: Any
    direction: str
    expression: Any
    explanation: str


def limit_at(
    function: SymbolicFunction,
    point: int | float | sp.Basic,
    direction: Direction = "+-",
) -> LimitResult:
    """Calcula o limite de ``function`` quando x tende a ``point``."""
    if direction not in ("+-", "+", "-"):
        raise ValidationError(
            f"Direção inválida: {direction!r}. Use '+', '-' ou '+-'."
        )

    if direction == "+-":
        value = limit(function.expr, function.symbol, point)
        direction_label = "bilateral"
    elif direction == "+":
        value = limit(function.expr, function.symbol, point, dir="+")
        direction_label = "pela direita"
    else:
        value = limit(function.expr, function.symbol, point, dir="-")
        direction_label = "pela esquerda"

    return LimitResult(
        value=value,
        point=point,
        direction=direction,
        expression=function.expr,
        explanation=(
            f"Limite {direction_label} de f({function.variable}) quando "
            f"{function.variable} → {point}."
        ),
    )


def limit_at_infinity(
    function: SymbolicFunction,
    direction: InfinityDirection = "+",
) -> LimitResult:
    """Calcula o limite de ``function`` quando x tende a ±∞."""
    if direction not in ("+", "-"):
        raise ValidationError(
            f"Direção inválida: {direction!r}. Use '+' ou '-' para ±∞."
        )

    point = oo if direction == "+" else -oo
    value = limit(function.expr, function.symbol, point)

    return LimitResult(
        value=value,
        point=point,
        direction=direction,
        expression=function.expr,
        explanation=(
            f"Limite de f({function.variable}) quando {function.variable} → "
            f"{'+∞' if direction == '+' else '-∞'}."
        ),
    )
