"""Testes de análise de pontos críticos."""

from typing import Any

import sympy as sp

from analyticmath.polynomial import Polynomial, analyze_critical_points, classify_critical_point


def _classifications(analysis) -> list[str]:
    return [point.classification for point in analysis.critical_points]


def _critical_x_values(analysis) -> list[Any]:
    return [point.x for point in analysis.critical_points]


def test_quadratic_minimum() -> None:
    analysis = analyze_critical_points(Polynomial("x**2"))

    assert len(analysis.critical_points) == 1
    assert sp.simplify(_critical_x_values(analysis)[0]) == 0
    assert _classifications(analysis) == ["local_minimum"]


def test_quadratic_maximum() -> None:
    analysis = analyze_critical_points(Polynomial("-x**2"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["local_maximum"]


def test_cubic_stationary_inflection() -> None:
    analysis = analyze_critical_points(Polynomial("x**3"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["stationary_inflection"]
    point = analysis.critical_points[0]
    assert point.first_derivative_left_sign == "+"
    assert point.first_derivative_right_sign == "+"


def test_quartic_minimum_despite_zero_second_derivative() -> None:
    analysis = analyze_critical_points(Polynomial("x**4"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["local_minimum"]
    point = analysis.critical_points[0]
    assert _is_zero(point.second_derivative_value)


def test_linear_polynomial() -> None:
    analysis = analyze_critical_points(Polynomial("x"))

    assert analysis.case == "linear_polynomial"
    assert analysis.critical_points == []
    assert len(analysis.increasing_intervals) == 1
    assert analysis.decreasing_intervals == []


def test_constant_polynomial() -> None:
    analysis = analyze_critical_points(Polynomial("5"))

    assert analysis.case == "constant_polynomial"
    assert analysis.critical_points == []
    assert analysis.stationary_points == []


def test_cubic_with_two_critical_points() -> None:
    analysis = analyze_critical_points(Polynomial("x**3 - 6*x**2 + 11*x - 6"))

    assert analysis.case == "general"
    assert len(analysis.critical_points) == 2
    assert _classifications(analysis).count("local_maximum") == 1
    assert _classifications(analysis).count("local_minimum") == 1
    assert len(analysis.increasing_intervals) == 2
    assert len(analysis.decreasing_intervals) == 1


def test_polynomial_methods() -> None:
    p = Polynomial("x**2")
    assert len(p.critical_points()) == 1
    assert p.analyze_critical_points().case == "general"


def test_no_critical_points_cubic_without_real_derivative_roots() -> None:
    analysis = analyze_critical_points(Polynomial("x**3 + x"))

    assert analysis.case == "no_critical_points"
    assert analysis.critical_points == []
    assert len(analysis.increasing_intervals) == 1


def test_classify_critical_point_helper() -> None:
    assert classify_critical_point("+", "-", 0) == "local_maximum"
    assert classify_critical_point("-", "+", 0) == "local_minimum"
    assert classify_critical_point("+", "+", 0) == "stationary_inflection"
    assert classify_critical_point("0", "0", 0) == "flat"


def test_format_critical_point_analysis_cubic() -> None:
    from analyticmath.polynomial.critical_points import format_critical_point_analysis

    analysis = analyze_critical_points(Polynomial("x**3 - 6*x**2 + 11*x - 6"))
    text = format_critical_point_analysis(analysis)

    assert "Análise de pontos críticos" in text
    assert "Primeira derivada" in text
    assert "Segunda derivada" in text
    assert "Crescente:" in text
    assert "Decrescente:" in text
    assert "máximo local" in text
    assert "mínimo local" in text


def _is_zero(value) -> bool:
    return sp.simplify(value) == 0
