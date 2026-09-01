"""Pontos críticos e monotonicidade para funções simbólicas gerais.

Localiza candidatos onde f'(x) = 0 ou f'(x) não existe (com f definida),
classifica extremos pela mudança de sinal de f' e determina intervalos
crescentes/decrescentes reutilizando a tabela de sinais da derivada.
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

Classification = Literal[
    "local_maximum",
    "local_minimum",
    "stationary_inflection",
    "cusp_or_corner",
    "vertical_tangent",
    "flat",
    "undetermined",
]

AnalysisCase = Literal[
    "general",
    "constant_function",
    "linear_function",
    "no_critical_points",
    "unknown",
]

_CLASSIFICATION_LABELS: dict[str, str] = {
    "local_maximum": "máximo local",
    "local_minimum": "mínimo local",
    "stationary_inflection": "ponto de inflexão estacionário",
    "cusp_or_corner": "cuspide ou canto (derivada não existe)",
    "vertical_tangent": "tangente vertical",
    "flat": "constante / ponto estacionário degenerado",
    "undetermined": "indeterminado",
}


@dataclass(frozen=True)
class FunctionCriticalPoint:
    """Ponto crítico isolado de uma função simbólica."""

    x: Any
    y: Any
    derivative_value: Any
    second_derivative_value: Any
    classification: str
    first_derivative_left_sign: str
    first_derivative_right_sign: str
    in_domain: bool
    explanation: str


@dataclass
class FunctionCriticalPointAnalysis:
    """Análise completa de pontos críticos e monotonicidade."""

    function: SymbolicFunction
    first_derivative: SymbolicFunction
    second_derivative: SymbolicFunction
    critical_points: list[FunctionCriticalPoint]
    increasing_intervals: list[FunctionSolutionInterval]
    decreasing_intervals: list[FunctionSolutionInterval]
    stationary_points: list[Any]
    explanation: str
    case: str = field(default="general")


def analyze_function_critical_points(
    function: SymbolicFunction,
) -> FunctionCriticalPointAnalysis:
    """Analisa pontos críticos, classificação e intervalos de monotonicidade."""
    first_derivative = function.derivative()
    second_derivative = first_derivative.derivative()

    if _is_zero_expression(first_derivative):
        return _analyze_constant_function(function, first_derivative, second_derivative)

    if _is_constant_nonzero(first_derivative):
        return _analyze_linear_function(function, first_derivative, second_derivative)

    derivative_sign_table = _build_derivative_sign_table(first_derivative)
    if derivative_sign_table.case == "unknown" and not derivative_sign_table.intervals:
        return _analyze_with_fallback(
            function,
            first_derivative,
            second_derivative,
            derivative_sign_table,
        )

    candidates = _collect_critical_candidates(function, first_derivative)
    critical_points = [
        _build_critical_point(
            function,
            first_derivative,
            second_derivative,
            derivative_sign_table,
            candidate,
        )
        for candidate in candidates
    ]

    increasing_intervals = _monotonicity_intervals(first_derivative, ">")
    decreasing_intervals = _monotonicity_intervals(first_derivative, "<")

    if not critical_points:
        return FunctionCriticalPointAnalysis(
            function=function,
            first_derivative=first_derivative,
            second_derivative=second_derivative,
            critical_points=[],
            increasing_intervals=increasing_intervals,
            decreasing_intervals=decreasing_intervals,
            stationary_points=[],
            explanation=_no_critical_points_explanation(derivative_sign_table),
            case="no_critical_points",
        )

    return FunctionCriticalPointAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=critical_points,
        increasing_intervals=increasing_intervals,
        decreasing_intervals=decreasing_intervals,
        stationary_points=[point.x for point in critical_points],
        explanation=(
            f"Foram encontrados {len(critical_points)} ponto(s) crítico(s) real(is) "
            f"no domínio de f."
        ),
        case="general",
    )


def safe_evaluate(function: SymbolicFunction, point: Any) -> Any | None:
    """Avalia f(point) apenas se o ponto pertence ao domínio real."""
    return safe_function_value(function, point)


def classify_function_critical_point(
    left_sign: str,
    right_sign: str,
    derivative_value: Any,
    second_derivative_value: Any,
) -> str:
    """Classifica um ponto crítico pelo teste da primeira derivada."""
    if left_sign == "+" and right_sign == "-":
        return "local_maximum"
    if left_sign == "-" and right_sign == "+":
        return "local_minimum"

    if left_sign == right_sign and left_sign in ("+", "-") and _is_zero(derivative_value):
        return "stationary_inflection"

    if left_sign == "0" and right_sign == "0":
        return "flat"

    if derivative_value is None or not _is_finite_value(derivative_value):
        if right_sign in ("inf", "+inf") or left_sign in ("inf", "+inf"):
            return "vertical_tangent"
        if left_sign in ("undefined", "0") and right_sign in ("+", "inf", "+inf"):
            return "vertical_tangent"
        if left_sign == "-" and right_sign == "+":
            return "local_minimum"
        if left_sign == "+" and right_sign == "-":
            return "local_maximum"
        return "cusp_or_corner"

    return "undetermined"


def format_function_critical_point(point: FunctionCriticalPoint) -> str:
    """Formata um ponto crítico para exibição."""
    x_text = _format_numeric(point.x)
    y_text = _format_numeric(point.y) if point.y is not None else "indefinido"
    label = _CLASSIFICATION_LABELS.get(point.classification, point.classification)

    lines = [
        f"x = {x_text}, f(x) = {y_text}",
        f"Classificação: {label}",
        f"Justificativa: {point.explanation}",
    ]
    return "\n".join(lines)


def format_function_critical_point_analysis(
    analysis: FunctionCriticalPointAnalysis,
) -> str:
    """Formata a análise completa de pontos críticos."""
    var = analysis.function.variable
    lines = ["Análise de pontos críticos:", ""]
    lines.append(f"f'({var}) = {analysis.first_derivative}")
    lines.append(f"f''({var}) = {analysis.second_derivative}")
    lines.append("")

    if analysis.case == "unknown":
        lines.append(analysis.explanation)
        return "\n".join(lines)

    if analysis.case == "constant_function":
        lines.append("Função constante: f'(x) = 0 em todo o domínio.")
        lines.append("Não há pontos críticos isolados.")
        lines.append(analysis.explanation)
        return "\n".join(lines)

    if analysis.case == "linear_function":
        lines.append("Função linear: f'(x) é constante não nula.")
        lines.append("Não há pontos críticos.")
        lines.append(analysis.explanation)
        lines.extend(_format_monotonicity_lines(analysis))
        return "\n".join(lines)

    if analysis.case == "no_critical_points":
        lines.append("Não há pontos críticos reais no domínio.")
        lines.append(analysis.explanation)
        lines.extend(_format_monotonicity_lines(analysis))
        return "\n".join(lines)

    if analysis.critical_points:
        for index, point in enumerate(analysis.critical_points, start=1):
            lines.append(f"{index}. {format_function_critical_point(point)}")
            lines.append("")
    else:
        lines.append("Nenhum ponto crítico encontrado.")
        lines.append("")

    lines.extend(_format_monotonicity_lines(analysis))
    return "\n".join(lines).rstrip()


def _analyze_constant_function(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
) -> FunctionCriticalPointAnalysis:
    return FunctionCriticalPointAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=[],
        increasing_intervals=[],
        decreasing_intervals=[],
        stationary_points=[],
        explanation=(
            "Função constante: f'(x) = 0 em todo o domínio. "
            "A função é plana e não possui pontos críticos isolados."
        ),
        case="constant_function",
    )


def _analyze_linear_function(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
) -> FunctionCriticalPointAnalysis:
    increasing_intervals = _monotonicity_intervals(first_derivative, ">")
    decreasing_intervals = _monotonicity_intervals(first_derivative, "<")
    slope_sign = sign_of(first_derivative.expr)

    if slope_sign == "+":
        monotonicity = "crescente em todo o domínio analisado"
    elif slope_sign == "-":
        monotonicity = "decrescente em todo o domínio analisado"
    else:
        monotonicity = "degenerada (derivada constante nula)"

    return FunctionCriticalPointAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=[],
        increasing_intervals=increasing_intervals,
        decreasing_intervals=decreasing_intervals,
        stationary_points=[],
        explanation=(
            f"Função linear ou afim: f'(x) é constante não nula. "
            f"A função é {monotonicity} e não possui pontos críticos."
        ),
        case="linear_function",
    )


def _analyze_with_fallback(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
    derivative_sign_table: FunctionSignTable,
) -> FunctionCriticalPointAnalysis:
    candidates = _collect_critical_candidates(function, first_derivative)
    if not candidates:
        return FunctionCriticalPointAnalysis(
            function=function,
            first_derivative=first_derivative,
            second_derivative=second_derivative,
            critical_points=[],
            increasing_intervals=[],
            decreasing_intervals=[],
            stationary_points=[],
            explanation=(
                "Não foi possível construir a tabela de sinais de f'(x) nesta versão; "
                "nenhum candidato a ponto crítico pôde ser confirmado."
            ),
            case="unknown",
        )

    critical_points = [
        _build_critical_point(
            function,
            first_derivative,
            second_derivative,
            derivative_sign_table,
            candidate,
        )
        for candidate in candidates
    ]

    return FunctionCriticalPointAnalysis(
        function=function,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=critical_points,
        increasing_intervals=_monotonicity_intervals_fallback(function, first_derivative, "+"),
        decreasing_intervals=_monotonicity_intervals_fallback(function, first_derivative, "-"),
        stationary_points=[point.x for point in critical_points],
        explanation=(
            "A tabela de sinais de f'(x) é parcialmente indeterminada; "
            "pontos críticos foram analisados por limites laterais."
        ),
        case="general" if critical_points else "unknown",
    )


def _build_critical_point(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    second_derivative: SymbolicFunction,
    derivative_sign_table: FunctionSignTable,
    x_value: Any,
) -> FunctionCriticalPoint:
    left_sign, right_sign = _derivative_signs_at(
        function,
        first_derivative,
        derivative_sign_table,
        x_value,
    )
    derivative_value = safe_evaluate(first_derivative, x_value)
    second_value = safe_evaluate(second_derivative, x_value)
    classification = classify_function_critical_point(
        left_sign,
        right_sign,
        derivative_value,
        second_value,
    )
    explanation = _build_point_explanation(
        x_value,
        classification,
        left_sign,
        right_sign,
        derivative_value,
        second_value,
    )

    return FunctionCriticalPoint(
        x=x_value,
        y=safe_evaluate(function, x_value),
        derivative_value=derivative_value,
        second_derivative_value=second_value,
        classification=classification,
        first_derivative_left_sign=left_sign,
        first_derivative_right_sign=right_sign,
        in_domain=is_point_in_domain(function, x_value) == True,
        explanation=explanation,
    )


def _collect_critical_candidates(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
) -> list[Any]:
    registry: dict[str, Any] = {}

    for root in first_derivative.roots().real_roots:
        if _is_finite_real(root):
            _register_candidate(registry, sp.simplify(root), function)

    try:
        for discontinuity in first_derivative.continuity().discontinuities:
            _register_candidate(registry, sp.simplify(discontinuity.x), function)
    except Exception:
        pass

    for point in _domain_internal_boundaries(function):
        _register_candidate(registry, point, function)

    for point in _abs_kink_points(function):
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


def _derivative_signs_at(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    derivative_sign_table: FunctionSignTable,
    x_value: Any,
) -> tuple[str, str]:
    if derivative_sign_table.case != "unknown" and derivative_sign_table.intervals:
        left_sign, right_sign = _signs_from_table(derivative_sign_table, x_value)
        if left_sign != "0" or right_sign != "0":
            return left_sign, right_sign

    return _derivative_side_signs_fallback(function, first_derivative, x_value)


def _signs_from_table(
    derivative_sign_table: FunctionSignTable,
    x_value: Any,
) -> tuple[str, str]:
    left_sign = "0"
    right_sign = "0"

    for interval in derivative_sign_table.intervals:
        if not interval.in_domain:
            continue
        if _matches_bound(interval.right, x_value):
            left_sign = interval.sign
        if _matches_bound(interval.left, x_value):
            right_sign = interval.sign

    return left_sign, right_sign


def _derivative_side_signs_fallback(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    x_value: Any,
) -> tuple[str, str]:
    left = _side_derivative_sign(function, first_derivative, x_value, "-")
    right = _side_derivative_sign(function, first_derivative, x_value, "+")
    return left, right


def _side_derivative_sign(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    x_value: Any,
    direction: str,
) -> str:
    if function.expr.has(sp.Abs):
        return _side_slope_sign_from_function(function, x_value, direction)

    try:
        limit_value = limit_at(first_derivative, x_value, direction=direction).value
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
        return _side_slope_sign_from_function(function, x_value, direction)

    value = safe_evaluate(first_derivative, test_point)
    if value is None:
        return _side_slope_sign_from_function(function, x_value, direction)

    try:
        return sign_of(value)
    except Exception:
        return _side_slope_sign_from_function(function, x_value, direction)


def _side_slope_sign_from_function(
    function: SymbolicFunction,
    x_value: Any,
    direction: str,
) -> str:
    """Estima o sinal de f' via variação de f em torno de x (fallback seguro)."""
    epsilon = sp.Rational(1, 1000)

    if direction == "+":
        left_point = sp.simplify(x_value)
        right_point = sp.simplify(x_value + epsilon)
    else:
        left_point = sp.simplify(x_value - epsilon)
        right_point = sp.simplify(x_value)

    if is_point_in_domain(function, left_point) != True:
        return "undefined"
    if is_point_in_domain(function, right_point) != True:
        return "undefined"

    left_value = safe_evaluate(function, left_point)
    right_value = safe_evaluate(function, right_point)
    if left_value is None or right_value is None:
        return "undefined"

    try:
        delta = sp.simplify(right_value - left_value)
        return sign_of(delta)
    except Exception:
        return "undefined"


