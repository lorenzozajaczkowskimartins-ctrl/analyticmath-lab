"""Demonstração de gráficos anotados para funções simbólicas."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt

from analyticmath.functions import SymbolicFunction
from analyticmath.reports import PlotWindow, build_function_plot

OUTPUT_DIR = Path(__file__).resolve().parent / "output"


def main() -> None:
    """Gera gráficos PNG de exemplo com tema XP Violet Dark."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    examples = [
        ("x**2", OUTPUT_DIR / "plot_x2.png"),
        ("(x + 1)/(x - 2)", OUTPUT_DIR / "plot_rational.png"),
        ("sqrt(x - 1)", OUTPUT_DIR / "plot_sqrt.png", PlotWindow(x_min=-1, x_max=6, y_min=-1, y_max=3)),
        ("sin(x)/x", OUTPUT_DIR / "plot_sinc.png"),
        ("(x**2 + 1)/(x - 1)", OUTPUT_DIR / "plot_oblique.png"),
    ]

    for entry in examples:
        if len(entry) == 2:
            expr, output_path = entry
            window = None
        else:
            expr, output_path, window = entry

        function = SymbolicFunction(expr)
        context = function.full_analysis()
        result = build_function_plot(
            function,
            context=context,
            window=window,
            output_path=str(output_path),
            theme="xp_violet_classic",
        )
        print(f"{expr}: case={result.case}, saved={output_path.name}, warnings={len(result.warnings)}")
        if result.figure is not None:
            plt.close(result.figure)

    rational = SymbolicFunction("(x + 1)/(x - 2)")
    default_path = OUTPUT_DIR / "plot_rational_default.png"
    default_result = build_function_plot(
        rational,
        context=rational.full_analysis(),
        output_path=str(default_path),
        theme="default",
    )
    print(
        f"(x + 1)/(x - 2) [default]: case={default_result.case}, "
        f"saved={default_path.name}, warnings={len(default_result.warnings)}"
    )
    if default_result.figure is not None:
        plt.close(default_result.figure)


if __name__ == "__main__":
    main()
