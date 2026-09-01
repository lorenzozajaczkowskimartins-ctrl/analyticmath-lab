"""Testes da classe Polynomial e operações algébricas básicas."""

import sympy as sp
import pytest

from analyticmath.polynomial import Polynomial
from analyticmath.utils.errors import ParseError, PolynomialError, ValidationError


CUBIC_EXPR = "x**3 - 6*x**2 + 11*x - 6"


def test_polynomial_creation_from_string() -> None:
    """Polinômio deve ser criado a partir de string."""
    p = Polynomial(CUBIC_EXPR)
    assert p.degree() == 3
    assert p.variable == "x"


def test_polynomial_creation_from_sympy_expr() -> None:
    """Polinômio deve ser criado a partir de expressão SymPy."""
    x = sp.Symbol("x")
    expr = x**2 - 4
    p = Polynomial(expr, variable="x")
    assert p.degree() == 2
    assert sp.simplify(p.expr - expr) == 0


def test_polynomial_invalid_expression_raises() -> None:
    """Expressão não polinomial deve levantar PolynomialError."""
    with pytest.raises(PolynomialError):
        Polynomial("1/x")


def test_polynomial_invalid_input_type_raises() -> None:
    """Tipo de entrada inválido deve levantar ParseError."""
    with pytest.raises(ParseError):
        Polynomial([1, 2, 3])  # type: ignore[arg-type]


def test_degree() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert p.degree() == 3


def test_coefficients() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert p.coefficients() == [1, -6, 11, -6]


def test_leading_coefficient() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert p.leading_coefficient() == 1


def test_constant_term() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert p.constant_term() == -6


def test_expanded_and_factored() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert str(p.expanded()) == str(p.expr)
    factored = p.factored()
    assert sp.expand(factored - p.expr) == 0


def test_latex_and_str_repr() -> None:
    p = Polynomial("x**2 - 1")
    assert "x" in p.latex()
    assert str(p) == "x**2 - 1"
    assert "Polynomial(" in repr(p)


def test_roots_cubic() -> None:
    p = Polynomial(CUBIC_EXPR)
    roots = p.roots()
    assert roots == {1: 1, 2: 1, 3: 1}


def test_real_and_complex_roots() -> None:
    p = Polynomial(CUBIC_EXPR)
    assert sorted(p.real_roots()) == [1, 2, 3]
    assert p.complex_roots() == []

    p2 = Polynomial("x**2 + 1")
    assert len(p2.complex_roots()) == 2
    assert p2.real_roots() == []


def test_root_multiplicities() -> None:
    p = Polynomial("(x - 1)**2 * (x - 3)")
    assert p.root_multiplicities() == {1: 2, 3: 1}


def test_evaluate() -> None:
    p = Polynomial("x**2 - 1")
    assert p.evaluate(2) == 3
    assert p.evaluate(0) == -1


def test_derivative() -> None:
    p = Polynomial("x**3")
    d = p.derivative()
    assert isinstance(d, Polynomial)
    assert sp.simplify(d.expr - 3 * sp.Symbol("x") ** 2) == 0

    with pytest.raises(ValidationError):
        p.derivative(order=0)


def test_indefinite_integral() -> None:
    p = Polynomial("x**2")
    integral = p.indefinite_integral()
    assert "C" in str(integral)
    x = sp.Symbol("x")
    assert sp.diff(integral, x) == x**2


def test_definite_integral() -> None:
    p = Polynomial("x**2")
    assert p.definite_integral(0, 1) == sp.Rational(1, 3)


def test_end_behavior_even_positive() -> None:
    p = Polynomial("x**4 - 1")
    behavior = p.end_behavior()
    assert behavior["degree"] == 4
    assert behavior["leading_coefficient"] == 1
    assert behavior["limit_positive_infinity"] == sp.oo
    assert behavior["limit_negative_infinity"] == sp.oo
    assert "par" in behavior["description"]
    assert "positivo" in behavior["description"]


def test_end_behavior_odd() -> None:
    p = Polynomial("x**3")
    behavior = p.end_behavior()
    assert behavior["limit_positive_infinity"] == sp.oo
    assert behavior["limit_negative_infinity"] == -sp.oo


def test_fundamental_theorem_statement() -> None:
    p = Polynomial(CUBIC_EXPR)
    statement = p.fundamental_theorem_statement()
    assert "grau 3" in statement
    assert "3 raízes complexas" in statement


def test_factor_theorem_check() -> None:
    p = Polynomial(CUBIC_EXPR)
    for root in (1, 2, 3):
        check = p.factor_theorem_check(root)
        assert check["value"] == 0
        assert check["is_root"] is True
        assert check["is_factor"] is True
        assert check["factor"] is not None

    check = p.factor_theorem_check(0)
    assert check["is_root"] is False
    assert check["factor"] is None


def test_rational_root_candidates_integer_coefficients() -> None:
    p = Polynomial(CUBIC_EXPR)
    result = p.rational_root_candidates()
    assert result["applicable"] is True
    candidates = result["candidates"]
    assert sp.Rational(1, 1) in candidates
    assert sp.Rational(2, 1) in candidates
    assert sp.Rational(3, 1) in candidates


def test_rational_root_candidates_non_integer() -> None:
    p = Polynomial("x**2 - 1/2")
    result = p.rational_root_candidates()
    assert result["applicable"] is False
    assert result["candidates"] == []


def test_polynomial_equality() -> None:
    p1 = Polynomial("x**2 - 1")
    p2 = Polynomial("x**2 - 1")
    p3 = Polynomial("x**2 - 4")
    assert p1 == p2
    assert p1 != p3


def test_package_version() -> None:
    """Pacote principal deve expor versão."""
    import analyticmath

    assert analyticmath.__version__ == "0.1.0"
