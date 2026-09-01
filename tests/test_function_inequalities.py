"""Testes de inequações para funções simbólicas gerais."""

import pytest

from analyticmath.functions import SymbolicFunction, solve_function_inequality
from analyticmath.functions.inequalities import (
    format_function_inequality_solution,
    interval_satisfies_operator,
    point_satisfies_operator,
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


def test_always_positive_function() -> None:
    f = SymbolicFunction("x**2 + 1")

    assert solve_function_inequality(f, ">").case == "all_domain"
    assert solve_function_inequality(f, "<").case == "empty"
    assert solve_function_inequality(f, "==").case == "empty"
    assert solve_function_inequality(f, "!=").case == "all_domain"


def test_always_negative_function() -> None:
    f = SymbolicFunction("-x**2 - 1")

    assert solve_function_inequality(f, "<").case == "all_domain"
    assert solve_function_inequality(f, ">").case == "empty"


def test_zero_function() -> None:
    f = SymbolicFunction("0")

    ge = solve_function_inequality(f, ">=")
    eq = solve_function_inequality(f, "==")
    ne = solve_function_inequality(f, "!=")

    assert ge.case in ("all_domain", "zero_function")
    assert eq.case in ("all_domain", "zero_function")
    assert ne.case == "empty"


def test_rational_simple_reciprocal() -> None:
    f = SymbolicFunction("1/(x - 2)")

    gt = solve_function_inequality(f, ">")
    lt = solve_function_inequality(f, "<")
    ne = solve_function_inequality(f, "!=")

    assert _solution_keys(gt) == [("2", "oo", False, False)]
    assert _solution_keys(lt) == [("-oo", "2", False, False)]
    assert len(ne.intervals) == 2
    assert 2 in ne.excluded_points or any(str(p) == "2" for p in ne.excluded_points)


def test_rational_with_root() -> None:
    f = SymbolicFunction("(x + 1)/(x - 2)")

    gt = solve_function_inequality(f, ">")
    lt = solve_function_inequality(f, "<")
    ge = solve_function_inequality(f, ">=")
    le = solve_function_inequality(f, "<=")
    eq = solve_function_inequality(f, "==")
    ne = solve_function_inequality(f, "!=")

    assert _solution_keys(gt) == [
        ("-oo", "-1", False, False),
        ("2", "oo", False, False),
    ]
    assert _solution_keys(lt) == [("-1", "2", False, False)]
    assert _solution_keys(ge) == [
        ("-oo", "-1", False, True),
        ("2", "oo", False, False),
    ]
    assert _solution_keys(le) == [("-1", "2", True, False)]
    assert _solution_keys(eq) == [("-1", "-1", True, True)]
    assert len(ne.intervals) == 3
    assert -1 in ne.excluded_points or any(str(p) == "-1" for p in ne.excluded_points)


def test_sqrt_domain_boundary() -> None:
    f = SymbolicFunction("sqrt(x - 1)")

    gt = solve_function_inequality(f, ">")
    ge = solve_function_inequality(f, ">=")
    eq = solve_function_inequality(f, "==")
    lt = solve_function_inequality(f, "<")

    assert _solution_keys(gt) == [("1", "oo", False, False)]
    assert _solution_keys(ge) == [("1", "oo", True, False)]
    assert _solution_keys(eq) == [("1", "1", True, True)]
    assert lt.case == "empty"


def test_sin_does_not_break() -> None:
    f = SymbolicFunction("sin(x)")
    solution = solve_function_inequality(f, ">")

    assert solution.case == "unknown"
    assert solution.intervals == []


def test_symbolic_function_methods() -> None:
    f = SymbolicFunction("x**2 + 1")
    assert f.solve_inequality(">").case == "all_domain"
    assert f.inequality(">").case == "all_domain"


def test_invalid_operator() -> None:
    f = SymbolicFunction("x")
    with pytest.raises(ValidationError):
        solve_function_inequality(f, "≥≥")


def test_interval_satisfies_operator() -> None:
    assert interval_satisfies_operator("+", ">")
    assert interval_satisfies_operator("-", "<")
    assert not interval_satisfies_operator("0", ">")
    assert interval_satisfies_operator("+", "!=")


def test_point_satisfies_operator() -> None:
    assert point_satisfies_operator(0, "==")
    assert point_satisfies_operator(0, ">=")
    assert not point_satisfies_operator(0, ">")
    assert point_satisfies_operator(1, "!=")


def test_format_rational_solution() -> None:
    f = SymbolicFunction("(x + 1)/(x - 2)")
    formatted = format_function_inequality_solution(solve_function_inequality(f, ">"))
    assert "f(x) > 0:" in formatted
    assert "(-∞, -1)" in formatted
    assert "(2, +∞)" in formatted
