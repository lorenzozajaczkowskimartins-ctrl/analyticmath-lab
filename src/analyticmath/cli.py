"""Interface de linha de comando do AnalyticMath Lab."""

from __future__ import annotations

import argparse
import sys

import matplotlib

matplotlib.use("Agg")

from analyticmath.functions import SymbolicFunction
from analyticmath.reports.export_bundle import FunctionReportBundleResult
from analyticmath.utils.errors import AnalyticMathError, ParseError


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="analyticmath",
        description="AnalyticMath Lab — análise simbólica e exportação de relatórios.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    analyze = subparsers.add_parser(
        "analyze-function",
        help="Analisa uma função e exporta pacote de relatório (PNG, HTML, metadata).",
    )
    analyze.add_argument(
        "expression",
        help='Expressão matemática, ex.: "(x + 1)/(x - 2)"',
    )
    analyze.add_argument("--variable", default="x", help="Nome da variável (default: x)")
    analyze.add_argument(
        "--out",
        dest="output_dir",
        default="output",
        help="Diretório de saída (default: output)",
    )
    analyze.add_argument(
        "--name",
        dest="base_filename",
        default=None,
        help="Nome base dos arquivos gerados",
    )
    analyze.add_argument(
        "--theme",
        default="xp_violet_classic",
        help="Tema visual (default: xp_violet_classic)",
    )
    analyze.add_argument("--no-plot", action="store_true", help="Não gerar PNG")
    analyze.add_argument("--no-html", action="store_true", help="Não gerar HTML")
    analyze.add_argument("--markdown", action="store_true", help="Gerar relatório Markdown")
    analyze.add_argument(
        "--external-plot",
        action="store_true",
        help="Referenciar PNG externamente no HTML (sem base64 embutido)",
    )
    analyze.add_argument(
        "--show-files",
        action="store_true",
        help="Listar cada arquivo gerado em linhas separadas",
    )

    return parser


def _print_bundle_summary(result: FunctionReportBundleResult, *, show_files: bool) -> None:
    print(f"Expressão: {result.function.expr}")
    print(f"case: {result.case}")
    print(f"output_dir: {result.output_dir}")

    if show_files:
        print("generated_files:")
        for path in result.generated_files:
            print(f"  {path}")
    else:
        print(f"generated_files: {result.generated_files}")

    if result.warnings:
        print("warnings:")
        for warning in result.warnings:
            print(f"  - {warning}")
    else:
        print("warnings: []")

    if result.errors:
        print("errors:")
        for error in result.errors:
            print(f"  - {error}")
    else:
        print("errors: []")


def _run_analyze_function(args: argparse.Namespace) -> int:
    try:
        function = SymbolicFunction(args.expression, variable=args.variable)
    except (ParseError, AnalyticMathError) as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 2
    except Exception as exc:
        print(f"Erro inesperado ao interpretar expressão: {exc}", file=sys.stderr)
        return 2

    try:
        result = function.export_report_bundle(
            output_dir=args.output_dir,
            base_filename=args.base_filename,
            include_plot=not args.no_plot,
            include_html=not args.no_html,
            include_markdown=args.markdown,
            embed_plot_base64=not args.external_plot,
            theme=args.theme,
        )
    except Exception as exc:
        print(f"Erro ao exportar relatório: {exc}", file=sys.stderr)
        return 1

    _print_bundle_summary(result, show_files=args.show_files)

    if result.case == "failed":
        return 1
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.command == "analyze-function":
        return _run_analyze_function(args)

    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
