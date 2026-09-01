"""Renderização de relatórios de funções para HTML standalone."""

from __future__ import annotations

import base64
import html
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from analyticmath.functions.report import FunctionAnalysisReport, FunctionReportSection

from analyticmath.reports.visual_tokens import css_variables_for_theme, resolve_visual_theme


@dataclass(frozen=True)
class HtmlRenderOptions:
    """Opções de renderização HTML para relatórios de função."""

    title: str | None = None
    include_plot: bool = True
    plot_path: str | None = None
    embed_plot_base64: bool = True
    theme: str = "xp_violet_classic"
    include_raw_markdown: bool = False


@dataclass
class HtmlRenderResult:
    """Resultado da renderização HTML de um relatório."""

    report: FunctionAnalysisReport
    html: str
    output_path: str | None
    warnings: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    case: str = "failed"


def escape_html(text: str) -> str:
    """Escapa caracteres especiais para uso seguro em HTML."""
    return html.escape(text, quote=True)


def image_to_base64(path: str) -> str:
    """Lê um arquivo PNG e retorna string base64."""
    data = Path(path).read_bytes()
    return base64.b64encode(data).decode("ascii")


def render_function_report_html(
    report: FunctionAnalysisReport,
    output_path: str | None = None,
    options: HtmlRenderOptions | None = None,
) -> HtmlRenderResult:
    """Gera HTML standalone a partir de ``report``."""
    render_options = options or HtmlRenderOptions()
    warnings: list[str] = list(report.warnings)
    errors: list[str] = list(report.errors)

    plot_html = ""
    if render_options.include_plot and render_options.plot_path:
        plot_html, plot_warnings = _build_plot_html(render_options)
        warnings.extend(plot_warnings)
    elif render_options.include_plot and not render_options.plot_path:
        warnings.append("plot_path não fornecido; relatório gerado sem gráfico.")

    title = render_options.title or report.title
    index_html = _render_section_index(report.sections)
    sections_html = _render_sections(report, render_options)
    warnings_html = _render_message_block("Avisos", warnings, "warnings")
    errors_html = _render_message_block("Erros", errors, "errors")

    document = _build_html_document(
        title=title,
        function_text=f"f({report.function.variable}) = {report.function.expr}",
        summary=report.summary,
        case=report.case,
        warnings_html=warnings_html,
        errors_html=errors_html,
        plot_html=plot_html,
        index_html=index_html,
        sections_html=sections_html,
        theme=render_options.theme,
    )

    result = HtmlRenderResult(
        report=report,
        html=document,
        output_path=output_path,
        warnings=warnings,
        errors=errors,
        case=_resolve_render_case(errors, warnings, report.warnings, report.errors),
    )

    if output_path:
        try:
            output = Path(output_path)
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(document, encoding="utf-8")
        except OSError as exc:
            errors.append(f"Falha ao salvar HTML: {exc}")
            result.errors = errors
            result.case = "failed"

    return result


def _build_plot_html(options: HtmlRenderOptions) -> tuple[str, list[str]]:
    warnings: list[str] = []
    plot_path = options.plot_path
    if plot_path is None:
        return "", warnings

    path = Path(plot_path)
    if not path.exists() or not path.is_file():
        warnings.append(f"plot_path inválido ou inexistente: {plot_path}")
        return "", warnings

    if path.stat().st_size == 0:
        warnings.append(f"plot_path vazio: {plot_path}")
        return "", warnings

    try:
        if options.embed_plot_base64:
            encoded = image_to_base64(str(path))
            src = f"data:image/png;base64,{encoded}"
        else:
            src = escape_html(str(path))
    except OSError as exc:
        warnings.append(f"Falha ao ler plot_path: {exc}")
        return "", warnings

    plot_html = (
        '<section class="graph-window xp-panel app-window">'
        '<div class="xp-titlebar graph-titlebar"><span>Graph View</span></div>'
        '<div class="graph-body xp-inset">'
        '<p class="plot-caption">'
        "Curve plot with roots, asymptotes, critical points, inflection points "
        "and removable discontinuities when available."
        "</p>"
        '<div class="plot-frame xp-bevel">'
        f'<img class="report-plot" src="{src}" alt="Gráfico anotado da função analisada" />'
        "</div>"
        "</div>"
        "</section>"
    )
    return plot_html, warnings


def _render_section_index(sections: list[FunctionReportSection]) -> str:
    links: list[str] = []
    for section in sections:
        anchor = _section_anchor_id(section.title)
        label = _section_index_label(section.title)
        links.append(
            f'<a class="index-link xp-button" href="#{anchor}">{escape_html(label)}</a>'
        )

    if not links:
        return ""

    return (
        '<nav class="report-index xp-toolbar xp-panel" aria-label="Índice do relatório">'
        '<div class="xp-titlebar"><span>Navigation Toolbar</span></div>'
        f'<div class="index-links xp-inset">{"".join(links)}</div>'
        "</nav>"
    )


