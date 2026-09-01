"""Testes de continuidade de funções simbólicas."""

import sympy as sp

from analyticmath.functions import SymbolicFunction, analyze_continuity


def test_removable_discontinuity_rational_hole() -> None:
    f = SymbolicFunction("(x**2 - 1)/(x - 1)")
    analysis = analyze_continuity(f)

    assert len(analysis.discontinuities) == 1
    disc = analysis.discontinuities[0]
    assert disc.x == 1
    assert disc.classification == "removable"
    assert disc.removable is True
    assert disc.vertical_asymptote is False
    assert sp.simplify(disc.left_limit - 2) == 0
    assert sp.simplify(disc.right_limit - 2) == 0


def test_infinite_discontinuity_rational_pole() -> None:
    f = SymbolicFunction("1/(x - 2)")
    analysis = analyze_continuity(f)

    assert len(analysis.discontinuities) == 1
    disc = analysis.discontinuities[0]
    assert disc.x == 2
    assert disc.classification == "infinite"
    assert disc.infinite is True
    assert disc.vertical_asymptote is True


def test_sqrt_continuous_on_domain() -> None:
    f = SymbolicFunction("sqrt(x - 1)")
    analysis = analyze_continuity(f)

    assert analysis.continuous_on_domain is True
    assert analysis.discontinuities == []
    assert analysis.case == "continuous_on_domain"


def test_log_continuous_on_domain() -> None:
    f = SymbolicFunction("log(x)")
    analysis = analyze_continuity(f)

    assert analysis.continuous_on_domain is True
    assert analysis.discontinuities == []
    assert "fronteira" in analysis.explanation.lower() or analysis.case == "continuous_on_domain"


def test_sin_over_x_removable_at_zero() -> None:
    f = SymbolicFunction("sin(x)/x")
    analysis = analyze_continuity(f)

    assert len(analysis.discontinuities) == 1
    disc = analysis.discontinuities[0]
    assert disc.x == 0
    assert disc.classification == "removable"
    assert sp.simplify(disc.left_limit - 1) == 0
    assert sp.simplify(disc.right_limit - 1) == 0


def test_polynomial_continuous() -> None:
    f = SymbolicFunction("x**2")
    analysis = analyze_continuity(f)

    assert analysis.continuous_on_domain is True
    assert analysis.discontinuities == []


def test_symbolic_function_continuity_method() -> None:
    f = SymbolicFunction("(x**2 - 1)/(x - 1)")
    analysis = f.continuity()

    assert analysis.discontinuities[0].classification == "removable"


def test_format_continuity_analysis() -> None:
    from analyticmath.functions.continuity import format_continuity_analysis

    f = SymbolicFunction("(x**2 - 1)/(x - 1)")
    text = format_continuity_analysis(analyze_continuity(f))

    assert "Continuidade:" in text
    assert "removível" in text
    assert "x = 1" in text
