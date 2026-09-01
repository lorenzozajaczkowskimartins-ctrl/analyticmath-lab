"""Resolução de inequações polinomiais a partir da tabela de sinais.

Determina conjuntos solução de P(x) > 0, ≥, <, ≤, == e != reutilizando
``build_sign_table`` sem duplicar a lógica de sinais.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import oo

from analyticmath.polynomial.sign_table import SignInterval, SignTable, build_sign_table
from analyticmath.utils.errors import ValidationError

if TYPE_CHECKING:
    from analyticmath.polynomial.polynomial import Polynomial

Operator = Literal[">", "<", ">=", "<=", "==", "!="]
SolutionCase = Literal[
    "general",
    "all_real",
    "empty",
    "zero_polynomial",
    "constant_positive",
    "constant_negative",
    "no_real_roots",
]

VALID_OPERATORS: frozenset[str] = frozenset({">", "<", ">=", "<=", "==", "!="})


@dataclass(frozen=True)
class SolutionInterval:
    """Intervalo ou ponto da solução de uma inequação."""

    left: Any
    right: Any
    left_closed: bool
    right_closed: bool


@dataclass
class PolynomialInequalitySolution:
    """Solução estruturada de uma inequação polinomial."""

    polynomial: Polynomial
    operator: str
    sign_table: SignTable
    intervals: list[SolutionInterval]
    roots_included: list[Any]
    explanation: str
    case: str = field(default="general")


def solve_polynomial_inequality(
    polynomial: Polynomial,
    operator: str,
) -> PolynomialInequalitySolution:
    """Resolve ``polynomial`` relação ``operator`` 0 usando a tabela de sinais."""
    normalized = _normalize_operator(operator)
    if normalized not in VALID_OPERATORS:
        raise ValidationError(
            f"Operador inválido: {operator!r}. Use um de {sorted(VALID_OPERATORS)}."
        )

    sign_table = build_sign_table(polynomial)
    return _solve_from_sign_table(polynomial, normalized, sign_table)


def interval_satisfies_operator(sign: str, operator: str) -> bool:
    """Indica se um sinal de intervalo contribui para a solução do operador."""
    if operator == ">":
        return sign == "+"
    if operator == "<":
        return sign == "-"
    if operator == ">=":
        return sign == "+"
    if operator == "<=":
        return sign == "-"
    if operator == "==":
        return False
    if operator == "!=":
        return sign in ("+", "-")
    return False


def format_solution_interval(interval: SolutionInterval) -> str:
    """Formata um intervalo de solução em notação padrão."""
    if _is_point_interval(interval):
        return f"{{{_format_bound(interval.left)}}}"

    left_bracket = "[" if interval.left_closed else "("
    right_bracket = "]" if interval.right_closed else ")"
    return (
        f"{left_bracket}{_format_bound(interval.left)}, "
        f"{_format_bound(interval.right)}{right_bracket}"
    )


def format_inequality_solution(solution: PolynomialInequalitySolution) -> str:
    """Formata a solução completa de uma inequação."""
    var = solution.polynomial.variable
    header = f"p({var}) {solution.operator} 0:"

    if solution.case == "empty" or not solution.intervals:
        return f"{header}\n∅"

    body = " ∪ ".join(format_solution_interval(i) for i in solution.intervals)
    return f"{header}\n{body}"


def _solve_from_sign_table(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    handlers = {
        "zero_polynomial": _solve_zero_polynomial,
        "constant_positive": _solve_constant_positive,
        "constant_negative": _solve_constant_negative,
        "no_real_roots": _solve_no_real_roots,
    }

    if sign_table.case in handlers:
        return handlers[sign_table.case](polynomial, operator, sign_table)

    return _solve_general(polynomial, operator, sign_table)


def _solve_zero_polynomial(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    if operator in (">", "<", "!="):
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=[],
            roots_included=[],
            case="empty",
            explanation="O polinômio é identicamente nulo; a inequação estrita ou de diferença não possui solução.",
        )

    return _make_solution(
        polynomial,
        operator,
        sign_table,
        intervals=[_all_real_interval()],
        roots_included=[],
        case="all_real",
        explanation="O polinômio é identicamente nulo; a solução é todo o conjunto dos números reais.",
    )


def _solve_constant_positive(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    if operator in (">", ">=", "!="):
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=[_all_real_interval()],
            roots_included=[],
            case="all_real",
            explanation="Polinômio constante positivo; a inequação é satisfeita em todo o domínio real.",
        )

    return _make_solution(
        polynomial,
        operator,
        sign_table,
        intervals=[],
        roots_included=[],
        case="empty",
        explanation="Polinômio constante positivo; não há valores reais que satisfaçam a inequação.",
    )


def _solve_constant_negative(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    if operator in ("<", "<=", "!="):
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=[_all_real_interval()],
            roots_included=[],
            case="all_real",
            explanation="Polinômio constante negativo; a inequação é satisfeita em todo o domínio real.",
        )

    return _make_solution(
        polynomial,
        operator,
        sign_table,
        intervals=[],
        roots_included=[],
        case="empty",
        explanation="Polinômio constante negativo; não há valores reais que satisfaçam a inequação.",
    )


def _solve_no_real_roots(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    sign = sign_table.intervals[0].sign if sign_table.intervals else "+"

    if operator == "==":
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=[],
            roots_included=[],
            case="empty",
            explanation="Não há raízes reais; a equação p(x) = 0 não possui solução real.",
        )

    if operator == "!=":
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=[_all_real_interval()],
            roots_included=[],
            case="all_real",
            explanation="Não há raízes reais; p(x) ≠ 0 em todo o domínio real.",
        )

    if operator in (">", ">="):
        if sign == "+":
            return _make_solution(
                polynomial,
                operator,
                sign_table,
                intervals=[_all_real_interval()],
                roots_included=[],
                case="all_real",
                explanation="O polinômio é sempre positivo; a solução é todo o domínio real.",
            )
        return _empty_solution(
            polynomial,
            operator,
            sign_table,
            "O polinômio é sempre negativo; p(x) > 0 (ou ≥ 0) não possui solução real.",
        )

    if operator in ("<", "<="):
        if sign == "-":
            return _make_solution(
                polynomial,
                operator,
                sign_table,
                intervals=[_all_real_interval()],
                roots_included=[],
                case="all_real",
                explanation="O polinômio é sempre negativo; a solução é todo o domínio real.",
            )
        return _empty_solution(
            polynomial,
            operator,
            sign_table,
            "O polinômio é sempre positivo; p(x) < 0 (ou ≤ 0) não possui solução real.",
        )

    return _empty_solution(polynomial, operator, sign_table, "Caso não tratado.")


def _solve_general(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
) -> PolynomialInequalitySolution:
    real_roots = sign_table.real_roots

    if operator == "==":
        intervals = [_point_interval(root) for root in real_roots]
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=intervals,
            roots_included=list(real_roots),
            case="empty" if not intervals else "general",
            explanation=(
                "A solução é o conjunto das raízes reais do polinômio."
                if intervals
                else "Não há raízes reais."
            ),
        )

    if operator == "!=":
        intervals = [
            _open_sign_interval(sign_interval)
            for sign_interval in sign_table.intervals
        ]
        return _make_solution(
            polynomial,
            operator,
            sign_table,
            intervals=intervals,
            roots_included=[],
            case="all_real" if _covers_all_reals(intervals) else "general",
            explanation="A solução exclui as raízes reais e inclui todos os demais intervalos abertos.",
        )

    target_sign = "+" if operator in (">", ">=") else "-"
    intervals = [
        _convert_sign_interval(sign_interval, operator, real_roots)
        for sign_interval in sign_table.intervals
        if sign_interval.sign == target_sign
    ]
    roots_included = list(real_roots) if operator in (">=", "<=") else []

    if _covers_all_reals(intervals):
        intervals = [_all_real_interval()]
        case: SolutionCase = "all_real"
        explanation = (
            f"A inequação p(x) {operator} 0 é satisfeita em todo o domínio real."
        )
    elif not intervals:
        case = "empty"
        explanation = f"Não há intervalos com sinal compatível com p(x) {operator} 0."
    else:
        case = "general"
        explanation = (
            f"Solução obtida a partir da tabela de sinais para p(x) {operator} 0."
        )

    return _make_solution(
        polynomial,
        operator,
        sign_table,
        intervals=intervals,
        roots_included=roots_included,
        case=case,
        explanation=explanation,
    )


def _convert_sign_interval(
    sign_interval: SignInterval,
    operator: str,
    real_roots: list[Any],
) -> SolutionInterval:
    left = sign_interval.left
    right = sign_interval.right
    include_roots = operator in (">=", "<=")

    left_closed = include_roots and _is_finite_root(left, real_roots)
    right_closed = include_roots and _is_finite_root(right, real_roots)

    return SolutionInterval(
        left=left,
        right=right,
        left_closed=left_closed,
        right_closed=right_closed,
    )


def _open_sign_interval(sign_interval: SignInterval) -> SolutionInterval:
    return SolutionInterval(
        left=sign_interval.left,
        right=sign_interval.right,
        left_closed=False,
        right_closed=False,
    )


def _point_interval(root: Any) -> SolutionInterval:
    return SolutionInterval(left=root, right=root, left_closed=True, right_closed=True)


def _all_real_interval() -> SolutionInterval:
    return SolutionInterval(
        left=sp.S.NegativeInfinity,
        right=sp.S.Infinity,
        left_closed=False,
        right_closed=False,
    )


def _make_solution(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
    *,
    intervals: list[SolutionInterval],
    roots_included: list[Any],
    case: str,
    explanation: str,
) -> PolynomialInequalitySolution:
    return PolynomialInequalitySolution(
        polynomial=polynomial,
        operator=operator,
        sign_table=sign_table,
        intervals=intervals,
        roots_included=roots_included,
        explanation=explanation,
        case=case,
    )


def _empty_solution(
    polynomial: Polynomial,
    operator: str,
    sign_table: SignTable,
    explanation: str,
) -> PolynomialInequalitySolution:
    return _make_solution(
        polynomial,
        operator,
        sign_table,
        intervals=[],
        roots_included=[],
        case="empty",
        explanation=explanation,
    )


def _normalize_operator(operator: str) -> str:
    mapping = {
        "≥": ">=",
        "≤": "<=",
    }
    return mapping.get(operator, operator.strip())


def _is_point_interval(interval: SolutionInterval) -> bool:
    if interval.left in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    if interval.right in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    difference = sp.simplify(sp.sympify(interval.left) - sp.sympify(interval.right))
    return difference == 0


def _is_finite_root(value: Any, real_roots: list[Any]) -> bool:
    if value in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    return any(sp.simplify(value - root) == 0 or value.equals(root) for root in real_roots)


def _covers_all_reals(intervals: list[SolutionInterval]) -> bool:
    if not intervals:
        return False

    if len(intervals) == 1:
        interval = intervals[0]
        return interval.left in (sp.S.NegativeInfinity, -oo) and interval.right in (
            sp.S.Infinity,
            oo,
        )

    if len(intervals) != 2:
        return False

    first, second = intervals[0], intervals[1]
    if not _is_neg_infinity(first.left) or not _is_pos_infinity(second.right):
        return False

    meeting_point = first.right
    if not sp.simplify(meeting_point - second.left) == 0 and not meeting_point.equals(
        second.left
    ):
        return False

    return first.right_closed and second.left_closed


def _is_neg_infinity(value: Any) -> bool:
    return value in (sp.S.NegativeInfinity, -oo)


def _is_pos_infinity(value: Any) -> bool:
    return value in (sp.S.Infinity, oo)


def _format_bound(bound: Any) -> str:
    if bound in (sp.S.NegativeInfinity, -oo):
        return "-∞"
    if bound in (sp.S.Infinity, oo):
        return "+∞"
    return str(bound)