def _render_sections(report: FunctionAnalysisReport, options: HtmlRenderOptions) -> str:
    blocks: list[str] = []
    for section in report.sections:
        status = _normalize_status(section.status)
        anchor = _section_anchor_id(section.title)
        title = escape_html(section.title)
        content_html = _render_section_content(section)
        raw_block = ""
        if options.include_raw_markdown:
            raw_block = (
                f'<details class="raw-markdown"><summary>Conteúdo bruto</summary>'
                f'<pre class="math-content">{escape_html(section.content)}</pre></details>'
            )

        status_label = _status_label(status)
        blocks.append(
            f'<section id="{anchor}" class="report-section xp-panel app-window status-{status}">'
            f'<div class="section-titlebar xp-titlebar">'
            f'<span class="section-title">{title}</span>'
            f'<span class="status-badge led-badge status-{status}">{status_label}</span>'
            f"</div>"
            f'<div class="section-body xp-inset">{content_html}</div>'
            f"{raw_block}"
            "</section>"
        )
    return "\n".join(blocks)


def _render_section_content(section: FunctionReportSection) -> str:
    title = section.title
    content = section.content

    if "Inequações básicas" in title:
        table_html = _try_render_inequalities_table(content)
        if table_html is not None:
            return table_html

    if "Tabela de sinais" in title:
        escaped = escape_html(content)
        return f'<div class="sign-table-block math-content"><pre>{escaped}</pre></div>'

    escaped = escape_html(content)
    body_class = "prose-content" if "Conclusão" in title else "math-content"
    tag = "p" if body_class == "prose-content" else "pre"
    return f'<div class="{body_class}"><{tag}>{escaped}</{tag}></div>'


def _try_render_inequalities_table(content: str) -> str | None:
    rows: list[tuple[str, str]] = []
    blocks = [block.strip() for block in content.split("\n\n") if block.strip()]

    for block in blocks:
        lines = block.splitlines()
        if not lines:
            return None

        header = lines[0].strip()
        if not header.endswith(":") or "f(" not in header:
            return None

        inequality = header[:-1].strip()
        solution = "\n".join(lines[1:]).strip() or "∅"
        rows.append((inequality, solution))

    if not rows:
        return None

    body_rows = "".join(
        "<tr>"
        f"<th scope=\"row\">{escape_html(left)}</th>"
        f"<td>{escape_html(right)}</td>"
        "</tr>"
        for left, right in rows
    )
    return (
        '<div class="inequalities-table-block">'
        '<table class="inequalities-table xp-grid">'
        "<thead><tr><th>Inequação</th><th>Solução</th></tr></thead>"
        f"<tbody>{body_rows}</tbody>"
        "</table>"
        "</div>"
    )


def _section_anchor_id(title: str) -> str:
    slug = title.lower()
    slug = re.sub(r"^\d+\.\s*", "", slug)
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = slug.strip("-")
    number_match = re.match(r"^(\d+)\.", title.strip())
    prefix = f"section-{number_match.group(1)}" if number_match else "section"
    return f"{prefix}-{slug}" if slug else prefix


def _section_index_label(title: str) -> str:
    match = re.match(r"^(\d+)\.\s*(.+)$", title.strip())
    if not match:
        return title.strip()

    number = match.group(1)
    rest = match.group(2)
    short_names = {
        "Definição da função": "Definição",
        "Domínio real": "Domínio",
        "Raízes e interceptos": "Raízes",
        "Limites principais": "Limites",
        "Continuidade": "Continuidade",
        "Assíntotas": "Assíntotas",
        "Tabela de sinais": "Sinais",
        "Inequações básicas": "Inequações",
        "Derivadas": "Derivadas",
        "Monotonicidade e pontos críticos": "Monotonicidade",
        "Concavidade e pontos de inflexão": "Concavidade",
        "Conclusão geométrica": "Conclusão",
    }
    short = short_names.get(rest, rest.split(" e ")[0].split(" ")[0])
    return f"{number}. {short}"


def _render_message_block(label: str, messages: list[str], css_class: str) -> str:
    if not messages:
        return ""
    items = "".join(f"<li>{escape_html(message)}</li>" for message in messages)
    return (
        f'<section class="report-messages xp-panel app-window {css_class}">'
        f'<div class="section-titlebar xp-titlebar"><span>{escape_html(label)}</span></div>'
        f'<div class="section-body xp-inset"><ul>{items}</ul></div>'
        "</section>"
    )


def _status_label(status: str) -> str:
    labels = {
        "ok": "OK",
        "warning": "WARNING",
        "error": "ERROR",
        "unknown": "UNKNOWN",
        "skipped": "SKIPPED",
    }
    return labels.get(status, status.upper())


