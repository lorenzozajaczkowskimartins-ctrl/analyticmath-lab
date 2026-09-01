"""Testes leves dos artefatos do instalador Windows."""

from __future__ import annotations

from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_installer_iss_exists() -> None:
    iss_path = PROJECT_ROOT / "installer" / "AnalyticMathLab.iss"
    assert iss_path.is_file()


def test_build_installer_script_exists() -> None:
    script_path = PROJECT_ROOT / "scripts" / "build_installer.py"
    assert script_path.is_file()


def test_installer_docs_exist() -> None:
    docs_path = PROJECT_ROOT / "docs" / "BUILD_WINDOWS_INSTALLER.md"
    assert docs_path.is_file()


def test_iss_contains_app_name_and_exe_reference() -> None:
    iss_path = PROJECT_ROOT / "installer" / "AnalyticMathLab.iss"
    content = iss_path.read_text(encoding="utf-8")

    assert "AppName=AnalyticMath Lab" in content or 'MyAppName "AnalyticMath Lab"' in content
    assert "AnalyticMathLab.exe" in content
