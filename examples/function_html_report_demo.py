"""Demonstração de exportação HTML de relatórios de funções."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from analyticmath.functions import SymbolicFunction
from analyticmath.reports import HtmlRenderOptions, build_function_plot, render_function_report_html

OUTPUT_DIR = Path(__file__).resolve().parent / "output"


def main() -> None:
    """Gera relatório HTML com gráfico embutido para função racional."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = function.full_analysis()
    report = function.report(context=context)

    plot_path = OUTPUT_DIR / "rational_plot.png"
    html_path = OUTPUT_DIR / "rational_report.html"

    plot_result = build_function_plot(
        function,
        context=context,
        output_path=str(plot_path),
        theme="xp_violet_classic",
    )

    html_result = render_function_report_html(
        report,
        output_path=str(html_path),
        options=HtmlRenderOptions(
            include_plot=True,
            plot_path=plot_result.output_path,
            embed_plot_base64=True,
        ),
    )

    html_size = html_path.stat().st_size if html_path.exists() else 0
    png_size = plot_path.stat().st_size if plot_path.exists() else 0

    print(f"HTML: {html_path}")
    print(f"HTML size: {html_size} bytes")
    print(f"PNG: {plot_path}")
    print(f"PNG size: {png_size} bytes")
    print(f"case: {html_result.case}")
    print(f"warnings: {html_result.warnings}")
    print(f"errors: {html_result.errors}")

    if plot_result.figure is not None:
        import matplotlib.pyplot as plt

        plt.close(plot_result.figure)


if __name__ == "__main__":
    main()
