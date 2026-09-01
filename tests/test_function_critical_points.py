"""Testes de pontos críticos para funções simbólicas gerais."""

from typing import Any

import sympy as sp
import pytest

from analyticmath.functions import SymbolicFunction, analyze_function_critical_points
from analyticmath.functions.critical_points import classify_function_critical_point


def _classifications(analysis) -> list[str]:
    return [point.classification for point in analysis.critical_points]


def _critical_x_values(analysis) -> list[Any]:
    return [point.x for point in analysis.critical_points]


def test_quadratic_minimum() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("x**2"))

    assert len(analysis.critical_points) == 1
    assert sp.simplify(_critical_x_values(analysis)[0]) == 0
    assert _classifications(analysis) == ["local_minimum"]


def test_quadratic_maximum() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("-x**2"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["local_maximum"]


def test_cubic_stationary_inflection() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("x**3"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["stationary_inflection"]
    point = analysis.critical_points[0]
    assert point.first_derivative_left_sign == "+"
    assert point.first_derivative_right_sign == "+"


def test_quartic_minimum_despite_zero_second_derivative() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("x**4"))

    assert len(analysis.critical_points) == 1
    assert _classifications(analysis) == ["local_minimum"]
    point = analysis.critical_points[0]
    assert sp.simplify(point.second_derivative_value) == 0


def test_reciprocal_no_critical_point_at_pole() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("1/(x - 2)"))

    assert analysis.critical_points == []
    assert analysis.case == "no_critical_points"
    assert len(analysis.decreasing_intervals) == 2
    assert analysis.increasing_intervals == []


def test_sqrt_domain_boundary() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("sqrt(x)"))

    assert analysis.case in ("general", "no_critical_points")
    assert len(analysis.critical_points) <= 1
    if analysis.critical_points:
        point = analysis.critical_points[0]
        assert sp.simplify(point.x) == 0
        assert point.classification in (
            "vertical_tangent",
            "undetermined",
            "local_minimum",
            "cusp_or_corner",
        )


def test_abs_detects_corner() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("Abs(x)"))

    assert len(analysis.critical_points) >= 1
    x_values = [sp.simplify(point.x) for point in analysis.critical_points]
    assert 0 in x_values or sp.Integer(0) in x_values
    zero_point = next(point for point in analysis.critical_points if sp.simplify(point.x) == 0)
    assert zero_point.classification in ("local_minimum", "cusp_or_corner")


def test_linear_function() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("x"))

    assert analysis.case == "linear_function"
    assert analysis.critical_points == []
    assert len(analysis.increasing_intervals) >= 1
    assert analysis.decreasing_intervals == []


def test_constant_function() -> None:
    analysis = analyze_function_critical_points(SymbolicFunction("5"))

    assert analysis.case == "constant_function"
    assert analysis.critical_points == []
    assert analysis.stationary_points == []


def test_symbolic_function_methods() -> None:
    function = SymbolicFunction("x**2")
    analysis = function.analyze_critical_points()
    points = function.critical_points()

    assert len(analysis.critical_points) == 1
    assert len(points) == 1
    assert points[0].classification == "local_minimum"


def test_classify_function_critical_point_helper() -> None:
    assert classify_function_critical_point("-", "+", 0, 0) == "local_minimum"
    assert classify_function_critical_point("+", "-", 0, 0) == "local_maximum"
    assert classify_function_critical_point("+", "+", 0, 0) == "stationary_inflection"