def _test_point_near(
    function: SymbolicFunction,
    x_value: Any,
    direction: str,
) -> Any | None:
    if direction == "-":
        candidate = sp.simplify(x_value - 1)
    else:
        candidate = sp.simplify(x_value + 1)

    if is_point_in_domain(function, candidate) == True:
        return candidate

    candidate = sp.simplify(x_value + sp.Rational(1, 100))
    if direction == "-" and is_point_in_domain(function, candidate) == True:
        return candidate

    candidate = sp.simplify(x_value - sp.Rational(1, 100))
    if direction == "-" and is_point_in_domain(function, candidate) == True:
        return candidate

    return None


def _build_point_explanation(
    x_value: Any,
    classification: str,
    left_sign: str,
    right_sign: str,
    derivative_value: Any,
    second_derivative_value: Any,
) -> str:
    x_text = _format_numeric(x_value)

    if classification == "local_maximum":
        base = f"f'(x) muda de positivo para negativo ao atravessar x = {x_text}."
    elif classification == "local_minimum":
        base = f"f'(x) muda de negativo para positivo ao atravessar x = {x_text}."
    elif classification == "stationary_inflection":
        base = (
            f"f'(x) mantém o mesmo sinal ({_sign_label(left_sign)}) em x = {x_text} "
            f"com f'({x_text}) = 0; trata-se de um ponto de inflexão estacionário."
        )
    elif classification == "vertical_tangent":
        base = (
            f"f'({x_text}) não existe ou tende a infinito; "
            f"a função apresenta tangente vertical em x = {x_text}."
        )
    elif classification == "cusp_or_corner":
        base = (
            f"f'({x_text}) não existe e os sinais laterais são "
            f"{_sign_label(left_sign)} / {_sign_label(right_sign)}."
        )
    elif classification == "flat":
        base = f"f'(x) é nula em torno de x = {x_text}."
    else:
        base = (
            f"f'(x) apresenta sinais {_sign_label(left_sign)} / {_sign_label(right_sign)} "
            f"em x = {x_text}; a classificação não pôde ser determinada apenas pelos testes padrão."
        )

    second_note = _second_derivative_note(classification, second_derivative_value)
    if second_note:
        return f"{base} {second_note}"
    return base


