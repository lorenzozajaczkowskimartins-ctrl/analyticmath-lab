"""Resolução de inequações reais para funções simbólicas gerais.

Determina conjuntos solução de f(x) > 0, ≥, <, ≤, == e != reutilizando
``build_function_sign_table`` sem duplicar lógica de domínio ou sinais.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import S, oo

from analyticmath.functions.domain import find_real_domain
from analyticmath.functions.sign_table import (
    FunctionCriticalSignPoint,
    FunctionSignInterval,
    FunctionSignTable,
    build_function_sign_table,
    sign_of,
)
from analyticmath.utils.errors import ValidationError

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

Operator = Literal[">", "<", ">=", "<=", "==", "!="]
SolutionCase = Literal[
    "general",
    "all_domain",
    "empty",
    "zero_function",
    "unknown",
    "domain_limited",
]

VALID_OPERATORS: frozenset[str] = frozenset({">", "<", ">=", "<=", "==", "!="})


@dataclass(frozen=True)
class FunctionSolutionInterval:
    """Intervalo ou ponto da solução de uma inequação de função."""

    left: Any
    right: Any
    left_closed: bool
    right_closed: bool
    reason: str = ""
    in_domain: bool = True


@dataclass
class FunctionInequalitySolution:
    """Solução estruturada de uma inequação f(x) relação 0."""

    function: SymbolicFunction
    operator: str
    sign_table: FunctionSignTable
    intervals: list[FunctionSolutionInterval]
    included_points: list[Any]
    excluded_points: list[Any]
    explanation: str
    case: str = field(default="general")


def solve_function_inequality(
    function: SymbolicFunction,
    operator: str,
) -> FunctionInequalitySolution:
    """Resolve ``function`` relação ``operator`` 0 usando a tabela de sinais."""
    normalized = _normalize_operator(operator)
    if normalized not in VALID_OPERATORS:
        raise ValidationError(
            f"Operador inválido: {operator!r}. Use um de {sorted(VALID_OPERATORS)}."
        )

    sign_table = build_function_sign_table(function)
    return _solve_from_sign_table(function, normalized, sign_table)


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


def point_satisfies_operator(value: Any, operator: str) -> bool:
    """Indica se o valor de f(x) em um ponto satisfaz o operador."""
    sign = sign_of(value)
    if operator == ">":
        return sign == "+"
    if operator == "<":
        return sign == "-"
    if operator == ">=":
        return sign in ("+", "0")
    if operator == "<=":
        return sign in ("-", "0")
    if operator == "==":
        return sign == "0"
    if operator == "!=":
        return sign in ("+", "-")
    return False


def format_function_solution_interval(interval: FunctionSolutionInterval) -> str:
    """Formata um intervalo de solução em notação padrão."""
    if _is_point_interval(interval):
        return f"{{{_format_bound(interval.left)}}}"

    left_bracket = "[" if interval.left_closed else "("
    right_bracket = "]" if interval.right_closed else ")"
    return (
        f"{left_bracket}{_format_bound(interval.left)}, "
        f"{_format_bound(interval.right)}{right_bracket}"
    )


def format_function_inequality_solution(solution: FunctionInequalitySolution) -> str:
    """Formata a solução completa de uma inequação de função."""
    var = solution.function.variable
    header = f"f({var}) {solution.operator} 0:"

    if solution.case == "unknown":
        body = solution.explanation or "Não foi possível determinar a solução nesta versão."
        return f"{header}\n{body}"

    if solution.case == "empty" or not solution.intervals:
        return f"{header}\n∅"

    body = " ∪ ".join(format_function_solution_interval(i) for i in solution.intervals)
    return f"{header}\n{body}"


def _solve_from_sign_table(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    if sign_table.case == "unknown":
        return _unknown_solution(function, operator, sign_table)

    handlers = {
        "zero_function": _solve_zero_function,
        "always_positive": _solve_always_positive,
        "always_negative": _solve_always_negative,
    }

    if sign_table.case in handlers:
        return handlers[sign_table.case](function, operator, sign_table)

    return _solve_general(function, operator, sign_table)


def _solve_zero_function(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    if operator in (">", "<", "!="):
        return _empty_solution(
            function,
            operator,
            sign_table,
            "A função é identicamente nula; a inequação estrita ou de diferença não possui solução.",
        )

    return _make_solution(
        function,
        operator,
        sign_table,
        intervals=[_all_domain_interval(function)],
        included_points=[],
        excluded_points=[],
        case="zero_function",
        explanation="A função é identicamente nula; a solução é todo o domínio da função.",
    )


def _solve_always_positive(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    if operator in (">", ">=", "!="):
        return _make_solution(
            function,
            operator,
            sign_table,
            intervals=[_all_domain_interval(function)],
            included_points=[],
            excluded_points=[],
            case="all_domain",
            explanation="A função é sempre positiva no domínio; a inequação é satisfeita em todo o domínio.",
        )

    return _empty_solution(
        function,
        operator,
        sign_table,
        "A função é sempre positiva; não há valores no domínio que satisfaçam a inequação.",
    )


def _solve_always_negative(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    if operator in ("<", "<=", "!="):
        return _make_solution(
            function,
            operator,
            sign_table,
            intervals=[_all_domain_interval(function)],
            included_points=[],
            excluded_points=[],
            case="all_domain",
            explanation="A função é sempre negativa no domínio; a inequação é satisfeita em todo o domínio.",
        )

    return _empty_solution(
        function,
        operator,
        sign_table,
        "A função é sempre negativa; não há valores no domínio que satisfaçam a inequação.",
    )


def _solve_general(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    critical_by_x = _index_critical_points(sign_table.critical_points)
    included_points, excluded_points = _collect_solution_points(sign_table, operator)

    if operator == "==":
        intervals = _point_intervals_from_points(included_points)
        case: SolutionCase = "empty" if not intervals else "general"
        if sign_table.case == "domain_limited" and intervals:
            case = "domain_limited"
        return _make_solution(
            function,
            operator,
            sign_table,
            intervals=intervals,
            included_points=included_points,
            excluded_points=excluded_points,
            case=case,
            explanation=(
                "A solução é o conjunto dos pontos em que f(x) = 0 no domínio."
                if intervals
                else "Não há pontos no domínio em que f(x) = 0."
            ),
        )

    if operator == "!=":
        intervals = [
            _open_sign_interval(sign_interval)
            for sign_interval in sign_table.intervals
            if sign_interval.in_domain
            and interval_satisfies_operator(sign_interval.sign, operator)
        ]
        case = _determine_general_case(function, intervals, sign_table)
        return _make_solution(
            function,
            operator,
            sign_table,
            intervals=intervals,
            included_points=[],
            excluded_points=excluded_points,
            case=case,
            explanation="A solução exclui os zeros de f(x) e inclui os demais intervalos abertos no domínio.",
        )

    target_sign = "+" if operator in (">", ">=") else "-"
    intervals = [
        _convert_sign_interval(sign_interval, operator, critical_by_x)
        for sign_interval in sign_table.intervals
        if sign_interval.in_domain
        and sign_interval.sign not in ("undefined", "unknown")
        and sign_interval.sign == target_sign
    ]

    if _covers_all_domain(function, intervals):
        intervals = [_all_domain_interval(function)]
        case = "all_domain"
        explanation = f"A inequação f(x) {operator} 0 é satisfeita em todo o domínio da função."
    elif not intervals:
        case = "empty"
        explanation = f"Não há intervalos no domínio compatíveis com f(x) {operator} 0."
    else:
        case = "domain_limited" if sign_table.case == "domain_limited" else "general"
        explanation = f"Solução obtida a partir da tabela de sinais para f(x) {operator} 0."

    return _make_solution(
        function,
        operator,
        sign_table,
        intervals=intervals,
        included_points=included_points,
        excluded_points=excluded_points,
        case=case,
        explanation=explanation,
    )


def _convert_sign_interval(
    sign_interval: FunctionSignInterval,
    operator: str,
    critical_by_x: dict[str, FunctionCriticalSignPoint],
) -> FunctionSolutionInterval:
    left = sign_interval.left
    right = sign_interval.right
    left_cp = _find_critical_at(left, critical_by_x)
    right_cp = _find_critical_at(right, critical_by_x)

    left_closed = _endpoint_included(left, operator, left_cp)
    right_closed = _endpoint_included(right, operator, right_cp)

    return FunctionSolutionInterval(
        left=left,
        right=right,
        left_closed=left_closed,
        right_closed=right_closed,
        reason=sign_interval.explanation,
        in_domain=True,
    )


def _open_sign_interval(sign_interval: FunctionSignInterval) -> FunctionSolutionInterval:
    return FunctionSolutionInterval(
        left=sign_interval.left,
        right=sign_interval.right,
        left_closed=False,
        right_closed=False,
        reason=sign_interval.explanation,
        in_domain=True,
    )


def _point_interval(point: Any) -> FunctionSolutionInterval:
    return FunctionSolutionInterval(
        left=point,
        right=point,
        left_closed=True,
        right_closed=True,
        reason="zero da função no domínio",
        in_domain=True,
    )


def _point_intervals_from_points(points: list[Any]) -> list[FunctionSolutionInterval]:
    return [_point_interval(point) for point in points]


def _all_domain_interval(function: SymbolicFunction) -> FunctionSolutionInterval:
    domain = find_real_domain(function).domain

    if domain in (S.Reals, sp.Reals) or str(domain) == "Reals":
        return FunctionSolutionInterval(
            left=sp.S.NegativeInfinity,
            right=sp.S.Infinity,
            left_closed=False,
            right_closed=False,
            reason="domínio real completo",
            in_domain=True,
        )

    if getattr(domain, "is_Interval", False):
        return FunctionSolutionInterval(
            left=domain.start,
            right=domain.end,
            left_closed=not domain.left_open,
            right_closed=not domain.right_open,
            reason="domínio completo da função",
            in_domain=True,
        )

    return FunctionSolutionInterval(
        left=sp.S.NegativeInfinity,
        right=sp.S.Infinity,
        left_closed=False,
        right_closed=False,
        reason="domínio da função",
        in_domain=True,
    )


def _collect_solution_points(
    sign_table: FunctionSignTable,
    operator: str,
) -> tuple[list[Any], list[Any]]:
    included: list[Any] = []
    excluded: list[Any] = []

    for point in sign_table.critical_points:
        if point.kind in ("discontinuity", "vertical_asymptote"):
            excluded.append(point.x)
            continue

        if point.kind == "root":
            if operator in (">=", "<=", "==") and point.included_in_domain:
                included.append(point.x)
            else:
                excluded.append(point.x)
            continue

        if point.kind == "domain_boundary":
            if operator in (">=", "<=", "==") and point.included_in_domain:
                if point_satisfies_operator(point.function_value, operator):
                    included.append(point.x)
                else:
                    excluded.append(point.x)
            elif operator == "!=" and point.included_in_domain and sign_of(point.function_value) == "0":
                excluded.append(point.x)
            else:
                excluded.append(point.x)

    return included, excluded


def _endpoint_included(
    value: Any,
    operator: str,
    critical_point: FunctionCriticalSignPoint | None,
) -> bool:
    if value in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    if critical_point is None:
        return False
    if critical_point.kind in ("discontinuity", "vertical_asymptote"):
        return False
    if operator in (">", "<", "!="):
        return False
    if operator in (">=", "<="):
        if critical_point.kind == "root" and critical_point.included_in_domain:
            return True
        if critical_point.kind == "domain_boundary" and critical_point.included_in_domain:
            return point_satisfies_operator(critical_point.function_value, operator)
    return False


def _index_critical_points(
    critical_points: list[FunctionCriticalSignPoint],
) -> dict[str, FunctionCriticalSignPoint]:
    return {str(sp.simplify(point.x)): point for point in critical_points}


def _find_critical_at(
    value: Any,
    critical_by_x: dict[str, FunctionCriticalSignPoint],
) -> FunctionCriticalSignPoint | None:
    if value in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return None
    key = str(sp.simplify(value))
    if key in critical_by_x:
        return critical_by_x[key]
    for point in critical_by_x.values():
        if sp.simplify(value - point.x) == 0 or value.equals(point.x):
            return point
    return None


def _determine_general_case(
    function: SymbolicFunction,
    intervals: list[FunctionSolutionInterval],
    sign_table: FunctionSignTable,
) -> SolutionCase:
    if _covers_all_domain(function, intervals):
        return "all_domain"
    if not intervals:
        return "empty"
    if sign_table.case == "domain_limited":
        return "domain_limited"
    return "general"


def _covers_all_domain(
    function: SymbolicFunction,
    intervals: list[FunctionSolutionInterval],
) -> bool:
    if not intervals:
        return False

    domain = find_real_domain(function).domain
    if domain in (S.Reals, sp.Reals) or str(domain) == "Reals":
        if len(intervals) == 1:
            interval = intervals[0]
            return interval.left in (sp.S.NegativeInfinity, -oo) and interval.right in (
                sp.S.Infinity,
                oo,
            )
        if len(intervals) == 2:
            first, second = intervals[0], intervals[1]
            if not _is_neg_infinity(first.left) or not _is_pos_infinity(second.right):
                return False
            meeting_point = first.right
            if not sp.simplify(meeting_point - second.left) == 0 and not meeting_point.equals(
                second.left
            ):
                return False
            return first.right_closed and second.left_closed
        return False

    if getattr(domain, "is_Interval", False) and len(intervals) == 1:
        interval = intervals[0]
        same_left = sp.simplify(interval.left - domain.start) == 0 or interval.left.equals(
            domain.start
        )
        same_right = sp.simplify(interval.right - domain.end) == 0 or interval.right.equals(
            domain.end
        )
        if same_left and same_right:
            expected_left_closed = not domain.left_open
            expected_right_closed = not domain.right_open
            return (
                interval.left_closed == expected_left_closed
                and interval.right_closed == expected_right_closed
            )

    return False


def _unknown_solution(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
) -> FunctionInequalitySolution:
    explanation = (
        sign_table.explanation
        or "A tabela de sinais não pôde ser construída completamente; "
        "a solução da inequação permanece indeterminada nesta versão."
    )
    return FunctionInequalitySolution(
        function=function,
        operator=operator,
        sign_table=sign_table,
        intervals=[],
        included_points=[],
        excluded_points=[],
        explanation=explanation,
        case="unknown",
    )


def _make_solution(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
    *,
    intervals: list[FunctionSolutionInterval],
    included_points: list[Any],
    excluded_points: list[Any],
    case: str,
    explanation: str,
) -> FunctionInequalitySolution:
    return FunctionInequalitySolution(
        function=function,
        operator=operator,
        sign_table=sign_table,
        intervals=intervals,
        included_points=included_points,
        excluded_points=excluded_points,
        explanation=explanation,
        case=case,
    )


def _empty_solution(
    function: SymbolicFunction,
    operator: str,
    sign_table: FunctionSignTable,
    explanation: str,
) -> FunctionInequalitySolution:
    return _make_solution(
        function,
        operator,
        sign_table,
        intervals=[],
        included_points=[],
        excluded_points=[],
        case="empty",
        explanation=explanation,
    )


def _normalize_operator(operator: str) -> str:
    mapping = {
        "≥": ">=",
        "≤": "<=",
    }
    return mapping.get(operator, operator.strip())


def _is_point_interval(interval: FunctionSolutionInterval) -> bool:
    if interval.left in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    if interval.right in (sp.S.NegativeInfinity, -oo, sp.S.Infinity, oo):
        return False
    difference = sp.simplify(sp.sympify(interval.left) - sp.sympify(interval.right))
    return difference == 0


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
