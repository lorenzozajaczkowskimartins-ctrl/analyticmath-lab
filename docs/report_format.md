# Formato dos Relatórios Matemáticos

## Objetivo

Padronizar a estrutura dos relatórios gerados pelo AnalyticMath Lab, garantindo consistência entre módulos (polinômios, cálculo, álgebra linear) e compatibilidade com exportação HTML, PDF e LaTeX.

## Estrutura de alto nível

Todo relatório é um documento composto por **seções ordenadas**, cada uma com tipo, título, conteúdo e metadados opcionais.

```yaml
report:
  title: "Análise do polinômio P(x) = x³ - 6x² + 11x - 6"
  module: polynomial
  created_at: "2026-06-15T12:00:00"
  language: pt-BR
  sections:
    - type: summary
    - type: problem_statement
    - type: step_by_step
    - type: result
    - type: graph
    - type: verification
    - type: references
```

## Tipos de seção

### `summary`

Resumo executivo em linguagem natural (2–5 frases).

```json
{
  "type": "summary",
  "title": "Resumo",
  "content": "O polinômio possui três raízes reais distintas: x = 1, 2 e 3."
}
```

### `problem_statement`

Enunciado original e dados de entrada.

```json
{
  "type": "problem_statement",
  "title": "Problema",
  "latex": "P(x) = x^3 - 6x^2 + 11x - 6",
  "input": { "representation": "string", "value": "x^3 - 6*x^2 + 11*x - 6" }
}
```

### `step_by_step`

Passos intermediários com explicação e fórmulas.

```json
{
  "type": "step_by_step",
  "title": "Fatoração",
  "steps": [
    {
      "order": 1,
      "description": "Aplicamos o teorema das raízes racionais.",
      "latex": "P(1) = 0 \\Rightarrow (x-1) \\text{ é fator}",
      "notes": null
    }
  ]
}
```

### `result`

Resultado final destacado.

```json
{
  "type": "result",
  "title": "Raízes",
  "latex": "x \\in \\{1, 2, 3\\}",
  "numeric": [1.0, 2.0, 3.0]
}
```

### `table`

Tabelas (ex.: tabela de sinais).

```json
{
  "type": "table",
  "title": "Tabela de sinais",
  "headers": ["Intervalo", "Sinal de P(x)"],
  "rows": [["(-∞, 1)", "-"], ["(1, 2)", "+"], ["(2, 3)", "-"], ["(3, +∞)", "+"]]
}
```

### `graph`

Referência a figura gerada por matplotlib/plotly.

```json
{
  "type": "graph",
  "title": "Gráfico de P(x)",
  "figure_path": "output/polynomial_plot.png",
  "caption": "Comportamento de P(x) em [-1, 4].",
  "interactive": false
}
```

### `verification`

Checagens de consistência (substituição, erro numérico).

```json
{
  "type": "verification",
  "title": "Verificação",
  "checks": [
    { "label": "P(1) = 0", "passed": true, "detail": "0.0" }
  ]
}
```

### `references`

Teoremas, métodos e bibliografias citadas.

```json
{
  "type": "references",
  "title": "Referências",
  "items": ["Teorema do resto", "Método de Horner"]
}
```

## Modelo de dados Python (previsto)

```python
# TODO: implementar em reports.report_builder
@dataclass
class ReportSection:
    type: str
    title: str
    content: dict

@dataclass
class Report:
    title: str
    module: str
    sections: list[ReportSection]
```

## Renderização por formato

| Formato | Renderizador            | Observações                          |
|---------|-------------------------|--------------------------------------|
| HTML    | `html_renderer.py`      | MathJax/KaTeX para LaTeX inline      |
| LaTeX   | `latex_renderer.py`     | Artigo `article` ou `report`         |
| PDF     | `pdf_exporter.py`       | LaTeX → PDF ou weasyprint sobre HTML |

## Estilo visual (HTML)

- Fonte legível (system-ui ou serif para fórmulas)
- Seções numeradas automaticamente
- Blocos de resultado com destaque visual
- Gráficos responsivos (largura máxima 100%)

## Internacionalização

Campo `language` no relatório (`pt-BR`, `en-US`). Textos gerados pelo motor devem respeitar o locale; templates de seção ficam externalizáveis na Fase 2.

## Extensibilidade

Novos módulos registram tipos de seção específicos (ex.: `eigenvalue_spectrum` para álgebra linear) desde que implementem o contrato `ReportSection` e um template de renderização correspondente.
