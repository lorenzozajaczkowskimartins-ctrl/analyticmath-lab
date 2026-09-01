"""Detecção de assíntotas verticais, horizontais e oblíquas."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import S, fraction, limit, oo, solve, together

from analyticmath.functions.domain import find_real_domain
from analyticmath.functions.limits import limit_at, limit_at_infinity

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

Direction = Literal["+oo", "-oo"]
AnalysisCase = Literal[
    "general",
    "no_asymptotes",
    "vertical_only",
    "horizontal_only",
    "oblique_only",
    "mixed",
]


@dataclass(frozen=True)
class VerticalAsymptote:
    """Assíntota vertical x = a."""

    x: Any
    left_limit: Any
    right_limit: Any
    exists: bool
    explanation: str


@dataclass(frozen=True)
class HorizontalAsymptote:
    """Assíntota horizontal y = L quando x tende a ±∞."""

    direction: str
    y: Any
    exists: bool
    explanation: str


@dataclass(frozen=True)
class ObliqueAsymptote:
    """Assíntota oblíqua y = m x + b."""

    direction: str
    slope: Any
    intercept: Any
    expression: Any
    exists: bool
    explanation: str


@dataclass
class AsymptoteAnalysis:
    """Resultado completo da análise de assíntotas."""

    function: SymbolicFunction
    vertical_asymptotes: list[VerticalAsymptote] = field(default_factory=list)
    horizontal_asymptotes: list[HorizontalAsymptote] = field(default_factory=list)
    oblique_asymptotes: list[ObliqueAsymptote] = field(default_factory=list)
    explanation: str = ""
    case: str = "general"


def analyze_asymptotes(function: SymbolicFunction) -> AsymptoteAnalysis:
    """Analisa assíntotas verticais, horizontais e oblíquas de ``function``."""
    notes: list[str] = []

    if _has_infinite_trig_family(function.expr):
        notes.append(
            "Funções trigonométricas periódicas possuem famílias infinitas de "
            "assíntotas verticais; esta versão não as enumera completamente."
        )
        vertical_candidates: list[Any] = []
    else:
        vertical_candidates = find_vertical_asymptote_candidates(function)

    vertical = _find_vertical_asymptotes(function, vertical_candidates)
    horizontal = _find_horizontal_asymptotes(function)
    horizontal_directions = {item.direction for item in horizontal if item.exists}
    oblique = _find_oblique_asymptotes(function, horizontal_directions)

    explanation_parts = []
    if vertical:
        explanation_parts.append(f"{len(vertical)} assíntota(s) vertical(is) detectada(s).")
    if horizontal:
        explanation_parts.append(f"{len(horizontal)} assíntota(s) horizontal(is) detectada(s).")
    if oblique:
        explanation_parts.append(f"{len(oblique)} assíntota(s) oblíqua(s) detectada(s).")
    if not vertical and not horizontal and not oblique:
        explanation_parts.append("Nenhuma assíntota detectada nos critérios atuais.")
    explanation_parts.extend(notes)

    return AsymptoteAnalysis(
        function=function,
        vertical_asymptotes=vertical,
        horizontal_asymptotes=horizontal,
        oblique_asymptotes=oblique,
        explanation=" ".join(explanation_parts),
        case=_determine_case(vertical, horizontal, oblique),
    )


def is_infinite_limit(value: Any) -> bool:
    """Indica se ``value`` representa +∞ ou -∞."""
    if value in (oo, -oo, sp.zoo):
        return True
    if value in (sp.S.Infinity, sp.S.NegativeInfinity, sp.S.ComplexInfinity):
        return True
    if getattr(value, "is_infinite", False):
        return True
    return False


def is_finite_real(value: Any) -> bool:
    """Indica se ``value`` é um número real finito."""
    if isinstance(value, (int, float)):
        return value not in (float("inf"), float("-inf")) and value == value

    if is_infinite_limit(value):
        return False
    if value is sp.nan or getattr(value, "is_nan", False):
        return False
    if getattr(value, "is_finite", None) is True:
        return getattr(value, "is_real", True) or sp.im(value).equals(0)
    if getattr(value, "is_number", False):
        try:
            numeric = complex(sp.N(value))
            return numeric != float("inf") and numeric != float("-inf")
        except (TypeError, ValueError):
            return False
    return False


def find_vertical_asymptote_candidates(function: SymbolicFunction) -> list[Any]:
    """Lista candidatos reais a assíntotas verticais."""
    candidates: set[Any] = set()

    _, denominator = fraction(together(function.expr))
    if denominator != 1:
        try:
            denom_roots = solve(denominator, function.symbol)
            if isinstance(denom_roots, dict):
                denom_roots = list(denom_roots.values())
            elif not isinstance(denom_roots, list):
                denom_roots = [denom_roots]

            for root in denom_roots:
                if root is None or root in (S.ComplexInfinity,):
                    continue
                if sp.im(root).equals(0):
                    candidates.add(sp.simplify(root))
        except Exception:
            pass

    candidates.update(_domain_excluded_points(function))

    unique = list(dict.fromkeys(candidates))
    return sorted(unique, key=lambda value: float(sp.N(value)))


def format_vertical_asymptote(asymptote: VerticalAsymptote) -> str:
    """Formata uma assíntota vertical."""
    lines = [
        f"x = {asymptote.x}",
        f"lim x→{asymptote.x}⁻ f(x) = {_format_limit_value(asymptote.left_limit)}",
        f"lim x→{asymptote.x}⁺ f(x) = {_format_limit_value(asymptote.right_limit)}",
    ]
    return "\n".join(lines)


def format_horizontal_asymptote(asymptote: HorizontalAsymptote) -> str:
    """Formata uma assíntota horizontal."""
    arrow = "+∞" if asymptote.direction == "+oo" else "-∞"
    return f"y = {asymptote.y} quando x → {arrow}"


def format_oblique_asymptote(asymptote: ObliqueAsymptote) -> str:
    """Formata uma assíntota oblíqua."""
    arrow = "+∞" if asymptote.direction == "+oo" else "-∞"
    return f"y = {asymptote.expression} quando x → {arrow}"


def format_asymptote_analysis(analysis: AsymptoteAnalysis) -> str:
    """Formata a análise completa de assíntotas."""
    lines = ["Assíntotas:"]

    lines.append("\nAssíntotas verticais:")
    if analysis.vertical_asymptotes:
        for item in analysis.vertical_asymptotes:
            lines.append(format_vertical_asymptote(item))
    else:
        lines.append("Nenhuma.")

    lines.append("\nAssíntotas horizontais:")
    if analysis.horizontal_asymptotes:
        for item in analysis.horizontal_asymptotes:
            lines.append(format_horizontal_asymptote(item))
    else:
        lines.append("Nenhuma.")

    lines.append("\nAssíntotas oblíquas:")
    if analysis.oblique_asymptotes:
        for item in analysis.oblique_asymptotes:
            lines.append(format_oblique_asymptote(item))
    else:
        lines.append("Nenhuma.")

    if analysis.explanation:
        lines.append(f"\nExplicação: {analysis.explanation}")

    return "\n".join(lines)


def _find_vertical_asymptotes(
    function: SymbolicFunction,
    candidates: list[Any],
) -> list[VerticalAsymptote]:
    asymptotes: list[VerticalAsymptote] = []

    for candidate in candidates:
        left = limit_at(function, candidate, direction="-").value
        right = limit_at(function, candidate, direction="+").value
        exists = is_infinite_limit(left) or is_infinite_limit(right)

        if not exists:
            continue

        asymptotes.append(
            VerticalAsymptote(
                x=candidate,
                left_limit=left,
                right_limit=right,
                exists=True,
                explanation=(
                    f"x = {candidate} exclui o domínio ou anula o denominador e "
                    f"pelo menos um limite lateral é infinito."
                ),
            )
        )

    return asymptotes


def _find_horizontal_asymptotes(function: SymbolicFunction) -> list[HorizontalAsymptote]:
    asymptotes: list[HorizontalAsymptote] = []

    for direction, infinity_direction in (("+oo", "+"), ("-oo", "-")):
        value = limit_at_infinity(function, direction=infinity_direction).value
        exists = is_finite_real(value)

        asymptotes.append(
            HorizontalAsymptote(
                direction=direction,
                y=value if exists else None,
                exists=exists,
                explanation=(
                    f"Limite finito L = {value} quando x → "
                    f"{'+∞' if direction == '+oo' else '-∞'}."
                    if exists
                    else f"Limite quando x → {'+∞' if direction == '+oo' else '-∞'} "
                    f"não é finito ({value})."
                ),
            )
        )

    return [item for item in asymptotes if item.exists]


def _find_oblique_asymptotes(
    function: SymbolicFunction,
    horizontal_directions: set[str],
) -> list[ObliqueAsymptote]:
    asymptotes: list[ObliqueAsymptote] = []
    symbol = function.symbol
    expr = function.expr

    for direction, infinity_direction in (("+oo", "+"), ("-oo", "-")):
        if direction in horizontal_directions:
            continue

        infinity_point = oo if infinity_direction == "+" else -oo
        slope = limit(expr / symbol, symbol, infinity_point)
        if not is_finite_real(slope) or sp.simplify(slope) == 0:
            continue

        intercept = limit(expr - slope * symbol, symbol, infinity_point)
        if not is_finite_real(intercept):
            continue

        expression = sp.simplify(slope * symbol + intercept)
        asymptotes.append(
            ObliqueAsymptote(
                direction=direction,
                slope=slope,
                intercept=intercept,
                expression=expression,
                exists=True,
                explanation=(
                    f"m = {slope}, b = {intercept}; y = {expression} quando x → "
                    f"{'+∞' if direction == '+oo' else '-∞'}."
                ),
            )
        )

    return asymptotes


def _domain_excluded_points(function: SymbolicFunction) -> set[Any]:
    """Extrai pontos isolados excluídos do domínio real."""
    excluded: set[Any] = set()
    domain = find_real_domain(function).domain
    symbol = function.symbol

    if hasattr(domain, "is_Complement") and domain.is_Complement:
        excluded_set = domain.args[1]
        if hasattr(excluded_set, "is_FiniteSet") and excluded_set.is_FiniteSet:
            excluded.update(excluded_set)

    if domain.is_Union:
        for interval in domain.args:
            if hasattr(interval, "is_Interval") and interval.is_Interval:
                for bound in (interval.start, interval.end):
                    if bound not in (S.NegativeInfinity, S.Infinity) and bound.is_real:
                        if not interval.contains(bound):
                            excluded.add(bound)

    real_excluded = set()
    for point in excluded:
        if sp.im(point).equals(0):
            real_excluded.add(sp.simplify(point))

    return real_excluded


def _has_infinite_trig_family(expr: Any) -> bool:
    trig_generators = (sp.tan, sp.cot, sp.sec, sp.csc)
    return any(expr.has(generator) for generator in trig_generators)


def _determine_case(
    vertical: list[VerticalAsymptote],
    horizontal: list[HorizontalAsymptote],
    oblique: list[ObliqueAsymptote],
) -> str:
    has_v = bool(vertical)
    has_h = bool(horizontal)
    has_o = bool(oblique)

    if not has_v and not has_h and not has_o:
        return "no_asymptotes"
    if has_v and not has_h and not has_o:
        return "vertical_only"
    if has_h and not has_v and not has_o:
        return "horizontal_only"
    if has_o and not has_v and not has_h:
        return "oblique_only"
    if (has_v and has_h) or (has_v and has_o) or (has_h and has_o):
        return "mixed"
    return "general"


def _format_limit_value(value: Any) -> str:
    if value in (oo, sp.S.Infinity):
        return "+∞"
    if value in (-oo, sp.S.NegativeInfinity):
        return "-∞"
    return str(value)