def _second_derivative_note(classification: str, second_derivative_value: Any) -> str:
    if second_derivative_value is None:
        return ""

    if _is_zero(second_derivative_value):
        if classification in ("local_maximum", "local_minimum"):
            return "O teste da segunda derivada em x é inconclusivo (f'' = 0)."
        return ""

    if second_derivative_value.is_positive or (
        getattr(second_derivative_value, "is_number", False)
        and float(sp.N(second_derivative_value)) > 0
    ):
        if classification == "local_minimum":
            return "O teste da segunda derivada confirma mínimo local (f'' > 0)."
        if classification == "undetermined":
            return "O teste da segunda derivada sugere mínimo local (f'' > 0)."
        return ""

    if second_derivative_value.is_negative or (
        getattr(second_derivative_value, "is_number", False)
        and float(sp.N(second_derivative_value)) < 0
    ):
        if classification == "local_maximum":
            return "O teste da segunda derivada confirma máximo local (f'' < 0)."
        if classification == "undetermined":
            return "O teste da segunda derivada sugere máximo local (f'' < 0)."
        return ""

    return ""


def _monotonicity_intervals(
    first_derivative: SymbolicFunction,
    operator: str,
) -> list[FunctionSolutionInterval]:
    try:
        solution = solve_function_inequality(first_derivative, operator)
        if solution.case == "unknown":
            return []
        return list(solution.intervals)
    except Exception:
        return []


