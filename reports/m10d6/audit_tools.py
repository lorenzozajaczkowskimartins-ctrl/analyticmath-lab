"""Deterministic M10D.6A extraction/checkpoint helpers; not runtime code.

Lexical extraction is enumeration, never semantic review. Model-authored batch
records explicitly attach interpretation after actual bounded source reads.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "reports/m10d6"
BASELINE = "377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca"


def load(name):
    return json.loads((OUT / name).read_text())


def evidence(path):
    p = ROOT / path
    data = p.read_bytes()
    return {"path": path, "sha256": hashlib.sha256(data).hexdigest(),
            "bytes": len(data), "lines": len(data.decode().splitlines())}


def extract(path):
    lines = (ROOT / path).read_text().splitlines()
    declarations = []
    patterns = [r"^\s*(?:function\s+)?([\w.!]+)\s*\(",
                r"^\s*(?:mutable\s+)?struct\s+([\w]+)",
                r"^\s*abstract\s+type\s+([\w]+)",
                r"^\s*macro\s+([\w]+)"]
    for i, line in enumerate(lines):
        match = next((m for p in patterns if (m := re.match(p, line))), None)
        if not match:
            continue
        name = match.group(1)
        if name in {"if", "for", "while", "return", "elseif"}:
            continue
        snippet = line.strip()
        if line.lstrip().startswith("function ") and snippet.count("(") > snippet.count(")"):
            for continuation in lines[i + 1:i + 12]:
                snippet += "\n" + continuation.strip()
                if snippet.count("(") <= snippet.count(")"):
                    break
        declarations.append({"name": name, "line": i + 1, "declaration_text": snippet,
                             "evidence_level": "LEXICAL_ENUMERATION"})
    return {**evidence(path), "declarations": declarations,
            "evidence_level": "VERIFIED_EXTRACTION_ONLY"}


def checkpoint(batch, findings, api_records, related=None):
    """Append a new immutable batch and update progress; refuse overwrites."""
    path = OUT / "batches" / (batch + ".json")
    if path.exists():
        raise FileExistsError(path)
    files = []
    for source, note in findings.items():
        rec = evidence(source)
        rec.update(read_ranges=[[1, rec["lines"]]], inspection="FULL_SEMANTIC_READ",
                   semantic_findings=note if isinstance(note, list) else [note])
        files.append(rec)
    exports = {x["symbol"]: x for x in load("exports.json")["exports"]}
    for rec in api_records:
        owner = exports.get(rec["symbol"])
        if owner:
            rec.setdefault("family", owner["family"])
            rec.setdefault("stability", owner["stability"])
        rec.setdefault("evidence_level", "SOURCE_INSPECTED")
        rec.setdefault("runtime_verification", "NOT_RUN")
        rec.setdefault("coverage_status", "PARTIAL")
        rec.setdefault("documentation_target", "reference/" + rec.get("family", "shared") + ".md (proposed)")
    result = {"baseline": BASELINE, "batch": batch, "files": files,
              "apis": api_records, "related_evidence": related or [],
              "scope": "Source-semantic audit only; no fresh runtime/test pass"}
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    progress = load("progress.json")
    progress.setdefault("sequential_batches", []).append({"batch": batch,
                "evidence": str(path.relative_to(OUT)), "files": list(findings),
                "api_records": len(api_records), "status": "SOURCE_INSPECTED"})
    progress["execution_strategy"] = "SEQUENTIAL; no new subagents"
    progress["recovery"]["active_assignments"] = []
    progress["recovery"]["interrupted_assignments"] = ["Resource/refusal audit", "Core public API audit"]
    progress["recovery"]["note"] = "Both interrupted children persisted useful bounded evidence; whole audit completion requires reconciliation."
    (OUT / "progress.json").write_text(json.dumps(progress, indent=2) + "\n")
    print(json.dumps({"saved": str(path), "source_files": len(files), "api_records": len(api_records)}))


def declarations():
    inv = load("repository_inventory.json")["files"]
    records = [extract(f["path"]) for f in inv if f["path"].endswith(".jl")]
    path = OUT / "declarations.json"
    if path.exists():
        raise FileExistsError(path)
    path.write_text(json.dumps({"baseline": BASELINE, "scope": "Lexical declarations; not method-completeness or semantic review", "files": records}, indent=2) + "\n")
    print("extracted", len(records), "Julia files")


if __name__ == "__main__":
    declarations()