def _resolve_html_theme(theme: str) -> str:
    visual = resolve_visual_theme(theme)
    return visual.name


def _normalize_report_case(case: str) -> str:
    mapping = {
        "complete": "ok",
        "partial": "warning",
        "failed": "error",
        "success": "ok",
    }
    if case in mapping:
        return mapping[case]
    return _normalize_status(case)


def _normalize_status(status: str) -> str:
    allowed = {"ok", "warning", "error", "skipped", "unknown"}
    if status in allowed:
        return status
    return "unknown"


def _resolve_render_case(
    errors: list[str],
    warnings: list[str],
    report_warnings: list[str],
    report_errors: list[str],
) -> str:
    if errors:
        return "failed"
    if warnings or report_warnings or report_errors:
        return "partial"
    return "success"


def _build_html_document(
    *,
    title: str,
    function_text: str,
    summary: str,
    case: str,
    warnings_html: str,
    errors_html: str,
    plot_html: str,
    index_html: str,
    sections_html: str,
    theme: str,
) -> str:
    css = _theme_css(_resolve_html_theme(theme))
    safe_title = escape_html(title)
    safe_function = escape_html(function_text)
    safe_summary = escape_html(summary)
    safe_case = escape_html(case)
    status_class = _normalize_report_case(case)
    case_label = _status_label(status_class)

    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{safe_title}</title>
  <style>
{css}
  </style>
</head>
<body class="theme-{escape_html(_resolve_html_theme(theme))}">
  <div class="page-shell">
    <header class="report-hero app-window xp-panel">
      <div class="xp-titlebar hero-titlebar"><span>ANALYTICMATH LAB</span></div>
      <div class="hero-body xp-inset">
        <h1>{safe_title}</h1>
        <p class="function-subtitle">{safe_function}</p>
        <div class="hero-status">
          <span class="status-badge led-badge status-{status_class}">{case_label}: {safe_case}</span>
        </div>
        <p class="hero-generated">Generated by AnalyticMath Lab</p>
      </div>
    </header>

    <section class="report-summary xp-panel app-window">
      <div class="section-titlebar xp-titlebar"><span>Summary</span></div>
      <div class="section-body xp-inset prose-content"><p>{safe_summary}</p></div>
    </section>

    {index_html}
    {warnings_html}
    {errors_html}
    {plot_html}
    {sections_html}

    <footer class="report-footer">
      Generated by AnalyticMath Lab — XP Violet Classic
    </footer>
  </div>
</body>
</html>
"""


def _theme_css(theme_name: str) -> str:
    visual = resolve_visual_theme(theme_name)
    variables = css_variables_for_theme(visual)
    rules = _theme_css_rules()
    return f"{variables}\n{rules}"


def _theme_css_rules() -> str:
    return """

body {
  margin: 0;
  min-height: 100vh;
  font-family: Tahoma, "Segoe UI", Verdana, Arial, sans-serif;
  font-size: 13px;
  color: var(--text-main);
  background: linear-gradient(180deg, var(--bg-0) 0%, var(--bg-1) 45%, var(--bg-2) 100%);
}

.page-shell {
  max-width: 1160px;
  margin: 0 auto;
  padding: 24px 16px 40px;
}

.app-window,
.xp-panel {
  border: 2px solid var(--bevel-light);
  border-right-color: var(--bevel-dark);
  border-bottom-color: var(--bevel-dark);
  border-radius: 6px;
  background: var(--panel);
  box-shadow: 2px 2px 0 rgba(0, 0, 0, 0.55), inset 0 0 0 1px rgba(255, 255, 255, 0.04);
  margin-bottom: 18px;
  overflow: hidden;
}

.xp-titlebar,
.section-titlebar,
.hero-titlebar,
.graph-titlebar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 5px 10px;
  background: var(--titlebar);
  color: var(--titlebar-text);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  border-bottom: 1px solid var(--titlebar-end);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18);
}

.hero-titlebar span,
.graph-titlebar span,
.section-titlebar .section-title {
  text-shadow: 1px 1px 0 rgba(0, 0, 0, 0.45);
}

.xp-inset,
.section-body,
.hero-body,
.graph-body {
  background: var(--panel-inset);
  padding: 12px 14px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  box-shadow: inset 1px 1px 0 rgba(0, 0, 0, 0.35), inset -1px -1px 0 rgba(157, 140, 255, 0.08);
}

.report-hero h1 {
  margin: 0 0 10px;
  font-size: 1.35rem;
  line-height: 1.25;
  color: var(--hero-title);
  font-weight: 700;
}

.function-subtitle {
  margin: 0 0 12px;
  font-family: Consolas, "Lucida Console", monospace;
  font-size: 13px;
  color: var(--function-subtitle);
  word-break: break-word;
}

