"""Bounded README-only execution, snippet extraction and static validation.

Never runs the canonical suite or optional training automatically. Logs stay
outside the repository; M10D.6A evidence is only read, never rewritten.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import time
import tomllib

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'reports/m10d6/readme_verification.json'
BASELINE = '143b5eecba95b63593457f709b2da3aaa3f91952'
LOGS = Path.home() / '.hermes/logs/analyticmath-lab/m10d6b'


def load():
    return json.loads(OUT.read_text())


def save(data):
    OUT.write_text(json.dumps(data, indent=2) + '\n')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def match(pattern, text):
    found = re.search(pattern, text, re.M)
    if found is None:
        raise ValueError('Missing output evidence: ' + pattern)
    return found


def blocks():
    text = (ROOT / 'README.md').read_text()
    return {name: {'language': lang, 'code': code} for name, lang, code in
            re.findall(r'<!-- readme: ([a-z-]+) -->\s*```([^\n]+)\n(.*?)\n```', text, re.S)}


def snapshot():
    data = load()
    if 'immutable_hashes' in data:
        raise RuntimeError('Snapshot already exists; preserve it')
    names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASELINE], cwd=ROOT, text=True).splitlines()
    data['immutable_hashes'] = {p: sha(ROOT / p) for p in names if p != 'README.md'}
    data['initial_readme_sha256'] = hashlib.sha256(subprocess.check_output(['git', 'show', BASELINE + ':README.md'], cwd=ROOT)).hexdigest()
    data['consulted_audit_hashes'] = {p: sha(ROOT / ('reports/m10d6/' + p)) for p in [
        'audit_summary.md', 'documentation_architecture_reconciled.md', 'readme_plan.md',
        'readme_inventory.json', 'api.json', 'exports.json', 'qualified_api.json',
        'scientific_contracts.md', 'resource_controls.json', 'refusal_review.json',
        'examples_tests_inventory.json']}
    save(data)
    print(json.dumps({'immutable_paths_snapshotted': len(data['immutable_hashes'])}))


def extract(name, destination):
    block = blocks()[name]
    path = Path(destination)
    if path.exists():
        raise FileExistsError(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(block['code'] + '\n')
    print(json.dumps({'block': name, 'language': block['language'], 'sha256': sha(path), 'path': str(path)}))


def run(name, cwd, command):
    if not command:
        raise ValueError('Explicit command required')
    data = load()
    if name in data.get('executions', {}):
        raise RuntimeError('Gate already recorded; use a separate name for a justified retry')
    LOGS.mkdir(parents=True, exist_ok=True)
    log = LOGS / (name + '.log')
    if log.exists():
        raise FileExistsError(log)
    record = {'command': command, 'cwd': str(Path(cwd).resolve()),
              'status': 'RUNNING', 'start_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
              'log': str(log), 'environment': {k: os.environ.get(k) for k in [
                  'JULIA_LOAD_PATH', 'JULIA_DEPOT_PATH', 'JULIA_PKG_OFFLINE',
                  'JULIA_PKG_PRECOMPILE_AUTO', 'JULIA_NUM_THREADS', 'OPENBLAS_NUM_THREADS']}}
    data.setdefault('executions', {})[name] = record
    save(data)
    with log.open('w') as stream:
        child = subprocess.Popen(command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT)
        record['pid'] = child.pid
        save(data)
        exit_code = child.wait()
    record.update(status='PASSED' if exit_code == 0 else 'FAILED', exit_code=exit_code,
                  end_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), log_sha256=sha(log))
    save(data)
    print(log.read_text())
    print(json.dumps({'gate': name, 'exit_code': exit_code, 'log': str(log)}))
    if exit_code:
        raise SystemExit(exit_code)


def static():
    data = load()
    errors = []
    for p, expected in data['immutable_hashes'].items():
        if not (ROOT / p).is_file() or sha(ROOT / p) != expected:
            errors.append('Protected file changed: ' + p)
    changed = subprocess.check_output(
        ['git', 'diff', BASELINE, '--name-only'], cwd=ROOT, text=True).splitlines()
    errors.extend('Protected baseline diff: ' + p for p in changed
                  if p in data['immutable_hashes'])
    text = (ROOT / 'README.md').read_text()
    headings = []
    for line in text.splitlines():
        if line.startswith('#'):
            heading = re.sub(r'[^\w\- ]', '', line.lstrip('#').strip().lower()).replace(' ', '-')
            headings.append(heading)
    links = []
    for target in re.findall(r'!?\[[^\]]*\]\(([^\s)]+)\)', text):
        if target.startswith(('https://', 'http://')):
            continue
        path, _, anchor = target.partition('#')
        if path and not (ROOT / path).exists():
            errors.append('Missing relative link: ' + target)
        if not path and anchor and anchor not in headings:
            errors.append('Missing README heading: ' + target)
        links.append(target)
    png = ROOT / 'docs/assets/readme/coupled_oscillator.png'
    image = None
    if png.exists():
        raw = png.read_bytes()
        if raw[:8] != b'\x89PNG\r\n\x1a\n' or len(raw) <= 1000:
            errors.append('Invalid or empty README PNG')
        else:
            w, h = struct.unpack('>II', raw[16:24])
            image = {'path': str(png.relative_to(ROOT)), 'bytes': len(raw), 'width': w, 'height': h, 'sha256': sha(png)}
    else:
        errors.append('README linked image missing')
    b = blocks()
    required = {'consumer-install', 'checkout', 'local-develop', 'quick-start', 'flagship', 'figure', 'full-suite-not-run'}
    if set(b) != required:
        errors.append('Unexpected README executable-block set')
    source_paths = sorted(set(re.findall(r'examples/[\w/.-]+\.jl', text)))
    errors.extend('Missing example source: ' + p for p in source_paths
                  if not (ROOT / p).is_file())
    log_checks = {}
    for name, gate in data.get('executions', {}).items():
        valid = (gate.get('exit_code') == 0 and gate['status'] == 'PASSED'
                 and Path(gate['log']).is_file()
                 and sha(Path(gate['log'])) == gate.get('log_sha256'))
        log_checks[name] = valid
        if not valid:
            errors.append('Unverified execution log: ' + name)
    result = {'status': 'PASSED' if not errors else 'FAILED', 'errors': errors,
              'immutable_paths_checked': len(data['immutable_hashes']), 'relative_links': links,
              'blocks': {name: {'language': block['language'], 'sha256': hashlib.sha256((block['code'] + '\n').encode()).hexdigest()} for name, block in b.items()},
              'source_paths': source_paths, 'execution_log_checks': log_checks,
              'image': image, 'readme_lines': len(text.splitlines()), 'readme_sha256': sha(ROOT / 'README.md')}
    data['static_validation'] = result
    save(data)
    print(json.dumps(result, indent=2))
    if errors:
        raise SystemExit(1)


def evidence(scratch):
    """Read back installation and exact-snippet evidence, without rerunning Julia."""
    data = load()
    scratch = Path(scratch).resolve()
    extracted = {}
    for name, filename in [('consumer-install', 'consumer-install.jl'),
                           ('checkout', 'checkout.sh'),
                           ('local-develop', 'local-develop.jl'),
                           ('quick-start', 'quick-start.jl'), ('figure', 'figure.jl')]:
        expected = hashlib.sha256((blocks()[name]['code'] + '\n').encode()).hexdigest()
        actual = sha(scratch / filename)
        if expected != actual:
            raise ValueError('Executed snippet differs from README: ' + name)
        extracted[name] = {'sha256': actual, 'path': str(scratch / filename)}
    consumer = scratch / 'aml-first-run'
    project = tomllib.loads((consumer / 'Project.toml').read_text())
    manifest = tomllib.loads((consumer / 'Manifest.toml').read_text())
    if set(project['deps']) != {'AnalyticMathLab', 'Symbolics'}:
        raise ValueError('Independent consumer direct dependencies differ')
    clone = scratch / 'analyticmath-lab'
    remote_commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=clone, text=True).strip()
    remote_tree = subprocess.check_output(['git', 'rev-parse', remote_commit + '^{tree}'], cwd=ROOT, text=True).strip()
    installed = manifest['deps']['AnalyticMathLab'][0]
    if installed['git-tree-sha1'] != remote_tree:
        raise ValueError('URL installed tree differs from cloned commit')
    if subprocess.check_output(['git', 'status', '--porcelain'], cwd=clone):
        raise ValueError('Clone changed after instantiate')
    quick_log = Path(data['executions']['quick-start-consumer']['log']).read_text()
    pkgroot = Path(match(r'^Path: (.*)/src/AnalyticMathLab.jl$', quick_log).group(1))
    executable = [p for p in data['immutable_hashes']
                  if p.startswith(('src/', 'ext/', 'test/', 'examples/', 'notebooks/'))]
    for p in executable:
        if sha(pkgroot / p) != data['immutable_hashes'][p]:
            raise ValueError('Installed executable file differs from local: ' + p)
    focused = Path(data['executions']['focused-flagship']['log']).read_text()
    rows = re.findall(r'^(M10D4 [^|]+)\|\s*(\d+)\s+(\d+)\s+\S+\s*$', focused, re.M)
    if len(rows) != 3 or not all(a == b for _, a, b in rows) or 'FOCUSED_FLAGSHIP_COMPLETE' not in focused:
        raise ValueError('Focused test summaries/completion marker incomplete')
    flagship = Path(data['executions']['flagship']['log']).read_text()
    comparisons = re.findall(r'^\(stage = (.*)$', flagship, re.M)
    if len(comparisons) != 12 or not all('agreement = true' in c for c in comparisons):
        raise ValueError('Flagship comparisons incomplete')
    metric_names = ['trajectory_error', 'energy_drift', 'energy_oracle_error',
                    'hamiltonian_energy_error', 'hamiltonian_flow_error',
                    'mode_residual', 'orthogonality_error', 'energy', 'saved_points']
    metrics = {n: float(match(r'\b' + n + r' = ([\d.e+-]+)', flagship).group(1))
               for n in metric_names}
    evaluated = re.findall(r'^(-?[\d.e+-]+)$', quick_log, re.M)
    quick_values = {n: float(match(r'\b' + n + r' = (-?[\d.e+-]+)', quick_log).group(1))
                    for n in ['symbolic', 'automatic', 'central']}
    dependency_names = ['Symbolics', 'CairoMakie', 'Makie', 'SciMLBase', 'OrdinaryDiffEqTsit5']
    root_manifest = tomllib.loads((ROOT / 'Manifest.toml').read_text())
    data['recovered_initial_state'] = {
        'head': BASELINE, 'branch': 'main', 'ahead': 1, 'staged': [],
        'modified': ['README.md'], 'untracked': ['reports/m10d6/readme_check.py',
            'reports/m10d6/readme_implementation_report.md', 'reports/m10d6/readme_verification.json']}
    data['readback_evidence'] = {
        'executed_snippets': extracted, 'remote_commit': remote_commit,
        'remote_tree': remote_tree, 'installed_repo_url': installed['repo-url'],
        'consumer_direct_deps': project['deps'], 'installed_executable_files_matched': len(executable),
        'consumer_environment_hashes': {p: sha(consumer / p) for p in ['Project.toml', 'Manifest.toml']},
        'dependency_versions': {label: {n: m['deps'][n][0]['version'] for n in dependency_names}
                                for label, m in [('root', root_manifest), ('consumer', manifest)]},
        'focused_tests': {'passed': sum(int(a) for _, a, _ in rows), 'failed': 0, 'errors': 0,
                          'rows': [{'name': n.strip(), 'passed': int(a), 'total': int(b)} for n, a, b in rows]},
        'flagship': {'comparisons_passed': len(comparisons), 'metrics': metrics},
        'quick_start': {'value': float(evaluated[0]), 'derivative': float(evaluated[1]),
                       'values': quick_values,
                       'output': quick_log, 'checks': 'QUICK_START_ASSERTIONS_OK'},
        'skipped': ['full canonical suite', 'optional learning/training', 'stress benchmarks',
                    'standalone optional plot test file (README figure executed instead)',
                    'Julia 1.13 or other platforms', 'cold/empty depot installation',
                    'Documenter build and Wiki publication']}
    for name in ['quick-start-local', 'quick-start-consumer', 'quick-start-clone', 'local-develop']:
        if 'QUICK_START_ASSERTIONS_OK' not in Path(data['executions'][name]['log']).read_text():
            raise ValueError('Quick Start completion marker absent: ' + name)
    save(data)
    print(json.dumps(data['readback_evidence'], indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='action', required=True)
    sub.add_parser('snapshot')
    sub.add_parser('static')
    p = sub.add_parser('evidence')
    p.add_argument('scratch')
    p = sub.add_parser('extract')
    p.add_argument('name')
    p.add_argument('destination')
    p = sub.add_parser('run')
    p.add_argument('name')
    p.add_argument('--cwd', default=str(ROOT))
    p.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.action == 'snapshot':
        snapshot()
    elif args.action == 'extract':
        extract(args.name, args.destination)
    elif args.action == 'static':
        static()
    elif args.action == 'evidence':
        evidence(args.scratch)
    else:
        command = args.command[1:] if args.command[:1] == ['--'] else args.command
        run(args.name, args.cwd, command)
