"""Demonstração de exportação integrada de pacote de relatório."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from analyticmath.functions import SymbolicFunction

OUTPUT_DIR = Path(__file__).resolve().parent / "output" / "bundles"


def main() -> None:
    """Exporta pacote completo para função racional de exemplo."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    function = SymbolicFunction("(x + 1)/(x - 2)")
    result = function.export_report_bundle(
        output_dir=str(OUTPUT_DIR),
        base_filename="rational_function",
        include_plot=True,
        include_html=True,
        include_markdown=True,
        embed_plot_base64=True,
        theme="xp_violet_classic",
    )

    html_path = result.html_result.output_path if result.html_result else None
    plot_path = next((path for path in result.generated_files if path.endswith("_plot.png")), None)
    markdown_path = result.markdown_path
    metadata_path = result.metadata_path

    print(f"output_dir: {result.output_dir}")
    print(f"case: {result.case}")
    print(f"generated_files: {result.generated_files}")
    print(f"HTML: {html_path}")
    print(f"PNG: {plot_path}")
    print(f"Markdown: {markdown_path}")
    print(f"Metadata: {metadata_path}")
    print(f"warnings: {result.warnings}")
    print(f"errors: {result.errors}")


if __name__ == "__main__":
    main()