.hero-generated,
.report-footer {
  margin: 10px 0 0;
  color: var(--text-muted);
  font-size: 11px;
  letter-spacing: 0.03em;
}

.report-footer {
  text-align: center;
  padding-top: 6px;
}

.hero-status {
  margin-top: 4px;
}

.xp-toolbar .index-links {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.xp-button,
.index-link {
  display: inline-block;
  padding: 4px 10px;
  border: 1px solid var(--bevel-light);
  border-right-color: var(--bevel-dark);
  border-bottom-color: var(--bevel-dark);
  border-radius: 3px;
  background: linear-gradient(180deg, var(--button-start) 0%, var(--button-end) 100%);
  color: var(--titlebar-text);
  text-decoration: none;
  font-size: 11px;
  font-family: Tahoma, "Segoe UI", Verdana, sans-serif;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.12);
}

.xp-button:hover,
.index-link:hover {
  background: linear-gradient(180deg, var(--button-hover-start) 0%, var(--button-hover-end) 100%);
  color: #ffffff;
}

.led-badge,
.status-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.06em;
  border: 1px solid rgba(0, 0, 0, 0.45);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18), inset 0 -1px 0 rgba(0, 0, 0, 0.25);
  flex-shrink: 0;
}

.status-ok {
  color: #062a14;
  background: linear-gradient(180deg, #7dffb0 0%, var(--ok) 100%);
}

.status-warning {
  color: #4a3200;
  background: linear-gradient(180deg, #ffe08a 0%, var(--warning) 100%);
}

.status-error {
  color: #4a0010;
  background: linear-gradient(180deg, #ff9db0 0%, var(--error) 100%);
}

.status-unknown {
  color: #2a1048;
  background: linear-gradient(180deg, #d7b8ff 0%, var(--unknown) 100%);
}

.status-skipped {
  color: #1f2937;
  background: linear-gradient(180deg, #cbd5e1 0%, var(--skipped) 100%);
}

.section-titlebar {
  padding-left: 10px;
  padding-right: 8px;
}

.section-title {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: none;
  color: var(--titlebar-text);
}

.math-content pre,
.sign-table-block pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  overflow-wrap: anywhere;
  font-family: Consolas, "Lucida Console", monospace;
  font-size: 12px;
  line-height: 1.45;
  color: var(--text-main);
}

.prose-content p {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  overflow-wrap: anywhere;
  line-height: 1.55;
  font-family: Tahoma, "Segoe UI", Verdana, sans-serif;
}

.sign-table-block {
  padding: 8px;
  border: 1px solid rgba(157, 140, 255, 0.22);
  background: rgba(0, 0, 0, 0.18);
}

.plot-caption {
  margin: 0 0 10px;
  color: var(--text-muted);
  font-size: 11px;
  line-height: 1.45;
  text-align: left;
}

.plot-frame {
  display: flex;
  justify-content: center;
}

.xp-bevel {
  padding: 6px;
  border: 2px solid var(--bevel-light);
  border-right-color: var(--bevel-dark);
  border-bottom-color: var(--bevel-dark);
  background: var(--graph-frame-bg);
  box-shadow: inset 1px 1px 0 rgba(0, 0, 0, 0.45);
}

.report-plot {
  max-width: 100%;
  height: auto;
  display: block;
}

.inequalities-table-block {
  overflow-x: auto;
}

.inequalities-table,
.xp-grid {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}

.inequalities-table thead th {
  padding: 7px 10px;
  text-align: left;
  color: var(--titlebar-text);
  font-size: 11px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  background: linear-gradient(180deg, var(--table-header-start) 0%, var(--table-header-end) 100%);
  border: 1px solid var(--table-border);
}

.inequalities-table th,
.inequalities-table td {
  padding: 7px 10px;
  border: 1px solid var(--table-cell-border);
  vertical-align: top;
  word-break: break-word;
}

.inequalities-table tbody tr:nth-child(even) {
  background: rgba(255, 255, 255, 0.03);
}

.inequalities-table tbody tr:hover {
  background: var(--table-row-hover);
}

.inequalities-table tbody th {
  font-family: Consolas, "Lucida Console", monospace;
  color: var(--function-subtitle);
  white-space: nowrap;
}

.inequalities-table tbody td {
  font-family: Consolas, "Lucida Console", monospace;
}

.report-messages ul {
  margin: 0;
  padding-left: 18px;
}

.raw-markdown {
  margin-top: 10px;
  color: var(--text-muted);
  font-size: 11px;
}

@media (max-width: 720px) {
  .page-shell {
    padding: 14px 10px 28px;
  }

  .section-titlebar {
    flex-direction: column;
    align-items: flex-start;
  }

  .xp-toolbar .index-links {
    gap: 4px;
  }
}
"""
