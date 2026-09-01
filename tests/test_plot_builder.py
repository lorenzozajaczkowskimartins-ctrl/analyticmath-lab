"""Testes do construtor de gráficos anotados."""

from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np

from analyticmath.functions import SymbolicFunction
from analyticmath.reports import PlotWindow, build_function_plot
from analyticmath.reports.plot_builder import (
    _color_close,
    _has_oblique_asymptote_line,
    _has_vertical_asymptote_line,
    _legend_contains,
    _legend_labels,
    auto_scale_y,
    deduplicate_legend,
    resolve_plot_theme,
    sample_function_real,
)


def _close_plot(result) -> None:
    if result.figure is not None:
        plt.close(result.figure)


def test_quadratic_plot_builds() -> None:
    function = SymbolicFunction("x**2")
    result = build_function_plot(function)

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None
    assert result.context is not None
    _close_plot(result)


def test_rational_plot_vertical_asymptote() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    result = build_function_plot(function)

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None
    assert _has_vertical_asymptote_line(result.axes, 2.0)
    _close_plot(result)


def test_sqrt_plot_respects_real_domain() -> None:
    function = SymbolicFunction("sqrt(x - 1)")
    window = PlotWindow(x_min=-2.0, x_max=5.0, y_min=-1.0, y_max=3.0, num_points=500)
    result = build_function_plot(function, window=window)

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None

    x_values = np.linspace(-2.0, 5.0, 500)
    y_values = sample_function_real(function, x_values)
    assert np.all(np.isnan(y_values[x_values < 1.0 - 1e-9]))
    assert np.any(np.isfinite(y_values[x_values > 1.0 + 1e-9]))
    _close_plot(result)


def test_plot_saves_png(tmp_path: Path) -> None:
    output_path = tmp_path / "plot_x2.png"
    result = build_function_plot(SymbolicFunction("x**2"), output_path=str(output_path))

    assert result.output_path == str(output_path)
    assert output_path.exists()
    assert output_path.stat().st_size > 0
    _close_plot(result)


def test_plot_reuses_context() -> None:
    function = SymbolicFunction("x**2")
    context = function.full_analysis()
    result = build_function_plot(function, context=context)

    assert result.case in ("success", "partial")
    assert result.context is context
    assert result.figure is not None
    assert result.axes is not None
    _close_plot(result)


def test_symbolic_function_plot_method() -> None:
    result = SymbolicFunction("x**2").plot()

    assert result.case in ("success", "partial")
    assert result.axes is not None
    _close_plot(result)


def test_auto_scale_y_normal_values() -> None:
    y_values = np.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    y_min, y_max = auto_scale_y(y_values)

    assert y_min < 0.0
    assert y_max > 5.0
    assert y_max - y_min > 5.0


def test_auto_scale_y_ignores_outliers() -> None:
    y_values = np.concatenate([np.linspace(1.0, 5.0, 50), np.array([1000.0])])
    y_min, y_max = auto_scale_y(y_values)

    assert y_max < 20.0
    assert y_min < 2.0


def test_auto_scale_y_all_nan_returns_default() -> None:
    y_values = np.array([np.nan, np.nan, np.inf, -np.inf])
    y_min, y_max = auto_scale_y(y_values)

    assert y_min == -10.0
    assert y_max == 10.0


def test_oblique_asymptote_plot() -> None:
    function = SymbolicFunction("(x**2 + 1)/(x - 1)")
    result = build_function_plot(function)

    assert result.case in ("success", "partial")
    assert result.axes is not None
    assert _legend_contains(result.axes, "assíntota oblíqua") or _has_oblique_asymptote_line(
        result.axes,
        slope=1.0,
        intercept=1.0,
    )
    _close_plot(result)


def test_plot_with_auto_y_limits() -> None:
    window = PlotWindow(x_min=-5.0, x_max=5.0, y_min=None, y_max=None, num_points=1000)
    result = build_function_plot(SymbolicFunction("x**2"), window=window)

    assert result.case in ("success", "partial")
    assert result.axes is not None
    y_min, y_max = result.axes.get_ylim()
    assert y_max > 0.0
    assert y_min < y_max
    _close_plot(result)


def test_xp_violet_dark_theme_builds() -> None:
    result = build_function_plot(SymbolicFunction("x**2"), theme="xp_violet_dark")

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None
    assert _color_close(result.axes.get_facecolor(), "#0d1728")
    _close_plot(result)


def test_xp_violet_classic_theme_builds() -> None:
    result = build_function_plot(SymbolicFunction("x**2"), theme="xp_violet_classic")

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None
    assert _color_close(result.figure.get_facecolor(), "#11143a")
    _close_plot(result)


def test_default_theme_builds() -> None:
    result = build_function_plot(SymbolicFunction("x**2"), theme="default")

    assert result.case in ("success", "partial")
    assert result.figure is not None
    assert result.axes is not None
    _close_plot(result)


def test_invalid_theme_falls_back_to_default() -> None:
    result = build_function_plot(SymbolicFunction("x**2"), theme="unknown_theme")

    assert result.case in ("success", "partial", "failed")
    assert any("desconhecido" in warning for warning in result.warnings)
    assert result.axes is not None
    _close_plot(result)


def test_legend_without_duplicate_function_labels() -> None:
    result = build_function_plot(SymbolicFunction("(x + 1)/(x - 2)"), theme="xp_violet_classic")

    labels = _legend_labels(result.axes)
    assert labels.count("f(x)") == 1
    _close_plot(result)


def test_dark_theme_png_output(tmp_path: Path) -> None:
    output_path = tmp_path / "plot_dark.png"
    result = build_function_plot(
        SymbolicFunction("x**2"),
        theme="xp_violet_classic",
        output_path=str(output_path),
    )

    assert output_path.exists()
    assert output_path.stat().st_size > 0
    _close_plot(result)


def test_resolve_plot_theme_invalid() -> None:
    warnings: list[str] = []
    theme = resolve_plot_theme("not_a_theme", warnings)

    assert theme["name"] == "default"
    assert warnings


def test_deduplicate_legend_helper() -> None:
    import matplotlib.pyplot as plt

    _, axes = plt.subplots()
    axes.plot([0, 1], [0, 1], label="f(x)")
    axes.plot([0, 1], [1, 2], label="f(x)")
    axes.plot([0, 1], [2, 3], label="assíntota vertical")
    axes.plot([4, 5], [2, 3], label="assíntota vertical")
    deduplicate_legend(axes, resolve_plot_theme("default", []))

    labels = _legend_labels(axes)
    assert labels.count("f(x)") == 1
    assert labels.count("assíntota vertical") == 1
    plt.close(axes.figure)
