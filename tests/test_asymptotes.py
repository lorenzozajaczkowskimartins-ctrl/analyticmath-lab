"""Testes de assíntotas de funções simbólicas."""

from typing import Any

import sympy as sp

from analyticmath.functions import SymbolicFunction, analyze_asymptotes
from analyticmath.functions.asymptotes import (
    format_asymptote_analysis,
    is_finite_real,
    is_infinite_limit,
)


def _vertical_x_values(analysis) -> list[Any]:
    return [item.x for item in analysis.vertical_asymptotes]


def _horizontal_by_direction(analysis) -> dict[str, Any]:
    return {item.direction: item.y for item in analysis.horizontal_asymptotes}


def _oblique_expressions(analysis) -> list[Any]:
    return [sp.simplify(item.expression) for item in analysis.oblique_asymptotes]


def test_reciprocal_vertical_and_horizontal() -> None:
    f = SymbolicFunction("1/(x - 2)")
    analysis = analyze_asymptotes(f)

    assert analysis.case == "mixed"
    assert _vertical_x_values(analysis) == [2]

    vertical = analysis.vertical_asymptotes[0]
    assert is_infinite_limit(vertical.left_limit)
    assert is_infinite_limit(vertical.right_limit)
    assert vertical.left_limit in (-sp.oo, sp.S.NegativeInfinity)
    assert vertical.right_limit in (sp.oo, sp.S.Infinity)

    horizontal = _horizontal_by_direction(analysis)
    assert horizontal["+oo"] == 0
    assert horizontal["-oo"] == 0
    assert analysis.oblique_asymptotes == []


def test_rational_oblique_without_horizontal() -> None:
    f = SymbolicFunction("(x**2 + 1)/(x - 1)")
    analysis = analyze_asymptotes(f)

    assert _vertical_x_values(analysis) == [1]
    assert analysis.horizontal_asymptotes == []
    assert any(sp.simplify(expr - (sp.Symbol("x") + 1)) == 0 for expr in _oblique_expressions(analysis))


def test_quadratic_no_asymptotes() -> None:
    f = SymbolicFunction("x**2")
    analysis = analyze_asymptotes(f)

    assert analysis.case == "no_asymptotes"
    assert analysis.vertical_asymptotes == []
    assert analysis.horizontal_asymptotes == []
    assert analysis.oblique_asymptotes == []


def test_exponential_horizontal_at_plus_infinity_only() -> None:
    f = SymbolicFunction("exp(-x)")
    analysis = analyze_asymptotes(f)

    horizontal = _horizontal_by_direction(analysis)
    assert "+oo" in horizontal
    assert horizontal["+oo"] == 0
    assert "-oo" not in horizontal
    assert analysis.oblique_asymptotes == []


def test_tangent_does_not_break() -> None:
    f = SymbolicFunction("tan(x)")
    analysis = analyze_asymptotes(f)

    assert analysis.function == f
    assert "trigonométricas" in analysis.explanation.lower() or analysis.case in {
        "no_asymptotes",
        "general",
        "vertical_only",
        "mixed",
    }


def test_removable_discontinuity_not_vertical_asymptote() -> None:
    f = SymbolicFunction("(x**2 - 1)/(x - 1)")
    analysis = analyze_asymptotes(f)

    assert analysis.vertical_asymptotes == []


def test_symbolic_function_asymptotes_method() -> None:
    f = SymbolicFunction("1/(x - 2)")
    analysis = f.asymptotes()

    assert len(analysis.vertical_asymptotes) == 1
    assert len(analysis.horizontal_asymptotes) == 2


def test_format_asymptote_analysis_reciprocal() -> None:
    f = SymbolicFunction("1/(x - 2)")
    text = format_asymptote_analysis(analyze_asymptotes(f))

    assert "Assíntotas verticais:" in text
    assert "x = 2" in text
    assert "Assíntotas horizontais:" in text
    assert "y = 0" in text


def test_limit_helpers() -> None:
    assert is_infinite_limit(sp.oo) is True
    assert is_finite_real(3) is True
    assert is_finite_real(sp.oo) is False
