"""Tabela de sinais para funções simbólicas gerais."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import S, oo, solveset

from analyticmath.functions.continuity import safe_function_value
from analyticmath.functions.domain import find_real_domain

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

SignSymbol = Literal["+", "-", "0", "undefined", "unknown"]
CriticalKind = Literal[
    "root",
    "discontinuity",
    "vertical_asymptote",
    "domain_boundary",
    "unknown",
]

_KIND_LABELS = {
    "root": "raiz",
    "discontinuity": "descontinuidade",
    "vertical_asymptote": "assíntota vertical",
    "domain_boundary": "fronteira do domínio",
    "unknown": "ponto crítico",
}


@dataclass(frozen=True)
class FunctionSignInterval:
    """Intervalo da reta real com sinal de f(x) no interior."""

    left: Any
    right: Any
    test_point: Any
    value_at_test_point: Any
    sign: str
    in_domain: bool
    explanation: str


@dataclass(frozen=True)
class FunctionCriticalSignPoint:
    """Ponto crítico que separa intervalos de sinal."""

    x: Any
    kind: str
    function_value: Any | None
    included_in_domain: bool
    sign_behavior: str
    explanation: str


@dataclass
class FunctionSignTable:
    """Resultado estruturado da tabela de sinais de uma função."""

    function: SymbolicFunction
    critical_points: list[FunctionCriticalSignPoint]
    intervals: list[FunctionSignInterval]
    explanation: str
    case: str = "general"


def build_function_sign_table(function: SymbolicFunction) -> FunctionSignTable:
    """Constrói a tabela de sinais real de ``function``."""
    notes: list[str] = []

    if _is_zero_function(function):
        interval = _build_interval(
            function,
            sp.S.NegativeInfinity,
            sp.S.Infinity,
            critical_points=[],
        )
        return FunctionSignTable(
            function=function,
            critical_points=[],
            intervals=[interval],
            explanation="A função é identicamente nula; o sinal é zero em todo o domínio.",
            case="zero_function",
        )

    infinite_roots = _has_infinite_real_roots(function)
    if infinite_roots:
        notes.append(
            "A função possui infinitas raízes reais ou periódicas; "
            "nesta versão não enumera todos os pontos críticos."
        )
        return FunctionSignTable(
            function=function,
            critical_points=[],
            intervals=[],
            explanation=" ".join(notes),
            case="unknown",
        )

    critical_points = _collect_critical_points(function)
    sorted_x = [point.x for point in critical_points]
    intervals = _build_intervals(function, sorted_x, critical_points)

    domain_limited = not _is_full_real_domain(function)
    case = _determine_case(function, intervals)
    explanation = _build_explanation(critical_points, intervals, case, notes)

    return FunctionSignTable(
        function=function,
        critical_points=critical_points,
        intervals=intervals,
        explanation=explanation,
        case=case,
    )


def sign_of(value: Any) -> str:
    """Retorna '+', '-', '0', 'undefined' ou 'unknown' para um valor."""
    if value is None:
        return "undefined"

    if isinstance(value, str) and value in ("undefined", "unknown"):
        return value

    try:
        simplified = sp.simplify(value)
    except Exception:
        return "unknown"

    if simplified == 0 or getattr(simplified, "equals", lambda _other: False)(0):
        return "0"

    if getattr(simplified, "is_positive", False):
        return "+"
    if getattr(simplified, "is_negative", False):
        return "-"

    if getattr(simplified, "is_number", False):
        try:
            numeric = float(sp.N(simplified))
            if numeric == 0.0:
                return "0"
            return "+" if numeric > 0 else "-"
        except (TypeError, ValueError):
            return "unknown"

    try:
        numeric = sp.N(simplified)
        if numeric.is_zero:
            return "0"
        return "+" if float(numeric) > 0 else "-"
    except (TypeError, ValueError):
        return "unknown"


def is_point_in_domain(function: SymbolicFunction, point: Any) -> bool | None:
    """Indica se ``point`` pertence ao domínio real da função."""
    if point in (sp.S.NegativeInfinity, sp.S.Infinity, -oo, oo):
        return None

    domain = find_real_domain(function).domain
    result = domain.contains(point)

    if result == True:
        return True
    if result == False:
        return False
    return None


def format_function_sign_interval(interval: FunctionSignInterval) -> str:
    """Formata um intervalo de sinal."""
    domain_note = "" if interval.in_domain else " [fora do domínio]"
    return f"{_format_bounds(interval.left, interval.right)}: {interval.sign}{domain_note}"


def format_function_critical_sign_point(point: FunctionCriticalSignPoint) -> str:
    """Formata um ponto crítico de sinal."""
    label = _format_critical_label(point)
    return f"x = {point.x}: {label}"


def format_function_sign_table(table: FunctionSignTable) -> str:
    """Formata a tabela de sinais completa."""
    lines = ["Tabela de sinais:"]

    if table.case == "zero_function":
        lines.append("(-∞, +∞): 0")
        lines.append(f"\nExplicação: {table.explanation}")
        return "\n".join(lines)

    if table.case == "unknown" and not table.intervals:
        lines.append("Não foi possível construir a tabela completa nesta versão.")
        if table.explanation:
            lines.append(f"\nExplicação: {table.explanation}")
        return "\n".join(lines)

    point_index = 0
    critical_points = table.critical_points

    for interval in table.intervals:
        if not interval.in_domain:
            continue
        lines.append(format_function_sign_interval(interval))

        while point_index < len(critical_points):
            critical = critical_points[point_index]
            if not _matches_bound(critical.x, interval.right):
                break
            lines.append(format_function_critical_sign_point(critical))
            point_index += 1

    if table.explanation:
        lines.append(f"\nExplicação: {table.explanation}")

    return "\n".join(lines)


def _collect_critical_points(function: SymbolicFunction) -> list[FunctionCriticalSignPoint]:
    registry: dict[str, FunctionCriticalSignPoint] = {}

    for root in function.roots().real_roots:
        if not _is_finite_real_number(root):
            continue
        _register_critical_point(
            registry,
            sp.simplify(root),
            kind="root",
            function=function,
            explanation=f"x = {root} anula a função.",
        )

    continuity = function.continuity()
    for discontinuity in continuity.discontinuities:
        kind = (
            "vertical_asymptote"
            if discontinuity.vertical_asymptote
            else "discontinuity"
        )
        _register_critical_point(
            registry,
            sp.simplify(discontinuity.x),
            kind=kind,
            function=function,
            explanation=discontinuity.explanation,
        )

    for asymptote in function.asymptotes().vertical_asymptotes:
        _register_critical_point(
            registry,
            sp.simplify(asymptote.x),
            kind="vertical_asymptote",
            function=function,
            explanation=asymptote.explanation,
        )

    domain = find_real_domain(function).domain
    for point in _domain_internal_boundaries(domain):
        _register_critical_point(
            registry,
            point,
            kind="domain_boundary",
            function=function,
            explanation=f"x = {point} é fronteira interna ou raiz no domínio.",
        )

    sorted_points = sorted(registry.values(), key=lambda item: float(sp.N(item.x)))
    return sorted_points


def _register_critical_point(
    registry: dict[str, FunctionCriticalSignPoint],
    x: Any,
    *,
    kind: str,
    function: SymbolicFunction,
    explanation: str,
) -> None:
    key = str(sp.simplify(x))
    included = is_point_in_domain(function, x)
    value = safe_function_value(function, x) if included else None

    if key in registry:
        existing = registry[key]
        merged_kind = _merge_kind(existing.kind, kind)
        merged_explanation = existing.explanation
        if kind not in existing.explanation:
            merged_explanation = f"{existing.explanation} {explanation}".strip()
        registry[key] = FunctionCriticalSignPoint(
            x=x,
            kind=merged_kind,
            function_value=value if value is not None else existing.function_value,
            included_in_domain=included if included is not None else existing.included_in_domain,
            sign_behavior=_sign_behavior_label(merged_kind),
            explanation=merged_explanation,
        )
        return

    registry[key] = FunctionCriticalSignPoint(
        x=x,
        kind=kind,
        function_value=value,
        included_in_domain=bool(included) if included is not None else False,
        sign_behavior=_sign_behavior_label(kind),
        explanation=explanation,
    )


def _build_intervals(
    function: SymbolicFunction,
    sorted_x: list[Any],
    critical_points: list[FunctionCriticalSignPoint],
) -> list[FunctionSignInterval]:
    del critical_points
    bounds: list[Any] = [sp.S.NegativeInfinity, *sorted_x, sp.S.Infinity]
    intervals: list[FunctionSignInterval] = []

    for left, right in zip(bounds[:-1], bounds[1:], strict=True):
        intervals.append(_build_interval(function, left, right, critical_points=[]))

    return intervals


def _build_interval(
    function: SymbolicFunction,
    left: Any,
    right: Any,
    critical_points: list[FunctionCriticalSignPoint],
) -> FunctionSignInterval:
    del critical_points
    test_point = _choose_test_point(left, right)
    in_domain = is_point_in_domain(function, test_point)

    if in_domain is False:
        return FunctionSignInterval(
            left=left,
            right=right,
            test_point=test_point,
            value_at_test_point=None,
            sign="undefined",
            in_domain=False,
            explanation="O ponto de teste não pertence ao domínio real da função.",
        )

    if in_domain is None:
        value = _safe_evaluate(function, test_point)
        sign = sign_of(value) if value is not None else "unknown"
        return FunctionSignInterval(
            left=left,
            right=right,
            test_point=test_point,
            value_at_test_point=value,
            sign=sign,
            in_domain=True,
            explanation="Não foi possível decidir completamente a pertinência ao domínio.",
        )

    value = _safe_evaluate(function, test_point)
    sign = sign_of(value) if value is not None else "undefined"

    return FunctionSignInterval(
        left=left,
        right=right,
        test_point=test_point,
        value_at_test_point=value,
        sign=sign,
        in_domain=True,
        explanation=f"Sinal determinado em x = {test_point}.",
    )


def _safe_evaluate(function: SymbolicFunction, point: Any) -> Any | None:
    try:
        value = sp.simplify(function.evaluate(point))
    except Exception:
        return None

    if value is sp.nan or getattr(value, "is_nan", False):
        return None
    if getattr(value, "is_complex", False) and not sp.im(value).equals(0):
        return None
    return value


def _choose_test_point(left: Any, right: Any) -> Any:
    neg_inf = sp.S.NegativeInfinity
    pos_inf = sp.S.Infinity

    if left in (neg_inf, -oo) and right not in (pos_inf, oo):
        return sp.simplify(right - 1)

    if right in (pos_inf, oo) and left not in (neg_inf, -oo):
        return sp.simplify(left + 1)

    if left in (neg_inf, -oo) and right in (pos_inf, oo):
        return sp.Integer(0)

    return sp.simplify((left + right) / 2)


def _has_infinite_real_roots(function: SymbolicFunction) -> bool:
    if function.expr.has(sp.sin, sp.cos, sp.tan, sp.cot, sp.sec, sp.csc):
        real_solution_set = solveset(function.expr, function.symbol, domain=S.Reals)
        if not getattr(real_solution_set, "is_FiniteSet", False):
            return True

    real_solution_set = solveset(function.expr, function.symbol, domain=S.Reals)
    if getattr(real_solution_set, "is_FiniteSet", False):
        return False
    if real_solution_set in (S.EmptySet, S.Reals):
        return False
    return bool(real_solution_set.has(sp.ImageSet, sp.ConditionSet))


def _is_zero_function(function: SymbolicFunction) -> bool:
    return sp.simplify(function.expr) == 0 or function.expr.equals(0)


def _is_full_real_domain(function: SymbolicFunction) -> bool:
    domain = find_real_domain(function).domain
    return domain in (S.Reals, sp.Reals) or str(domain) == "Reals"


def _domain_internal_boundaries(domain: Any) -> set[Any]:
    boundaries: set[Any] = set()
    if domain.is_Interval and not domain.left_open and domain.start.is_real:
        boundaries.add(sp.simplify(domain.start))
    return boundaries


def _determine_case(
    function: SymbolicFunction,
    intervals: list[FunctionSignInterval],
) -> str:
    valid = [interval for interval in intervals if interval.in_domain]

    if not _is_full_real_domain(function) and any(not interval.in_domain for interval in intervals):
        return "domain_limited"

    if len(valid) == 1:
        sign = valid[0].sign
        if sign == "+":
            return "always_positive"
        if sign == "-":
            return "always_negative"

    return "general"


def _build_explanation(
    critical_points: list[FunctionCriticalSignPoint],
    intervals: list[FunctionSignInterval],
    case: str,
    notes: list[str],
) -> str:
    parts: list[str] = []

    if case == "always_positive":
        parts.append("A função mantém sinal positivo no domínio analisado.")
    elif case == "always_negative":
        parts.append("A função mantém sinal negativo no domínio analisado.")
    elif case == "domain_limited":
        parts.append("A função possui domínio limitado; intervalos fora do domínio foram ignorados.")
    else:
        parts.append(
            f"Tabela construída com {len(critical_points)} ponto(s) crítico(s) "
            f"e {len([i for i in intervals if i.in_domain])} intervalo(s) válido(s)."
        )

    parts.extend(notes)
    return " ".join(parts)


def _merge_kind(existing: str, new: str) -> str:
    priority = {
        "vertical_asymptote": 4,
        "discontinuity": 3,
        "domain_boundary": 2,
        "root": 1,
        "unknown": 0,
    }
    return existing if priority.get(existing, 0) >= priority.get(new, 0) else new


def _sign_behavior_label(kind: str) -> str:
    return _KIND_LABELS.get(kind, kind)


def _format_critical_label(point: FunctionCriticalSignPoint) -> str:
    if point.kind == "root":
        return "raiz"
    if point.kind == "vertical_asymptote":
        if point.sign_behavior == "descontinuidade":
            return "descontinuidade / assíntota vertical"
        return "descontinuidade / assíntota vertical"
    if point.kind == "discontinuity":
        return "descontinuidade"
    if point.kind == "domain_boundary":
        return "fronteira do domínio / raiz"
    return point.sign_behavior


def _format_bounds(left: Any, right: Any) -> str:
    return f"({_format_bound(left)}, {_format_bound(right)})"


def _format_bound(bound: Any) -> str:
    if bound in (sp.S.NegativeInfinity, -oo):
        return "-∞"
    if bound in (sp.S.Infinity, oo):
        return "+∞"
    return str(bound)


def _matches_bound(value: Any, bound: Any) -> bool:
    if bound in (sp.S.Infinity, oo):
        return False
    return sp.simplify(value - bound) == 0 or value.equals(bound)


def _is_finite_real_number(value: Any) -> bool:
    if value in (sp.S.NegativeInfinity, sp.S.Infinity, -oo, oo, sp.zoo):
        return False
    return sp.im(value).equals(0)
