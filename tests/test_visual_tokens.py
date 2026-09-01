"""Testes dos tokens visuais compartilhados."""

from analyticmath.reports.visual_tokens import (
    VISUAL_THEMES,
    VisualTheme,
    css_variables_for_theme,
    resolve_visual_theme,
)


def test_resolve_xp_violet_classic() -> None:
    theme = resolve_visual_theme("xp_violet_classic")

    assert isinstance(theme, VisualTheme)
    assert theme.name == "xp_violet_classic"
    assert theme.background == "#070b1f"
    assert theme.curve_color == "#62d8ff"
    assert theme.root_color == "#50fa7b"


def test_resolve_xp_violet_dark() -> None:
    theme = resolve_visual_theme("xp_violet_dark")

    assert theme.name == "xp_violet_dark"
    assert theme.panel_background == VISUAL_THEMES["xp_violet_classic"].panel_background


def test_resolve_default_theme() -> None:
    theme = resolve_visual_theme("default")

    assert theme.name == "default"
    assert theme.curve_color is None


def test_resolve_none_uses_classic() -> None:
    theme = resolve_visual_theme(None)

    assert theme.name == "xp_violet_classic"


def test_invalid_theme_adds_warning() -> None:
    warnings: list[str] = []
    theme = resolve_visual_theme("not_a_theme", warnings)

    assert theme.name == "default"
    assert any("desconhecido" in warning for warning in warnings)


def test_theme_has_essential_fields() -> None:
    theme = resolve_visual_theme("xp_violet_classic")

    assert theme.background
    assert theme.panel_background
    assert theme.curve_color
    assert theme.root_color


def test_to_plot_config_preserves_requested_name() -> None:
    plot = resolve_visual_theme("xp_violet_dark").to_plot_config(requested_name="xp_violet_dark")

    assert plot["name"] == "xp_violet_dark"
    assert plot["figure_facecolor"] == "#11143a"
    assert plot["axes_facecolor"] == "#0d1728"


def test_css_variables_contains_theme_colors() -> None:
    theme = resolve_visual_theme("xp_violet_classic")
    css = css_variables_for_theme(theme)

    assert theme.background in css
    assert theme.panel_background in css
    assert theme.titlebar_start in css
