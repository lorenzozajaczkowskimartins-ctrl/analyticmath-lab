"""Relatório unificado de análise de funções simbólicas gerais.

Reúne domínio, limites, continuidade, assíntotas, sinais, inequações,
pontos críticos e concavidade em estrutura textual e dataclasses.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Literal

import sympy as sp
from sympy import S, oo

from analyticmath.functions.analysis_context import FunctionAnalysisContext
from analyticmath.functions.asymptotes import format_asymptote_analysis
from analyticmath.functions.concavity import format_concavity_analysis
from analyticmath.functions.continuity import format_continuity_analysis, safe_function_value
from analyticmath.functions.critical_points import format_function_critical_point_analysis
from analyticmath.functions.inequalities import (
    format_function_inequality_solution,
    format_function_solution_interval,
)
from analyticmath.functions.sign_table import format_function_sign_table, is_point_in_domain

if TYPE_CHECKING:
    from analyticmath.functions.symbolic_function import SymbolicFunction

SectionStatus = Literal["ok", "warning", "error", "skipped", "unknown"]
ReportCase = Literal["complete", "partial", "failed", "unknown"]

_INEQUALITY_OPERATORS = (">", "<", ">=", "<=", "==", "!=")


@dataclass(frozen=True)
class FunctionReportSection:
    """Seção individual de um relatório de função."""

    title: str
    content: str
    status: str
    data: Any


@dataclass
class FunctionAnalysisReport:
    """Relatório matemático estruturado de uma função simbólica."""

    function: SymbolicFunction
    title: str
    sections: list[FunctionReportSection]
    summary: str
    warnings: list[str]
    errors: list[str]
    case: str = field(default="partial")


def generate_function_report(
    function: SymbolicFunction,
    context: FunctionAnalysisContext | None = None,
) -> FunctionAnalysisReport:
    """Gera relatório completo de análise para ``function``."""
    analysis_ctx = context if context is not None else FunctionAnalysisContext(function)
    var = function.variable
    section_data: dict[str, Any] = {}
    warnings: list[str] = list(analysis_ctx.warnings)
    errors: list[str] = []

    builders: list[tuple[str, Callable[[], tuple[str, str, Any]]]] = [
        ("1. Definição da função", lambda: _build_definition_section(function)),
        ("2. Domínio real", lambda: _build_domain_section(analysis_ctx, section_data)),
        ("3. Raízes e interceptos", lambda: _build_roots_section(function, analysis_ctx, section_data)),
        ("4. Limites principais", lambda: _build_limits_section(function, analysis_ctx, section_data)),
        ("5. Continuidade", lambda: _build_continuity_section(analysis_ctx, section_data)),
        ("6. Assíntotas", lambda: _build_asymptotes_section(analysis_ctx, section_data)),
        ("7. Tabela de sinais", lambda: _build_sign_table_section(analysis_ctx, section_data)),
        ("8. Inequações básicas", lambda: _build_inequalities_section(analysis_ctx, section_data)),
        ("9. Derivadas", lambda: _build_derivatives_section(function, analysis_ctx, section_data)),
        (
            "10. Monotonicidade e pontos críticos",
            lambda: _build_critical_points_section(analysis_ctx, section_data),
        ),
        (
            "11. Concavidade e pontos de inflexão",
            lambda: _build_concavity_section(analysis_ctx, section_data),
        ),
        (
            "12. Conclusão geométrica",
            lambda: _build_geometric_conclusion(function, section_data),
        ),
    ]

    sections: list[FunctionReportSection] = []
    for title, builder in builders:
        section = safe_build_section(title, builder)
        sections.append(section)
        _collect_section_messages(section, warnings, errors)

    for err in analysis_ctx.errors:
        if err not in errors:
            errors.append(err)

    case = _determine_report_case(sections, errors)
    summary = _build_summary(function, sections, case)

    return FunctionAnalysisReport(
        function=function,
        title=f"Relatório de Análise de Função — f({var})",
        sections=sections,
        summary=summary,
        warnings=warnings,
        errors=errors,
        case=case,
    )


def safe_build_section(
    title: str,
    builder: Callable[[], tuple[str, str, Any]],
) -> FunctionReportSection:
    """Constrói uma seção com tratamento seguro de falhas."""
    try:
        content, status, data = builder()
        return FunctionReportSection(
            title=title,
            content=content,
            status=status,
            data=data,
        )
    except Exception as exc:
        return FunctionReportSection(
            title=title,
            content=f"Não foi possível gerar esta seção: {exc}",
            status="error",
            data={"error": str(exc), "error_type": type(exc).__name__},
        )


def format_function_report(report: FunctionAnalysisReport) -> str:
    """Formata o relatório completo em texto Markdown-like."""
    var = report.function.variable
    lines = [
        "# Relatório de Análise de Função",
        "",
        f"Função: f({var}) = {report.function}",
        "",
        f"Resumo: {report.summary}",
        "",
    ]

    if report.warnings:
        lines.append("Avisos:")
        for warning in report.warnings:
            lines.append(f"- {warning}")
        lines.append("")

    if report.errors:
        lines.append("Erros:")
        for error in report.errors:
            lines.append(f"- {error}")
        lines.append("")

    for section in report.sections:
        lines.append(f"## {section.title}")
        lines.append("")
        if section.status != "ok":
            lines.append(f"_Status da seção: {section.status}_")
            lines.append("")
        lines.append(section.content)
        lines.append("")

    return "\n".join(lines).rstrip()


def _build_definition_section(function: SymbolicFunction) -> tuple[str, str, Any]:
    var = function.variable
    simplified = function.simplified()
    latex_repr = function.latex()

    content = "\n".join(
        [
            f"Expressão original: f({var}) = {function.expr}",
            f"Variável independente: {var}",
            f"Forma simplificada: {simplified}",
            f"Representação LaTeX: {latex_repr}",
        ]
    )
    data = {
        "expression": str(function.expr),
        "variable": var,
        "simplified": str(simplified),
        "latex": latex_repr,
    }
    return content, "ok", data


def _build_domain_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    domain_result = analysis_ctx.domain()
    if domain_result is None:
        return "Domínio real indeterminado.", "error", {}

    content = "\n".join(
        [
            f"Domínio real: {_humanize_infinity_text(str(domain_result.domain))}",
            f"Explicação: {domain_result.explanation}",
        ]
    )
    section_data["domain"] = domain_result
    return content, "ok", {"domain": str(domain_result.domain), "explanation": domain_result.explanation}


def _build_roots_section(
    function: SymbolicFunction,
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    roots_result = analysis_ctx.roots()
    if roots_result is None:
        return "Raízes indeterminadas.", "error", {}

    var = function.variable
    lines = [f"Análise de f({var}) = 0:", f"Explicação: {roots_result.explanation}"]

    if roots_result.real_roots:
        lines.append(f"Raízes reais encontradas: {roots_result.real_roots}")
    else:
        lines.append("Raízes reais encontradas: nenhuma ou não enumeradas.")

    if roots_result.roots:
        lines.append(f"Raízes simbólicas: {roots_result.roots}")

    intercept = None
    if is_point_in_domain(function, 0) == True:
        intercept = safe_function_value(function, 0)
        lines.append(f"Intercepto em y (f(0)): {intercept}")
    else:
        lines.append("Intercepto em y: x = 0 não pertence ao domínio.")

    status = "ok"
    explanation_lower = roots_result.explanation.lower()
    if "infinit" in explanation_lower or "periód" in explanation_lower:
        status = "warning"

    data = {
        "real_roots": roots_result.real_roots,
        "roots": roots_result.roots,
        "intercept_y": intercept,
        "explanation": roots_result.explanation,
    }
    section_data["roots"] = roots_result
    section_data["real_roots"] = roots_result.real_roots
    return "\n".join(lines), status, data


def _build_limits_section(
    function: SymbolicFunction,
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    var = function.variable
    lines: list[str] = []
    lateral_limits: list[dict[str, Any]] = []

    domain_result = analysis_ctx.domain()
    domain = domain_result.domain if domain_result is not None else S.Reals

    if domain_extends_to_positive_infinity(domain):
        plus = function.limit_infinity("+")
        lines.append(f"lim {var}→+∞ f({var}) = {_format_limit_value(plus.value)}")
    else:
        lines.append(f"lim {var}→+∞ não é considerado no domínio real da função.")

    if domain_extends_to_negative_infinity(domain):
        minus = function.limit_infinity("-")
        if _is_invalid_real_limit(minus.value):
            lines.append(f"lim {var}→-∞ não é considerado no domínio real da função.")
        else:
            lines.append(f"lim {var}→-∞ f({var}) = {_format_limit_value(minus.value)}")
    else:
        lines.append(f"lim {var}→-∞ não é considerado no domínio real da função.")

    discontinuity_points: set[str] = set()
    continuity = analysis_ctx.continuity()
    if continuity is not None:
        section_data["continuity_preview"] = continuity
        for discontinuity in continuity.discontinuities:
            point = discontinuity.x
            key = str(sp.simplify(point))
            discontinuity_points.add(key)
            left = function.limit(point, direction="-")
            right = function.limit(point, direction="+")
            lines.append(f"lim {var}→{point}⁻ f({var}) = {_format_limit_value(left.value)}")
            lines.append(f"lim {var}→{point}⁺ f({var}) = {_format_limit_value(right.value)}")
            lateral_limits.append(
                {
                    "point": key,
                    "left": str(left.value),
                    "right": str(right.value),
                    "kind": "discontinuity",
                }
            )

    for point in _domain_boundary_points(domain):
        key = str(sp.simplify(point))
        if key in discontinuity_points:
            continue
        right = function.limit(point, direction="+")
        if not _is_invalid_real_limit(right.value):
            lines.append(
                f"lim {var}→{point}⁺ f({var}) = {_format_limit_value(right.value)} "
                f"(fronteira do domínio)"
            )
            lateral_limits.append(
                {
                    "point": key,
                    "right": str(right.value),
                    "kind": "domain_boundary",
                }
            )
        left = function.limit(point, direction="-")
        if not _is_invalid_real_limit(left.value) and is_point_in_domain(function, point) != True:
            lines.append(
                f"lim {var}→{point}⁻ f({var}) = {_format_limit_value(left.value)} "
                f"(fronteira do domínio)"
            )
            lateral_limits.append(
                {
                    "point": key,
                    "left": str(left.value),
                    "kind": "domain_boundary",
                }
            )

    data = {
        "lateral_limits": lateral_limits,
        "domain": str(domain),
    }
    section_data["limits"] = data

    status = "unknown" if continuity is None else "ok"
    return "\n".join(lines), status, data


def _build_continuity_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    continuity = analysis_ctx.continuity()
    if continuity is None:
        return "Continuidade indeterminada.", "error", {}

    content = format_continuity_analysis(continuity)
    section_data["continuity"] = continuity

    status = "ok"
    if continuity.case == "unknown":
        status = "unknown"

    data = {
        "continuous_on_domain": continuity.continuous_on_domain,
        "case": continuity.case,
        "discontinuities": [
            {
                "x": str(item.x),
                "classification": item.classification,
                "removable": item.removable,
            }
            for item in continuity.discontinuities
        ],
    }
    return content, status, data


def _build_asymptotes_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    asymptotes = analysis_ctx.asymptotes()
    if asymptotes is None:
        return "Assíntotas indeterminadas.", "error", {}

    content = format_asymptote_analysis(asymptotes)
    section_data["asymptotes"] = asymptotes

    status = "ok"
    if asymptotes.case == "unknown":
        status = "unknown"

    data = {
        "vertical": [{"x": str(item.x)} for item in asymptotes.vertical_asymptotes],
        "horizontal": [
            {"direction": item.direction, "y": str(item.y)} for item in asymptotes.horizontal_asymptotes
        ],
        "oblique": [
            {"direction": item.direction, "expression": str(item.expression)}
            for item in asymptotes.oblique_asymptotes
        ],
    }
    return content, status, data


def _build_sign_table_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    sign_table = analysis_ctx.sign_table()
    if sign_table is None:
        return "Tabela de sinais indeterminada.", "error", {}

    content = format_function_sign_table(sign_table)
    section_data["sign_table"] = sign_table

    status = "ok"
    if sign_table.case == "unknown":
        status = "unknown"

    data = {"case": sign_table.case, "explanation": sign_table.explanation}
    return content, status, data


def _build_inequalities_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    solutions = analysis_ctx.inequalities()
    lines: list[str] = []
    status = "ok"

    for operator in _INEQUALITY_OPERATORS:
        solution = solutions.get(operator)
        if solution is None:
            lines.append(f"f(x) {operator} 0: indeterminado")
            lines.append("")
            status = "error"
            continue

        formatted = format_function_inequality_solution(solution)
        lines.append(formatted)
        lines.append("")
        if solution.case == "unknown":
            status = "unknown"

    section_data["inequalities"] = solutions
    return "\n".join(lines).strip(), status, {"operators": list(_INEQUALITY_OPERATORS)}


def _build_derivatives_section(
    function: SymbolicFunction,
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    var = function.variable
    first = analysis_ctx.derivative(1)
    second = analysis_ctx.derivative(2)

    if first is None or second is None:
        return "Derivadas indeterminadas.", "error", {}

    lines = [
        f"f'({var}) = {first}",
        f"f''({var}) = {second}",
        "",
        "A primeira derivada controla crescimento e decrescimento (monotonicidade).",
        "A segunda derivada controla concavidade e candidatos a inflexão.",
    ]

    third = None
    try:
        third_candidate = analysis_ctx.derivative(3)
        if third_candidate is not None:
            third_expr = sp.simplify(third_candidate.expr)
            if _is_simple_expression(third_expr):
                third = third_candidate
                lines.insert(2, f"f'''({var}) = {third}")
    except Exception:
        pass

    section_data["derivatives"] = {"first": first, "second": second, "third": third}
    data = {
        "first": str(first),
        "second": str(second),
        "third": str(third) if third is not None else None,
    }
    return "\n".join(lines), "ok", data


def _build_critical_points_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    analysis = analysis_ctx.critical_points()
    if analysis is None:
        return "Pontos críticos indeterminados.", "error", {}

    content = format_function_critical_point_analysis(analysis)
    section_data["critical_points"] = analysis

    status = "ok"
    if analysis.case == "unknown":
        status = "unknown"

    data = {
        "case": analysis.case,
        "critical_points": [str(point.x) for point in analysis.critical_points],
        "classifications": [point.classification for point in analysis.critical_points],
    }
    return content, status, data


def _build_concavity_section(
    analysis_ctx: FunctionAnalysisContext,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    analysis = analysis_ctx.concavity()
    if analysis is None:
        return "Concavidade indeterminada.", "error", {}

    content = format_concavity_analysis(analysis)
    section_data["concavity"] = analysis

    status = "ok"
    if analysis.case == "unknown":
        status = "unknown"

    data = {
        "case": analysis.case,
        "inflection_points": [str(point.x) for point in analysis.inflection_points],
        "classifications": [point.classification for point in analysis.inflection_points],
    }
    return content, status, data


def _build_geometric_conclusion(
    function: SymbolicFunction,
    section_data: dict[str, Any],
) -> tuple[str, str, Any]:
    var = function.variable
    parts: list[str] = []

    domain_result = section_data.get("domain")
    if domain_result is not None:
        domain_text = _humanize_infinity_text(str(domain_result.domain))
        if not domain_extends_to_negative_infinity(domain_result.domain) or not domain_extends_to_positive_infinity(
            domain_result.domain
        ):
            parts.append(
                f"A interpretação gráfica deve ser restrita ao domínio real {domain_text}."
            )
        else:
            parts.append(f"Domínio: {domain_text}.")

    sign_table = section_data.get("sign_table")
    if sign_table is not None:
        if sign_table.case == "always_positive":
            parts.append("A função permanece positiva no domínio analisado.")
        elif sign_table.case == "always_negative":
            parts.append("A função permanece negativa no domínio analisado.")
        elif sign_table.case == "zero_function":
            parts.append("A função é identicamente nula.")
        elif sign_table.case == "domain_limited":
            parts.append(
                "O sinal e o comportamento local devem ser lidos apenas nos intervalos válidos do domínio."
            )

    asymptotes = section_data.get("asymptotes")
    if asymptotes is not None and asymptotes.vertical_asymptotes:
        vertical = ", ".join(f"x = {item.x}" for item in asymptotes.vertical_asymptotes)
        parts.append(f"Assíntotas verticais em {vertical}.")
        parts.append(
            "O gráfico se separa em ramos nos pontos excluídos do domínio associados a essas assíntotas."
        )

    if asymptotes is not None and asymptotes.horizontal_asymptotes:
        horizontal = ", ".join(
            f"y = {_format_numeric_text(item.y)} quando x → {_format_limit_direction(item.direction)}"
            for item in asymptotes.horizontal_asymptotes
        )
        parts.append(f"Assíntotas horizontais: {horizontal}.")

    inequalities = section_data.get("inequalities")
    if inequalities:
        gt = inequalities.get(">")
        lt = inequalities.get("<")
        if gt is not None and gt.intervals:
            parts.append("Há regiões em que f(x) > 0.")
        if lt is not None and lt.intervals:
            parts.append("Há regiões em que f(x) < 0.")

    critical = section_data.get("critical_points")
    if critical is not None:
        if critical.critical_points:
            labels = ", ".join(
                f"x = {point.x} ({point.classification})" for point in critical.critical_points
            )
            parts.append(f"Pontos críticos relevantes: {labels}.")
        elif critical.case == "linear_function":
            parts.append("A função é monótona (linear ou afim) sem pontos críticos internos.")
        elif critical.case == "constant_function":
            parts.append("A função é constante; não há variação local.")

    concavity = section_data.get("concavity")
    if concavity is not None:
        if concavity.inflection_points:
            labels = ", ".join(
                f"x = {point.x} ({point.classification})" for point in concavity.inflection_points
            )
            parts.append(f"Pontos de inflexão confirmados: {labels}.")

        up_text = _format_interval_list(concavity.concave_up_intervals)
        down_text = _format_interval_list(concavity.concave_down_intervals)
        if up_text and down_text:
            parts.append(
                f"A função apresenta concavidade para cima em {up_text} "
                f"e para baixo em {down_text}."
            )
        elif up_text:
            parts.append(f"A função é côncava para cima em {up_text}.")
        elif down_text:
            parts.append(f"A função é côncava para baixo em {down_text}.")

    continuity = section_data.get("continuity")
    if continuity is not None and continuity.discontinuities:
        removable = [str(item.x) for item in continuity.discontinuities if item.removable]
        if removable:
            holes = ", ".join(f"x = {point}" for point in removable)
            parts.append(f"Há furo(s) ou descontinuidade(s) removível(is) em {holes}.")

    if not parts:
        parts.append(
            f"A função f({var}) foi analisada parcialmente; consulte as seções anteriores para detalhes."
        )

    content = _humanize_infinity_text(" ".join(parts))
    data = {"points": parts}
    return content, "ok", data


def _build_summary(
    function: SymbolicFunction,
    sections: list[FunctionReportSection],
    case: str,
) -> str:
    var = function.variable
    ok_count = sum(1 for section in sections if section.status == "ok")
    total = len(sections)
    return (
        f"Análise de f({var}) = {function} concluída com status: {case} "
        f"({ok_count}/{total} seções completas)."
    )


def _determine_report_case(sections: list[FunctionReportSection], errors: list[str]) -> str:
    error_count = sum(1 for section in sections if section.status == "error")
    unknown_count = sum(1 for section in sections if section.status == "unknown")

    if error_count >= max(1, len(sections) // 2):
        return "failed"

    if errors or error_count > 0:
        return "partial"

    if unknown_count >= max(1, len(sections) // 2):
        return "unknown"

    if unknown_count > 0:
        return "partial"

    return "complete"


def _collect_section_messages(
    section: FunctionReportSection,
    warnings: list[str],
    errors: list[str],
) -> None:
    if section.status == "warning":
        warnings.append(f"{section.title}: {section.content.splitlines()[0]}")
    elif section.status == "error":
        errors.append(f"{section.title}: {section.content.splitlines()[0]}")
    elif section.status == "unknown":
        warnings.append(f"{section.title}: resultado parcial ou indeterminado.")


def _is_simple_expression(expr: Any) -> bool:
    if expr.is_number:
        return True
    if expr.is_symbol:
        return True
    if expr.is_Add or expr.is_Mul or expr.is_Pow:
        return len(list(expr.args)) <= 4
    return False


def domain_extends_to_negative_infinity(domain: Any) -> bool:
    """Indica se o domínio se estende até -∞."""
    if domain in (S.Reals, sp.Reals) or str(domain) == "Reals":
        return True
    if getattr(domain, "is_Interval", False):
        return domain.start in (S.NegativeInfinity, -oo)
    if getattr(domain, "is_Union", False):
        return any(domain_extends_to_negative_infinity(arg) for arg in domain.args)
    return False


def domain_extends_to_positive_infinity(domain: Any) -> bool:
    """Indica se o domínio se estende até +∞."""
    if domain in (S.Reals, sp.Reals) or str(domain) == "Reals":
        return True
    if getattr(domain, "is_Interval", False):
        return domain.end in (S.Infinity, oo)
    if getattr(domain, "is_Union", False):
        return any(domain_extends_to_positive_infinity(arg) for arg in domain.args)
    return False


def _domain_boundary_points(domain: Any) -> list[Any]:
    """Retorna fronteiras reais do domínio (ex.: x = 0 em log(x), x = 1 em sqrt(x - 1))."""
    boundaries: list[Any] = []
    if getattr(domain, "is_Interval", False) and domain.start.is_real:
        boundaries.append(sp.simplify(domain.start))
    if getattr(domain, "is_Union", False):
        for arg in domain.args:
            for point in _domain_boundary_points(arg):
                if point not in boundaries:
                    boundaries.append(point)
    return boundaries


def _is_invalid_real_limit(value: Any) -> bool:
    if value is None:
        return True
    if value is sp.zoo or value is sp.nan:
        return True
    if getattr(value, "is_complex", False) and not sp.im(value).equals(0):
        return True
    text = str(value)
    return "I" in text and ("oo" in text or "inf" in text.lower())


def _format_limit_value(value: Any) -> str:
    if value in (sp.S.Infinity, oo):
        return "+∞"
    if value in (S.NegativeInfinity, -oo):
        return "-∞"
    return str(value)


def _format_interval_list(intervals: list[Any]) -> str:
    if not intervals:
        return ""
    return " ∪ ".join(format_function_solution_interval(interval) for interval in intervals)


def _humanize_infinity_text(text: str) -> str:
    """Substitui notações SymPy de infinito por símbolos legíveis."""
    replacements = (
        ("-oo", "-∞"),
        ("+oo", "+∞"),
        ("oo", "+∞"),
    )
    result = text
    for old, new in replacements:
        result = result.replace(old, new)
    return result


def _format_limit_direction(direction: str) -> str:
    if direction in ("+oo", "+"):
        return "+∞"
    if direction in ("-oo", "-"):
        return "-∞"
    return _humanize_infinity_text(str(direction))


def _format_numeric_text(value: Any) -> str:
    text = str(value)
    if text in ("1", "1.0"):
        return "1"
    return _humanize_infinity_text(text)
