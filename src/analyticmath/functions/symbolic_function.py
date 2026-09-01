"""Funções simbólicas gerais usando SymPy."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

import sympy as sp
from sympy import Symbol, diff, expand, integrate, latex, simplify, sympify
from sympy.core.expr import Expr

from analyticmath.functions.base import MathFunction
from analyticmath.functions.domain import RealDomainResult, find_real_domain
from analyticmath.functions.limits import LimitResult, limit_at, limit_at_infinity
from analyticmath.functions.roots import RootsResult, find_roots
from analyticmath.utils.errors import ParseError

if TYPE_CHECKING:
    from analyticmath.functions.analysis_context import FunctionAnalysisContext
    from analyticmath.functions.asymptotes import AsymptoteAnalysis
    from analyticmath.functions.concavity import ConcavityAnalysis
    from analyticmath.functions.continuity import ContinuityAnalysis
    from analyticmath.functions.critical_points import FunctionCriticalPointAnalysis
    from analyticmath.functions.inequalities import FunctionInequalitySolution
    from analyticmath.functions.report import FunctionAnalysisReport
    from analyticmath.functions.sign_table import FunctionSignTable
    from analyticmath.reports.plot_builder import FunctionPlotResult, PlotWindow


class SymbolicFunction(MathFunction):
    """Função real de uma variável representada simbolicamente com SymPy."""

    def __init__(
        self,
        expression: str | Expr,
        *,
        variable: str = "x",
    ) -> None:
        self.variable = variable
        self.symbol = Symbol(variable)

        try:
            if isinstance(expression, str):
                expr = sympify(expression, locals={variable: self.symbol})
            elif isinstance(expression, Expr):
                expr = expression
            else:
                raise ParseError(
                    f"Entrada inválida: esperada str ou Expr SymPy, recebido {type(expression).__name__}."
                )
        except ParseError:
            raise
        except Exception as exc:
            raise ParseError(f"Não foi possível interpretar a expressão: {expression!r}.") from exc

        self.expr = expr

    def __str__(self) -> str:
        return str(self.expr)

    def __repr__(self) -> str:
        return f"SymbolicFunction({self.expr!r}, variable={self.variable!r})"

    def latex(self) -> str:
        """Retorna representação LaTeX da função."""
        return latex(self.expr)

    def expanded(self) -> Expr:
        """Retorna a expressão expandida."""
        return expand(self.expr)

    def simplified(self) -> Expr:
        """Retorna a expressão simplificada."""
        return simplify(self.expr)

    def evaluate(self, value: int | float | complex | sp.Basic) -> Any:
        """Avalia a função em um ponto."""
        return self.expr.subs(self.symbol, value)

    def derivative(self, order: int = 1) -> SymbolicFunction:
        """Retorna ``SymbolicFunction`` representando a derivada."""
        derived = diff(self.expr, self.symbol, order)
        return SymbolicFunction(derived, variable=self.variable)

    def indefinite_integral(self) -> Expr:
        """Retorna a integral indefinida simbólica (com constante C)."""
        integration_constant = Symbol("C")
        return integrate(self.expr, self.symbol) + integration_constant

    def definite_integral(self, a: Any, b: Any) -> Any:
        """Retorna a integral definida de ``a`` até ``b``."""
        return integrate(self.expr, (self.symbol, a, b))

    def domain(self) -> RealDomainResult:
        """Retorna o domínio real da função."""
        return find_real_domain(self)

    def roots(self) -> RootsResult:
        """Retorna raízes reais e simbólicas de f(x) = 0."""
        return find_roots(self)

    def limit(
        self,
        point: int | float | sp.Basic,
        direction: str = "+-",
    ) -> LimitResult:
        """Calcula limite em ``point`` com direção opcional."""
        return limit_at(self, point, direction=direction)  # type: ignore[arg-type]

    def limit_infinity(self, direction: str = "+") -> LimitResult:
        """Calcula limite quando x tende a +∞ ou -∞."""
        return limit_at_infinity(self, direction=direction)  # type: ignore[arg-type]

    def integral(self) -> Expr:
        """Alias para integral indefinida (interface ``MathFunction``)."""
        return self.indefinite_integral()

    def limits(self) -> dict[str, Any]:
        """Retorna limites básicos nos infinitos."""
        return {
            "plus_infinity": self.limit_infinity("+"),
            "minus_infinity": self.limit_infinity("-"),
        }

    def asymptotes(self) -> AsymptoteAnalysis:
        """Analisa assíntotas verticais, horizontais e oblíquas."""
        from analyticmath.functions.asymptotes import AsymptoteAnalysis, analyze_asymptotes

        return analyze_asymptotes(self)

    def continuity(self) -> ContinuityAnalysis:
        """Analisa continuidade e descontinuidades no domínio real."""
        from analyticmath.functions.continuity import analyze_continuity

        return analyze_continuity(self)

    def sign_table(self) -> FunctionSignTable:
        """Constrói a tabela de sinais real da função."""
        from analyticmath.functions.sign_table import FunctionSignTable, build_function_sign_table

        return build_function_sign_table(self)

    def solve_inequality(self, operator: str) -> FunctionInequalitySolution:
        """Resolve f(x) relação ``operator`` 0 no domínio real."""
        from analyticmath.functions.inequalities import (
            FunctionInequalitySolution,
            solve_function_inequality,
        )

        return solve_function_inequality(self, operator)

    def inequality(self, operator: str) -> FunctionInequalitySolution:
        """Alias para ``solve_inequality``."""
        return self.solve_inequality(operator)

    def analyze_critical_points(self) -> FunctionCriticalPointAnalysis:
        """Analisa pontos críticos, classificação e monotonicidade."""
        from analyticmath.functions.critical_points import (
            FunctionCriticalPointAnalysis,
            analyze_function_critical_points,
        )

        return analyze_function_critical_points(self)

    def critical_points(self) -> list:
        """Retorna a lista de pontos críticos reais no domínio."""
        from analyticmath.functions.critical_points import FunctionCriticalPoint

        analysis = self.analyze_critical_points()
        return analysis.critical_points

    def analyze_concavity(self) -> ConcavityAnalysis:
        """Analisa concavidade e pontos de inflexão."""
        from analyticmath.functions.concavity import ConcavityAnalysis, analyze_concavity

        return analyze_concavity(self)

    def concavity(self) -> ConcavityAnalysis:
        """Alias para ``analyze_concavity``."""
        return self.analyze_concavity()

    def report(
        self,
        context: FunctionAnalysisContext | None = None,
    ) -> FunctionAnalysisReport:
        """Gera relatório unificado de análise."""
        from analyticmath.functions.report import FunctionAnalysisReport, generate_function_report

        return generate_function_report(self, context=context)

    def format_report(
        self,
        context: FunctionAnalysisContext | None = None,
    ) -> str:
        """Retorna o relatório formatado em texto."""
        from analyticmath.functions.report import format_function_report

        return format_function_report(self.report(context=context))

    def analysis_context(self) -> FunctionAnalysisContext:
        """Retorna contexto local de cache para análises."""
        from analyticmath.functions.analysis_context import FunctionAnalysisContext

        return FunctionAnalysisContext(self)

    def full_analysis(self) -> FunctionAnalysisContext:
        """Executa análises principais e retorna o contexto preenchido."""
        return self.analysis_context().full_analysis()

    def plot(
        self,
        context: FunctionAnalysisContext | None = None,
        window: PlotWindow | None = None,
        output_path: str | None = None,
        show: bool = False,
        theme: str = "xp_violet_classic",
    ) -> FunctionPlotResult:
        """Gera gráfico anotado da função."""
        from analyticmath.reports.plot_builder import build_function_plot

        return build_function_plot(
            self,
            context=context,
            window=window,
            output_path=output_path,
            show=show,
            theme=theme,
        )

    def export_report_bundle(
        self,
        output_dir: str,
        base_filename: str | None = None,
        **kwargs: Any,
    ):
        """Exporta pacote completo de relatório (PNG, HTML, metadata, etc.)."""
        from analyticmath.reports.export_bundle import (
            FunctionReportBundleOptions,
            FunctionReportBundleResult,
            export_function_report_bundle,
        )

        options = FunctionReportBundleOptions(
            output_dir=output_dir,
            base_filename=base_filename,
            **kwargs,
        )
        return export_function_report_bundle(self, options)
