"""Testes da CLI do AnalyticMath Lab."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from analyticmath.cli import main

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = PROJECT_ROOT / "src"


def _run_module_cli(*args: str) -> subprocess.CompletedProcess[str]:
    env = {**os.environ, "PYTHONPATH": str(SRC_DIR)}
    return subprocess.run(
        [sys.executable, "-m", "analyticmath.cli", *args],
        capture_output=True,
        text=True,
        env=env,
        cwd=PROJECT_ROOT,
    )


def test_cli_help_does_not_fail() -> None:
    result = _run_module_cli("--help")
    assert result.returncode == 0
    assert "analyze-function" in result.stdout


def test_analyze_function_generates_bundle(tmp_path: Path) -> None:
    exit_code = main(["analyze-function", "x**2", "--out", str(tmp_path)])
    assert exit_code == 0

    files = list(tmp_path.iterdir())
    assert files
    assert any(path.suffix == ".html" for path in files)
    assert any(path.suffix == ".png" for path in files)
    assert any(path.name.endswith("_metadata.json") for path in files)


def test_analyze_function_no_plot_skips_png(tmp_path: Path) -> None:
    exit_code = main(["analyze-function", "x**2", "--out", str(tmp_path), "--no-plot"])
    assert exit_code == 0

    assert not any(path.suffix == ".png" for path in tmp_path.iterdir())
    assert any(path.suffix == ".html" for path in tmp_path.iterdir())


def test_analyze_function_markdown(tmp_path: Path) -> None:
    exit_code = main(["analyze-function", "x**2", "--out", str(tmp_path), "--markdown"])
    assert exit_code == 0

    markdown_files = [path for path in tmp_path.iterdir() if path.suffix == ".md"]
    assert markdown_files
    content = markdown_files[0].read_text(encoding="utf-8")
    assert "Relatório de Análise de Função" in content


def test_analyze_function_invalid_expression(tmp_path: Path, capsys) -> None:
    exit_code = main(["analyze-function", "@@@invalid@@@", "--out", str(tmp_path)])
    captured = capsys.readouterr()

    assert exit_code == 2
    assert "Erro" in captured.err
    assert not list(tmp_path.iterdir())
