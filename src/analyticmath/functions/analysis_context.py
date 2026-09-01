"""Contexto e cache local para análises de funções simbólicas."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from analyticmath.functions.asymptotes import analyze_asymptotes
from analyticmath.functions.concavity import ConcavityAnalysis, analyze_concavity
from analyticmath.functions.continuity import ContinuityAnalysis, analyze_continuity
from analyticmath.functions.critical_points import (
    FunctionCriticalPointAnalysis,
    analyze_function_critical_points,
)
from analyticmath.functions.domain import RealDomainResult, find_real_domain
from analyticmath.functions.inequalities import (
    FunctionInequalitySolution,
    solve_function_inequality,
)
from analyticmath.functions.roots import RootsResult, find_roots
from analyticmath.functions.sign_table import FunctionSignTable, build_function_sign_table

if TYPE_CHECKING:
    from analyticmath.functions.asymptotes import AsymptoteAnalysis
    from analyticmath.functions.symbolic_function import SymbolicFunction

_BASIC_INEQUALITY_OPERATORS = (">", "<", ">=", "<=", "==", "!=")


class FunctionAnalysisContext:
    """Cache local de resultados de análise para uma função simbólica."""

    def __init__(self, function: SymbolicFunction) -> None:
        self.function = function
        self._domain: RealDomainResult | None = None
        self._roots: RootsResult | None = None
        self._continuity: ContinuityAnalysis | None = None
        self._asymptotes: AsymptoteAnalysis | None = None
        self._sign_table: FunctionSignTable | None = None
        self._inequalities: dict[str, FunctionInequalitySolution | None] = {}
        self._critical_points: FunctionCriticalPointAnalysis | None = None
        self._concavity: ConcavityAnalysis | None = None
        self._derivatives: dict[int, SymbolicFunction | None] = {}
        self.warnings: list[str] = []
        self.errors: list[str] = []

    def domain(self) -> RealDomainResult | None:
        """Retorna o domínio real cacheado."""
        if self._domain is not None:
            return self._domain
        try:
            self._domain = find_real_domain(self.function)
            return self._domain
        except Exception as exc:
            self._record_error("domain", exc)
            return None

    def roots(self) -> RootsResult | None:
        """Retorna raízes cacheadas."""
        if self._roots is not None:
            return self._roots
        try:
            self._roots = find_roots(self.function)
            return self._roots
        except Exception as exc:
            self._record_error("roots", exc)
            return None

    def continuity(self) -> ContinuityAnalysis | None:
        """Retorna análise de continuidade cacheada."""
        if self._continuity is not None:
            return self._continuity
        try:
            self._continuity = analyze_continuity(self.function)
            return self._continuity
        except Exception as exc:
            self._record_error("continuity", exc)
            return None

    def asymptotes(self) -> AsymptoteAnalysis | None:
        """Retorna análise de assíntotas cacheada."""
        if self._asymptotes is not None:
            return self._asymptotes
        try:
            self._asymptotes = analyze_asymptotes(self.function)
            return self._asymptotes
        except Exception as exc:
            self._record_error("asymptotes", exc)
            return None

    def sign_table(self) -> FunctionSignTable | None:
        """Retorna tabela de sinais cacheada."""
        if self._sign_table is not None:
            return self._sign_table
        try:
            self._sign_table = build_function_sign_table(self.function)
            return self._sign_table
        except Exception as exc:
            self._record_error("sign_table", exc)
            return None

    def inequality(self, operator: str) -> FunctionInequalitySolution | None:
        """Retorna solução cacheada de uma inequação básica."""
        if operator in self._inequalities:
            return self._inequalities[operator]
        try:
            solution = solve_function_inequality(self.function, operator)
            self._inequalities[operator] = solution
            return solution
        except Exception as exc:
            self._record_error(f"inequality({operator})", exc)
            self._inequalities[operator] = None
            return None

    def inequalities(self) -> dict[str, FunctionInequalitySolution | None]:
        """Calcula e retorna as seis inequações básicas cacheadas."""
        return {operator: self.inequality(operator) for operator in _BASIC_INEQUALITY_OPERATORS}

    def derivative(self, order: int = 1) -> SymbolicFunction | None:
        """Retorna derivada cacheada de ordem ``order``."""
        if order in self._derivatives:
            return self._derivatives[order]
        try:
            derived = self.function.derivative(order)
            self._derivatives[order] = derived
            return derived
        except Exception as exc:
            self._record_error(f"derivative({order})", exc)
            self._derivatives[order] = None
            return None

    def critical_points(self) -> FunctionCriticalPointAnalysis | None:
        """Retorna análise de pontos críticos cacheada."""
        if self._critical_points is not None:
            return self._critical_points
        try:
            self._critical_points = analyze_function_critical_points(self.function)
            return self._critical_points
        except Exception as exc:
            self._record_error("critical_points", exc)
            return None

    def concavity(self) -> ConcavityAnalysis | None:
        """Retorna análise de concavidade cacheada."""
        if self._concavity is not None:
            return self._concavity
        try:
            self._concavity = analyze_concavity(self.function)
            return self._concavity
        except Exception as exc:
            self._record_error("concavity", exc)
            return None

    def full_analysis(self) -> FunctionAnalysisContext:
        """Executa as análises principais em ordem e retorna o contexto."""
        self.domain()
        self.roots()
        self.continuity()
        self.asymptotes()
        self.sign_table()
        self.inequalities()
        self.derivative(1)
        self.derivative(2)
        self.critical_points()
        self.concavity()
        return self

    def _record_error(self, label: str, exc: Exception) -> None:
        self.errors.append(f"{label}: {exc}")
