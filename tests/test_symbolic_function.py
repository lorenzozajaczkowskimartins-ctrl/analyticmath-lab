"""Testes de SymbolicFunction e integração com Polynomial."""

import math

import sympy as sp

from analyticmath.functions import SymbolicFunction, find_real_domain, limit_at
from analyticmath.polynomial import Polynomial


def test_sin_over_x_creation_and_basic_methods() -> None:
    f = SymbolicFunction("sin(x)/x")

    assert str(f) == "sin(x)/x"
    assert "sin" in f.latex()
    assert abs(float(sp.N(f.evaluate(1))) - math.sin(1)) < 1e-9
    assert str(f.derivative()) == "cos(x)/x - sin(x)/x**2"


def test_rational_domain_excludes_pole() -> None:
    f = SymbolicFunction("1/(x - 2)")
    domain = find_real_domain(f).domain

    assert domain.contains(2) == False
    assert domain.contains(0) == True
    assert domain.contains(3) == True


def test_rational_limits_at_pole() -> None:
    f = SymbolicFunction("1/(x - 2)")

    left = limit_at(f, 2, direction="-")
    right = limit_at(f, 2, direction="+")

    assert left.value in (sp.S.NegativeInfinity, -sp.oo)
    assert right.value in (sp.S.Infinity, sp.oo)


def test_sqrt_domain_starts_at_one() -> None:
    f = SymbolicFunction("sqrt(x - 1)")
    domain = find_real_domain(f).domain

    assert domain.contains(0) == False
    assert domain.contains(1) == True
    assert domain.contains(2) == True


def test_exponential_root_is_log_three() -> None:
    f = SymbolicFunction("exp(x) - 3")
    roots = f.roots()

    assert roots.real_roots
    assert any(sp.simplify(root - sp.log(3)) == 0 for root in roots.real_roots)


def test_polynomial_as_function() -> None:
    p = Polynomial("x**2 - 1")
    f = p.as_function()

    assert isinstance(f, SymbolicFunction)
    assert sp.simplify(f.expr - p.expr) == 0
    assert f.roots().real_roots == [-1, 1]


def test_symbolic_function_simplified_and_integrals() -> None:
    f = SymbolicFunction("x**2")
    assert f.simplified() == sp.Symbol("x") ** 2
    assert "C" in str(f.indefinite_integral())
    assert f.definite_integral(0, 1) == sp.Rational(1, 3)


def test_limit_infinity() -> None:
    f = SymbolicFunction("1/x")
    result = f.limit_infinity("+")
    assert result.value == 0
