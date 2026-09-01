"""Testes do pipeline de exportação de pacotes de relatório."""

from __future__ import annotations

import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from analyticmath.functions import SymbolicFunction
from analyticmath.reports import (
    FunctionReportBundleOptions,
    export_function_report_bundle,
    sanitize_filename,
)

_INVALID_FILENAME_CHARS = '/\\:*?"<>|'


def test_basic_export_generates_html_png_and_metadata(tmp_path: Path) -> None:
    function = SymbolicFunction("x**2")
    result = export_function_report_bundle(
        function,
        FunctionReportBundleOptions(output_dir=str(tmp_path)),
    )

    assert result.case in ("success", "partial")
    assert result.plot_result is not None
    assert result.html_result is not None
    assert result.metadata_path is not None

    html_path = Path(result.html_result.output_path or "")
    plot_path = tmp_path / f"{sanitize_filename(str(function.expr))}_plot.png"
    metadata_path = Path(result.metadata_path)

    assert html_path.exists() and html_path.stat().st_size > 0
    assert plot_path.exists() and plot_path.stat().st_size > 0
    assert metadata_path.exists() and metadata_path.stat().st_size > 0


def test_export_with_markdown(tmp_path: Path) -> None:
    result = export_function_report_bundle(
        SymbolicFunction("x**2"),
        FunctionReportBundleOptions(
            output_dir=str(tmp_path),
            include_markdown=True,
        ),
    )

    assert result.markdown_path is not None
    markdown = Path(result.markdown_path).read_text(encoding="utf-8")
    assert "Relatório de Análise de Função" in markdown


def test_export_without_plot(tmp_path: Path) -> None:
    result = export_function_report_bundle(
        SymbolicFunction("x**2"),
        FunctionReportBundleOptions(
            output_dir=str(tmp_path),
            include_plot=False,
        ),
    )

    assert result.plot_result is None
    assert result.html_result is not None
    assert result.html_result.output_path is not None
    assert Path(result.html_result.output_path).exists()

    metadata = json.loads(Path(result.metadata_path).read_text(encoding="utf-8"))
    assert metadata["include_plot"] is False
    assert metadata["plot_generated"] is False


def test_export_without_html(tmp_path: Path) -> None:
    result = export_function_report_bundle(
        SymbolicFunction("x**2"),
        FunctionReportBundleOptions(
            output_dir=str(tmp_path),
            include_html=False,
        ),
    )

    assert result.html_result is None
    assert result.plot_result is not None
    assert result.metadata_path is not None
    assert not any(path.endswith(".html") for path in result.generated_files)


def test_sanitize_filename_rational_expression() -> None:
    sanitized = sanitize_filename("(x + 1)/(x - 2)")

    assert sanitized
    assert not any(character in sanitized for character in _INVALID_FILENAME_CHARS)


def test_symbolic_function_export_report_bundle_method(tmp_path: Path) -> None:
    result = SymbolicFunction("x**2").export_report_bundle(
        output_dir=str(tmp_path),
        base_filename="quadratic",
    )

    assert result.case in ("success", "partial")
    assert (tmp_path / "quadratic_plot.png").exists()
    assert (tmp_path / "quadratic_report.html").exists()
    assert (tmp_path / "quadratic_metadata.json").exists()


def test_invalid_theme_does_not_break_export(tmp_path: Path) -> None:
    result = export_function_report_bundle(
        SymbolicFunction("x**2"),
        FunctionReportBundleOptions(
            output_dir=str(tmp_path),
            theme="unknown_theme_name",
        ),
    )

    assert result.case in ("success", "partial", "failed")
    assert any("desconhecido" in warning for warning in result.warnings)
    assert result.metadata_path is not None
