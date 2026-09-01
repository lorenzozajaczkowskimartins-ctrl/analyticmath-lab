"""Testes de inequações polinomiais."""

import sympy as sp
import pytest

from analyticmath.polynomial import Polynomial, solve_polynomial_inequality
from analyticmath.polynomial.inequalities import (
    format_inequality_solution,
    format_solution_interval,
    interval_satisfies_operator,
)
from analyticmath.utils.errors import ValidationError


def _interval_key(interval) -> tuple:
    return (
        str(interval.left),
        str(interval.right),
        interval.left_closed,
        interval.right_closed,
    )


def _solution_keys(solution) -> list[tuple]:
    return [_interval_key(i) for i in solution.intervals]


def test_cubic_greater_than_zero() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, ">")

    assert len(solution.intervals) == 2
    assert _solution_keys(solution) == [
        ("1", "2", False, False),
        ("3", "oo", False, False),
    ]
    assert solution.roots_included == []


def test_cubic_less_than_zero() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, "<")

    assert _solution_keys(solution) == [
        ("-oo", "1", False, False),
        ("2", "3", False, False),
    ]


def test_cubic_greater_equal_includes_roots() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, ">=")

    assert _solution_keys(solution) == [
        ("1", "2", True, True),
        ("3", "oo", True, False),
    ]
    assert solution.roots_included == [1, 2, 3]


def test_cubic_less_equal_includes_roots() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, "<=")

    assert _solution_keys(solution) == [
        ("-oo", "1", False, True),
        ("2", "3", True, True),
    ]
    assert solution.roots_included == [1, 2, 3]


def test_cubic_equal_zero() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, "==")

    assert len(solution.intervals) == 3
    assert {str(i.left) for i in solution.intervals} == {"1", "2", "3"}
    assert all(i.left_closed and i.right_closed for i in solution.intervals)


def test_cubic_not_equal_zero() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    solution = solve_polynomial_inequality(p, "!=")

    assert len(solution.intervals) == 4
    assert all(not i.left_closed and not i.right_closed for i in solution.intervals)


def test_double_root_greater_than_zero() -> None:
    p = Polynomial("(x - 2)**2")
    solution = solve_polynomial_inequality(p, ">")

    assert _solution_keys(solution) == [
        ("-oo", "2", False, False),
        ("2", "oo", False, False),
    ]


def test_double_root_greater_equal_all_real() -> None:
    p = Polynomial("(x - 2)**2")
    solution = solve_polynomial_inequality(p, ">=")

    assert solution.case == "all_real"
    assert len(solution.intervals) == 1
    assert _is_all_real(solution.intervals[0])


def test_double_root_equal_zero() -> None:
    p = Polynomial("(x - 2)**2")
    solution = solve_polynomial_inequality(p, "==")

    assert len(solution.intervals) == 1
    assert str(solution.intervals[0].left) == "2"


def test_double_root_less_than_zero_empty() -> None:
    p = Polynomial("(x - 2)**2")
    solution = solve_polynomial_inequality(p, "<")

    assert solution.case == "empty"
    assert solution.intervals == []


def test_no_real_roots_positive() -> None:
    p = Polynomial("x**2 + 1")

    assert solve_polynomial_inequality(p, ">").case == "all_real"
    assert solve_polynomial_inequality(p, "<").case == "empty"
    assert solve_polynomial_inequality(p, "==").case == "empty"


def test_no_real_roots_negative() -> None:
    p = Polynomial("-x**2 - 1")

    assert solve_polynomial_inequality(p, "<").case == "all_real"
    assert solve_polynomial_inequality(p, ">").case == "empty"


def test_zero_polynomial_all_operators() -> None:
    p = Polynomial("0")

    assert solve_polynomial_inequality(p, ">").case == "empty"
    assert solve_polynomial_inequality(p, "<").case == "empty"
    assert solve_polynomial_inequality(p, "!=").case == "empty"
    assert solve_polynomial_inequality(p, ">=").case == "all_real"
    assert solve_polynomial_inequality(p, "<=").case == "all_real"
    assert solve_polynomial_inequality(p, "==").case == "all_real"


def test_constant_polynomial_cases() -> None:
    pos = Polynomial("5")
    neg = Polynomial("-3")

    assert solve_polynomial_inequality(pos, ">").case == "all_real"
    assert solve_polynomial_inequality(pos, "<").case == "empty"
    assert solve_polynomial_inequality(neg, "<").case == "all_real"
    assert solve_polynomial_inequality(neg, ">").case == "empty"


def test_polynomial_method_alias() -> None:
    p = Polynomial("x**2 - 1")
    assert p.solve_inequality(">").intervals
    assert p.inequality("==").roots_included == [-1, 1]


def test_invalid_operator_raises() -> None:
    p = Polynomial("x**2 - 1")
    with pytest.raises(ValidationError):
        solve_polynomial_inequality(p, "=>")


def test_interval_satisfies_operator_helper() -> None:
    assert interval_satisfies_operator("+", ">") is True
    assert interval_satisfies_operator("-", ">=") is False
    assert interval_satisfies_operator("-", "<=") is True
    assert interval_satisfies_operator("+", "==") is False


def test_format_solution_interval() -> None:
    from analyticmath.polynomial.inequalities import SolutionInterval

    assert format_solution_interval(
        SolutionInterval(1, 2, False, False)
    ) == "(1, 2)"
    assert format_solution_interval(SolutionInterval(3, 3, True, True)) == "{3}"


def test_format_inequality_solution_cubic() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    text = format_inequality_solution(solve_polynomial_inequality(p, ">"))

    assert "p(x) > 0:" in text
    assert "(1, 2)" in text
    assert "(3, +∞)" in text


def _is_all_real(interval) -> bool:
    return str(interval.left) in ("-oo", "NegativeInfinity") and str(interval.right) in (
        "oo",
        "Infinity",
    )
