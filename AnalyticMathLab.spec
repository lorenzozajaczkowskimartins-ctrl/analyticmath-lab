# -*- mode: python ; coding: utf-8 -*-
"""Spec PyInstaller — AnalyticMath Lab (CLI, backend Agg)."""

from pathlib import Path

from PyInstaller.utils.hooks import collect_data_files, collect_submodules

spec_root = Path(SPECPATH).resolve()
src = spec_root / "src"
cli_entry = str(src / "analyticmath" / "cli.py")

# Evita arrastar pytest/pandas/tkinter via matplotlib.tests
excludes = [
    "pytest",
    "_pytest",
    "pytest_cov",
    "pandas",
    "pyarrow",
    "sqlalchemy",
    "tkinter",
    "matplotlib.tests",
    "IPython",
    "notebook",
    "sphinx",
    "django",
    "flask",
    "pydantic",
    "rich",
]

datas = collect_data_files("matplotlib")
hiddenimports = collect_submodules("analyticmath")
hiddenimports += [
    "sympy",
    "scipy",
    "matplotlib.backends.backend_agg",
]

a = Analysis(
    [cli_entry],
    pathex=[str(src)],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={"matplotlib": {"backends": "Agg"}},
    runtime_hooks=[],
    excludes=excludes,
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="AnalyticMathLab",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
