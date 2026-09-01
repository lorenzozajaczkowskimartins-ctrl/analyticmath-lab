# AnalyticMath Lab

Software de matemática analítica para resolver, analisar e gerar relatórios explicativos com gráficos.

## Visão geral

O **AnalyticMath Lab** é um motor matemático modular escrito em Python para análise simbólica e numérica. O projeto inclui APIs para polinômios e funções simbólicas, uma interface de linha de comando e exportação de relatórios com gráficos.

## Recursos atuais

- Análise de domínio, raízes, limites, derivadas e integrais com SymPy
- Análise de polinômios, inequações, sinais, pontos críticos e concavidade
- Relatórios explicativos em HTML e Markdown, metadados em JSON e gráficos em PNG
- CLI para analisar funções e exportar pacotes de relatório
- Empacotamento opcional para Windows com PyInstaller e Inno Setup

## Estrutura do projeto

```
analyticmath_lab/
├── src/analyticmath/     # Pacote principal
│   ├── core/             # Tipos e operações fundamentais
│   ├── functions/        # Funções simbólicas e análises completas
│   ├── polynomial/       # Polinômios
│   ├── linear_algebra/   # Matrizes, vetores e autovalores
│   ├── calculus/         # Derivadas, integrais, limites e Taylor
│   ├── geometry/         # Geometria analítica e cônicas
│   ├── vector_calculus/  # Campos e operadores vetoriais
│   ├── numeric/          # Métodos numéricos
│   ├── reports/          # Geração de relatórios
│   └── utils/            # Utilitários compartilhados
├── docs/                 # Documentação de visão e arquitetura
├── examples/             # Exemplos de uso
└── tests/                # Testes automatizados
```

## Instalação

```bash
pip install -e .
# ou
pip install -r requirements.txt
```

## Uso

```python
from analyticmath import SymbolicFunction

function = SymbolicFunction("(x + 1)/(x - 2)")
print(function.domain().domain)
print(function.roots().real_roots)
```

Pela CLI:

```bash
analyticmath analyze-function "(x + 1)/(x - 2)" --out output --markdown --show-files
```

Consulte `examples/` para demonstrações e `docs/` para a documentação detalhada.

## Desenvolvimento

```bash
pytest tests/
```

## Licença

MIT, conforme declarado em `pyproject.toml`.

## Estado do projeto

Versão `0.1.0`, em estágio pre-alpha. A API ainda pode mudar entre versões.
