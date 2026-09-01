"""Tokens visuais oficiais do AnalyticMath Lab."""

from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Any

DEFAULT_THEME_NAME = "xp_violet_classic"

_VISUAL_ALIASES = {
    "xp_violet_dark": "xp_violet_classic",
}


@dataclass(frozen=True)
class VisualTheme:
    """Paleta e tokens visuais compartilhados entre HTML e gráficos."""

    name: str
    display_name: str
    background: str
    desktop_gradient_start: str
    desktop_gradient_mid: str
    desktop_gradient_end: str
    panel_background: str
    panel_background_alt: str
    panel_border_light: str
    panel_border_dark: str
    titlebar_start: str
    titlebar_end: str
    title_text: str
    body_text: str
    muted_text: str
    accent_violet: str
    accent_blue: str
    accent_cyan: str
    accent_green: str
    accent_yellow: str
    accent_red: str
    accent_pink: str
    grid_color: str
    axis_color: str
    curve_color: str | None
    branch_alt_color: str | None
    root_color: str | None
    vertical_asymptote_color: str | None
    horizontal_asymptote_color: str | None
    oblique_asymptote_color: str | None
    critical_point_color: str | None
    inflection_color: str | None
    legend_facecolor: str
    legend_edgecolor: str

    def to_plot_config(self, *, requested_name: str | None = None) -> dict[str, Any]:
        """Converte tokens visuais em configuração usada pelo plot builder."""
        name = requested_name or self.name
        is_default = name == "default" or self.name == "default"

        return {
            "name": name,
            "title_prefix": "AnalyticMath Lab",
            "grid": True,
            "figure_facecolor": self.desktop_gradient_mid if not is_default else "white",
            "axes_facecolor": self.panel_background_alt if not is_default else "white",
            "text_color": self.body_text if not is_default else "black",
            "grid_color": self.grid_color if not is_default else "#b0b0b0",
            "grid_alpha": 0.32 if not is_default else 0.35,
            "axis_color": self.axis_color if not is_default else "black",
            "curve_color": self.curve_color,
            "branch_alt_color": self.branch_alt_color,
            "root_color": self.root_color,
            "critical_point_color": self.critical_point_color,
            "inflection_color": self.inflection_color,
            "vertical_asymptote_color": self.vertical_asymptote_color,
            "horizontal_asymptote_color": self.horizontal_asymptote_color,
            "oblique_asymptote_color": self.oblique_asymptote_color,
            "removable_discontinuity_edge_color": self.body_text if not is_default else None,
            "legend_facecolor": self.legend_facecolor if not is_default else "white",
            "legend_edgecolor": self.legend_edgecolor if not is_default else "#cccccc",
            "reference_axis_color": self.grid_color if not is_default else "black",
            "reference_axis_alpha": 0.5 if not is_default else 0.35,
            "curve_linewidth": 1.9 if not is_default else 1.6,
            "asymptote_linewidth": 1.1 if not is_default else 1.0,
            "asymptote_linestyle": (0, (6, 4)) if not is_default else "--",
        }


_XP_VIOLET_CLASSIC = VisualTheme(
    name="xp_violet_classic",
    display_name="XP Violet Classic",
    background="#070b1f",
    desktop_gradient_start="#070b1f",
    desktop_gradient_mid="#11143a",
    desktop_gradient_end="#1a1d4d",
    panel_background="#101a2e",
    panel_background_alt="#0d1728",
    panel_border_light="#9d8cff",
    panel_border_dark="#1a1440",
    titlebar_start="#4f46a8",
    titlebar_end="#1e1b4b",
    title_text="#f5f3ff",
    body_text="#e8e4ff",
    muted_text="#b6b0e8",
    accent_violet="#7c6cff",
    accent_blue="#5b52a8",
    accent_cyan="#62d8ff",
    accent_green="#50fa7b",
    accent_yellow="#ffcc66",
    accent_red="#ff6b81",
    accent_pink="#ff79c6",
    grid_color="#5a6592",
    axis_color="#a7b1ff",
    curve_color="#62d8ff",
    branch_alt_color="#ffb86c",
    root_color="#50fa7b",
    vertical_asymptote_color="#ffcc66",
    horizontal_asymptote_color="#8be9fd",
    oblique_asymptote_color="#bd93f9",
    critical_point_color="#ff79c6",
    inflection_color="#f1fa8c",
    legend_facecolor="#101a2e",
    legend_edgecolor="#7c6cff",
)