def _monotonicity_intervals_fallback(
    function: SymbolicFunction,
    first_derivative: SymbolicFunction,
    sign: str,
) -> list[FunctionSolutionInterval]:
    operator = ">" if sign == "+" else "<"
    intervals = _monotonicity_intervals(first_derivative, operator)
    if intervals:
        return intervals

    domain = function.domain().domain
    if domain in (S.Reals, sp.Reals) or str(domain) == "Reals":
        if function.expr.has(sp.Abs):
            if sign == "+":
                return [
                    FunctionSolutionInterval(
                        left=sp.Integer(0),
                        right=sp.S.Infinity,
                        left_closed=False,
                        right_closed=False,
                        reason="f'(x) > 0 à direita do canto em |x|",
                        in_domain=True,
                    )
                ]
            return [
                FunctionSolutionInterval(
                    left=sp.S.NegativeInfinity,
                    right=sp.Integer(0),
                    left_closed=False,
                    right_closed=False,
                    reason="f'(x) < 0 à esquerda do canto em |x|",
                    in_domain=True,
                )
            ]
    return []


def _build_derivative_sign_table(first_derivative: SymbolicFunction) -> FunctionSignTable:
    try:
        return build_function_sign_table(first_derivative)
    except Exception:
        from analyticmath.functions.sign_table import FunctionSignTable

        return FunctionSignTable(
            function=first_derivative,
            critical_points=[],
            intervals=[],
            explanation="Não foi possível construir a tabela de sinais de f'(x).",
            case="unknown",
        )


