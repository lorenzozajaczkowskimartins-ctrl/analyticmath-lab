"""Testes de concavidade para funções simbólicas gerais."""

from typing import Any

import sympy as sp

from analyticmath.functions import SymbolicFunction, analyze_concavity
from analyticmath.functions.concavity import classify_inflection_point


def _inflection_x_values(analysis) -> list[Any]:
    return [point.x for point in analysis.inflection_points]


def _inflection_classifications(analysis) -> list[str]:
    return [point.classification for point in analysis.inflection_points]


def test_quadratic_concave_up_everywhere() -> None:
    analysis = analyze_concavity(SymbolicFunction("x**2"))

    assert analysis.concave_up_intervals
    assert analysis.concave_down_intervals == []
    assert analysis.inflection_points == []


def test_negative_quadratic_concave_down_everywhere() -> None:
    analysis = analyze_concavity(SymbolicFunction("-x**2"))

    assert analysis.concave_down_intervals
    assert analysis.concave_up_intervals == []
    assert analysis.inflection_points == []


def test_cubic_inflection_at_zero() -> None:
    analysis = analyze_concavity(SymbolicFunction("x**3"))

    assert len(analysis.inflection_points) == 1
    assert sp.simplify(_inflection_x_values(analysis)[0]) == 0
    assert _inflection_classifications(analysis)[0] in (
        "inflection_point",
        "stationary_inflection",
    )


def test_quartic_zero_not_inflection() -> None:
    analysis = analyze_concavity(SymbolicFunction("x**4"))

    assert _inflection_classifications(analysis) == []
    assert analysis.concave_up_intervals
    assert analysis.concave_down_intervals == []


def test_reciprocal_concavity_branches() -> None:
    analysis = analyze_concavity(SymbolicFunction("1/(x - 2)"))

    assert analysis.inflection_points == []
    assert len(analysis.concave_down_intervals) == 1
    assert len(analysis.concave_up_intervals) == 1

    down = analysis.concave_down_intervals[0]
    up = analysis.concave_up_intervals[0]
    assert str(down.right) == "2"
    assert str(up.left) == "2"


def test_sqrt_does_not_break() -> None:
    analysis = analyze_concavity(SymbolicFunction("sqrt(x)"))

    assert analysis.case in ("general", "no_inflection_points", "unknown")
    assert analysis.concave_down_intervals or analysis.concave_up_intervals or analysis.case == "unknown"


def test_abs_does_not_break() -> None:
    analysis = analyze_concavity(SymbolicFunction("Abs(x)"))

    assert analysis.case in ("unknown", "no_inflection_points", "general")


def test_symbolic_function_methods() -> None:
    function = SymbolicFunction("x**3")
    assert function.analyze_concavity().inflection_points
    assert function.concavity().inflection_points


def test_classify_inflection_point_helper() -> None:
    assert classify_inflection_point("-", "+", 0) == "stationary_inflection"
    assert classify_inflection_point("+", "-", 1) == "inflection_point"
    assert classify_inflection_point("+", "+", 0) == "candidate_not_inflection"
