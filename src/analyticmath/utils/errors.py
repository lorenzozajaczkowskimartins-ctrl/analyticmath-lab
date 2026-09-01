"""Hierarquia de exceções customizadas do AnalyticMath Lab.

Exceções específicas para erros de parsing, domínio matemático
e falhas numéricas, facilitando tratamento por clientes externos.
"""


class AnalyticMathError(Exception):
    """Exceção base para todos os erros do AnalyticMath Lab."""


class ParseError(AnalyticMathError):
    """Erro ao interpretar entrada matemática (string inválida)."""


class DomainError(AnalyticMathError):
    """Operação inválida no domínio matemático (ex.: divisão por zero)."""


class NumericError(AnalyticMathError):
    """Falha em método numérico (convergência, overflow)."""


class ValidationError(AnalyticMathError):
    """Entrada não passou na validação de pré-condições."""


class PolynomialError(AnalyticMathError):
    """Erro específico do módulo de polinômios (entrada inválida ou operação inválida)."""