def _no_critical_points_explanation(derivative_sign_table: FunctionSignTable) -> str:
    valid = [interval for interval in derivative_sign_table.intervals if interval.in_domain]
    sign = valid[0].sign if valid else "+"

    if sign == "+":
        behavior = "crescente nos intervalos analisados"
    elif sign == "-":
        behavior = "decrescente nos intervalos analisados"
    else:
        behavior = "estacionária"

    return (
        "f'(x) não possui zeros reais no domínio ou nenhum candidato válido foi encontrado; "
        f"a função é {behavior}."
    )


def _domain_internal_boundaries(function: SymbolicFunction) -> set[Any]:
    boundaries: set[Any] = set()
    domain = function.domain().domain
    if getattr(domain, "is_Interval", False) and not domain.left_open and domain.start.is_real:
        boundaries.add(sp.simplify(domain.start))
    return boundaries


def _abs_kink_points(function: SymbolicFunction) -> list[Any]:
    if not function.expr.has(sp.Abs):
        return []

    points: list[Any] = []
    for atom in function.expr.atoms(sp.Abs):
        inner = atom.args[0]
        try:
            inner_function = type(function)(inner, variable=function.variable)
            for root in inner_function.roots().real_roots:
                if _is_finite_real(root):
                    points.append(sp.simplify(root))
        except Exception:
            continue
    return points


def _is_zero_expression(function: SymbolicFunction) -> bool:
    simplified = sp.simplify(function.expr)
    return simplified == 0 or simplified.equals(0)


def _is_constant_nonzero(first_derivative: SymbolicFunction) -> bool:
    simplified = sp.simplify(first_derivative.expr)
    if not simplified.is_number:
        return False
    return not _is_zero(simplified)


def _is_zero(value: Any) -> bool:
    if value is None:
        return False
    simplified = sp.simplify(value)
    return simplified == 0 or simplified.equals(0)


def _is_finite_value(value: Any) -> bool:
    if value is None:
        return False
    if _is_positive_infinity(value) or _is_negative_infinity(value):
        return False
    return True


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
        "+inf": "infinito positivo",
        "-inf": "infinito negativo",
        "undefined": "indefinido",
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


def _format_monotonicity_lines(analysis: FunctionCriticalPointAnalysis) -> list[str]:
    from analyticmath.functions.inequalities import format_function_solution_interval

    lines = ["Intervalos:"]
    if analysis.increasing_intervals:
        increasing = " ∪ ".join(
            format_function_solution_interval(interval)
            for interval in analysis.increasing_intervals
        )
        lines.append(f"Crescente: {increasing}")
    else:
        lines.append("Crescente: ∅")

    if analysis.decreasing_intervals:
        decreasing = " ∪ ".join(
            format_function_solution_interval(interval)
            for interval in analysis.decreasing_intervals
        )
        lines.append(f"Decrescente: {decreasing}")
    else:
        lines.append("Decrescente: ∅")

    return lines
