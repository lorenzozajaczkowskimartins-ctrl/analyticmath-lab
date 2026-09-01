"""Testes do renderizador HTML de relatórios."""

from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt

from analyticmath.functions import SymbolicFunction
from analyticmath.reports import HtmlRenderOptions, build_function_plot, render_function_report_html
from analyticmath.reports.html_renderer import escape_html


def _close_plot(result) -> None:
    if result.figure is not None:
        plt.close(result.figure)


def test_render_quadratic_html_string() -> None:
    function = SymbolicFunction("x**2")
    report = function.report(context=function.full_analysis())
    result = render_function_report_html(
        report,
        options=HtmlRenderOptions(include_plot=False),
    )

    assert result.case in ("success", "partial")
    assert result.html
    assert "<html" in result.html.lower()
    assert "Relatório" in result.html
    assert "x**2" in result.html
    assert "report-section" in result.html
    assert "report-index" in result.html
    assert "xp-titlebar" in result.html
    assert "xp-panel" in result.html
    assert 'href="#section-' in result.html


def test_render_html_saves_file(tmp_path: Path) -> None:
    report = SymbolicFunction("x**2").report()
    output_path = tmp_path / "report.html"
    result = render_function_report_html(
        report,
        output_path=str(output_path),
        options=HtmlRenderOptions(include_plot=False),
    )

    assert result.output_path == str(output_path)
    assert output_path.exists()
    assert output_path.stat().st_size > 0


def test_render_html_embeds_plot_base64(tmp_path: Path) -> None:
    function = SymbolicFunction("x**2")
    plot_path = tmp_path / "plot.png"
    plot_result = build_function_plot(function, output_path=str(plot_path))
    assert plot_path.exists()

    report = function.report()
    html_result = render_function_report_html(
        report,
        options=HtmlRenderOptions(
            include_plot=True,
            plot_path=str(plot_path),
            embed_plot_base64=True,
        ),
    )

    assert "data:image/png;base64," in html_result.html
    assert "graph-window" in html_result.html
    assert "Graph View" in html_result.html
    _close_plot(plot_result)


def test_escape_html_special_characters() -> None:
    assert escape_html("<tag> & \"quote\"") == "&lt;tag&gt; &amp; &quot;quote&quot;"


def test_render_html_contains_status_classes() -> None:
    report = SymbolicFunction("x**2").report()
    html = render_function_report_html(
        report,
        options=HtmlRenderOptions(include_plot=False),
    ).html

    assert "status-badge" in html
    assert "status-ok" in html or "status-warning" in html


def test_render_html_contains_inequalities_table() -> None:
    report = SymbolicFunction("(x + 1)/(x - 2)").report(context=SymbolicFunction("(x + 1)/(x - 2)").full_analysis())
    html = render_function_report_html(
        report,
        options=HtmlRenderOptions(include_plot=False),
    ).html

    assert "inequalities-table" in html or "inequalities-table-block" in html


def test_render_html_xp_classic_theme_classes() -> None:
    html = render_function_report_html(
        SymbolicFunction("x**2").report(),
        options=HtmlRenderOptions(include_plot=False, theme="xp_violet_classic"),
    ).html

    assert "theme-xp_violet_classic" in html
    assert "xp-titlebar" in html
    assert "led-badge" in html


def test_render_html_xp_violet_dark_alias() -> None:
    html = render_function_report_html(
        SymbolicFunction("x**2").report(),
        options=HtmlRenderOptions(include_plot=False, theme="xp_violet_dark"),
    ).html

    assert "xp-panel" in html
    assert "section-titlebar" in html


def test_invalid_plot_path_adds_warning() -> None:
    report = SymbolicFunction("x**2").report()
    result = render_function_report_html(
        report,
        options=HtmlRenderOptions(
            include_plot=True,
            plot_path="examples/output/does_not_exist.png",
            embed_plot_base64=True,
        ),
    )

    assert result.case in ("partial", "success")
    assert any("plot_path" in warning for warning in result.warnings)
    assert "data:image/png;base64," not in result.html
