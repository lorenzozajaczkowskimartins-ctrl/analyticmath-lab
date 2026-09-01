"""Exportação integrada de pacotes de relatório de funções."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING, Any

from analyticmath.functions.report import format_function_report
from analyticmath.reports.html_renderer import HtmlRenderOptions, HtmlRenderResult, render_function_report_html
from analyticmath.reports.plot_builder import FunctionPlotResult, PlotWindow, build_function_plot
from analyticmath.reports.visual_tokens import resolve_visual_theme

if TYPE_CHECKING:
    from analyticmath.functions.analysis_context import FunctionAnalysisContext
    from analyticmath.functions.report import FunctionAnalysisReport
    from analyticmath.functions.symbolic_function import SymbolicFunction

_WINDOWS_INVALID_CHARS = '<>:"/\\|?*'
_FILENAME_FALLBACK = "function_report"


@dataclass(frozen=True)
class FunctionReportBundleOptions:
    """Opções para exportação de pacote completo de relatório."""

    output_dir: str
    base_filename: str | None = None
    include_plot: bool = True
    include_html: bool = True
    include_markdown: bool = False
    embed_plot_base64: bool = True
    theme: str = "xp_violet_classic"
    plot_window: PlotWindow | None = None
    html_options: HtmlRenderOptions | None = None


@dataclass
class FunctionReportBundleResult:
    """Resultado da exportação de pacote completo."""

    function: SymbolicFunction
    context: FunctionAnalysisContext
    report: FunctionAnalysisReport
    plot_result: FunctionPlotResult | None
    html_result: HtmlRenderResult | None
    markdown_path: str | None
    metadata_path: str | None
    output_dir: str
    generated_files: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    case: str = "failed"


def sanitize_filename(text: str) -> str:
    """Sanitiza texto para uso seguro como nome de arquivo no Windows."""
    value = text.strip().lower()
    if not value:
        return _FILENAME_FALLBACK

    value = value.replace("**", "pow")
    for old, new in (("+", "plus"), ("-", "minus"), ("*", "mul"), ("/", "over")):
        value = value.replace(old, new)

    value = value.replace("(", "_").replace(")", "_")

    for character in _WINDOWS_INVALID_CHARS:
        value = value.replace(character, "_")

    value = re.sub(r"[^a-z0-9_]+", "_", value)
    value = re.sub(r"_+", "_", value).strip("_")

    if not value:
        return _FILENAME_FALLBACK

    if len(value) > 80:
        value = value[:80].rstrip("_")

    return value or _FILENAME_FALLBACK


def write_text_file(path: str | Path, content: str) -> None:
    """Escreve conteúdo textual em UTF-8."""
    Path(path).write_text(content, encoding="utf-8")


def write_json_file(path: str | Path, data: Any) -> None:
    """Escreve dados JSON com suporte a objetos não nativos via ``str``."""
    Path(path).write_text(
        json.dumps(data, indent=2, ensure_ascii=False, default=str),
        encoding="utf-8",
    )


def export_function_report_bundle(
    function: SymbolicFunction,
    options: FunctionReportBundleOptions,
) -> FunctionReportBundleResult:
    """Exporta pacote completo: análise, gráfico, HTML, Markdown e metadata."""
    warnings: list[str] = []
    errors: list[str] = []
    generated_files: list[str] = []

    output_dir = Path(options.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    resolve_visual_theme(options.theme, warnings)

    if options.base_filename:
        base_filename = sanitize_filename(options.base_filename)
    else:
        base_filename = sanitize_filename(str(function.expr))

    context = function.full_analysis()
    report = function.report(context=context)
    warnings.extend(context.warnings)

    plot_result: FunctionPlotResult | None = None
    html_result: HtmlRenderResult | None = None
    plot_path: Path | None = None
    markdown_path: str | None = None
    metadata_path: str | None = None

    if options.include_plot:
        plot_path = output_dir / f"{base_filename}_plot.png"
        try:
            plot_result = build_function_plot(
                function,
                context=context,
                window=options.plot_window,
                output_path=str(plot_path),
                theme=options.theme,
            )
            warnings.extend(plot_result.warnings)
            errors.extend(plot_result.errors)
            _close_plot_figure(plot_result)
            if plot_path.exists() and plot_path.stat().st_size > 0:
                generated_files.append(str(plot_path))
            else:
                warnings.append("Plot solicitado, mas arquivo PNG não foi gerado.")
                plot_path = None
        except Exception as exc:
            errors.append(f"plot: {exc}")
            plot_path = None
            plot_result = None

    if options.include_html:
        html_path = output_dir / f"{base_filename}_report.html"
        try:
            html_options = _build_html_options(options, plot_path)
            html_result = render_function_report_html(
                report,
                output_path=str(html_path),
                options=html_options,
            )
            warnings.extend(html_result.warnings)
            errors.extend(html_result.errors)
            if html_path.exists() and html_path.stat().st_size > 0:
                generated_files.append(str(html_path))
        except Exception as exc:
            errors.append(f"html: {exc}")
            html_result = None

    if options.include_markdown:
        markdown_file = output_dir / f"{base_filename}_report.md"
        try:
            write_text_file(markdown_file, format_function_report(report))
            markdown_path = str(markdown_file)
            generated_files.append(markdown_path)
        except Exception as exc:
            errors.append(f"markdown: {exc}")
            markdown_path = None

    metadata_file = output_dir / f"{base_filename}_metadata.json"
    try:
        metadata_path_str = str(metadata_file)
        metadata = _build_metadata(
            function=function,
            context=context,
            report=report,
            options=options,
            generated_files=[*generated_files, metadata_path_str],
            warnings=warnings,
            errors=errors,
            plot_result=plot_result,
            html_result=html_result,
            plot_generated=plot_path is not None and str(plot_path) in generated_files,
            html_generated=html_result is not None
            and html_result.output_path is not None
            and html_result.output_path in generated_files,
        )
        write_json_file(metadata_file, metadata)
        metadata_path = metadata_path_str
        generated_files.append(metadata_path)
    except Exception as exc:
        errors.append(f"metadata: {exc}")
        metadata_path = None

    bundle_case = _resolve_bundle_case(
        generated_files=generated_files,
        warnings=warnings,
        errors=errors,
    )

    return FunctionReportBundleResult(
        function=function,
        context=context,
        report=report,
        plot_result=plot_result,
        html_result=html_result,
        markdown_path=markdown_path,
        metadata_path=metadata_path,
        output_dir=str(output_dir),
        generated_files=generated_files,
        warnings=warnings,
        errors=errors,
        case=bundle_case,
    )


def _build_html_options(
    options: FunctionReportBundleOptions,
    plot_path: Path | None,
) -> HtmlRenderOptions:
    base = options.html_options
    plot_file = str(plot_path) if plot_path is not None and plot_path.exists() else None
    include_plot = options.include_plot and plot_file is not None

    if base is None:
        return HtmlRenderOptions(
            include_plot=include_plot,
            plot_path=plot_file,
            embed_plot_base64=options.embed_plot_base64,
            theme=options.theme,
        )

    return HtmlRenderOptions(
        title=base.title,
        include_plot=include_plot,
        plot_path=plot_file if include_plot else None,
        embed_plot_base64=options.embed_plot_base64,
        theme=options.theme,
        include_raw_markdown=base.include_raw_markdown,
    )


def _build_metadata(
    *,
    function: SymbolicFunction,
    context: FunctionAnalysisContext,
    report: FunctionAnalysisReport,
    options: FunctionReportBundleOptions,
    generated_files: list[str],
    warnings: list[str],
    errors: list[str],
    plot_result: FunctionPlotResult | None,
    html_result: HtmlRenderResult | None,
    plot_generated: bool,
    html_generated: bool,
) -> dict[str, Any]:
    domain_text = _safe_context_value(context, "domain", lambda result: str(result.domain))
    real_roots = _safe_context_value(
        context,
        "roots",
        lambda result: [str(root) for root in result.real_roots],
        default=[],
    )
    vertical_asymptotes = _extract_vertical_asymptotes(context)
    horizontal_asymptotes = _extract_horizontal_asymptotes(context)
    oblique_asymptotes = _extract_oblique_asymptotes(context)

    bundle_case = _resolve_bundle_case(
        generated_files=generated_files,
        warnings=warnings,
        errors=errors,
    )

    return {
        "expression": str(function.expr),
        "variable": function.variable,
        "theme": options.theme,
        "report_case": report.case,
        "plot_case": plot_result.case if plot_result is not None else ("skipped" if not options.include_plot else "failed"),
        "html_case": html_result.case if html_result is not None else ("skipped" if not options.include_html else "failed"),
        "bundle_case": bundle_case,
        "generated_files": list(generated_files),
        "warnings": list(warnings),
        "errors": list(errors),
        "include_plot": options.include_plot,
        "include_html": options.include_html,
        "include_markdown": options.include_markdown,
        "plot_generated": plot_generated,
        "html_generated": html_generated,
        "domain": domain_text,
        "real_roots": real_roots,
        "vertical_asymptotes": vertical_asymptotes,
        "horizontal_asymptotes": horizontal_asymptotes,
        "oblique_asymptotes": oblique_asymptotes,
    }


def _safe_context_value(
    context: FunctionAnalysisContext,
    label: str,
    extractor: Any,
    default: Any = None,
) -> Any:
    try:
        getter = getattr(context, label)
        result = getter()
        if result is None:
            return default
        return extractor(result)
    except Exception:
        return default


def _extract_vertical_asymptotes(context: FunctionAnalysisContext) -> list[str]:
    asymptotes = context.asymptotes()
    if asymptotes is None:
        return []
    return [str(item.x) for item in asymptotes.vertical_asymptotes if item.exists]


def _extract_horizontal_asymptotes(context: FunctionAnalysisContext) -> list[str]:
    asymptotes = context.asymptotes()
    if asymptotes is None:
        return []
    return [
        f"y = {item.y} when x -> {item.direction}"
        for item in asymptotes.horizontal_asymptotes
        if item.exists
    ]


def _extract_oblique_asymptotes(context: FunctionAnalysisContext) -> list[str]:
    asymptotes = context.asymptotes()
    if asymptotes is None:
        return []
    return [
        f"y = {item.expression} when x -> {item.direction}"
        for item in asymptotes.oblique_asymptotes
        if item.exists
    ]


def _resolve_bundle_case(
    *,
    generated_files: list[str],
    warnings: list[str],
    errors: list[str],
) -> str:
    if not generated_files:
        return "failed"
    if errors:
        return "partial"
    if warnings:
        return "partial"
    return "success"


def _close_plot_figure(plot_result: FunctionPlotResult | None) -> None:
    if plot_result is None or plot_result.figure is None:
        return
    try:
        import matplotlib.pyplot as plt

        plt.close(plot_result.figure)
    except Exception:
        pass
