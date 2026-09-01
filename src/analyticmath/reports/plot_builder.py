"""Construção de gráficos anotados para funções simbólicas reais."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Callable

import matplotlib.pyplot as plt
import numpy as np
import sympy as sp
from sympy import lambdify

from analyticmath.functions.asymptotes import is_finite_real
from analyticmath.functions.critical_points import _CLASSIFICATION_LABELS as _CRITICAL_LABELS
from analyticmath.functions.sign_table import is_point_in_domain
from analyticmath.reports.visual_tokens import (
    VISUAL_THEMES,
    resolve_visual_theme,
)

if TYPE_CHECKING:
    from matplotlib.axes import Axes
    from matplotlib.figure import Figure

    from analyticmath.functions.analysis_context import FunctionAnalysisContext
    from analyticmath.functions.symbolic_function import SymbolicFunction

DEFAULT_FIGSIZE = (9, 6)
DEFAULT_DPI = 120
DEFAULT_Y_MIN = -10.0
DEFAULT_Y_MAX = 10.0

PLOT_THEMES: dict[str, dict[str, Any]] = {
    name: visual.to_plot_config(requested_name=name)
    for name, visual in VISUAL_THEMES.items()
}
PLOT_THEME = PLOT_THEMES["xp_violet_classic"]


@dataclass(frozen=True)
class PlotWindow:
    """Janela de visualização para amostragem e limites do gráfico."""

    x_min: float = -10.0
    x_max: float = 10.0
    y_min: float | None = None
    y_max: float | None = None
    num_points: int = 2000


@dataclass
class FunctionPlotResult:
    """Resultado da construção de um gráfico anotado."""

    function: SymbolicFunction
    context: FunctionAnalysisContext
    figure: Figure | None
    axes: Axes | None
    output_path: str | None
    warnings: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    case: str = "failed"


@dataclass(frozen=True)
class _PlotBounds:
    """Limites efetivos usados no gráfico (eixo y pode ser autoescalado)."""

    x_min: float
    x_max: float
    y_min: float
    y_max: float
    auto_y: bool


def resolve_plot_theme(theme: str, warnings: list[str]) -> dict[str, Any]:
    """Resolve nome de tema para configuração; tema inválido cai para ``default``."""
    visual = resolve_visual_theme(theme, warnings)
    if theme in VISUAL_THEMES:
        return visual.to_plot_config(requested_name=theme)
    return visual.to_plot_config()


def _is_xp_theme(theme: dict[str, Any]) -> bool:
    return theme.get("name") in ("xp_violet_classic", "xp_violet_dark")


def deduplicate_legend(axes: Axes, theme: dict[str, Any]) -> None:
    """Remove entradas duplicadas da legenda do eixo."""
    handles, labels = axes.get_legend_handles_labels()
    if not labels:
        return

    unique_handles: list[Any] = []
    unique_labels: list[str] = []
    seen: set[str] = set()

    for handle, label in zip(handles, labels):
        if not label or label == "_nolegend_":
            continue
        if label in seen:
            continue
        seen.add(label)
        unique_handles.append(handle)
        unique_labels.append(label)

    if not unique_labels:
        legend = axes.get_legend()
        if legend is not None:
            legend.remove()
        return

    legend_kwargs: dict[str, Any] = {"loc": "best", "fontsize": 8}
    if _is_xp_theme(theme):
        legend_kwargs.update(
            {
                "facecolor": theme["legend_facecolor"],
                "edgecolor": theme["legend_edgecolor"],
                "labelcolor": theme["text_color"],
            }
        )
    else:
        legend_kwargs.update(
            {
                "facecolor": theme["legend_facecolor"],
                "edgecolor": theme["legend_edgecolor"],
            }
        )

    axes.legend(unique_handles, unique_labels, **legend_kwargs)


def auto_scale_y(
    y_values: np.ndarray,
    default_y_min: float = DEFAULT_Y_MIN,
    default_y_max: float = DEFAULT_Y_MAX,
    padding_ratio: float = 0.12,
) -> tuple[float, float]:
    """Calcula limites verticais ignorando NaN, infinitos e outliers extremos."""
    valid = np.asarray(y_values, dtype=float)
    valid = valid[np.isfinite(valid)]

    if valid.size < 2:
        return default_y_min, default_y_max

    low = float(np.percentile(valid, 2))
    high = float(np.percentile(valid, 98))

    if not np.isfinite(low) or not np.isfinite(high):
        return default_y_min, default_y_max

    if low >= high:
        center = low
        margin = max(abs(center) * padding_ratio, 1.0)
        return center - margin, center + margin

    span = high - low
    padding = span * padding_ratio
    return low - padding, high + padding


def sample_function_real(
    function: SymbolicFunction,
    x_values: np.ndarray | list[float],
    *,
    lambdify_cache: dict[int, Callable[..., Any]] | None = None,
) -> np.ndarray:
    """Avalia ``function`` numericamente, convertendo valores inválidos em NaN."""
    x_array = np.asarray(x_values, dtype=float)
    numeric_fn = _get_lambdified(function, lambdify_cache)

    if numeric_fn is not None:
        try:
            raw = numeric_fn(x_array)
            result = _vectorized_to_finite_array(raw, x_array.shape)
            if np.any(np.isfinite(result)):
                return result
        except (TypeError, ValueError, ZeroDivisionError, FloatingPointError):
            pass

    return _sample_function_real_scalar(function, x_array, numeric_fn)


def build_function_plot(
    function: SymbolicFunction,
    context: FunctionAnalysisContext | None = None,
    window: PlotWindow | None = None,
    output_path: str | None = None,
    show: bool = False,
    theme: str = "xp_violet_classic",
) -> FunctionPlotResult:
    """Gera gráfico anotado de ``function`` usando dados de ``context``."""
    plot_window = window or PlotWindow()
    warnings: list[str] = []
    errors: list[str] = []
    lambdify_cache: dict[int, Callable[..., Any]] = {}
    theme_config = resolve_plot_theme(theme, warnings)

    if context is None:
        context = function.full_analysis()

    result = FunctionPlotResult(
        function=function,
        context=context,
        figure=None,
        axes=None,
        output_path=output_path,
        warnings=warnings,
        errors=errors,
        case="failed",
    )

    try:
        figure, axes = plt.subplots(figsize=DEFAULT_FIGSIZE, dpi=DEFAULT_DPI)
        result.figure = figure
        result.axes = axes

        sampled_y = _plot_function_branches(
            function,
            axes,
            plot_window,
            context,
            warnings,
            lambdify_cache,
            theme_config,
        )
        bounds = _resolve_plot_bounds(plot_window, sampled_y)

        _annotate_roots(function, axes, bounds, context, warnings, theme_config)
        _annotate_vertical_asymptotes(axes, bounds, context, warnings, theme_config)
        _annotate_horizontal_asymptotes(axes, bounds, context, warnings, theme_config)
        _annotate_oblique_asymptotes(axes, bounds, context, warnings, theme_config)
        _annotate_critical_points(function, axes, bounds, context, warnings, theme_config)
        _annotate_inflection_points(axes, bounds, context, warnings, theme_config)
        _annotate_removable_discontinuities(axes, bounds, context, warnings, theme_config)

        var = function.variable
        title = f"{theme_config['title_prefix']} — f({var}) = {function.expr}"
        title_kwargs: dict[str, Any] = {"color": theme_config["text_color"]}
        if _is_xp_theme(theme_config):
            title_kwargs.update(
                {
                    "fontsize": 10,
                    "fontweight": "bold",
                    "fontfamily": "Tahoma",
                    "bbox": {
                        "boxstyle": "round,pad=0.35",
                        "facecolor": theme_config["legend_facecolor"],
                        "edgecolor": theme_config["legend_edgecolor"],
                        "linewidth": 1.0,
                        "alpha": 0.95,
                    },
                }
            )
        axes.set_title(title, **title_kwargs)
        axes.set_xlabel("x", color=theme_config["text_color"])
        axes.set_ylabel(f"f({var})", color=theme_config["text_color"])
        axes.set_xlim(bounds.x_min, bounds.x_max)
        axes.set_ylim(bounds.y_min, bounds.y_max)

        _apply_plot_theme(figure, axes, theme_config)
        deduplicate_legend(axes, theme_config)

        if output_path:
            figure.savefig(
                output_path,
                dpi=DEFAULT_DPI,
                bbox_inches="tight",
                facecolor=figure.get_facecolor(),
            )

        if show:
            plt.show()

        result.case = _resolve_plot_case(context, warnings, errors)
    except Exception as exc:
        errors.append(str(exc))
        result.errors = errors
        result.case = "failed"

    return result


def _apply_plot_theme(figure: Figure, axes: Axes, theme: dict[str, Any]) -> None:
    figure.patch.set_facecolor(theme["figure_facecolor"])
    axes.set_facecolor(theme["axes_facecolor"])

    if theme.get("grid", True):
        axes.grid(True, color=theme["grid_color"], alpha=theme["grid_alpha"])

    axes.tick_params(colors=theme["text_color"])
    for spine in axes.spines.values():
        spine.set_color(theme["axis_color"])

    ref_color = theme["reference_axis_color"]
    ref_alpha = theme["reference_axis_alpha"]
    axes.axhline(0, color=ref_color, linewidth=0.6, alpha=ref_alpha, zorder=0)
    axes.axvline(0, color=ref_color, linewidth=0.6, alpha=ref_alpha, zorder=0)


def _plot_color(theme: dict[str, Any], key: str, fallback: str | None = None) -> str | None:
    value = theme.get(key)
    return value if value is not None else fallback


def _get_lambdified(
    function: SymbolicFunction,
    cache: dict[int, Callable[..., Any]] | None,
) -> Callable[..., Any] | None:
    key = id(function)
    if cache is not None and key in cache:
        return cache[key]

    try:
        numeric_fn = lambdify(function.symbol, function.expr, modules=["numpy"])
    except Exception:
        numeric_fn = None

    if cache is not None and numeric_fn is not None:
        cache[key] = numeric_fn
    return numeric_fn


def _vectorized_to_finite_array(raw: Any, shape: tuple[int, ...]) -> np.ndarray:
    array = np.asarray(raw, dtype=complex).reshape(shape)
    result = np.full(shape, np.nan, dtype=float)

    real_part = np.real(array)
    imag_part = np.imag(array)
    mask = np.isfinite(real_part) & np.isfinite(imag_part) & (np.abs(imag_part) <= 1e-10)
    result[mask] = real_part[mask]
    result[~np.isfinite(result)] = np.nan
    return result


def _sample_function_real_scalar(
    function: SymbolicFunction,
    x_array: np.ndarray,
    numeric_fn: Callable[..., Any] | None,
) -> np.ndarray:
    result = np.full(x_array.shape, np.nan, dtype=float)

    for index, x_value in enumerate(x_array.flat):
        domain_status = is_point_in_domain(function, x_value)
        if domain_status is False:
            continue

        if numeric_fn is not None:
            try:
                raw = numeric_fn(x_value)
            except (TypeError, ValueError, ZeroDivisionError, FloatingPointError):
                raw = _evaluate_scalar(function, x_value)
        else:
            raw = _evaluate_scalar(function, x_value)

        finite = _to_finite_float(raw)
        if finite is not None:
            result.flat[index] = finite

    return result


def _resolve_plot_bounds(window: PlotWindow, sampled_y: np.ndarray) -> _PlotBounds:
    auto_y = window.y_min is None or window.y_max is None

    if window.y_min is None and window.y_max is None:
        y_min, y_max = auto_scale_y(sampled_y)
    else:
        auto_min, auto_max = auto_scale_y(sampled_y)
        y_min = window.y_min if window.y_min is not None else auto_min
        y_max = window.y_max if window.y_max is not None else auto_max

    return _PlotBounds(
        x_min=window.x_min,
        x_max=window.x_max,
        y_min=y_min,
        y_max=y_max,
        auto_y=auto_y,
    )


def _evaluate_scalar(function: SymbolicFunction, x_value: float) -> Any:
    try:
        return function.evaluate(x_value)
    except Exception:
        try:
            return float(sp.N(function.expr.subs(function.symbol, x_value)))
        except Exception:
            return sp.nan


def _to_finite_float(value: Any) -> float | None:
    if value is None:
        return None

    if isinstance(value, (np.ndarray, list, tuple)):
        if len(value) == 0:
            return None
        value = value[0]

    if isinstance(value, (complex, np.complexfloating)):
        if abs(value.imag) > 1e-10:
            return None
        value = value.real

    try:
        numeric = float(value)
    except (TypeError, ValueError):
        if is_finite_real(value):
            try:
                numeric = float(sp.N(value))
            except (TypeError, ValueError):
                return None
        else:
            return None

    if not np.isfinite(numeric):
        return None
    return numeric


def _collect_branch_breakpoints(
    context: FunctionAnalysisContext,
    x_min: float,
    x_max: float,
) -> list[float]:
    breakpoints: set[float] = set()

    asymptotes = context.asymptotes()
    if asymptotes is not None:
        for item in asymptotes.vertical_asymptotes:
            if not item.exists:
                continue
            numeric = _to_finite_float(item.x)
            if numeric is not None and x_min < numeric < x_max:
                breakpoints.add(numeric)

    continuity = context.continuity()
    if continuity is not None:
        for item in continuity.discontinuities:
            if item.classification == "removable":
                continue
            numeric = _to_finite_float(item.x)
            if numeric is None:
                continue
            if x_min < numeric < x_max:
                breakpoints.add(numeric)

    return sorted(breakpoints)


def _split_plot_intervals(
    x_min: float,
    x_max: float,
    breakpoints: list[float],
    num_points: int,
) -> list[tuple[float, float]]:
    if not breakpoints:
        return [(x_min, x_max)]

    span = max(x_max - x_min, 1.0)
    epsilon = max(1e-6, span / max(num_points, 1))
    intervals: list[tuple[float, float]] = []
    left = x_min

    for point in breakpoints:
        right = point - epsilon
        if right > left:
            intervals.append((left, right))
        left = point + epsilon

    if left < x_max:
        intervals.append((left, x_max))

    return intervals or [(x_min, x_max)]


def _plot_function_branches(
    function: SymbolicFunction,
    axes: Axes,
    window: PlotWindow,
    context: FunctionAnalysisContext,
    warnings: list[str],
    lambdify_cache: dict[int, Callable[..., Any]],
    theme: dict[str, Any],
) -> np.ndarray:
    breakpoints = _collect_branch_breakpoints(context, window.x_min, window.x_max)
    intervals = _split_plot_intervals(
        window.x_min,
        window.x_max,
        breakpoints,
        window.num_points,
    )
    branch_count = len(intervals)
    points_per_branch = max(50, window.num_points // max(branch_count, 1))

    plotted_label = False
    sampled_chunks: list[np.ndarray] = []
    branch_colors = [
        _plot_color(theme, "curve_color"),
        _plot_color(theme, "branch_alt_color", _plot_color(theme, "curve_color")),
    ]

    for branch_index, (left, right) in enumerate(intervals):
        if right <= left:
            continue
        x_values = np.linspace(left, right, points_per_branch)
        y_values = sample_function_real(function, x_values, lambdify_cache=lambdify_cache)
        sampled_chunks.append(y_values)

        label = f"f({function.variable})" if not plotted_label else "_nolegend_"
        plot_kwargs: dict[str, Any] = {
            "label": label,
            "linewidth": theme.get("curve_linewidth", 1.6),
        }
        branch_color = branch_colors[branch_index % len(branch_colors)]
        if branch_color is not None:
            plot_kwargs["color"] = branch_color

        axes.plot(x_values, y_values, **plot_kwargs)
        plotted_label = True

    if not sampled_chunks:
        return np.array([], dtype=float)
    return np.concatenate(sampled_chunks)


def _annotate_roots(
    function: SymbolicFunction,
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        roots_result = context.roots()
        if roots_result is None:
            return

        labeled = False
        root_color = _plot_color(theme, "root_color")
        for root in roots_result.real_roots:
            x_value = _to_finite_float(root)
            if x_value is None:
                continue
            if not (bounds.x_min <= x_value <= bounds.x_max):
                continue
            if is_point_in_domain(function, x_value) is False:
                continue

            label = "raiz" if not labeled else "_nolegend_"
            plot_kwargs: dict[str, Any] = {
                "marker": "o",
                "linestyle": "None",
                "label": label,
            }
            if root_color is not None:
                plot_kwargs["color"] = root_color
            axes.plot(x_value, 0.0, **plot_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"raízes: {exc}")


def _annotate_vertical_asymptotes(
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        asymptotes = context.asymptotes()
        if asymptotes is None:
            return

        labeled = False
        line_color = _plot_color(theme, "vertical_asymptote_color")
        for item in asymptotes.vertical_asymptotes:
            if not item.exists:
                continue
            x_value = _to_finite_float(item.x)
            if x_value is None:
                continue
            if not (bounds.x_min <= x_value <= bounds.x_max):
                continue

            label = "assíntota vertical" if not labeled else "_nolegend_"
            line_kwargs: dict[str, Any] = {
                "linestyle": theme.get("asymptote_linestyle", "--"),
                "linewidth": theme.get("asymptote_linewidth", 1.0),
                "alpha": 0.9,
                "label": label,
            }
            if line_color is not None:
                line_kwargs["color"] = line_color
            axes.axvline(x_value, **line_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"assíntotas verticais: {exc}")


def _annotate_horizontal_asymptotes(
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        asymptotes = context.asymptotes()
        if asymptotes is None:
            return

        labeled = False
        seen_levels: set[float] = set()
        line_color = _plot_color(theme, "horizontal_asymptote_color")
        for item in asymptotes.horizontal_asymptotes:
            if not item.exists:
                continue
            y_value = _to_finite_float(item.y)
            if y_value is None:
                continue
            if y_value in seen_levels:
                continue
            seen_levels.add(y_value)

            label = "assíntota horizontal" if not labeled else "_nolegend_"
            line_kwargs: dict[str, Any] = {
                "linestyle": theme.get("asymptote_linestyle", "--"),
                "linewidth": theme.get("asymptote_linewidth", 1.0),
                "alpha": 0.9,
                "label": label,
            }
            if line_color is not None:
                line_kwargs["color"] = line_color
            axes.axhline(y_value, **line_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"assíntotas horizontais: {exc}")


def _annotate_oblique_asymptotes(
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        asymptotes = context.asymptotes()
        if asymptotes is None:
            return

        labeled = False
        seen: set[tuple[float, float]] = set()
        x_values = np.array([bounds.x_min, bounds.x_max], dtype=float)
        line_color = _plot_color(theme, "oblique_asymptote_color")

        for item in asymptotes.oblique_asymptotes:
            if not item.exists:
                continue

            slope = _to_finite_float(item.slope)
            intercept = _to_finite_float(item.intercept)
            if slope is None or intercept is None:
                continue

            key = (round(slope, 8), round(intercept, 8))
            if key in seen:
                continue
            seen.add(key)

            y_values = slope * x_values + intercept
            label = "assíntota oblíqua" if not labeled else "_nolegend_"
            plot_kwargs: dict[str, Any] = {
                "linestyle": theme.get("asymptote_linestyle", "--"),
                "linewidth": theme.get("asymptote_linewidth", 1.0),
                "alpha": 0.9,
                "label": label,
            }
            if line_color is not None:
                plot_kwargs["color"] = line_color
            axes.plot(x_values, y_values, **plot_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"assíntotas oblíquas: {exc}")


def _annotate_critical_points(
    function: SymbolicFunction,
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        analysis = context.critical_points()
        if analysis is None:
            return

        labeled = False
        point_color = _plot_color(theme, "critical_point_color")
        for point in analysis.critical_points:
            if not point.in_domain:
                continue

            x_value = _to_finite_float(point.x)
            y_value = _to_finite_float(point.y)
            if x_value is None or y_value is None:
                continue
            if not (bounds.x_min <= x_value <= bounds.x_max and bounds.y_min <= y_value <= bounds.y_max):
                continue

            label = "ponto crítico" if not labeled else "_nolegend_"
            plot_kwargs: dict[str, Any] = {
                "marker": "s",
                "linestyle": "None",
                "label": label,
            }
            if point_color is not None:
                plot_kwargs["color"] = point_color
            axes.plot(x_value, y_value, **plot_kwargs)

            classification = _CRITICAL_LABELS.get(point.classification, point.classification)
            axes.annotate(
                classification,
                (x_value, y_value),
                textcoords="offset points",
                xytext=(6, 6),
                fontsize=7,
                color=theme["text_color"],
            )
            labeled = True
    except Exception as exc:
        warnings.append(f"pontos críticos: {exc}")


def _annotate_inflection_points(
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        analysis = context.concavity()
        if analysis is None:
            return

        labeled = False
        point_color = _plot_color(theme, "inflection_color")
        for point in analysis.inflection_points:
            if point.classification not in ("inflection_point", "stationary_inflection"):
                continue
            if not point.in_domain:
                continue

            x_value = _to_finite_float(point.x)
            y_value = _to_finite_float(point.y)
            if x_value is None or y_value is None:
                continue
            if not (bounds.x_min <= x_value <= bounds.x_max and bounds.y_min <= y_value <= bounds.y_max):
                continue

            label = "ponto de inflexão" if not labeled else "_nolegend_"
            plot_kwargs: dict[str, Any] = {
                "marker": "D",
                "linestyle": "None",
                "label": label,
            }
            if point_color is not None:
                plot_kwargs["color"] = point_color
            axes.plot(x_value, y_value, **plot_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"pontos de inflexão: {exc}")


def _annotate_removable_discontinuities(
    axes: Axes,
    bounds: _PlotBounds,
    context: FunctionAnalysisContext,
    warnings: list[str],
    theme: dict[str, Any],
) -> None:
    try:
        continuity = context.continuity()
        if continuity is None:
            return

        labeled = False
        edge_color = _plot_color(theme, "removable_discontinuity_edge_color")
        for item in continuity.discontinuities:
            if item.classification != "removable" and not item.removable:
                continue

            x_value = _to_finite_float(item.x)
            if x_value is None:
                continue
            if not (bounds.x_min <= x_value <= bounds.x_max):
                continue

            y_value = _limit_value_for_removable(item)
            if y_value is None:
                continue
            if not (bounds.y_min <= y_value <= bounds.y_max):
                continue

            label = "descontinuidade removível" if not labeled else "_nolegend_"
            plot_kwargs: dict[str, Any] = {
                "marker": "o",
                "linestyle": "None",
                "markerfacecolor": "none",
                "markeredgewidth": 1.5,
                "label": label,
            }
            if edge_color is not None:
                plot_kwargs["markeredgecolor"] = edge_color
            axes.plot(x_value, y_value, **plot_kwargs)
            labeled = True
    except Exception as exc:
        warnings.append(f"descontinuidades removíveis: {exc}")


def _limit_value_for_removable(discontinuity: Any) -> float | None:
    for candidate in (discontinuity.left_limit, discontinuity.right_limit):
        value = _to_finite_float(candidate)
        if value is not None:
            return value
    return None


def _resolve_plot_case(
    context: FunctionAnalysisContext,
    warnings: list[str],
    errors: list[str],
) -> str:
    if errors:
        return "failed"
    if warnings or context.errors:
        return "partial"
    return "success"


def _has_vertical_asymptote_line(axes: Axes, x_target: float, tolerance: float = 1e-6) -> bool:
    for line in axes.lines:
        x_data = line.get_xdata()
        y_data = line.get_ydata()
        if len(x_data) < 2 or len(y_data) < 2:
            continue
        if abs(float(x_data[0]) - float(x_data[-1])) > tolerance:
            continue
        if abs(float(x_data[0]) - x_target) <= tolerance:
            if abs(float(y_data[0]) - float(y_data[-1])) > tolerance:
                return True
    return False


def _has_oblique_asymptote_line(
    axes: Axes,
    slope: float,
    intercept: float,
    tolerance: float = 0.75,
) -> bool:
    for line in axes.lines:
        x_data = np.asarray(line.get_xdata(), dtype=float)
        y_data = np.asarray(line.get_ydata(), dtype=float)
        if x_data.size < 2 or y_data.size < 2:
            continue
        if np.allclose(x_data, x_data[0]):
            continue
        expected = slope * x_data + intercept
        if np.allclose(y_data, expected, atol=tolerance, rtol=0.1):
            return True
    return False


def _legend_contains(axes: Axes, text: str) -> bool:
    legend = axes.get_legend()
    if legend is None:
        return False
    labels = [label.get_text() for label in legend.get_texts()]
    return text in labels


def _legend_labels(axes: Axes) -> list[str]:
    legend = axes.get_legend()
    if legend is None:
        return []
    return [label.get_text() for label in legend.get_texts()]


def _color_close(rgba: tuple[float, ...], hex_color: str, tolerance: float = 0.08) -> bool:
    hex_color = hex_color.lstrip("#")
    target = tuple(int(hex_color[index : index + 2], 16) / 255.0 for index in (0, 2, 4))
    return all(abs(float(rgba[index]) - target[index]) <= tolerance for index in range(3))
