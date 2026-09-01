# Arquitetura do AnalyticMath Lab

## Visão geral

O projeto segue uma arquitetura em **camadas modulares**, com dependências unidirecionais: módulos de domínio dependem de `core` e `utils`, mas não uns dos outros.

```
                    ┌─────────────────────────────────┐
                    │   Clientes futuros (Tauri,      │
                    │   Java, C++, CLI, Jupyter)      │
                    └───────────────┬─────────────────┘
                                    │ API Python
                    ┌───────────────▼─────────────────┐
                    │  Módulos de domínio           │
                    │  polynomial │ linear_algebra  │
                    │  calculus   │ geometry        │
                    │  vector_calculus              │
                    └───────────────┬─────────────────┘
                                    │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
┌─────────▼─────────┐   ┌───────────▼──────────┐   ┌─────────▼─────────┐
│      reports      │   │       numeric        │   │       utils       │
│  HTML/PDF/LaTeX   │   │  root_finding, ODE   │   │  errors, format   │
└─────────┬─────────┘   └───────────┬──────────┘   └─────────┬─────────┘
          │                         │                         │
          └─────────────────────────┼─────────────────────────┘
                                    │
                    ┌───────────────▼─────────────────┐
                    │            core                 │
                    │  expression, symbols, parser    │
                    └─────────────────────────────────┘
```

## Pacotes

### `core`

Fundamentos compartilhados: representação de expressões, símbolos, números, operações e parsing. Nenhum conhecimento de domínio (polinômio, matriz, etc.) deve residir aqui.

### Módulos de domínio

Cada módulo (`polynomial`, `linear_algebra`, …) expõe uma API pública via seu `__init__.py` e implementa algoritmos específicos. Módulos futuros não devem importar uns dos outros diretamente; compartilhamento ocorre via `core`, `numeric` ou `utils`.

### `numeric`

Algoritmos numéricos reutilizáveis (busca de raízes, integração, ODE). Usado quando a abordagem simbólica é insuficiente ou para validação cruzada.

### `reports`

Camada de apresentação: constrói relatórios estruturados a partir de resultados dos módulos de domínio. Renderizadores (HTML, LaTeX, PDF) e `plot_builder` ficam isolados aqui.

### `utils`

Formatação, validação de entradas e hierarquia de exceções customizadas.

## Convenções

| Aspecto            | Convenção                                              |
|--------------------|--------------------------------------------------------|
| Import público     | `from analyticmath.polynomial import Polynomial`       |
| Import interno     | `from analyticmath.core.expression import Expression`  |
| Testes             | Um arquivo `test_*.py` por área funcional              |
| Docstrings         | Google style, em português ou inglês (consistente)     |
| TODOs              | `# TODO:` para funcionalidades pendentes               |

## Fluxo típico (módulo de polinômios)

1. Entrada do usuário → `core.parser` converte string em expressão.
2. `polynomial.polynomial.Polynomial` encapsula coeficientes e metadados.
3. Operações (`roots`, `factorization`, `sign_table`, …) produzem objetos de resultado tipados.
4. `polynomial.report` ou `reports.report_builder` monta o relatório.
5. `reports.*_renderer` exporta para HTML/PDF/LaTeX.

## Integração com interfaces externas

O pacote Python será distribuído como biblioteca instalável (`pip install -e .`). Clientes desktop (Tauri, etc.) invocarão funções Python via subprocess, PyO3, JPype ou similar — a API deve permanecer estável e livre de dependências de GUI.

## Dependências externas

| Biblioteca  | Uso principal                          |
|-------------|----------------------------------------|
| SymPy       | Álgebra simbólica                      |
| NumPy       | Arrays numéricos, coeficientes         |
| SciPy       | Métodos numéricos avançados            |
| matplotlib  | Gráficos estáticos nos relatórios      |
| plotly      | Gráficos interativos (fase futura)     |
| pytest      | Testes automatizados                   |

## Próximos passos arquiteturais

- [ ] Definir tipos de resultado padronizados (`core` ou `utils`)
- [ ] Estabelecer contrato da API pública do módulo `polynomial`
- [ ] Prototipar `ReportBuilder` com seções reutilizáveis
- [ ] Documentar pontos de extensão para novos módulos
