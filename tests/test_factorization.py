"""Testes de fatoração de polinômios."""

import pytest

# TODO: importar factor quando implementado
# from analyticmath.polynomial.factorization import factor


@pytest.mark.skip(reason="factor ainda não implementado")
def test_factor_cubic() -> None:
    """x^3 - 6x^2 + 11x - 6 deve fatorar em (x-1)(x-2)(x-3)."""
    pass


@pytest.mark.skip(reason="factor ainda não implementado")
def test_factor_quadratic_irreducible() -> None:
    """x^2 + 1 deve permanecer irredutível sobre R."""
    pass
