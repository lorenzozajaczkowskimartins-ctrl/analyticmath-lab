"""Pontos críticos e classificação (máximos, mínimos, inflexão estacionária).

Localiza zeros da derivada primeira e classifica com base na tabela
de sinais de p'(x) e, auxiliarmente, no teste da segunda derivada.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp

from analyticmath.polynomial.inequalities import SolutionInterval, solve_polynomial_inequality
from analyticmath.polynomial.sign_table import build_sign_table, sign_of, sort_real_roots

if TYPE_CHECKING:
    from analyticmath.polynomial.polynomial import Polynomial

Classification = Literal[
    "local_maximum",
    "local_minimum",
    "stationary_inflection",
    "flat",
    "undetermined",
]

AnalysisCase = Literal[
    "general",
    "constant_polynomial",
    "linear_polynomial",
    "no_critical_points",
]

_CLASSIFICATION_LABELS: dict[str, str] = {
    "local_maximum": "máximo local",
    "local_minimum": "mínimo local",
    "stationary_inflection": "ponto de inflexão estacionário",
    "flat": "constante / ponto estacionário degenerado",
    "undetermined": "indeterminado",
}


@dataclass(frozen=True)
class CriticalPoint:
    """Ponto crítico isolado de um polinômio."""

    x: Any
    y: Any
    derivative_value: Any
    second_derivative_value: Any
    classification: str
    first_derivative_left_sign: str
    first_derivative_right_sign: str
    explanation: str


@dataclass
class CriticalPointAnalysis:
    """Análise completa de pontos críticos e monotonicidade."""

    polynomial: Polynomial
    first_derivative: Polynomial
    second_derivative: Polynomial
    critical_points: list[CriticalPoint]
    increasing_intervals: list[SolutionInterval]
    decreasing_intervals: list[SolutionInterval]
    stationary_points: list[Any]
    explanation: str
    case: str = field(default="general")


def analyze_critical_points(polynomial: Polynomial) -> CriticalPointAnalysis:
    """Analisa pontos críticos, classificação e intervalos de monotonicidade."""
    first_derivative = polynomial.derivative()
    second_derivative = first_derivative.derivative()

    if _is_zero_polynomial(polynomial):
        return _analyze_constant_polynomial(polynomial, first_derivative, second_derivative)

    if polynomial.degree() == 0:
        return _analyze_constant_polynomial(polynomial, first_derivative, second_derivative)

    if polynomial.degree() == 1:
        return _analyze_linear_polynomial(polynomial, first_derivative, second_derivative)

    derivative_sign_table = build_sign_table(first_derivative)
    critical_x_values = sort_real_roots(
        list(_real_roots_with_multiplicity(first_derivative).keys())
    )

    if not critical_x_values:
        return _analyze_no_critical_points(
            polynomial,
            first_derivative,
            second_derivative,
            derivative_sign_table,
        )

    critical_points = [
        _build_critical_point(
            polynomial,
            first_derivative,
            second_derivative,
            derivative_sign_table,
            x_value,
        )
        for x_value in critical_x_values
    ]

    increasing_intervals = solve_polynomial_inequality(first_derivative, ">").intervals
    decreasing_intervals = solve_polynomial_inequality(first_derivative, "<").intervals

    return CriticalPointAnalysis(
        polynomial=polynomial,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=critical_points,
        increasing_intervals=increasing_intervals,
        decreasing_intervals=decreasing_intervals,
        stationary_points=[point.x for point in critical_points],
        explanation=(
            f"Foram encontrados {len(critical_points)} ponto(s) crítico(s) real(is) "
            f"como raízes de p'(x) = 0."
        ),
        case="general",
    )


def classify_critical_point(
    left_sign: str,
    right_sign: str,
    second_derivative_value: Any,
) -> str:
    """Classifica um ponto crítico pelo teste da primeira derivada."""
    if left_sign == "+" and right_sign == "-":
        return "local_maximum"
    if left_sign == "-" and right_sign == "+":
        return "local_minimum"
    if left_sign == right_sign and left_sign in ("+", "-") and _is_zero(second_derivative_value):
        return "stationary_inflection"
    if left_sign == "0" and right_sign == "0":
        return "flat"
    return "undetermined"


def format_critical_point(point: CriticalPoint) -> str:
    """Formata um ponto crítico para exibição."""
    x_text = _format_numeric(point.x)
    y_text = _format_numeric(point.y)
    label = _CLASSIFICATION_LABELS.get(point.classification, point.classification)

    lines = [
        f"x = {x_text}, p(x) = {y_text}",
        f"Classificação: {label}",
        f"Justificativa: {point.explanation}",
    ]
    return "\n".join(lines)


def format_critical_point_analysis(analysis: CriticalPointAnalysis) -> str:
    """Formata a análise completa de pontos críticos."""
    lines = ["Análise de pontos críticos:", ""]
    lines.append(f"Primeira derivada:  p'(x) = {analysis.first_derivative}")
    lines.append(f"Segunda derivada:   p''(x) = {analysis.second_derivative}")
    lines.append("")

    if analysis.case == "constant_polynomial":
        lines.append("Polinômio constante: p'(x) = 0 em todo o domínio.")
        lines.append("Não há pontos críticos isolados.")
        lines.append(analysis.explanation)
        return "\n".join(lines)

    if analysis.case == "linear_polynomial":
        lines.append("Polinômio linear: p'(x) é constante não nula.")
        lines.append("Não há pontos críticos.")
        lines.append(analysis.explanation)
        lines.extend(_format_monotonicity_lines(analysis))
        return "\n".join(lines)

    if analysis.case == "no_critical_points":
        lines.append("Não há pontos críticos reais.")
        lines.append(analysis.explanation)
        lines.extend(_format_monotonicity_lines(analysis))
        return "\n".join(lines)

    lines.append("Pontos críticos:")
    if analysis.critical_points:
        for index, point in enumerate(analysis.critical_points, start=1):
            lines.append(f"{index}. {format_critical_point(point)}")
            lines.append("")
    else:
        lines.append("Nenhum ponto crítico encontrado.")
        lines.append("")

    lines.extend(_format_monotonicity_lines(analysis))
    return "\n".join(lines).rstrip()


def _build_critical_point(
    polynomial: Polynomial,
    first_derivative: Polynomial,
    second_derivative: Polynomial,
    derivative_sign_table,
    x_value: Any,
) -> CriticalPoint:
    left_sign, right_sign = _derivative_signs_at(derivative_sign_table, x_value)
    second_value = sp.simplify(second_derivative.evaluate(x_value))
    classification = classify_critical_point(left_sign, right_sign, second_value)
    explanation = _build_point_explanation(
        x_value,
        classification,
        left_sign,
        right_sign,
        second_value,
    )

    return CriticalPoint(
        x=x_value,
        y=sp.simplify(polynomial.evaluate(x_value)),
        derivative_value=sp.simplify(first_derivative.evaluate(x_value)),
        second_derivative_value=second_value,
        classification=classification,
        first_derivative_left_sign=left_sign,
        first_derivative_right_sign=right_sign,
        explanation=explanation,
    )


def _build_point_explanation(
    x_value: Any,
    classification: str,
    left_sign: str,
    right_sign: str,
    second_derivative_value: Any,
) -> str:
    x_text = _format_numeric(x_value)

    if classification == "local_maximum":
        base = (
            f"p'(x) muda de positivo para negativo ao atravessar x = {x_text}."
        )
    elif classification == "local_minimum":
        base = (
            f"p'(x) muda de negativo para positivo ao atravessar x = {x_text}."
        )
    elif classification == "stationary_inflection":
        base = (
            f"p'(x) mantém o mesmo sinal ({_sign_label(left_sign)}) em x = {x_text} "
            f"e p''({x_text}) = 0; trata-se de um ponto de inflexão estacionário."
        )
    elif classification == "flat":
        base = f"p'(x) é identicamente nula em torno de x = {x_text}."
    else:
        base = (
            f"p'(x) apresenta sinais {_sign_label(left_sign)} / {_sign_label(right_sign)} "
            f"em x = {x_text}; a classificação não pôde ser determinada apenas pelos testes padrão."
        )

    second_note = _second_derivative_note(classification, second_derivative_value)
    if second_note:
        return f"{base} {second_note}"
    return base


def _second_derivative_note(classification: str, second_derivative_value: Any) -> str:
    if _is_zero(second_derivative_value):
        if classification in ("local_maximum", "local_minimum"):
            return "O teste da segunda derivada em x é inconclusivo (p'' = 0)."
        return ""

    if second_derivative_value.is_positive or (
        second_derivative_value.is_number and float(sp.N(second_derivative_value)) > 0
    ):
        if classification == "local_minimum":
            return "O teste da segunda derivada confirma mínimo local (p'' > 0)."
        if classification == "undetermined":
            return "O teste da segunda derivada sugere mínimo local (p'' > 0)."
        return ""

    if second_derivative_value.is_negative or (
        second_derivative_value.is_number and float(sp.N(second_derivative_value)) < 0
    ):
        if classification == "local_maximum":
            return "O teste da segunda derivada confirma máximo local (p'' < 0)."
        if classification == "undetermined":
            return "O teste da segunda derivada sugere máximo local (p'' < 0)."
        return ""

    return ""


def _analyze_constant_polynomial(
    polynomial: Polynomial,
    first_derivative: Polynomial,
    second_derivative: Polynomial,
) -> CriticalPointAnalysis:
    return CriticalPointAnalysis(
        polynomial=polynomial,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=[],
        increasing_intervals=[],
        decreasing_intervals=[],
        stationary_points=[],
        explanation=(
            "Polinômio constante: p'(x) = 0 em todo o domínio. "
            "A função é plana e não possui pontos críticos isolados."
        ),
        case="constant_polynomial",
    )


def _analyze_linear_polynomial(
    polynomial: Polynomial,
    first_derivative: Polynomial,
    second_derivative: Polynomial,
) -> CriticalPointAnalysis:
    increasing_intervals = solve_polynomial_inequality(first_derivative, ">").intervals
    decreasing_intervals = solve_polynomial_inequality(first_derivative, "<").intervals
    slope_sign = sign_of(first_derivative.constant_term())

    if slope_sign == "+":
        monotonicity = "crescente em todo o domínio real"
    elif slope_sign == "-":
        monotonicity = "decrescente em todo o domínio real"
    else:
        monotonicity = "degenerada (coeficiente angular nulo)"

    return CriticalPointAnalysis(
        polynomial=polynomial,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=[],
        increasing_intervals=increasing_intervals,
        decreasing_intervals=decreasing_intervals,
        stationary_points=[],
        explanation=(
            f"Polinômio linear: p'(x) é constante não nula. "
            f"A função é {monotonicity} e não possui pontos críticos."
        ),
        case="linear_polynomial",
    )


def _analyze_no_critical_points(
    polynomial: Polynomial,
    first_derivative: Polynomial,
    second_derivative: Polynomial,
    derivative_sign_table,
) -> CriticalPointAnalysis:
    increasing_intervals = solve_polynomial_inequality(first_derivative, ">").intervals
    decreasing_intervals = solve_polynomial_inequality(first_derivative, "<").intervals
    sign = derivative_sign_table.intervals[0].sign if derivative_sign_table.intervals else "+"

    if sign == "+":
        behavior = "sempre crescente"
    elif sign == "-":
        behavior = "sempre decrescente"
    else:
        behavior = "estacionária"

    return CriticalPointAnalysis(
        polynomial=polynomial,
        first_derivative=first_derivative,
        second_derivative=second_derivative,
        critical_points=[],
        increasing_intervals=increasing_intervals,
        decreasing_intervals=decreasing_intervals,
        stationary_points=[],
        explanation=(
            "p'(x) não possui raízes reais; a função é "
            f"{behavior} em todo o domínio real."
        ),
        case="no_critical_points",
    )


def _derivative_signs_at(derivative_sign_table, root: Any) -> tuple[str, str]:
    left_sign = "0"
    right_sign = "0"

    for interval in derivative_sign_table.intervals:
        if _matches_root(interval.right, root):
            left_sign = interval.sign
        if _matches_root(interval.left, root):
            right_sign = interval.sign

    return left_sign, right_sign


def _format_monotonicity_lines(analysis: CriticalPointAnalysis) -> list[str]:
    from analyticmath.polynomial.inequalities import format_solution_interval

    lines = ["Intervalos:"]
    if analysis.increasing_intervals:
        increasing = " ∪ ".join(
            format_solution_interval(interval)
            for interval in analysis.increasing_intervals
        )
        lines.append(f"Crescente: {increasing}")
    else:
        lines.append("Crescente: ∅")

    if analysis.decreasing_intervals:
        decreasing = " ∪ ".join(
            format_solution_interval(interval)
            for interval in analysis.decreasing_intervals
        )
        lines.append(f"Decrescente: {decreasing}")
    else:
        lines.append("Decrescente: ∅")

    return lines


def _real_roots_with_multiplicity(polynomial: Polynomial) -> dict[Any, int]:
    return {
        root: multiplicity
        for root, multiplicity in polynomial.root_multiplicities().items()
        if sp.im(root).equals(0)
    }


def _is_zero_polynomial(polynomial: Polynomial) -> bool:
    return sp.simplify(polynomial.expr) == 0 or polynomial.expr.equals(0)


def _is_zero(value: Any) -> bool:
    simplified = sp.simplify(value)
    return simplified == 0 or simplified.equals(0)


def _matches_root(value: Any, root: Any) -> bool:
    if value in (sp.S.NegativeInfinity, sp.S.Infinity):
        return False
    return sp.simplify(value - root) == 0 or value.equals(root)


def _sign_label(sign: str) -> str:
    return {"+": "positivo", "-": "negativo", "0": "nulo"}.get(sign, sign)


def _format_numeric(value: Any) -> str:
    if value.is_number:
        numeric = float(sp.N(value))
        if numeric == int(numeric):
            return str(int(numeric))
        return f"{numeric:.3f}"
    return str(value)
