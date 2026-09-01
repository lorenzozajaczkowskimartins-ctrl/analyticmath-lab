"""Demonstração do relatório unificado de funções simbólicas."""

from analyticmath.functions import SymbolicFunction, format_function_report


def main() -> None:
    """Gera e imprime relatórios completos para funções de exemplo."""
    examples = [
        ("f(x) = x**2", "x**2"),
        ("r(x) = (x + 1)/(x - 2)", "(x + 1)/(x - 2)"),
        ("h(x) = sqrt(x - 1)", "sqrt(x - 1)"),
        ("s(x) = sin(x)/x", "sin(x)/x"),
    ]

    for label, expr in examples:
        function = SymbolicFunction(expr)
        context = function.full_analysis()
        report = function.report(context=context)

        print(f"Exemplo: {label}  (case: {report.case})\n")
        print(format_function_report(report))
        print("\n" + "=" * 72 + "\n")


if __name__ == "__main__":
    main()
