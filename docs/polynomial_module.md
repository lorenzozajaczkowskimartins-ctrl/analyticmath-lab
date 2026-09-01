# Módulo de Polinômios

## Escopo

Primeiro módulo funcional do AnalyticMath Lab. Cobre polinômios em uma variável (inicialmente real, com extensão complexa planejada).

## Arquivos e responsabilidades

| Arquivo               | Responsabilidade                                      |
|-----------------------|-------------------------------------------------------|
| `polynomial.py`       | Classe principal `Polynomial`, operações básicas      |
| `coefficients.py`     | Manipulação e normalização de coeficientes            |
| `roots.py`            | Cálculo de raízes (simbólico e numérico)              |
| `factorization.py`    | Fatoração em fatores irredutíveis                     |
| `division.py`         | Divisão euclidiana, algoritmo de Horner               |
| `theorems.py`         | Teorema do resto, Bolzano, raízes racionais           |
| `sign_table.py`       | Tabela de sinais a partir das raízes                  |
| `inequalities.py`     | Resolução de inequações polinomiais                   |
| `derivatives.py`      | Derivadas de ordem arbitrária                         |
| `integrals.py`        | Integrais definidas e indefinidas                     |
| `critical_points.py`  | Pontos críticos e classificação                       |
| `concavity.py`        | Análise de concavidade e pontos de inflexão             |
| `interpolation.py`    | Interpolação polinomial (Lagrange, Newton)            |
| `regression.py`       | Ajuste polinomial por mínimos quadrados               |
| `companion_matrix.py` | Matriz companheira para autovalores = raízes          |
| `report.py`           | Relatório específico de análise polinomial            |

## Funcionalidades planejadas (Fase 1)

### Entrada e representação

- Definição por coeficientes `[a_n, …, a_0]` ou string `"x^3 - 2x + 1"`
- Grau, termo líder, avaliação em ponto (`Horner`)
- Conversão SymPy ↔ `Polynomial`

### Álgebra

- Soma, subtração, multiplicação, divisão com resto
- Derivada e integral simbólica
- Fatoração sobre ℝ e ℂ (quando aplicável)

### Análise

- Raízes exatas e aproximadas
- Multiplicidade de raízes
- Tabela de sinais e gráfico esboçado
- Inequações do tipo `P(x) > 0`, `P(x) ≥ 0`, etc.
- Estudo de função: críticos, concavidade, inflexão

### Aplicações

- Interpolação por pontos dados
- Regressão polinomial
- Relatório completo exportável

## API prevista (rascunho)

```python
# TODO: implementar
from analyticmath.polynomial import Polynomial

p = Polynomial("x^3 - 6*x^2 + 11*x - 6")
p.roots()           # [1, 2, 3]
p.factor()          # (x - 1)(x - 2)(x - 3)
p.sign_table()      # objeto SignTable
p.generate_report() # Report
```

## Dependências internas

- `core`: expressões, símbolos, parser
- `numeric.root_finding`: fallback numérico para raízes
- `reports`: renderização final
- SymPy para manipulação simbólica; NumPy/SciPy para numérico

## Critérios de aceite (MVP)

1. Criar polinômio a partir de coeficientes ou string
2. Calcular raízes de polinômios até grau 4 simbolicamente
3. Gerar tabela de sinais para polinômios com raízes reais distintas
4. Produzir relatório textual básico (sem PDF ainda)
5. Cobertura de testes ≥ 80% no subpacote `polynomial`

## Limitações conhecidas (inicial)

- Polinômios multivariados fora do escopo da Fase 1
- Coeficientes simbólicos parametrizados: fase posterior
- Gráficos interativos: dependem do módulo `reports.plot_builder`
