# Build do executável Windows (AnalyticMath Lab)

Este guia descreve como instalar o pacote em modo desenvolvimento, usar a CLI e gerar um executável standalone com PyInstaller.

## Pré-requisitos

- Python 3.10 ou superior
- Windows (para o `.exe`; a CLI funciona em qualquer SO)

## Passo 1 — Instalar dependências de desenvolvimento

Na raiz do projeto `analyticmath_lab/`:

```bash
pip install -e ".[dev]"
```

Isso instala o pacote `analyticmath-lab`, pytest, pytest-cov e PyInstaller.

## Passo 2 — Verificar a CLI

```bash
python -m analyticmath.cli --help
```

Após a instalação editável, também funciona o entry point:

```bash
analyticmath --help
```

Exemplo de análise:

```bash
python -m analyticmath.cli analyze-function "(x + 1)/(x - 2)" --out examples/output/cli --name rational --markdown --show-files
```

## Passo 3 — Gerar o executável

```bash
python scripts/build_exe.py
```

O script invoca PyInstaller com layout `src/`:

- spec: `AnalyticMathLab.spec` (backend Matplotlib `Agg` apenas)
- build em `%LOCALAPPDATA%\AnalyticMathLab\pyinstaller\` (path **sem espaços**)
- cópia final para `dist/AnalyticMathLab.exe`

Isso evita falhas conhecidas do PyInstaller em paths como `My Projects` (`set_exe_build_timestamp: Invalid argument`).

Artefatos:

- `dist/AnalyticMathLab.exe` — executável final
- `%LOCALAPPDATA%\AnalyticMathLab\pyinstaller\` — build temporário
- `AnalyticMathLab.spec` — spec versionado do projeto

## Passo 4 — Executar o EXE

No prompt do Windows, a partir da raiz do projeto:

```bash
dist\AnalyticMathLab.exe analyze-function "(x + 1)/(x - 2)" --out reports --markdown
```

Opções úteis:

| Opção | Descrição |
|-------|-----------|
| `--variable x` | Variável independente |
| `--out DIR` | Diretório de saída |
| `--name BASE` | Nome base dos arquivos |
| `--theme xp_violet_classic` | Tema visual |
| `--no-plot` | Omitir PNG |
| `--no-html` | Omitir HTML |
| `--markdown` | Incluir `.md` |
| `--external-plot` | HTML referencia PNG externo (sem base64) |
| `--show-files` | Lista arquivos um por linha |

## Passo 5 — Instalador Windows (opcional)

Após gerar o EXE, o próximo passo é criar um instalador com Inno Setup:

```bash
python scripts/build_installer.py
```

Guia completo: [BUILD_WINDOWS_INSTALLER.md](BUILD_WINDOWS_INSTALLER.md)

Resultado: `installer/output/AnalyticMathLabSetup.exe`

## Solução de problemas

- **PyInstaller não encontrado:** `pip install -e ".[dev]"` novamente.
- **set_exe_build_timestamp / Invalid argument:** path com espaços; o script usa staging em `%LOCALAPPDATA%`. Se persistir, verifique antivírus bloqueando o `.exe`.
- **WinError 32 / arquivo em uso ao copiar para dist/:** feche `AnalyticMathLab.exe` (terminais abertos, testes anteriores). O build em `%LOCALAPPDATA%\AnalyticMathLab\pyinstaller\dist\` continua válido; também pode existir `dist/AnalyticMathLab.new.exe`.
- **ImportError no EXE:** revise `AnalyticMathLab.spec` e adicione `hiddenimports` se necessário.
- **Matplotlib sem backend:** a CLI força `Agg`; o spec restringe backends via `hooksconfig`.

## Próximos passos (fora do escopo atual)

- Ícone `.ico` customizado no executável e instalador (`assets/analyticmath.ico`)
- Assinatura de código para distribuição
- Integração com UI Tauri
