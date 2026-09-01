"""Continuidade e classificação de descontinuidades em funções simbólicas."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import Piecewise, S, fraction, solve, together

from analyticmath.functions.asymptotes import (
    find_vertical_asymptote_candidates,
    is_finite_real,
    is_infinite_limit,
)
from analyticmath.functions.domain import find_real_domain
from analyticmath.functions.limits import limit_at

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

Classification = Literal[
    "removable",
    "infinite",
    "jump",
    "essential",
    "undefined",
    "unknown",
]

AnalysisCase = Literal[
    "continuous_on_domain",
    "has_discontinuities",
    "piecewise",
    "unknown",
]

_CLASSIFICATION_LABELS = {
    "removable": "descontinuidade removível",
    "infinite": "descontinuidade infinita",
    "jump": "descontinuidade de salto",
    "essential": "descontinuidade essencial/oscilatória",
    "undefined": "sem descontinuidade detectada",
    "unknown": "descontinuidade indeterminada",
}


@dataclass(frozen=True)
class Discontinuity:
    """Descontinuidade detectada em um ponto candidato."""

    x: Any
    left_limit: Any
    right_limit: Any
    function_value: Any | None
    classification: str
    removable: bool
    infinite: bool
    jump: bool
    vertical_asymptote: bool
    explanation: str


@dataclass
class ContinuityAnalysis:
    """Resultado da análise de continuidade no domínio real."""

    function: SymbolicFunction
    domain: Any
    discontinuities: list[Discontinuity]
    continuous_on_domain: bool
    explanation: str
    case: str = "continuous_on_domain"


def analyze_continuity(function: SymbolicFunction) -> ContinuityAnalysis:
    """Analisa continuidade e descontinuidades de ``function`` no domínio real."""
    domain_result = find_real_domain(function)
    domain = domain_result.domain
    notes: list[str] = []

    if _has_infinite_trig_family(function.expr):
        notes.append(
            "Funções trigonométricas periódicas possuem infinitas descontinuidades "
            "potenciais; esta versão não as enumera completamente."
        )

    candidates = find_discontinuity_candidates(function)
    discontinuities: list[Discontinuity] = []

    for point in candidates:
        if _is_domain_exterior_boundary(domain, point):
            if _should_note_boundary_behavior(function, point):
                notes.append(
                    f"x = {point} é fronteira do domínio; a função diverge ou não está "
                    f"definida ao se aproximar desse ponto."
                )
            continue

        discontinuity = classify_discontinuity(function, point)
        if discontinuity.classification in ("undefined",):
            continue
        if _is_continuous_at_point(function, point, discontinuity):
            continue
        discontinuities.append(discontinuity)

    continuous_on_domain = len(discontinuities) == 0
    explanation_parts: list[str] = []

    if continuous_on_domain:
        explanation_parts.append(
            "A função é contínua em todos os pontos internos do domínio real analisado."
        )
    else:
        explanation_parts.append(
            f"Foram detectadas {len(discontinuities)} descontinuidade(s) relevante(s)."
        )

    explanation_parts.extend(notes)

    return ContinuityAnalysis(
        function=function,
        domain=domain,
        discontinuities=discontinuities,
        continuous_on_domain=continuous_on_domain,
        explanation=" ".join(explanation_parts),
        case=_determine_case(function, discontinuities),
    )


def find_discontinuity_candidates(function: SymbolicFunction) -> list[Any]:
    """Lista candidatos reais a pontos de descontinuidade."""
    if _has_infinite_trig_family(function.expr):
        return []

    candidates: set[Any] = set()

    if not function.expr.has(Piecewise):
        candidates.update(find_vertical_asymptote_candidates(function))
    else:
        candidates.update(_piecewise_boundary_points(function.expr, function.symbol))
        _, denominator = fraction(together(function.expr))
        if denominator != 1:
            candidates.update(_solve_real_roots(denominator, function.symbol))

    candidates.update(_domain_interior_gaps(function))

    if function.expr.has(sp.log):
        candidates.update(_log_domain_boundaries(function))

    unique = list(dict.fromkeys(candidates))
    return sorted(unique, key=lambda value: float(sp.N(value)))


def classify_discontinuity(function: SymbolicFunction, point: Any) -> Discontinuity:
    """Classifica a descontinuidade (ou continuidade) em ``point``."""
    left_limit = limit_at(function, point, direction="-").value
    right_limit = limit_at(function, point, direction="+").value
    function_value = safe_function_value(function, point)

    classification, explanation = _classify_from_limits(
        function,
        point,
        left_limit,
        right_limit,
        function_value,
    )

    return Discontinuity(
        x=point,
        left_limit=left_limit,
        right_limit=right_limit,
        function_value=function_value,
        classification=classification,
        removable=classification == "removable",
        infinite=classification == "infinite",
        jump=classification == "jump",
        vertical_asymptote=classification == "infinite",
        explanation=explanation,
    )


def is_infinite(value: Any) -> bool:
    """Indica se ``value`` representa infinito."""
    return is_infinite_limit(value)


def values_equal(a: Any, b: Any) -> bool:
    """Compara dois valores simbólicos ou numéricos."""
    if a is None or b is None:
        return False
    try:
        return sp.simplify(a - b) == 0 or a.equals(b)
    except Exception:
        return False


def safe_function_value(function: SymbolicFunction, point: Any) -> Any | None:
    """Avalia f(point) apenas se o ponto pertence ao domínio real."""
    domain = find_real_domain(function).domain
    if domain.contains(point) != True:
        return None

    try:
        value = sp.simplify(function.evaluate(point))
    except Exception:
        return None

    if is_infinite(value) or value is sp.nan or getattr(value, "is_nan", False):
        return None
    if getattr(value, "is_complex", False) and not sp.im(value).equals(0):
        return None
    return value


def format_discontinuity(discontinuity: Discontinuity) -> str:
    """Formata uma descontinuidade para exibição."""
    label = _CLASSIFICATION_LABELS.get(
        discontinuity.classification,
        discontinuity.classification,
    )
    lines = [
        f"A função apresenta {label} em x = {discontinuity.x}.",
        f"lim x→{discontinuity.x}⁻ f(x) = {_format_value(discontinuity.left_limit)}",
        f"lim x→{discontinuity.x}⁺ f(x) = {_format_value(discontinuity.right_limit)}",
    ]
    if discontinuity.function_value is None:
        lines.append(f"f({discontinuity.x}) não está definida.")
    else:
        lines.append(f"f({discontinuity.x}) = {discontinuity.function_value}")
    lines.append(discontinuity.explanation)
    return "\n".join(lines)


def format_continuity_analysis(analysis: ContinuityAnalysis) -> str:
    """Formata a análise completa de continuidade."""
    lines = ["Continuidade:", f"Domínio: {analysis.domain}"]

    if analysis.continuous_on_domain:
        lines.append("A função é contínua em seu domínio real.")
    else:
        lines.append("Descontinuidades encontradas:")
        for index, item in enumerate(analysis.discontinuities, start=1):
            lines.append(f"\n{index}. {format_discontinuity(item)}")

    if analysis.explanation:
        lines.append(f"\nExplicação: {analysis.explanation}")

    return "\n".join(lines)


def _classify_from_limits(
    function: SymbolicFunction,
    point: Any,
    left_limit: Any,
    right_limit: Any,
    function_value: Any | None,
) -> tuple[str, str]:
    left_finite = is_finite_real(left_limit)
    right_finite = is_finite_real(right_limit)
    left_infinite = is_infinite(left_limit)
    right_infinite = is_infinite(right_limit)

    if left_infinite or right_infinite:
        return (
            "infinite",
            (
                f"Como pelo menos um limite lateral em x = {point} é infinito, "
                f"a descontinuidade é do tipo infinita (assíntota vertical)."
            ),
        )

    if _is_nonexistent_limit(left_limit) or _is_nonexistent_limit(right_limit):
        return (
            "essential",
            (
                f"Os limites laterais em x = {point} não existem ou são oscilatórios; "
                f"trata-se de descontinuidade essencial."
            ),
        )

    if not left_finite or not right_finite:
        return (
            "unknown",
            f"SymPy não determinou com segurança os limites laterais em x = {point}.",
        )

    if values_equal(left_limit, right_limit):
        if function_value is None or not values_equal(function_value, left_limit):
            return (
                "removable",
                (
                    "Como os limites laterais são iguais e finitos, mas a função "
                    "não está definida no ponto ou possui valor diferente do limite, "
                    "a descontinuidade é removível."
                ),
            )
        return (
            "undefined",
            f"A função parece contínua em x = {point} dentro do domínio analisado.",
        )

    return (
        "jump",
        (
            f"Os limites laterais finitos em x = {point} são diferentes "
            f"({left_limit} ≠ {right_limit}); trata-se de descontinuidade de salto."
        ),
    )


def _is_continuous_at_point(
    function: SymbolicFunction,
    point: Any,
    discontinuity: Discontinuity,
) -> bool:
    if discontinuity.classification == "undefined":
        return True
    domain = find_real_domain(function).domain
    if domain.contains(point) != True:
        return False
    value = discontinuity.function_value
    if value is None:
        return False
    return (
        is_finite_real(discontinuity.left_limit)
        and is_finite_real(discontinuity.right_limit)
        and values_equal(discontinuity.left_limit, discontinuity.right_limit)
        and values_equal(value, discontinuity.left_limit)
    )


def _is_nonexistent_limit(value: Any) -> bool:
    if value is sp.nan or getattr(value, "is_nan", False):
        return True
    if value in (sp.zoo, S.ComplexInfinity):
        return True
    return False


def _domain_interior_gaps(function: SymbolicFunction) -> set[Any]:
    """Pontos excluídos entre subintervalos do domínio."""
    gaps: set[Any] = set()
    domain = find_real_domain(function).domain

    if not domain.is_Union:
        return gaps

    intervals = [arg for arg in domain.args if hasattr(arg, "is_Interval") and arg.is_Interval]
    for left_interval, right_interval in zip(intervals[:-1], intervals[1:], strict=False):
        if left_interval.end == right_interval.start:
            point = sp.simplify(left_interval.end)
            if left_interval.right_open or right_interval.left_open:
                if sp.im(point).equals(0):
                    gaps.add(point)

    return gaps


def _is_domain_exterior_boundary(domain: Any, point: Any) -> bool:
    """Indica se ``point`` é fronteira exterior do domínio (não buraco interno)."""
    if domain.contains(point) == True:
        return False

    if domain.is_Interval:
        return _is_interval_exterior_boundary(domain, point)

    if domain.is_Union:
        if _is_interior_gap_point(domain, point):
            return False
        for arg in domain.args:
            if hasattr(arg, "is_Interval") and arg.is_Interval:
                if _is_interval_exterior_boundary(arg, point):
                    return True
        return False

    return False


def _is_interval_exterior_boundary(interval: Any, point: Any) -> bool:
    if not interval.is_Interval:
        return False
    if not values_equal(interval.start, point) and not values_equal(interval.end, point):
        return False
    if values_equal(interval.start, point) and interval.left_open:
        return True
    if values_equal(interval.end, point) and interval.right_open:
        return True
    return False


def _is_interior_gap_point(domain: Any, point: Any) -> bool:
    if not domain.is_Union:
        return False
    intervals = [arg for arg in domain.args if arg.is_Interval]
    for left_interval, right_interval in zip(intervals[:-1], intervals[1:], strict=False):
        if values_equal(left_interval.end, point) and values_equal(right_interval.start, point):
            if left_interval.right_open and right_interval.left_open:
                return True
    return False


def _should_note_boundary_behavior(function: SymbolicFunction, point: Any) -> bool:
    if not function.expr.has(sp.log):
        return False
    try:
        right = limit_at(function, point, direction="+").value
        return is_infinite(right)
    except Exception:
        return False


def _piecewise_boundary_points(expr: Any, symbol: sp.Symbol) -> set[Any]:
    points: set[Any] = set()
    if not expr.has(Piecewise):
        return points

    for piecewise in expr.atoms(Piecewise):
        for expr_piece, condition in piecewise.args:
            del expr_piece
            for atom in condition.atoms(sp.Rel):
                if atom.relational_infinite or atom.canonical.rhs == S.NaN:
                    continue
                if symbol in atom.free_symbols:
                    try:
                        solutions = solve(atom, symbol)
                        if isinstance(solutions, list):
                            points.update(solutions)
                        elif solutions is not None:
                            points.add(solutions)
                    except Exception:
                        continue
    return {sp.simplify(point) for point in points if sp.im(point).equals(0)}


def _log_domain_boundaries(function: SymbolicFunction) -> set[Any]:
    """Fronteiras de argumentos logarítmicos; apenas buracos internos serão usados."""
    del function
    return set()


def _solve_real_roots(expression: Any, symbol: sp.Symbol) -> set[Any]:
    roots: set[Any] = set()
    try:
        solutions = solve(expression, symbol)
        if isinstance(solutions, dict):
            solutions = list(solutions.values())
        elif not isinstance(solutions, list):
            solutions = [solutions]
        for root in solutions:
            if sp.im(root).equals(0):
                roots.add(sp.simplify(root))
    except Exception:
        pass
    return roots


def _has_infinite_trig_family(expr: Any) -> bool:
    return any(expr.has(generator) for generator in (sp.tan, sp.cot, sp.sec, sp.csc))


def _determine_case(function: SymbolicFunction, discontinuities: list[Discontinuity]) -> str:
    if not discontinuities:
        return "continuous_on_domain"
    if function.expr.has(Piecewise):
        return "piecewise"
    if any(item.classification == "unknown" for item in discontinuities):
        return "unknown"
    return "has_discontinuities"


def _format_value(value: Any) -> str:
    if is_infinite(value) and value in (-sp.oo, sp.S.NegativeInfinity):
        return "-∞"
    if is_infinite(value):
        return "+∞"
    return str(value)
