"""Testes do relatório unificado de funções simbólicas."""

import sympy as sp

from analyticmath.functions import SymbolicFunction, format_function_report, generate_function_report


def _section_titles(report) -> list[str]:
    return [section.title for section in report.sections]


def _section_content(report, title_part: str) -> str:
    for section in report.sections:
        if title_part in section.title:
            return section.content
    return ""


def _section_status(report, title_part: str) -> str:
    for section in report.sections:
        if title_part in section.title:
            return section.status
    return ""


def test_quadratic_report_structure() -> None:
    function = SymbolicFunction("x**2")
    report = function.report()
    formatted = format_function_report(report)

    assert report.case == "complete"
    assert _section_status(report, "Inequações") == "ok"
    assert _section_status(report, "Concavidade") == "ok"
    assert "2. Domínio real" in _section_titles(report)
    assert formatted.startswith("# Relatório de Análise de Função")
    assert "f(x) = x**2" in formatted


def test_quadratic_report_no_spurious_warnings() -> None:
    report = SymbolicFunction("x**2").report()
    assert report.case != "failed"
    assert _section_status(report, "Inequações básicas") == "ok"
    assert _section_status(report, "Concavidade e pontos de inflexão") == "ok"


def test_rational_report_contains_key_results() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    report = generate_function_report(function)
    formatted = format_function_report(report)
    conclusion = _section_content(report, "Conclusão geométrica").lower()

    assert report.case in ("complete", "partial")
    assert report.case != "failed"
    assert _section_status(report, "Continuidade") == "ok"
    assert "assíntota" in formatted.lower()
    assert "2" in _section_content(report, "Assíntotas")
    assert "-1" in _section_content(report, "Raízes")
    assert "f(x) > 0" in formatted
    assert "ramos" in conclusion or "x = 2" in conclusion


def test_sin_over_x_report_continuity() -> None:
    function = SymbolicFunction("sin(x)/x")
    report = function.report()
    continuity = _section_content(report, "Continuidade").lower()
    limits = _section_content(report, "Limites")

    assert report.case in ("partial", "unknown")
    assert "descontinuidade" in continuity or "continuidade" in continuity
    assert "0" in continuity
    assert "0" in limits


def test_sqrt_report_domain_and_limits() -> None:
    function = SymbolicFunction("sqrt(x - 1)")
    report = function.report()
    formatted = format_function_report(report)
    limits = _section_content(report, "Limites")
    domain = _section_content(report, "Domínio")

    assert "oo*I" not in formatted
    assert "oo*I" not in limits
    assert "não é considerado no domínio real" in limits
    assert "1" in domain or "interval" in domain.lower()
    assert "f(x) >= 0" in formatted or "f(x) > 0" in formatted
    assert _section_status(report, "Tabela de sinais") == "ok"


def test_abs_report_does_not_break() -> None:
    function = SymbolicFunction("Abs(x)")
    report = function.report()
    formatted = function.format_report()

    assert len(report.sections) == 12
    assert report.case in ("complete", "partial", "unknown", "failed")
    assert "# Relatório de Análise de Função" in formatted


def test_format_report_method() -> None:
    function = SymbolicFunction("x**2")
    assert function.format_report() == format_function_report(function.report())


def test_format_report_spacing() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    report = function.report()
    formatted = format_function_report(report)
    conclusion = _section_content(report, "Conclusão geométrica")

    assert "paraf" not in formatted
    assert "1quando" not in formatted
    assert "estaversão" not in formatted
    assert "em quef" not in formatted
    assert "quandox" not in formatted
    assert "status'" not in formatted
    assert "status:" in formatted
    assert " quando x → " in conclusion
    assert "+oo" not in conclusion
    assert "-oo" not in conclusion
    assert "continuous_domain, aplicado a f(x)" in formatted


def test_rational_concavity_branch_explanation() -> None:
    report = SymbolicFunction("(x + 1)/(x - 2)").report()
    concavity = _section_content(report, "Concavidade")

    assert _section_status(report, "Concavidade") == "ok"
    assert "ramos separados" in concavity
    assert "côncava para baixo nos intervalos analisados" not in concavity
