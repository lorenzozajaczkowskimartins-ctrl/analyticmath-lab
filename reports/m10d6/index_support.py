"""Index frozen history/manifests without claiming semantic or runtime review."""
import csv
import json
import tomllib
from pathlib import Path
import audit_tools as audit


def record(paths, batch):
    destination = audit.OUT / 'batches' / (batch + '.json')
    if destination.exists():
        raise FileExistsError(destination)
    records = []
    for name in paths:
        path = audit.ROOT / name
        raw = path.read_bytes()
        rec = {'path': name, 'sha256': __import__('hashlib').sha256(raw).hexdigest(),
               'bytes': len(raw)}
        lines = path.read_text().splitlines() if path.suffix == '.md' else []
        if path.suffix == '.md':
            chosen = sorted(set(range(min(16, len(lines)))) |
                            {i for i, line in enumerate(lines) if line.startswith('#')} |
                            set(range(max(0, len(lines) - 12), len(lines))))
            rec.update(inspection='HEADINGS_AND_BOOKENDS_INSPECTED',
                       read_ranges=[[i + 1, i + 1] for i in chosen],
                       excerpt=[{'line': i + 1, 'text': lines[i]} for i in chosen],
                       semantic_findings=['Frozen historical audit/reference; indexed for documentation navigation, not revalidated as a current all-method contract or a fresh executed gate.'])
        elif path.suffix == '.toml':
            data = tomllib.loads(path.read_text())
            deps = data.get('deps', {})
            aml = deps.get('AnalyticMathLab', [])
            rec.update(inspection='DETERMINISTIC_MANIFEST_ENUMERATION',
                       metadata={key: data.get(key) for key in ['julia_version', 'manifest_format', 'project_hash']},
                       packages=len(deps), aml_registration=aml,
                       semantic_findings=['Environment lockfile indexed; no resolution/install/load verification.'])
        elif path.suffix == '.csv':
            with path.open(newline='') as stream:
                rows = list(csv.DictReader(stream))
            rec.update(inspection='DETERMINISTIC_FROZEN_DATA_ENUMERATION',
                       rows=len(rows), columns=list(rows[0]) if rows else [],
                       statuses=sorted({row.get('status', '') for row in rows}),
                       semantic_findings=['Historical measurements preserved; requested dimension, consumed work, cumulative allocation and returned-object bytes are not interchangeable. No measurements regenerated.'])
        else:
            rec.update(inspection='HASH_ENUMERATION_ONLY',
                       semantic_findings=['Frozen artifact; hash preservation only, no fresh rendering/measurement verification.'])
        records.append(rec)
    payload = {'baseline': audit.BASELINE, 'batch': batch, 'files': records,
               'apis': [], 'scope': 'Documentation/environment/evidence inventory only; not full semantic review or fresh scientific execution.'}
    destination.write_text(json.dumps(payload, indent=2) + '\n')
    progress = audit.load('progress.json')
    progress.setdefault('sequential_batches', []).append({
        'batch': batch, 'evidence': str(destination.relative_to(audit.OUT)),
        'files': paths, 'api_records': 0, 'status': 'INDEXED_NOT_FULL_SEMANTIC_READ'})
    (audit.OUT / 'progress.json').write_text(json.dumps(progress, indent=2) + '\n')
    print(json.dumps({'saved': str(destination), 'files': len(paths)}))
