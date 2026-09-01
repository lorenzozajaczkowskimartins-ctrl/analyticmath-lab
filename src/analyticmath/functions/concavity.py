"""Concavidade e pontos de inflexão para funções simbólicas gerais.

Analisa sinais de f''(x), intervalos côncavos para cima/baixo e
classifica candidatos a inflexão pela mudança de concavidade.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import S, oo

from analyticmath.functions.continuity import safe_function_value
from analyticmath.functions.inequalities import (
    FunctionSolutionInterval,
    solve_function_inequality,
)
from analyticmath.functions.limits import limit_at
from analyticmath.functions.sign_table import (
    build_function_sign_table,
    is_point_in_domain,
    sign_of,
)

if TYPE_CHECKING:
    from analyticmath.functions.sign_table import FunctionSignTable
    from analyticmath.functions.symbolic_function import SymbolicFunction

InflectionClassification = Literal[
    "inflection_point",
    "stationary_inflection",
    "candidate_not_inflection",
    "undetermined",
]

AnalysisCase = Literal[
    "general",
    "linear_function",
    "constant_function",
    "no_inflection_points",
    "unknown",
]

_CLASSIFICATION_LABELS: dict[str, str] = {
    "inflection_point": "ponto de inflexão",
    "stationary_inflection": "ponto de inflexão estacionário",
    "candidate_not_inflection": "candidato sem mudança de concavidade",
    "undetermined": "indeterminado",
}


@dataclass(frozen=True)
class InflectionPoint:
    """Candidato ou ponto de inflexão de uma função simbólica."""

    x: Any
    y: Any
    second_derivative_value: Any
    concavity_left_sign: str
    concavity_right_sign: str
    in_domain: bool
    classification: str
    explanation: str


@dataclass
class ConcavityAnalysis:
    """Análise completa de concavidade e inflexão."""

    function: SymbolicFunction
    first_derivative: SymbolicFunction
    second_derivative: SymbolicFunction
    concave_up_intervals: list[FunctionSolutionInterval]
    concave_down_intervals: list[FunctionSolutionInterval]
    inflection_points: list[InflectionPoint]
    explanation: str
    case: str = field(default="general")


def analyze_concavity(function: SymbolicFunction) -> ConcavityAnalysis:
    """Analisa concavidade, intervalos e pontos de inflexão de ``function``."""
    first_derivative = function.derivative()
    second_derivative = first_derivative.derivative()

    if _is_zero_expression(second_derivative):
        if _is_zero_expression(first_derivative):
            return _analyze_constant_function(function, first_derivative, second_derivative)
        return _analyze_linear_function(function, first_derivative, second_derivative)

    second_derivative_sign_table = _build_sign_table(second_derivative)
    if second_derivative_sign_table.case == "unknown" and not second_derivative_sign_table.intervals:
        return _analyze_unknown(function, first_derivative, second_derivative, second_derivative_sign_table)

    candidates = _collect_inflection_candidates(function, second_derivative)
    evaluated_points = [
        _build_inflection_point(
            function,
            first_derivative,
            second_derivative,
            second_derivative_sign_table,
            candidate,
        )
        for candidate in candidates
    ]

    inflection_points = [
        point
        for point in evaluated_points
        if point.classification in ("inflection_point", "stationary_inflection")
    ]

    concave_up_intervals = _concavity_intervals(second_derivative, ">")
    concave_down_intervals = _concavity_intervals(second_derivative, "<")

    if inflection_points:
        case: AnalysisCase = "general"
        explanation = (
            f"Foram identificados {len(inflection_points)} ponto(s) de inflexão "
            f"com mudança de concavidade."
        )
    else:
        case = "no_inflection_points"
        explanation = _no_inflection_explanation(
            second_derivative_sign_table,
            evaluated_points,
            concave_up_intervals=concave_up_intervals,
            concave_down_intervals=concave_down_intervals,
        )

    return ConcavityAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        concave_up_intervals=concave_up_intervals,
        concave_down_intervals=concave_down_intervals,
        inflection_points=inflection_points,
        explanation=explanation,
        case=case,
    )


def safe_evaluate(function: SymbolicFunction, point: Any) -> Any | None:
    """Avalia f(point) apenas se o ponto pertence ao domínio real."""
    return safe_function_value(function, point)


def classify_inflection_point(
    left_sign: str,
    right_sign: str,
    first_derivative_value: Any | None = None,
) -> str:
    """Classifica um candidato a inflexão pelos sinais laterais de f''."""
    if left_sign == "+" and right_sign == "-":
        if first_derivative_value is not None and _is_zero(first_derivative_value):
            return "stationary_inflection"
        return "inflection_point"

    if left_sign == "-" and right_sign == "+":
        if first_derivative_value is not None and _is_zero(first_derivative_value):
            return "stationary_inflection"
        return "inflection_point"

    if left_sign == right_sign and left_sign in ("+", "-"):
        return "candidate_not_inflection"

    if left_sign in ("undefined", "unknown", "0") or right_sign in ("undefined", "unknown", "0"):
        return "undetermined"

    return "undetermined"


def format_inflection_point(point: InflectionPoint) -> str:
    """Formata um ponto de inflexão para exibição."""
    x_text = _format_numeric(point.x)
    y_text = _format_numeric(point.y) if point.y is not None else "indefinido"
    label = _CLASSIFICATION_LABELS.get(point.classification, point.classification)

    lines = [
        f"x = {x_text}, f(x) = {y_text}",
        f"Classificação: {label}",
        f"Justificativa: {point.explanation}",
    ]
    return "\n".join(lines)


def format_concavity_analysis(analysis: ConcavityAnalysis) -> str:
    """Formata a análise completa de concavidade."""
    var = analysis.function.variable
    lines = ["Análise de concavidade:", ""]
    lines.append(f"f''({var}) = {analysis.second_derivative}")
    lines.append("")

    if analysis.case == "unknown":
        lines.append(analysis.explanation)
        return "\n".join(lines)

    if analysis.case == "constant_function":
        lines.append("Função constante: f''(x) = 0 em todo o domínio.")
        lines.append("A concavidade não varia; não há pontos de inflexão.")
        lines.append(analysis.explanation)
        return "\n".join(lines)

    if analysis.case == "linear_function":
        lines.append("Função linear ou afim: f''(x) = 0 em todo o domínio.")
        lines.append("A concavidade não varia; não há pontos de inflexão.")
        lines.append(analysis.explanation)
        return "\n".join(lines)

    lines.extend(_format_concavity_interval_lines(analysis))
    lines.append("")

    if analysis.inflection_points:
        lines.append("Pontos de inflexão:")
        for index, point in enumerate(analysis.inflection_points, start=1):
            lines.append(f"{index}. {format_inflection_point(point)}")
            lines.append("")
    else:
        lines.append("Pontos de inflexão: nenhum confirmado.")
        lines.append("")

    if analysis.explanation:
        lines.append(analysis.explanation)

    return "\n".join(lines).rstrip()


def _analyze_constant_function(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
) -> ConcavityAnalysis:
    return ConcavityAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        concave_up_intervals=[],
        concave_down_intervals=[],
        inflection_points=[],
        explanation=(
            "Função constante: f''(x) = 0 em todo o domínio. "
            "Não há variação de concavidade nem pontos de inflexão."
        ),
        case="constant_function",
    )


def _analyze_linear_function(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
) -> ConcavityAnalysis:
    return ConcavityAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        concave_up_intervals=[],
        concave_down_intervals=[],
        inflection_points=[],
        explanation=(
            "Função linear ou afim: f''(x) = 0 em todo o domínio. "
            "Não há variação de concavidade nem pontos de inflexão."
        ),
        case="linear_function",
    )


def _analyze_unknown(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
    sign_table: FunctionSignTable,
) -> ConcavityAnalysis:
    explanation = (
        sign_table.explanation
        or "Não foi possível construir a tabela de sinais de f''(x) nesta versão; "
        "a análise de concavidade permanece indeterminada."
    )
    return ConcavityAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        concave_up_intervals=[],
        concave_down_intervals=[],
        inflection_points=[],
        explanation=explanation,
        case="unknown",
    )


def _build_inflection_point(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
    sign_table: FunctionSignTable,
    x_value: Any,
) -> InflectionPoint:
    left_sign, right_sign = _concavity_signs_at(
        function,
        second_derivative,
        sign_table,
        x_value,
    )
    first_value = safe_evaluate(first_derivative, x_value)
    second_value = safe_evaluate(second_derivative, x_value)
    classification = classify_inflection_point(left_sign, right_sign, first_value)
    explanation = _build_point_explanation(
        x_value,
        classification,
        left_sign,
        right_sign,
        first_value,
    )

    return InflectionPoint(
        x=x_value,
        y=safe_evaluate(function, x_value),
        second_derivative_value=second_value,
        concavity_left_sign=left_sign,
        concavity_right_sign=right_sign,
        in_domain=is_point_in_domain(function, x_value) == True,
        classification=classification,
        explanation=explanation,
    )


def _collect_inflection_candidates(
    function: SymbolicFunction,
    second_derivative: SymbolicFunction,
) -> list[Any]:
    registry: dict[str, Any] = {}

    for root in second_derivative.roots().real_roots:
        if _is_finite_real(root):
            _register_candidate(registry, sp.simplify(root), function)

    try:
        for discontinuity in second_derivative.continuity().discontinuities:
            _register_candidate(registry, sp.simplify(discontinuity.x), function)
    except Exception:
        pass

    for point in _domain_internal_boundaries(function):
        _register_candidate(registry, point, function)

    return sorted(registry.values(), key=lambda value: float(sp.N(value)))


def _register_candidate(
    registry: dict[str, Any],
    x_value: Any,
    function: SymbolicFunction,
) -> None:
    if not _function_defined_at(function, x_value):
        return
    registry[str(sp.simplify(x_value))] = sp.simplify(x_value)


def _function_defined_at(function: SymbolicFunction, point: Any) -> bool:
    if is_point_in_domain(function, point) != True:
        return False
    return safe_evaluate(function, point) is not None


def _concavity_signs_at(
    function: SymbolicFunction,
    second_derivative: SymbolicFunction,
    sign_table: FunctionSignTable,
    x_value: Any,
) -> tuple[str, str]:
    if sign_table.case != "unknown" and sign_table.intervals:
        left_sign, right_sign = _signs_from_table(sign_table, x_value)
        if not (left_sign == "0" and right_sign == "0"):
            return left_sign, right_sign

    return _concavity_side_signs_fallback(function, second_derivative, x_value)


def _signs_from_table(
    sign_table: FunctionSignTable,
    x_value: Any,
) -> tuple[str, str]:
    left_sign = "0"
    right_sign = "0"

    for interval in sign_table.intervals:
        if not interval.in_domain:
            continue
        if _matches_bound(interval.right, x_value):
            left_sign = interval.sign
        if _matches_bound(interval.left, x_value):
            right_sign = interval.sign

    return left_sign, right_sign


def _concavity_side_signs_fallback(
    function: SymbolicFunction,
    second_derivative: SymbolicFunction,
    x_value: Any,
) -> tuple[str, str]:
    left = _side_second_derivative_sign(function, second_derivative, x_value, "-")
    right = _side_second_derivative_sign(function, second_derivative, x_value, "+")
    return left, right


def _side_second_derivative_sign(
    function: SymbolicFunction,
    second_derivative: SymbolicFunction,
    x_value: Any,
    direction: str,
) -> str:
    if function.expr.has(sp.Abs):
        return "undefined"

    try:
        limit_value = limit_at(second_derivative, x_value, direction=direction).value
        if _is_positive_infinity(limit_value):
            return "inf"
        if _is_negative_infinity(limit_value):
            return "-inf"
        if limit_value is not None:
            return sign_of(limit_value)
    except Exception:
        pass

    test_point = _test_point_near(function, x_value, direction)
    if test_point is None:
        return "undefined"

    value = safe_evaluate(second_derivative, test_point)
    if value is None:
        return "undefined"

    try:
        return sign_of(value)
    except Exception:
        return "undefined"


def _test_point_near(
    function: SymbolicFunction,
    x_value: Any,
    direction: str,
) -> Any | None:
    if direction == "-":
        candidate = sp.simplify(x_value - sp.Rational(1, 100))
    else:
        candidate = sp.simplify(x_value + sp.Rational(1, 100))

    if is_point_in_domain(function, candidate) == True:
        return candidate

    if direction == "+":
        candidate = sp.simplify(x_value + sp.Rational(1, 1000))
    else:
        candidate = sp.simplify(x_value - sp.Rational(1, 1000))

    if is_point_in_domain(function, candidate) == True:
        return candidate

    return None


def _concavity_intervals(
    second_derivative: SymbolicFunction,
    operator: str,
) -> list[FunctionSolutionInterval]:
    try:
        solution = solve_function_inequality(second_derivative, operator)
        if solution.case == "unknown":
            return []
        return list(solution.intervals)
    except Exception:
        return []


def _build_point_explanation(
    x_value: Any,
    classification: str,
    left_sign: str,
    right_sign: str,
    first_derivative_value: Any,
) -> str:
    x_text = _format_numeric(x_value)

    if classification == "inflection_point":
        base = (
            f"f'' muda de {_sign_label(left_sign)} para {_sign_label(right_sign)} "
            f"ao atravessar x = {x_text}."
        )
    elif classification == "stationary_inflection":
        base = (
            f"f'' muda de {_sign_label(left_sign)} para {_sign_label(right_sign)} "
            f"ao atravessar x = {x_text}, e f'({x_text}) = 0."
        )
    elif classification == "candidate_not_inflection":
        base = (
            f"f''({x_text}) = 0 ou é candidato, mas mantém sinal "
            f"{_sign_label(left_sign)} dos dois lados; não há inflexão."
        )
    else:
        base = (
            f"f'' apresenta sinais {_sign_label(left_sign)} / {_sign_label(right_sign)} "
            f"em x = {x_text}; não foi possível confirmar inflexão."
        )

    if classification == "stationary_inflection" and first_derivative_value is None:
        return base.replace(", e f'(x) = 0.", ".")
    return base


def _no_inflection_explanation(
    sign_table: FunctionSignTable,
    evaluated_points: list[InflectionPoint],
    *,
    concave_up_intervals: list[FunctionSolutionInterval] | None = None,
    concave_down_intervals: list[FunctionSolutionInterval] | None = None,
) -> str:
    if evaluated_points:
        rejected = sum(
            1 for point in evaluated_points if point.classification == "candidate_not_inflection"
        )
        if rejected:
            return (
                f"Nenhum ponto confirmado como inflexão; "
                f"{rejected} candidato(s) não apresentaram mudança de concavidade."
            )

    if concave_up_intervals and concave_down_intervals:
        return (
            "Nenhum ponto confirmado como inflexão. "
            "A concavidade muda entre ramos separados por pontos fora do domínio, "
            "mas isso não caracteriza ponto de inflexão, pois o ponto de separação "
            "não pertence ao domínio da função."
        )

    valid = [interval for interval in sign_table.intervals if interval.in_domain]
    sign = valid[0].sign if valid else "+"

    if sign == "+":
        behavior = "côncava para cima nos intervalos analisados"
    elif sign == "-":
        behavior = "côncava para baixo nos intervalos analisados"
    else:
        behavior = "de concavidade constante ou indeterminada"

    return (
        "f''(x) não possui zeros confirmados com mudança de sinal; "
        f"a função é {behavior}."
    )


def _build_sign_table(second_derivative: SymbolicFunction) -> FunctionSignTable:
    try:
        return build_function_sign_table(second_derivative)
    except Exception:
        from analyticmath.functions.sign_table import FunctionSignTable

        return FunctionSignTable(
            function=second_derivative,
            critical_points=[],
            intervals=[],
            explanation="Não foi possível construir a tabela de sinais de f''(x).",
            case="unknown",
        )


def _domain_internal_boundaries(function: SymbolicFunction) -> set[Any]:
    boundaries: set[Any] = set()
    domain = function.domain().domain
    if getattr(domain, "is_Interval", False) and not domain.left_open and domain.start.is_real:
        boundaries.add(sp.simplify(domain.start))
    return boundaries


def _is_zero_expression(function: SymbolicFunction) -> bool:
    simplified = sp.simplify(function.expr)
    return simplified == 0 or simplified.equals(0)


def _is_zero(value: Any) -> bool:
    if value is None:
        return False
    simplified = sp.simplify(value)
    return simplified == 0 or simplified.equals(0)


def _is_finite_real(value: Any) -> bool:
    if value in (sp.S.NegativeInfinity, sp.S.Infinity, -oo, oo, sp.zoo):
        return False
    return sp.im(value).equals(0)


def _matches_bound(value: Any, bound: Any) -> bool:
    if value in (sp.S.Infinity, oo):
        return False
    return sp.simplify(value - bound) == 0 or value.equals(bound)


def _is_positive_infinity(value: Any) -> bool:
    return value in (sp.S.Infinity, oo, sp.zoo)


def _is_negative_infinity(value: Any) -> bool:
    return value in (sp.S.NegativeInfinity, -oo)


def _sign_label(sign: str) -> str:
    return {
        "+": "positivo",
        "-": "negativo",
        "0": "nulo",
        "inf": "infinito positivo",
        "-inf": "infinito negativo",
        "undefined": "indefinido",
        "unknown": "indeterminado",
    }.get(sign, sign)


def _format_numeric(value: Any) -> str:
    if value is None:
        return "indefinido"
    if getattr(value, "is_number", False):
        numeric = float(sp.N(value))
        if numeric == int(numeric):
            return str(int(numeric))
        return f"{numeric:.3f}"
    return str(value)


def _format_concavity_interval_lines(analysis: ConcavityAnalysis) -> list[str]:
    from analyticmath.functions.inequalities import format_function_solution_interval

    lines = ["Intervalos:"]
    if analysis.concave_up_intervals:
        concave_up = " ∪ ".join(
            format_function_solution_interval(interval)
            for interval in analysis.concave_up_intervals
        )
        lines.append(f"Côncava para cima: {concave_up}")
    else:
        lines.append("Côncava para cima: ∅")

    if analysis.concave_down_intervals:
        concave_down = " ∪ ".join(
            format_function_solution_interval(interval)
            for interval in analysis.concave_down_intervals
        )
        lines.append(f"Côncava para baixo: {concave_down}")
    else:
        lines.append("Côncava para baixo: ∅")

    return lines
