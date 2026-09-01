"""Classe principal Polynomial e operações algébricas básicas.

Ponto de entrada do módulo de polinômios: criação a partir de
expressão SymPy ou string, grau, avaliação e operações elementares.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

import sympy as sp
from sympy import (
    Poly,
    Symbol,
    diff,
    expand,
    factor,
    integrate,
    latex,
    oo,
    roots as sympy_roots,
    sympify,
)
from sympy.core.expr import Expr
from sympy.polys.polyerrors import PolificationFailed
from sympy.polys.polyerrors import PolynomialError as SymPyPolynomialError

from analyticmath.utils.errors import ParseError, PolynomialError, ValidationError

if TYPE_CHECKING:
    from analyticmath.polynomial.sign_table import SignTable
    from analyticmath.polynomial.inequalities import PolynomialInequalitySolution
    from analyticmath.polynomial.critical_points import CriticalPoint, CriticalPointAnalysis
    from analyticmath.functions.symbolic_function import SymbolicFunction


class Polynomial:
    """Polinômio real ou simbólico de uma variável.

    Encapsula uma expressão SymPy expandida e expõe operações comuns
    de análise polinomial (grau, coeficientes, raízes, derivadas, etc.).
    """

    def __init__(
        self,
        expression: str | Expr,
        *,
        variable: str = "x",
    ) -> None:
        self.variable = variable
        self.symbol = Symbol(variable)

        try:
            if isinstance(expression, str):
                expr = sympify(expression, locals={variable: self.symbol})
            elif isinstance(expression, Expr):
                expr = expression
            else:
                raise ParseError(
                    f"Entrada inválida: esperada str ou Expr SymPy, recebido {type(expression).__name__}."
                )
        except (ParseError, PolynomialError):
            raise
        except Exception as exc:
            raise ParseError(f"Não foi possível interpretar a expressão: {expression!r}.") from exc

        self.expr = expand(expr)

        try:
            self.poly = Poly(self.expr, self.symbol)
        except (PolificationFailed, SymPyPolynomialError) as exc:
            raise PolynomialError(
                f"A expressão não é um polinômio na variável {variable!r}: {self.expr}."
            ) from exc

    def degree(self) -> int:
        """Retorna o grau do polinômio."""
        return int(self.poly.degree())

    def coefficients(self) -> list[Any]:
        """Retorna coeficientes em ordem decrescente de grau."""
        return list(self.poly.all_coeffs())

    def leading_coefficient(self) -> Any:
        """Retorna o coeficiente do termo de maior grau."""
        return self.poly.LC()

    def constant_term(self) -> Any:
        """Retorna o termo independente P(0)."""
        return self.poly.TC()

    def expanded(self) -> Expr:
        """Retorna a expressão SymPy expandida."""
        return self.expr

    def factored(self) -> Expr:
        """Retorna a forma fatorada com SymPy."""
        return factor(self.expr)

    def latex(self) -> str:
        """Retorna a representação LaTeX do polinômio."""
        return latex(self.expr)

    def evaluate(self, value: int | float | complex | sp.Basic) -> Any:
        """Avalia o polinômio em um ponto numérico ou simbólico."""
        return self.expr.subs(self.symbol, value)

    def roots(self) -> dict[Any, int]:
        """Retorna raízes com multiplicidade (dict raiz -> multiplicidade)."""
        return dict(sympy_roots(self.poly, self.symbol))

    def real_roots(self) -> list[Any]:
        """Retorna apenas raízes reais (multiplicidade repetida na lista)."""
        result: list[Any] = []
        for root, multiplicity in self.roots().items():
            if sp.im(root).equals(0):
                result.extend([root] * multiplicity)
        return result

    def complex_roots(self) -> list[Any]:
        """Retorna raízes complexas não reais (com multiplicidade)."""
        result: list[Any] = []
        for root, multiplicity in self.roots().items():
            if not sp.im(root).equals(0):
                result.extend([root] * multiplicity)
        return result

    def root_multiplicities(self) -> dict[Any, int]:
        """Retorna dicionário raiz -> multiplicidade."""
        return self.roots()

    def derivative(self, order: int = 1) -> Polynomial:
        """Retorna um ``Polynomial`` representando a derivada de ordem ``order``."""
        if order < 1:
            raise ValidationError(f"A ordem da derivada deve ser >= 1, recebido {order}.")
        derived = diff(self.expr, self.symbol, order)
        return Polynomial(derived, variable=self.variable)

    def indefinite_integral(self) -> Expr:
        """Retorna a expressão simbólica da integral indefinida (inclui constante C)."""
        integration_constant = Symbol("C")
        return integrate(self.expr, self.symbol) + integration_constant

    def definite_integral(self, a: Any, b: Any) -> Any:
        """Retorna o valor da integral definida de ``a`` até ``b``."""
        return integrate(self.expr, (self.symbol, a, b))

    def end_behavior(self) -> dict[str, Any]:
        """Descreve o comportamento assintótico quando x -> ±∞."""
        degree = self.degree()
        leading = self.leading_coefficient()

        if degree == 0:
            limit_pos = self.constant_term()
            limit_neg = self.constant_term()
            description = (
                f"Como o grau é zero, p({self.variable}) é constante igual a {limit_pos} "
                f"quando {self.variable} tende a +∞ ou -∞."
            )
        else:
            leading_sign = _leading_coefficient_sign(leading)

            if degree % 2 == 0:
                if leading_sign == 1:
                    limit_pos = oo
                    limit_neg = oo
                    description = (
                        f"Como o grau é par e o coeficiente líder é positivo, "
                        f"p({self.variable}) tende a +∞ quando {self.variable} tende a +∞ "
                        f"e também quando {self.variable} tende a -∞."
                    )
                elif leading_sign == -1:
                    limit_pos = -oo
                    limit_neg = -oo
                    description = (
                        f"Como o grau é par e o coeficiente líder é negativo, "
                        f"p({self.variable}) tende a -∞ quando {self.variable} tende a +∞ "
                        f"e também quando {self.variable} tende a -∞."
                    )
                else:
                    limit_pos = sp.nan
                    limit_neg = sp.nan
                    description = (
                        f"O coeficiente líder é zero ou indeterminado; "
                        f"não é possível descrever o comportamento nos extremos."
                    )
            else:
                if leading_sign == 1:
                    limit_pos = oo
                    limit_neg = -oo
                    description = (
                        f"Como o grau é ímpar e o coeficiente líder é positivo, "
                        f"p({self.variable}) tende a +∞ quando {self.variable} tende a +∞ "
                        f"e a -∞ quando {self.variable} tende a -∞."
                    )
                elif leading_sign == -1:
                    limit_pos = -oo
                    limit_neg = oo
                    description = (
                        f"Como o grau é ímpar e o coeficiente líder é negativo, "
                        f"p({self.variable}) tende a -∞ quando {self.variable} tende a +∞ "
                        f"e a +∞ quando {self.variable} tende a -∞."
                    )
                else:
                    limit_pos = sp.nan
                    limit_neg = sp.nan
                    description = (
                        f"O coeficiente líder é zero ou indeterminado; "
                        f"não é possível descrever o comportamento nos extremos."
                    )

        return {
            "degree": degree,
            "leading_coefficient": leading,
            "limit_positive_infinity": limit_pos,
            "limit_negative_infinity": limit_neg,
            "description": description,
        }

    def fundamental_theorem_statement(self) -> str:
        """Enuncia quantas raízes complexas existem contando multiplicidade."""
        degree = self.degree()
        total_roots = sum(self.roots().values()) if self.roots() else degree
        if degree == 0:
            return (
                "Pelo Teorema Fundamental da Álgebra, um polinômio constante não possui "
                "raízes no sentido usual (grau zero)."
            )
        return (
            f"Pelo Teorema Fundamental da Álgebra, um polinômio de grau {degree} possui "
            f"exatamente {degree} raízes complexas contando multiplicidade "
            f"(encontradas simbolicamente: {total_roots})."
        )

    def factor_theorem_check(self, a: Any) -> dict[str, Any]:
        """Verifica o Teorema do Fator para o valor ``a``."""
        value = self.evaluate(a)
        is_root = sp.simplify(value) == 0
        factor_expr: str | None = None
        if is_root:
            factor_expr = f"{self.variable} - ({a})"
        return {
            "value": value,
            "is_root": bool(is_root),
            "is_factor": bool(is_root),
            "factor": factor_expr,
        }

    def rational_root_candidates(self) -> dict[str, Any]:
        """Lista candidatos racionais pelo Teorema das Raízes Racionais."""
        coeffs = self.coefficients()
        if not coeffs:
            return {
                "candidates": [],
                "applicable": False,
                "explanation": "Polinômio vazio ou inválido.",
            }

        if not all(c.is_integer for c in coeffs):
            return {
                "candidates": [],
                "applicable": False,
                "explanation": (
                    "O Teorema das Raízes Racionais aplica-se a coeficientes inteiros; "
                    "este polinômio possui coeficientes não inteiros."
                ),
            }

        leading = int(self.leading_coefficient())
        constant = int(self.constant_term())

        if leading == 0:
            return {
                "candidates": [],
                "applicable": False,
                "explanation": "Coeficiente líder nulo: expressão não é um polinômio de grau positivo.",
            }

        divisors_p = _integer_divisors(abs(constant))
        divisors_q = _integer_divisors(abs(leading))

        candidates_set: set[sp.Rational] = set()
        for p in divisors_p:
            for q in divisors_q:
                for sign in (1, -1):
                    candidates_set.add(sp.Rational(sign * p, q))

        candidates = sorted(candidates_set, key=lambda r: (float(r), str(r)))
        return {
            "candidates": candidates,
            "applicable": True,
            "explanation": (
                f"Candidatos da forma p/q, com p | {constant} e q | {leading}."
            ),
        }

    def sign_table(self) -> SignTable:
        """Retorna a tabela de sinais real do polinômio."""
        from analyticmath.polynomial.sign_table import build_sign_table

        return build_sign_table(self)

    def solve_inequality(self, operator: str) -> PolynomialInequalitySolution:
        """Resolve a inequação p(x) ``operator`` 0."""
        from analyticmath.polynomial.inequalities import solve_polynomial_inequality

        return solve_polynomial_inequality(self, operator)

    def inequality(self, operator: str) -> PolynomialInequalitySolution:
        """Alias para :meth:`solve_inequality`."""
        return self.solve_inequality(operator)

    def critical_points(self) -> list[CriticalPoint]:
        """Retorna a lista de pontos críticos reais de ``p(x)``."""
        from analyticmath.polynomial.critical_points import analyze_critical_points

        return analyze_critical_points(self).critical_points

    def analyze_critical_points(self) -> CriticalPointAnalysis:
        """Analisa pontos críticos, classificação e monotonicidade."""
        from analyticmath.polynomial.critical_points import analyze_critical_points

        return analyze_critical_points(self)

    def as_function(self) -> SymbolicFunction:
        """Converte o polinômio em ``SymbolicFunction`` para análise geral."""
        from analyticmath.functions.symbolic_function import SymbolicFunction

        return SymbolicFunction(self.expr, variable=self.variable)

    def __str__(self) -> str:
        return str(self.expr)

    def __repr__(self) -> str:
        return f"Polynomial({self.expr!r}, variable={self.variable!r})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Polynomial):
            return NotImplemented
        return (
            self.variable == other.variable
            and sp.simplify(self.expr - other.expr) == 0
        )


def _integer_divisors(n: int) -> list[int]:
    """Retorna divisores positivos de ``n`` (inclui 0 apenas se n=0)."""
    if n == 0:
        return [0]
    divisors: list[int] = []
    for d in range(1, abs(n) + 1):
        if n % d == 0:
            divisors.append(d)
    return divisors


def _leading_coefficient_sign(leading: Any) -> int:
    """Retorna 1 (positivo), -1 (negativo) ou 0 se indeterminado."""
    if leading.is_positive:
        return 1
    if leading.is_negative:
        return -1
    if leading.is_number:
        value = float(leading)
        if value > 0:
            return 1
        if value < 0:
            return -1
    return 0
