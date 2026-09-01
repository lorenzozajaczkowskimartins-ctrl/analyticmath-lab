"""Testes de tabela de sinais para funções simbólicas."""

from typing import Any

import sympy as sp

from analyticmath.functions import SymbolicFunction, build_function_sign_table


def _valid_intervals(table) -> list:
    return [interval for interval in table.intervals if interval.in_domain]


def _valid_signs(table) -> list[str]:
    return [interval.sign for interval in _valid_intervals(table)]


def _critical_x_values(table) -> list[Any]:
    return [point.x for point in table.critical_points]


def test_always_positive_quadratic_plus_one() -> None:
    table = build_function_sign_table(SymbolicFunction("x**2 + 1"))

    assert table.case == "always_positive"
    assert len(_valid_intervals(table)) == 1
    assert _valid_signs(table) == ["+"]


def test_always_negative_quadratic_minus_one() -> None:
    table = build_function_sign_table(SymbolicFunction("-x**2 - 1"))

    assert table.case == "always_negative"
    assert len(_valid_intervals(table)) == 1
    assert _valid_signs(table) == ["-"]


def test_zero_function() -> None:
    table = build_function_sign_table(SymbolicFunction("0"))

    assert table.case == "zero_function"
    assert table.intervals[0].sign == "0"


def test_reciprocal_signs() -> None:
    table = build_function_sign_table(SymbolicFunction("1/(x - 2)"))

    assert 2 in _critical_x_values(table) or sp.Integer(2) in _critical_x_values(table)
    assert _valid_signs(table) == ["-", "+"]


def test_rational_signs_with_root_and_pole() -> None:
    table = build_function_sign_table(SymbolicFunction("(x + 1)/(x - 2)"))

    critical = {str(x) for x in _critical_x_values(table)}
    assert "-1" in critical
    assert "2" in critical
    assert _valid_signs(table) == ["+", "-", "+"]


def test_sqrt_domain_limited() -> None:
    table = build_function_sign_table(SymbolicFunction("sqrt(x - 1)"))

    assert table.case == "domain_limited"
    assert len(_valid_intervals(table)) == 1
    assert _valid_signs(table) == ["+"]
    assert all(not interval.in_domain for interval in table.intervals if str(interval.right) == "1")


def test_rational_hole_includes_critical_points() -> None:
    table = build_function_sign_table(SymbolicFunction("(x**2 - 1)/(x - 1)"))

    critical = {str(x) for x in _critical_x_values(table)}
    assert "-1" in critical
    assert "1" in critical


def test_sin_does_not_break() -> None:
    table = build_function_sign_table(SymbolicFunction("sin(x)"))

    assert table.case == "unknown"
    assert table.intervals == []


def test_symbolic_function_sign_table_method() -> None:
    table = SymbolicFunction("1/(x - 2)").sign_table()
    assert _valid_signs(table) == ["-", "+"]


def test_format_function_sign_table_rational() -> None:
    from analyticmath.functions.sign_table import format_function_sign_table

    table = build_function_sign_table(SymbolicFunction("(x + 1)/(x - 2)"))
    text = format_function_sign_table(table)

    assert "Tabela de sinais:" in text
    assert "x = -1" in text
    assert "x = 2" in text
