"""Testes de tabela de sinais de polinômios."""

import sympy as sp

from analyticmath.polynomial import Polynomial
from analyticmath.polynomial.sign_table import (
    SignTable,
    build_sign_table,
    choose_test_point,
    format_sign_table_text,
    sign_of,
    sort_real_roots,
)


def _interval_signs(table: SignTable) -> list[str]:
    return [interval.sign for interval in table.intervals]


def test_sign_table_three_distinct_roots() -> None:
    """Tabela de sinais para polinômio com três raízes reais distintas."""
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    table = build_sign_table(p)

    assert table.real_roots == [1, 2, 3]
    assert table.root_multiplicities == {1: 1, 2: 1, 3: 1}
    assert len(table.intervals) == 4
    assert _interval_signs(table) == ["-", "+", "-", "+"]

    for info in table.root_sign_info:
        assert info.crosses_axis is True
        assert info.touches_axis is False
        assert info.value_at_root == 0


def test_sign_table_via_polynomial_method() -> None:
    """Método Polynomial.sign_table() deve delegar para build_sign_table."""
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    assert _interval_signs(p.sign_table()) == ["-", "+", "-", "+"]


def test_sign_table_double_root() -> None:
    """Raiz dupla não deve alternar sinal."""
    p = Polynomial("(x - 2)**2")
    table = build_sign_table(p)

    assert table.real_roots == [2]
    assert table.root_multiplicities == {2: 2}
    assert len(table.intervals) == 2
    assert _interval_signs(table) == ["+", "+"]

    info = table.root_sign_info[0]
    assert info.multiplicity == 2
    assert info.crosses_axis is False
    assert info.touches_axis is True


def test_sign_table_no_real_roots_positive() -> None:
    """Polinômio sem raízes reais com sinal sempre positivo."""
    p = Polynomial("x**2 + 1")
    table = build_sign_table(p)

    assert table.real_roots == []
    assert len(table.intervals) == 1
    assert table.intervals[0].sign == "+"
    assert table.case == "no_real_roots"


def test_sign_table_no_real_roots_negative() -> None:
    """Polinômio sem raízes reais com sinal sempre negativo."""
    p = Polynomial("-x**2 - 1")
    table = build_sign_table(p)

    assert table.real_roots == []
    assert len(table.intervals) == 1
    assert table.intervals[0].sign == "-"


def test_sign_table_zero_polynomial() -> None:
    """Polinômio identicamente nulo."""
    p = Polynomial("0")
    table = build_sign_table(p)

    assert table.case == "zero_polynomial"
    assert len(table.intervals) == 1
    assert table.intervals[0].sign == "0"
    assert table.root_sign_info == []


def test_sign_of_helper() -> None:
    assert sign_of(5) == "+"
    assert sign_of(-3) == "-"
    assert sign_of(0) == "0"
    assert sign_of(sp.Rational(1, 2)) == "+"


def test_choose_test_point_helpers() -> None:
    assert choose_test_point(sp.S.NegativeInfinity, 3) == 2
    assert choose_test_point(3, sp.S.Infinity) == 4
    assert sp.simplify(choose_test_point(1, 3) - 2) == 0


def test_sort_real_roots() -> None:
    assert sort_real_roots([3, 1, 2, 1]) == [1, 2, 3]


def test_format_sign_table_text_cubic() -> None:
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")
    text = format_sign_table_text(build_sign_table(p))

    assert "Tabela de sinais:" in text
    assert "(-∞, 1): -" in text
    assert "(1, 2): +" in text
    assert "(2, 3): -" in text
    assert "(3, +∞): +" in text
    assert "raiz 1, multiplicidade 1: cruza o eixo x" in text
