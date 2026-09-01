"""Demonstração de análise completa com contexto cacheado."""

from analyticmath.functions import SymbolicFunction, format_function_report, generate_function_report
from analyticmath.functions.inequalities import format_function_inequality_solution


def main() -> None:
    """Executa full_analysis e gera relatório reutilizando o contexto."""
    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = function.full_analysis()

    domain = context.domain()
    roots = context.roots()
    asymptotes = context.asymptotes()
    gt = context.inequality(">")

    print("AnalyticMath Lab — Análise completa com contexto\n")
    print(f"Função: f(x) = {function}\n")

    if domain is not None:
        print(f"Domínio: {domain.domain}")
    if roots is not None:
        print(f"Raízes reais: {roots.real_roots}")
    if asymptotes is not None:
        vertical = [item.x for item in asymptotes.vertical_asymptotes]
        print(f"Assíntotas verticais: {vertical or 'nenhuma'}")
    if gt is not None:
        print("\nInequação f(x) > 0:")
        print(format_function_inequality_solution(gt))

    print(f"\nWarnings: {len(context.warnings)}")
    print(f"Errors: {len(context.errors)}")

    report = generate_function_report(function, context=context)
    formatted = format_function_report(report)
    lines = formatted.splitlines()

    print("\n--- Relatório (trecho inicial) ---\n")
    for line in lines[:40]:
        print(line)
    print("...")
    print(f"\n[Relatório completo: {len(lines)} linhas]")


if __name__ == "__main__":
    main()
