"""Exemplos básicos de funções simbólicas gerais."""

from analyticmath.functions import SymbolicFunction
from analyticmath.functions.asymptotes import format_asymptote_analysis
from analyticmath.functions.continuity import format_continuity_analysis
from analyticmath.functions.concavity import format_concavity_analysis
from analyticmath.functions.inequalities import format_function_inequality_solution
from analyticmath.functions.critical_points import format_function_critical_point_analysis
from analyticmath.functions.sign_table import format_function_sign_table


def _print_function_analysis(name: str, function: SymbolicFunction) -> None:
    print(f"=== {name} ===")
    print(f"Função:              f(x) = {function}")
    print(f"Domínio:             {function.domain().domain}")
    print(f"Derivada:            f'(x) = {function.derivative()}")
    print(f"Integral indefinida: {function.indefinite_integral()}")

    roots = function.roots()
    print(f"Raízes:              {roots.real_roots or roots.roots or 'nenhuma encontrada'}")
    print(f"  ({roots.explanation})")

    if name.startswith("g"):
        left = function.limit(2, direction="-")
        right = function.limit(2, direction="+")
        print(f"Limite em x→2⁻:      {left.value}")
        print(f"Limite em x→2⁺:      {right.value}")
    elif name.startswith("f"):
        print(f"Limite em x→0:       {function.limit(0).value}")
        print(f"Limite em x→+∞:      {function.limit_infinity('+').value}")
    else:
        print(f"Limite em x→+∞:      {function.limit_infinity('+').value}")

    print()


def _print_asymptotes(name: str, function: SymbolicFunction) -> None:
    print(f"--- Assíntotas: {name} ---")
    print(format_asymptote_analysis(function.asymptotes()))
    print()


def _print_continuity(name: str, function: SymbolicFunction) -> None:
    print(f"--- Continuidade: {name} ---")
    print(format_continuity_analysis(function.continuity()))
    print()


def _print_sign_table(name: str, function: SymbolicFunction) -> None:
    print(f"--- Tabela de sinais: {name} ---")
    print(format_function_sign_table(function.sign_table()))
    print()


def _print_inequalities(name: str, function: SymbolicFunction) -> None:
    print(f"--- Inequações: {name} ---")
    for operator in (">", "<", ">=", "<=", "==", "!="):
        solution = function.solve_inequality(operator)
        print(format_function_inequality_solution(solution))
        print()


def _print_critical_points(name: str, function: SymbolicFunction) -> None:
    print(f"--- Pontos críticos: {name} ---")
    print(format_function_critical_point_analysis(function.analyze_critical_points()))
    print()


def _print_concavity(name: str, function: SymbolicFunction) -> None:
    print(f"--- Concavidade: {name} ---")
    print(format_concavity_analysis(function.analyze_concavity()))
    print()


def main() -> None:
    """Demonstra análise inicial de funções simbólicas."""
    print("AnalyticMath Lab — Funções simbólicas\n")

    _print_function_analysis("f(x) = sin(x)/x", SymbolicFunction("sin(x)/x"))
    _print_function_analysis("g(x) = 1/(x - 2)", SymbolicFunction("1/(x - 2)"))
    _print_function_analysis("h(x) = sqrt(x - 1)", SymbolicFunction("sqrt(x - 1)"))
    _print_function_analysis("q(x) = exp(x) - 3", SymbolicFunction("exp(x) - 3"))

    g = SymbolicFunction("1/(x - 2)")
    r = SymbolicFunction("(x + 1)/(x - 2)")
    hole = SymbolicFunction("(x**2 - 1)/(x - 1)")
    f = SymbolicFunction("sin(x)/x")
    h = SymbolicFunction("sqrt(x - 1)")
    log_f = SymbolicFunction("log(x)")

    print("Assíntotas:\n")
    _print_asymptotes("g(x) = 1/(x - 2)", g)
    _print_asymptotes("r(x) = (x**2 + 1)/(x - 1)", SymbolicFunction("(x**2 + 1)/(x - 1)"))
    _print_asymptotes("hole(x) = (x**2 - 1)/(x - 1)", hole)

    print("Continuidade:\n")
    _print_continuity("hole(x) = (x**2 - 1)/(x - 1)", hole)
    _print_continuity("g(x) = 1/(x - 2)", g)
    _print_continuity("f(x) = sin(x)/x", f)
    _print_continuity("h(x) = sqrt(x - 1)", h)
    _print_continuity("l(x) = log(x)", log_f)

    print("Tabelas de sinais gerais:\n")
    _print_sign_table("g(x) = 1/(x - 2)", g)
    _print_sign_table("r(x) = (x + 1)/(x - 2)", r)
    _print_sign_table("h(x) = sqrt(x - 1)", h)
    _print_sign_table("hole(x) = (x**2 - 1)/(x - 1)", hole)

    print("Inequações gerais:\n")
    _print_inequalities("f(x) = 1/(x - 2)", g)
    _print_inequalities("r(x) = (x + 1)/(x - 2)", r)
    _print_inequalities("h(x) = sqrt(x - 1)", h)

    sq = SymbolicFunction("x**2")
    cubic = SymbolicFunction("x**3")
    quartic = SymbolicFunction("x**4")
    abs_f = SymbolicFunction("Abs(x)")

    print("Pontos críticos e monotonicidade:\n")
    _print_critical_points("f(x) = x**2", sq)
    _print_critical_points("g(x) = x**3", cubic)
    _print_critical_points("h(x) = 1/(x - 2)", g)
    _print_critical_points("a(x) = Abs(x)", abs_f)

    print("Concavidade e pontos de inflexão:\n")
    _print_concavity("f(x) = x**2", sq)
    _print_concavity("g(x) = x**3", cubic)
    _print_concavity("h(x) = x**4", quartic)
    _print_concavity("r(x) = 1/(x - 2)", g)


if __name__ == "__main__":
    main()
