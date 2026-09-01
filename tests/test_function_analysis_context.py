"""Testes do contexto de cache de análise de funções."""

import sympy as sp

from analyticmath.functions import SymbolicFunction, generate_function_report
from analyticmath.functions.analysis_context import FunctionAnalysisContext


def test_rational_context_basic_analyses() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = function.analysis_context()

    domain = context.domain()
    roots = context.roots()
    asymptotes = context.asymptotes()
    sign_table = context.sign_table()
    gt = context.inequality(">")
    all_inequalities = context.inequalities()

    assert domain is not None
    assert roots is not None
    assert asymptotes is not None
    assert sign_table is not None
    assert gt is not None
    assert set(all_inequalities.keys()) == {">", "<", ">=", "<=", "==", "!="}


def test_domain_cache_returns_same_object() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = FunctionAnalysisContext(function)

    first = context.domain()
    second = context.domain()

    assert first is not None
    assert second is not None
    assert first is second


def test_full_analysis_populates_fields() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = function.full_analysis()

    assert context._domain is not None
    assert context._roots is not None
    assert context._continuity is not None
    assert context._asymptotes is not None
    assert context._sign_table is not None
    assert len(context._inequalities) == 6
    assert 1 in context._derivatives
    assert 2 in context._derivatives
    assert context._critical_points is not None
    assert context._concavity is not None


def test_generate_report_with_context() -> None:
    function = SymbolicFunction("(x + 1)/(x - 2)")
    context = function.full_analysis()
    report = generate_function_report(function, context=context)

    assert report.case in ("complete", "partial")
    assert len(report.sections) == 12
    assert "-1" in report.sections[2].content


def test_abs_full_analysis_does_not_break() -> None:
    context = SymbolicFunction("Abs(x)").full_analysis()

    assert context is not None
    assert context.domain() is not None or context.errors


def test_inequality_cache_reuses_results() -> None:
    function = SymbolicFunction("x**2")
    context = FunctionAnalysisContext(function)

    first = context.inequality(">")
    second = context.inequality(">")

    assert first is second