_DEFAULT = VisualTheme(
    name="default",
    display_name="Default",
    background="#ffffff",
    desktop_gradient_start="#ffffff",
    desktop_gradient_mid="#ffffff",
    desktop_gradient_end="#f5f5f5",
    panel_background="#ffffff",
    panel_background_alt="#ffffff",
    panel_border_light="#cccccc",
    panel_border_dark="#888888",
    titlebar_start="#e8e8e8",
    titlebar_end="#d0d0d0",
    title_text="#111111",
    body_text="#111111",
    muted_text="#555555",
    accent_violet="#7c6cff",
    accent_blue="#4f8cff",
    accent_cyan="#62d8ff",
    accent_green="#37d67a",
    accent_yellow="#ffcc66",
    accent_red="#ff6b81",
    accent_pink="#ff79c6",
    grid_color="#b0b0b0",
    axis_color="#111111",
    curve_color=None,
    branch_alt_color=None,
    root_color=None,
    vertical_asymptote_color=None,
    horizontal_asymptote_color=None,
    oblique_asymptote_color=None,
    critical_point_color=None,
    inflection_color=None,
    legend_facecolor="#ffffff",
    legend_edgecolor="#cccccc",
)

VISUAL_THEMES: dict[str, VisualTheme] = {
    "xp_violet_classic": _XP_VIOLET_CLASSIC,
    "xp_violet_dark": replace(_XP_VIOLET_CLASSIC, name="xp_violet_dark", display_name="XP Violet Dark"),
    "default": _DEFAULT,
}


def resolve_visual_theme(
    name: str | None = None,
    warnings: list[str] | None = None,
) -> VisualTheme:
    """Resolve nome de tema visual; inválido retorna ``default`` com warning."""
    warning_list = warnings if warnings is not None else []
    theme_name = name or DEFAULT_THEME_NAME
    resolved = _VISUAL_ALIASES.get(theme_name, theme_name)

    if resolved in VISUAL_THEMES:
        if theme_name in VISUAL_THEMES:
            return VISUAL_THEMES[theme_name]
        theme = VISUAL_THEMES[resolved]
        if theme_name != resolved:
            return replace(theme, name=theme_name, display_name=theme.display_name)
        return theme

    warning_list.append(f"Tema visual desconhecido: {theme_name!r}; usando 'default'.")
    return VISUAL_THEMES["default"]


def css_variables_for_theme(theme: VisualTheme) -> str:
    """Gera bloco :root com variáveis CSS a partir dos tokens visuais."""
    unknown_color = theme.oblique_asymptote_color or theme.accent_violet
    table_cell_border = "rgba(157, 140, 255, 0.22)" if theme.name != "default" else "#dddddd"
    table_row_hover = "rgba(98, 216, 255, 0.08)" if theme.name != "default" else "rgba(0, 0, 0, 0.04)"
    function_subtitle = "#d9d2ff" if theme.name != "default" else theme.muted_text
    return f""":root {{
  --bg-0: {theme.desktop_gradient_start};
  --bg-1: {theme.desktop_gradient_mid};
  --bg-2: {theme.desktop_gradient_end};
  --panel: {theme.panel_background};
  --panel-inset: {theme.panel_background_alt};
  --titlebar: linear-gradient(180deg, {theme.titlebar_start} 0%, {theme.accent_violet} 55%, {theme.titlebar_end} 100%);
  --titlebar-text: {theme.title_text};
  --bevel-light: {theme.panel_border_light};
  --bevel-dark: {theme.panel_border_dark};
  --text-main: {theme.body_text};
  --text-muted: {theme.muted_text};
  --hero-title: {theme.title_text};
  --function-subtitle: {function_subtitle};
  --graph-frame-bg: {theme.background};
  --button-start: {theme.accent_blue};
  --button-end: {theme.titlebar_end};
  --button-hover-start: {theme.titlebar_start};
  --button-hover-end: {theme.accent_blue};
  --table-header-start: {theme.titlebar_start};
  --table-header-end: {theme.accent_blue};
  --table-border: {theme.panel_border_light};
  --table-cell-border: {table_cell_border};
  --table-row-hover: {table_row_hover};
  --ok: {theme.accent_green};
  --warning: {theme.accent_yellow};
  --error: {theme.accent_red};
  --unknown: {unknown_color};
  --skipped: #94a3b8;
}}
"""
