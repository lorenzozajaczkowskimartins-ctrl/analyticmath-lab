"""Construção de tabela de sinais a partir das raízes reais.

Determina intervalos onde P(x) > 0, P(x) < 0 ou P(x) = 0 com base
nas raízes reais ordenadas e na multiplicidade de cada raiz.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import oo

if TYPE_CHECKING:
    from analyticmath.polynomial.polynomial import Polynomial

SignSymbol = Literal["+", "-", "0"]


@dataclass(frozen=True)
class SignInterval:
    """Intervalo da reta real com o sinal de P(x) no interior."""

    left: Any
    right: Any
    test_point: Any
    value_at_test_point: Any
    sign: SignSymbol


@dataclass(frozen=True)
class RootSignInfo:
    """Informação sobre o comportamento do polinômio em uma raiz real."""

    root: Any
    multiplicity: int
    value_at_root: Any
    crosses_axis: bool
    touches_axis: bool
    explanation: str


@dataclass
class SignTable:
    """Resultado estruturado da tabela de sinais de um polinômio."""

    polynomial: Polynomial
    real_roots: list[Any]
    root_multiplicities: dict[Any, int]
    intervals: list[SignInterval]
    root_sign_info: list[RootSignInfo]
    explanation: str
    case: str = field(default="general")


def build_sign_table(polynomial: Polynomial) -> SignTable:
    """Constrói a tabela de sinais real de ``polynomial``."""
    if _is_zero_polynomial(polynomial):
        return _build_zero_polynomial_table(polynomial)

    real_mult = _real_root_multiplicities(polynomial)
    sorted_roots = sort_real_roots(list(real_mult.keys()))

    if polynomial.degree() == 0:
        return _build_constant_polynomial_table(polynomial, real_mult, sorted_roots)

    if not sorted_roots:
        return _build_no_real_roots_table(polynomial, real_mult)

    return _build_general_sign_table(polynomial, real_mult, sorted_roots)


def sign_of(value: Any) -> SignSymbol:
    """Retorna '+', '-' ou '0' para um valor numérico ou simbólico."""
    simplified = sp.simplify(value)

    if simplified == 0 or simplified.equals(0):
        return "0"

    if simplified.is_positive:
        return "+"
    if simplified.is_negative:
        return "-"

    if simplified.is_number:
        numeric = float(sp.N(simplified))
        if numeric == 0.0:
            return "0"
        return "+" if numeric > 0 else "-"

    numeric = sp.N(simplified)
    if numeric.is_zero:
        return "0"
    return "+" if float(numeric) > 0 else "-"


def choose_test_point(left: Any, right: Any) -> Any:
    """Escolhe um ponto de teste no interior do intervalo ``(left, right)``."""
    neg_inf = sp.S.NegativeInfinity
    pos_inf = sp.S.Infinity

    if left in (neg_inf, -oo) and right not in (pos_inf, oo):
        return sp.simplify(right - 1)

    if right in (pos_inf, oo) and left not in (neg_inf, -oo):
        return sp.simplify(left + 1)

    if left in (neg_inf, -oo) and right in (pos_inf, oo):
        return sp.Integer(0)

    return sp.simplify((left + right) / 2)


def sort_real_roots(roots: list[Any]) -> list[Any]:
    """Ordena raízes reais de forma crescente, removendo duplicatas."""
    unique_roots = list(dict.fromkeys(roots))

    def sort_key(root: Any) -> float:
        return float(sp.N(root))

    return sorted(unique_roots, key=sort_key)


def format_interval(left: Any, right: Any) -> str:
    """Formata os limites de um intervalo para exibição."""
    return f"({_format_bound(left)}, {_format_bound(right)})"


def format_sign_table_text(table: SignTable) -> str:
    """Formata a tabela de sinais como texto legível."""
    lines: list[str] = ["Tabela de sinais:"]

    root_info_by_value = {info.root: info for info in table.root_sign_info}
    root_index = 0

    for interval in table.intervals:
        lines.append(f"{format_interval(interval.left, interval.right)}: {interval.sign}")

        while root_index < len(table.real_roots):
            root = table.real_roots[root_index]
            if not _root_lies_at_interval_end(root, interval.right):
                break

            info = root_info_by_value[root]
            behavior = "cruza o eixo x" if info.crosses_axis else "toca o eixo x e retorna"
            lines.append(
                f"raiz {root}, multiplicidade {info.multiplicity}: {behavior}"
            )
            root_index += 1

    return "\n".join(lines)


def _build_zero_polynomial_table(polynomial: Polynomial) -> SignTable:
    interval = SignInterval(
        left=sp.S.NegativeInfinity,
        right=sp.S.Infinity,
        test_point=sp.Integer(0),
        value_at_test_point=sp.Integer(0),
        sign="0",
    )
    return SignTable(
        polynomial=polynomial,
        real_roots=[],
        root_multiplicities={},
        intervals=[interval],
        root_sign_info=[],
        explanation=(
            "O polinômio é identicamente nulo; p(x) = 0 em todo o domínio real."
        ),
        case="zero_polynomial",
    )


def _build_constant_polynomial_table(
    polynomial: Polynomial,
    real_mult: dict[Any, int],
    sorted_roots: list[Any],
) -> SignTable:
    constant = sp.simplify(polynomial.constant_term())
    sign = sign_of(constant)
    interval = SignInterval(
        left=sp.S.NegativeInfinity,
        right=sp.S.Infinity,
        test_point=sp.Integer(0),
        value_at_test_point=constant,
        sign=sign,
    )

    if sign == "+":
        explanation = (
            "Polinômio constante positivo; o sinal é positivo em todo o domínio real."
        )
        case = "constant_positive"
    elif sign == "-":
        explanation = (
            "Polinômio constante negativo; o sinal é negativo em todo o domínio real."
        )
        case = "constant_negative"
    else:
        explanation = "Polinômio constante nulo; o sinal é zero em todo o domínio real."
        case = "zero_polynomial"

    return SignTable(
        polynomial=polynomial,
        real_roots=sorted_roots,
        root_multiplicities=real_mult,
        intervals=[interval],
        root_sign_info=_build_root_sign_info(polynomial, real_mult, sorted_roots),
        explanation=explanation,
        case=case,
    )


def _build_no_real_roots_table(
    polynomial: Polynomial,
    real_mult: dict[Any, int],
) -> SignTable:
    test_point = sp.Integer(0)
    value = sp.simplify(polynomial.evaluate(test_point))
    sign = sign_of(value)
    interval = SignInterval(
        left=sp.S.NegativeInfinity,
        right=sp.S.Infinity,
        test_point=test_point,
        value_at_test_point=value,
        sign=sign,
    )

    if sign == "+":
        explanation = (
            "O polinômio não possui raízes reais; o sinal permanece positivo "
            "em todo o domínio real."
        )
    else:
        explanation = (
            "O polinômio não possui raízes reais; o sinal permanece negativo "
            "em todo o domínio real."
        )

    return SignTable(
        polynomial=polynomial,
        real_roots=[],
        root_multiplicities=real_mult,
        intervals=[interval],
        root_sign_info=[],
        explanation=explanation,
        case="no_real_roots",
    )


def _build_general_sign_table(
    polynomial: Polynomial,
    real_mult: dict[Any, int],
    sorted_roots: list[Any],
) -> SignTable:
    bounds: list[Any] = [sp.S.NegativeInfinity, *sorted_roots, sp.S.Infinity]
    intervals: list[SignInterval] = []

    for left, right in zip(bounds[:-1], bounds[1:], strict=True):
        test_point = choose_test_point(left, right)
        value = sp.simplify(polynomial.evaluate(test_point))
        intervals.append(
            SignInterval(
                left=left,
                right=right,
                test_point=test_point,
                value_at_test_point=value,
                sign=sign_of(value),
            )
        )

    root_sign_info = _build_root_sign_info(polynomial, real_mult, sorted_roots)
    explanation = (
        f"Tabela de sinais construída a partir de {len(sorted_roots)} raiz(es) real(is) "
        f"distinta(s): {', '.join(str(r) for r in sorted_roots)}."
    )

    return SignTable(
        polynomial=polynomial,
        real_roots=sorted_roots,
        root_multiplicities=real_mult,
        intervals=intervals,
        root_sign_info=root_sign_info,
        explanation=explanation,
        case="general",
    )


def _build_root_sign_info(
    polynomial: Polynomial,
    real_mult: dict[Any, int],
    sorted_roots: list[Any],
) -> list[RootSignInfo]:
    info_list: list[RootSignInfo] = []

    for root in sorted_roots:
        multiplicity = real_mult[root]
        value = sp.simplify(polynomial.evaluate(root))
        crosses = multiplicity % 2 == 1
        touches = multiplicity % 2 == 0

        if crosses:
            explanation = (
                f"Na raiz x = {root}, com multiplicidade {multiplicity} (ímpar), "
                f"o gráfico cruza o eixo x."
            )
        else:
            explanation = (
                f"Na raiz x = {root}, com multiplicidade {multiplicity} (par), "
                f"o gráfico toca o eixo x e retorna, sem trocar de sinal."
            )

        info_list.append(
            RootSignInfo(
                root=root,
                multiplicity=multiplicity,
                value_at_root=value,
                crosses_axis=crosses,
                touches_axis=touches,
                explanation=explanation,
            )
        )

    return info_list


def _real_root_multiplicities(polynomial: Polynomial) -> dict[Any, int]:
    return {
        root: multiplicity
        for root, multiplicity in polynomial.root_multiplicities().items()
        if sp.im(root).equals(0)
    }


def _is_zero_polynomial(polynomial: Polynomial) -> bool:
    return sp.simplify(polynomial.expr) == 0 or polynomial.expr.equals(0)


def _format_bound(bound: Any) -> str:
    if bound in (sp.S.NegativeInfinity, -oo):
        return "-∞"
    if bound in (sp.S.Infinity, oo):
        return "+∞"
    return str(bound)


def _root_lies_at_interval_end(root: Any, right: Any) -> bool:
    if right in (sp.S.Infinity, oo):
        return False
    return sp.simplify(root - right) == 0 or root.equals(right)
