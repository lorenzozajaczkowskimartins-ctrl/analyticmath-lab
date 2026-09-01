"""Gera executável Windows do AnalyticMath Lab com PyInstaller."""

from __future__ import annotations

import os
import shutil
import sys
import time
from pathlib import Path


def _staging_root() -> Path:
    """Diretório de build sem espaços (evita falha set_exe_build_timestamp no Windows)."""
    local_app_data = os.environ.get("LOCALAPPDATA")
    if local_app_data:
        return Path(local_app_data) / "AnalyticMathLab" / "pyinstaller"
    return Path.home() / "AppData" / "Local" / "AnalyticMathLab" / "pyinstaller"


def _running_analyticmath_processes() -> list[str]:
    """Lista PIDs de AnalyticMathLab.exe em execução (Windows)."""
    if sys.platform != "win32":
        return []

    try:
        import subprocess

        completed = subprocess.run(
            [
                "tasklist",
                "/FI",
                "IMAGENAME eq AnalyticMathLab.exe",
                "/FO",
                "CSV",
                "/NH",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return []

    pids: list[str] = []
    for line in completed.stdout.splitlines():
        if "AnalyticMathLab.exe" not in line:
            continue
        parts = [part.strip('"') for part in line.split(",")]
        if len(parts) >= 2 and parts[1].isdigit():
            pids.append(parts[1])
    return pids


def _publish_exe(
    staged_exe: Path,
    target_exe: Path,
    *,
    attempts: int = 6,
    delay_s: float = 2.0,
) -> None:
    """Copia o EXE do staging para dist/, com retry se o destino estiver bloqueado."""
    target_exe.parent.mkdir(parents=True, exist_ok=True)
    temp_target = target_exe.with_name(f"{target_exe.stem}.new{target_exe.suffix}")

    if temp_target.exists():
        temp_target.unlink()

    shutil.copy2(staged_exe, temp_target)

    last_error: PermissionError | OSError | None = None
    for attempt in range(1, attempts + 1):
        try:
            os.replace(temp_target, target_exe)
            return
        except PermissionError as exc:
            last_error = exc
            if attempt < attempts:
                print(
                    f"Destino bloqueado (tentativa {attempt}/{attempts}): "
                    f"aguardando {delay_s:.0f}s antes de substituir {target_exe.name}..."
                )
                time.sleep(delay_s)

    running = _running_analyticmath_processes()
    hints = [
        f"Não foi possível substituir {target_exe}.",
        "O arquivo provavelmente está em uso (WinError 32).",
        "",
        "Ações sugeridas:",
        "  1. Feche terminais/janelas com AnalyticMathLab.exe em execução",
        "  2. Encerre o processo no Gerenciador de Tarefas, se necessário",
        "  3. Aguarde o antivírus terminar a varredura e rode o build novamente",
    ]
    if running:
        hints.append(f"  Processos detectados: PID {', '.join(running)}")

    hints.extend(
        [
            "",
            f"Build válido no staging: {staged_exe}",
            f"Cópia alternativa salva em: {temp_target}",
            "Você pode fechar o processo e executar:",
            f'  copy /Y "{temp_target}" "{target_exe}"',
        ]
    )

    if last_error is not None:
        raise PermissionError("\n".join(hints)) from last_error

    raise PermissionError("\n".join(hints))


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    spec_path = root / "AnalyticMathLab.spec"
    cli_entry = root / "src" / "analyticmath" / "cli.py"
    project_dist = root / "dist"
    project_dist.mkdir(parents=True, exist_ok=True)

    staging = _staging_root()
    staging_dist = staging / "dist"
    staging_build = staging / "build"
    staging.mkdir(parents=True, exist_ok=True)

    if not cli_entry.is_file():
        print(f"Ponto de entrada não encontrado: {cli_entry}", file=sys.stderr)
        return 1

    if not spec_path.is_file():
        print(f"Arquivo spec não encontrado: {spec_path}", file=sys.stderr)
        return 1

    try:
        import PyInstaller.__main__
    except ImportError:
        print(
            "PyInstaller não instalado. Execute: pip install -e \".[dev]\"",
            file=sys.stderr,
        )
        return 1

    running = _running_analyticmath_processes()
    if running:
        print(
            "Aviso: AnalyticMathLab.exe está em execução "
            f"(PID {', '.join(running)}). "
            "Feche-o para evitar erro ao substituir dist/AnalyticMathLab.exe.",
        )

    for path in (staging_dist, staging_build):
        if path.exists():
            shutil.rmtree(path, ignore_errors=True)

    args = [
        str(spec_path),
        "--noconfirm",
        "--clean",
        "--distpath",
        str(staging_dist),
        "--workpath",
        str(staging_build),
    ]

    print("Executando PyInstaller:")
    print(f"  staging (sem espaços): {staging}")
    print(" ", " ".join(args))

    PyInstaller.__main__.run(args)

    staged_exe = staging_dist / "AnalyticMathLab.exe"
    if not staged_exe.is_file() or staged_exe.stat().st_size == 0:
        print(
            "Build falhou: executável não gerado no staging.\n"
            "Se o erro mencionar set_exe_build_timestamp, confirme que o antivírus "
            "não bloqueou o arquivo e tente novamente.",
            file=sys.stderr,
        )
        return 1

    target_exe = project_dist / "AnalyticMathLab.exe"
    try:
        _publish_exe(staged_exe, target_exe)
    except PermissionError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    size_mb = target_exe.stat().st_size / (1024 * 1024)
    print(f"Executável copiado para: {target_exe}")
    print(f"Tamanho: {size_mb:.2f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
