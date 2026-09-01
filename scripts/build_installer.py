"""Gera instalador Windows do AnalyticMath Lab com Inno Setup."""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


def _project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def _find_iscc() -> Path | None:
    local_app_data = Path.home() / "AppData" / "Local" / "Programs" / "Inno Setup 6" / "ISCC.exe"
    candidates = [
        local_app_data,
        Path(r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe"),
        Path(r"C:\Program Files\Inno Setup 6\ISCC.exe"),
    ]

    path_from_path = shutil.which("ISCC.exe")
    if path_from_path:
        candidates.insert(0, Path(path_from_path))

    for candidate in candidates:
        if candidate.is_file():
            return candidate
    return None


def main() -> int:
    root = _project_root()
    exe_path = root / "dist" / "AnalyticMathLab.exe"
    iss_path = root / "installer" / "AnalyticMathLab.iss"
    output_dir = root / "installer" / "output"
    setup_exe = output_dir / "AnalyticMathLabSetup.exe"

    if not exe_path.is_file():
        print(
            f"Executável não encontrado: {exe_path}\n"
            "Gere o EXE primeiro com: python scripts/build_exe.py",
            file=sys.stderr,
        )
        return 1

    if not iss_path.is_file():
        print(f"Script Inno Setup não encontrado: {iss_path}", file=sys.stderr)
        return 1

    iscc = _find_iscc()
    if iscc is None:
        local_iscc = Path.home() / "AppData" / "Local" / "Programs" / "Inno Setup 6" / "ISCC.exe"
        print(
            "Inno Setup 6 (ISCC.exe) não encontrado.\n"
            "Instale em https://jrsoftware.org/isinfo.php e tente novamente.\n"
            "Caminhos verificados:\n"
            f"  {local_iscc}\n"
            "  C:\\Program Files (x86)\\Inno Setup 6\\ISCC.exe\n"
            "  C:\\Program Files\\Inno Setup 6\\ISCC.exe",
            file=sys.stderr,
        )
        return 1

    output_dir.mkdir(parents=True, exist_ok=True)

    command = [str(iscc), str(iss_path)]
    print("Executando Inno Setup:")
    print(" ", " ".join(command))

    completed = subprocess.run(command, cwd=root, check=False)
    if completed.returncode != 0:
        print("Falha ao compilar o instalador.", file=sys.stderr)
        return completed.returncode

    if setup_exe.is_file():
        size_mb = setup_exe.stat().st_size / (1024 * 1024)
        print(f"Instalador criado: {setup_exe}")
        print(f"Tamanho: {size_mb:.2f} MB")
        return 0

    print(f"Compilação concluída, mas o instalador não foi encontrado: {setup_exe}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
