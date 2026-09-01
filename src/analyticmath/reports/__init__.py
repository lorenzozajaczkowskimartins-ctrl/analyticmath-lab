"""Geração e exportação de relatórios matemáticos (HTML, PDF, LaTeX, gráficos)."""

from analyticmath.reports.export_bundle import (
    FunctionReportBundleOptions,
    FunctionReportBundleResult,
    export_function_report_bundle,
    sanitize_filename,
)
from analyticmath.reports.html_renderer import (
    HtmlRenderOptions,
    HtmlRenderResult,
    escape_html,
    image_to_base64,
    render_function_report_html,
)
from analyticmath.reports.plot_builder import (
    FunctionPlotResult,
    PlotWindow,
    PLOT_THEME,
    PLOT_THEMES,
    auto_scale_y,
    build_function_plot,
    deduplicate_legend,
    resolve_plot_theme,
)
from analyticmath.reports.visual_tokens import (
    VISUAL_THEMES,
    VisualTheme,
    resolve_visual_theme,
)

__all__ = [
    "PlotWindow",
    "FunctionPlotResult",
    "PLOT_THEME",
    "PLOT_THEMES",
    "auto_scale_y",
    "build_function_plot",
    "deduplicate_legend",
    "resolve_plot_theme",
    "VisualTheme",
    "VISUAL_THEMES",
    "resolve_visual_theme",
    "FunctionReportBundleOptions",
    "FunctionReportBundleResult",
    "export_function_report_bundle",
    "sanitize_filename",
    "HtmlRenderOptions",
    "HtmlRenderResult",
    "escape_html",
    "image_to_base64",
    "render_function_report_html",
]
