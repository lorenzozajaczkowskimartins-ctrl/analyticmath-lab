"""Exemplo básico de uso do módulo de polinômios.

Demonstra criação de polinômio, análise e teoremas com
p(x) = x**3 - 6*x**2 + 11*x - 6.
"""

from analyticmath.polynomial import Polynomial, format_inequality_solution
from analyticmath.polynomial.critical_points import format_critical_point_analysis
from analyticmath.polynomial.sign_table import format_sign_table_text


def main() -> None:
    """Executa demonstração básica de polinômios."""
    p = Polynomial("x**3 - 6*x**2 + 11*x - 6")

    print("=== AnalyticMath Lab — Polinômios ===\n")
    print(f"Polinômio:           {p}")
    print(f"Grau:                {p.degree()}")
    print(f"Coeficientes:        {p.coefficients()}")
    print(f"Coeficiente líder:   {p.leading_coefficient()}")
    print(f"Termo independente:  {p.constant_term()}")
    print(f"Fatoração:           {p.factored()}")
    print(f"Raízes:              {p.roots()}")
    print(f"Raízes reais:        {p.real_roots()}")
    print(f"Derivada:            {p.derivative()}")
    print(f"Integral indefinida: {p.indefinite_integral()}")

    behavior = p.end_behavior()
    print(f"\nComportamento nos extremos:")
    print(f"  {behavior['description']}")

    print(f"\n{p.fundamental_theorem_statement()}")

    print("\nTeorema do Fator:")
    for a in (1, 2, 3):
        check = p.factor_theorem_check(a)
        print(
            f"  a = {a}: p(a) = {check['value']}, "
            f"é raiz = {check['is_root']}, fator = {check['factor']}"
        )

    rational = p.rational_root_candidates()
    print(f"\nCandidatos racionais ({rational['explanation']}):")
    print(f"  {rational['candidates']}")

    print()
    print(format_sign_table_text(p.sign_table()))

    print("\nInequações:")
    for operator in (">", "<", ">=", "<=", "==", "!="):
        print(format_inequality_solution(p.solve_inequality(operator)))

    print()
    print(format_critical_point_analysis(p.analyze_critical_points()))


if __name__ == "__main__":
    main()
