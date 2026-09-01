# Visão do AnalyticMath Lab

## Propósito

O **AnalyticMath Lab** nasce da necessidade de um software unificado capaz de **resolver problemas de matemática analítica**, **explicar cada passo** e **apresentar resultados** em formatos adequados ao ensino, à pesquisa e à documentação técnica.

Diferente de calculadoras genéricas, o foco está em:

1. **Compreensão** — relatórios que explicam o raciocínio, não apenas o resultado final.
2. **Modularidade** — cada área da matemática vive em um módulo independente e expansível.
3. **Interoperabilidade** — núcleo Python desacoplado de qualquer interface gráfica, permitindo integração futura com Tauri, Java ou C++.
4. **Rigor** — combinação de métodos simbólicos (SymPy) e numéricos (NumPy/SciPy) conforme a natureza do problema.

## Público-alvo

- Estudantes de engenharia, física e matemática
- Professores que precisam gerar material didático
- Pesquisadores que desejam documentar cálculos de forma reprodutível

## Escopo inicial: polinômios

A primeira entrega concentra-se em polinômios reais e complexos:

- Operações algébricas (soma, multiplicação, divisão)
- Raízes e fatoração
- Teoremas (Bolzano, resto, raízes racionais)
- Análise de sinais e inequações
- Derivadas, integrais e pontos críticos
- Interpolação e regressão polinomial
- Relatórios com gráficos e explicações passo a passo

## Expansão futura

| Módulo              | Conteúdo previsto                                      |
|---------------------|--------------------------------------------------------|
| Álgebra linear      | Matrizes, autovalores, sistemas lineares               |
| Cálculo 1           | Limites, derivadas, integrais, séries de Taylor        |
| Geometria analítica | Retas, cônicas, curvas paramétricas                    |
| Cálculo vetorial    | Gradiente, divergência, rotacional, integrais de linha   |
| Relatórios          | HTML, PDF, LaTeX com figuras matplotlib/plotly         |

## Princípios de design

- **Separação de responsabilidades**: `core` fornece abstrações; módulos de domínio implementam a lógica matemática; `reports` cuida da apresentação.
- **Testabilidade**: cada função matemática deve ser testável de forma isolada.
- **Extensibilidade**: novos módulos seguem o mesmo padrão de pacotes sem alterar o núcleo.
- **Sem dependência de GUI**: toda comunicação com interfaces externas ocorrerá via API Python estável.

## Resultado esperado

Um laboratório matemático onde o usuário (ou uma aplicação cliente) submete um problema, recebe uma solução completa com explicações intermediárias, gráficos relevantes e exportação em múltiplos formatos — tudo a partir de um único motor Python bem estruturado.
