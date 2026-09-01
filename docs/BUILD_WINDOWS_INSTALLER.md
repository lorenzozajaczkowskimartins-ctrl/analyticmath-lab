# Build do instalador Windows (AnalyticMath Lab)

Este guia descreve como gerar o instalador `AnalyticMathLabSetup.exe` com [Inno Setup 6](https://jrsoftware.org/isinfo.php), empacotando o executável PyInstaller.

## Pré-requisitos

- Windows 10/11
- Python 3.12+ (ou 3.10+ conforme o projeto)
- Dependências de desenvolvimento: `pip install -e ".[dev]"` (inclui PyInstaller)
- **Inno Setup 6** instalado ([download](https://jrsoftware.org/isdl.php))

## Estratégia de instalação (sem administrador)

O script `installer/AnalyticMathLab.iss` usa:

```iss
DefaultDirName={localappdata}\Programs\AnalyticMath Lab
PrivilegesRequired=lowest
```

Isso instala em `%LOCALAPPDATA%\Programs\AnalyticMath Lab\` **por usuário**, sem pedir elevação UAC na maioria dos casos.

Alternativa com admin (não usada por padrão): `{autopf}\AnalyticMath Lab` exigiria permissões de administrador.

## Passo 1 — Gerar o executável

Na raiz do projeto:

```bash
python scripts/build_exe.py
```

Resultado esperado: `dist/AnalyticMathLab.exe`

## Passo 2 — Gerar o instalador

```bash
python scripts/build_installer.py
```

O script:

1. Verifica se `dist/AnalyticMathLab.exe` existe
2. Localiza `ISCC.exe` (Inno Setup Compiler)
3. Compila `installer/AnalyticMathLab.iss`

Resultado esperado:

```text
installer/output/AnalyticMathLabSetup.exe
```

## Passo 3 — Instalar e testar

1. Execute `installer/output/AnalyticMathLabSetup.exe`
2. Siga o assistente (instalação em `%LOCALAPPDATA%\Programs\AnalyticMath Lab`)
3. Abra o atalho **AnalyticMath Lab CLI** no Menu Iniciar — abre um terminal com `--help`
4. No prompt, rode:

```cmd
"%LOCALAPPDATA%\Programs\AnalyticMath Lab\AnalyticMathLab.exe" analyze-function "x**2" --out "%USERPROFILE%\Documents\AnalyticMathReports" --markdown
```

Verifique se foram criados PNG, HTML, Markdown e `metadata.json` em `Documents\AnalyticMathReports`.

## Conteúdo do instalador

| Item | Destino |
|------|---------|
| `AnalyticMathLab.exe` | `{app}\AnalyticMathLab.exe` |

Atalhos:

- Menu Iniciar: **AnalyticMath Lab CLI** → `cmd /K AnalyticMathLab.exe --help`
- Área de trabalho: opcional (tarefa desmarcada por padrão)

Pós-instalação: opção para abrir a CLI com `--help`.

## Ícone (opcional)

Quando existir `assets/analyticmath.ico`, o `.iss` usa automaticamente via `#ifexist`. Até lá, o instalador funciona com ícone padrão do Windows.

## Solução de problemas

| Problema | Ação |
|----------|------|
| EXE não encontrado | `python scripts/build_exe.py` |
| ISCC não encontrado | Instale Inno Setup 6; reinicie o terminal. Caminhos comuns: `%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe` (winget), `C:\Program Files (x86)\Inno Setup 6\ISCC.exe` |
| Compilação falha no `.iss` | Confirme que `dist/AnalyticMathLab.exe` existe antes de compilar |
| Antivírus bloqueia Setup | Assinatura de código (próximo passo recomendado) |

## Ver também

- [BUILD_WINDOWS_EXE.md](BUILD_WINDOWS_EXE.md) — gerar o `.exe` com PyInstaller

## Próximos passos

- Ícone `assets/analyticmath.ico` no EXE e no instalador
- Assinatura de código (Authenticode)
- Entrada no "Adicionar ou remover programas" com metadados completos
- Instalador MSI ou winget package
- UI Tauri integrada ao pipeline de bundle
