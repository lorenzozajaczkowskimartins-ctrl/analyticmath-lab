"""Render existing measurements only; never launches Julia or regenerates benchmarks.
Run from the root: python3 examples/scaling/plot_reports.py
Requires matplotlib; no scientific workload or GPU dependency. CSVs come from the
serialized Julia examples. Refused rows are annotated, never plotted as zero time.
"""
from pathlib import Path
import csv
import json
import hashlib
import shutil
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "output/scaling"
OUTPUT = ROOT / "docs/m10c_measurements"
PANELS = [
    ("when_dense_dies", "Dense normal modes / payload", "result_bytes"),
    ("partial_modes", "Partial chain: four modes", "result_bytes"),
    ("oscillator_stress", "ODE storage policies", "result_bytes"),
    ("statistics", "Stored vs lazy moments", "allocated_bytes"),
    ("atomistic", "All-pair vs coordination output", "result_bytes"),
    ("million_query_analysis", "Scientific-ML query analysis", "result_bytes"),
]

def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for path in sorted(INPUT.glob("*.csv")):
        shutil.copyfile(path, OUTPUT / path.name)
        manifest[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
    (OUTPUT / "csv_sha256.json").write_text(json.dumps(manifest, indent=2) + "\n")
    fig, axes = plt.subplots(3, 2, figsize=(15, 15), constrained_layout=True)
    for ax, (name, title, metric) in zip(axes.flat, PANELS):
        source = INPUT / (name + ".csv")
        if name == "oscillator_stress" and not source.exists():
            source = INPUT / "large_oscillator_ode.csv"
        with source.open() as stream:
            rows = list(csv.DictReader(stream))
        names = dict.fromkeys(r["name"] for r in rows)
        for label in names:
            selected = [r for r in rows if r["name"] == label and r["status"] == "completed"
                        and float(r[metric]) > 0 and float(r["n"]) > 0]
            if not selected:
                continue
            selected.sort(key=lambda r: float(r["n"]))
            ax.plot([float(r["n"]) for r in selected], [float(r[metric]) for r in selected],
                    marker="o", markersize=4, label=label)
        refused = [r for r in rows if r["status"] != "completed"]
        if refused:
            text = "; ".join(f'n={r["n"]}: {r["status"]}' for r in refused)
            ax.text(0.01, 0.01, text.replace("; ", "\n"), transform=ax.transAxes,
                    fontsize=8, va="bottom", bbox=dict(facecolor="white", alpha=0.9, edgecolor="#999"))
        ax.set(xscale="log", yscale="log", xlabel="Requested dimension / observations / queries",
               ylabel="Returned object bytes" if metric == "result_bytes" else "Allocated bytes per warmed call",
               title=title)
        ax.grid(True, which="both", alpha=0.2)
        ax.legend(loc="upper left", fontsize=8)
    fig.suptitle("M10C local measurements — Julia 1.12.7, Intel i7-1355U\n"
                 "Storage and cumulative allocation are distinct; refusal is not execution", fontsize=15)
    fig.savefig(OUTPUT / "scaling.png", dpi=130)
    fig.savefig(OUTPUT / "scaling.svg")
    print(json.dumps({"csv_files": len(manifest), "figures": [str(OUTPUT / "scaling.png"), str(OUTPUT / "scaling.svg")]}, indent=2))

if __name__ == "__main__":
    main()
