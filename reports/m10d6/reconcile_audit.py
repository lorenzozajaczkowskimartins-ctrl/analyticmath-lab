"""Deterministic M10D.6A aggregation and static verification, never Julia execution.

Build appends final artifacts and refuses overwrites. Verify is read-only and
checks the fixed baseline, source hashes, coverage, citations and preserved inputs.
"""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import subprocess

import audit_tools as audit

ROOT, OUT, BASELINE = audit.ROOT, audit.OUT, audit.BASELINE
CORE_FIELDS = ['source_location', 'public_signature', 'keywords', 'inputs',
               'returns', 'errors', 'optional_dependencies', 'numerical_limitations',
               'units', 'ownership', 'docstring_status', 'test_references',
               'example_references', 'documentation_target']
FAMILY_PAGES = {
    **dict.fromkeys(['F01', 'F02'], 'reference/core.md'),
    **dict.fromkeys(['F03', 'F04'], 'reference/scalar.md'),
    **dict.fromkeys(['F05', 'F06'], 'reference/derivatives.md'),
    'F07': 'reference/vector.md',
    **dict.fromkeys(['F08', 'F09'], 'reference/dynamics.md'),
    **dict.fromkeys(['F10', 'F11', 'F12', 'F13', 'F14'], 'reference/mechanics.md'),
    **dict.fromkeys(['F15', 'F16', 'F17', 'F18'], 'reference/atomistic.md'),
    **dict.fromkeys(['F19', 'F20', 'F21', 'F22', 'F24'], 'reference/statistics.md'),
    'F23': 'reference/transport.md', 'F25': 'reference/comparison.md',
    **dict.fromkeys(['F26', 'F27', 'F28', 'F29', 'F30', 'F33', 'F34'], 'reference/scientific-ml.md'),
    **dict.fromkeys(['F31', 'F32'], 'reference/datasets.md'),
    'F35': 'reference/plots.md', 'F36': 'guides/api-boundaries.md',
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(name, value):
    target = OUT / name
    if target.exists():
        raise FileExistsError(target)
    text = value if isinstance(value, str) else json.dumps(value, indent=2, ensure_ascii=False) + '\n'
    target.write_text(text)


def load(name):
    return json.loads((OUT / name).read_text())


def evidence_records():
    records = defaultdict(list)
    for name in ['core_inspection.json', 'parent_inspection.json']:
        for rec in load(name)['files']:
            records[rec['path']].append({'artifact': name, **rec})
    for path in sorted((OUT / 'batches').glob('*.json')):
        for rec in json.loads(path.read_text())['files']:
            records[rec['path']].append({'artifact': str(path.relative_to(OUT)), **rec})
    return records


def full_read(rec, count):
    return (rec.get('inspection') == 'FULL_SEMANTIC_READ' or rec.get('status') == 'SOURCE_INSPECTED') and any(a == 1 and b >= count for a, b in rec.get('read_ranges', []))


def category(path):
    if path.startswith('test/'):
        return 'TEST_SOURCE_NOT_EXECUTED'
    if path.endswith('Manifest.toml'):
        return 'ENVIRONMENT_LOCK_ENUMERATION_NOT_LOADED'
    if path.endswith('Project.toml'):
        return 'ENVIRONMENT_CONTRACT_SOURCE_INSPECTED'
    if path.startswith('examples/scaling/'):
        return 'MAINTAINER_ONLY_EXPERIMENT'
    if 'gate' in path or path.endswith('/runtests.jl'):
        return 'MANUAL_OPTIONAL_GATE_NOT_EXECUTED'
    if path.startswith('notebooks/'):
        return 'EXECUTABLE_NOTEBOOK_NOT_EXECUTED'
    return 'SCIENTIFIC_EXAMPLE_NOT_EXECUTED'


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from strings(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from strings(item)


def build():
    inputs = ['repository_inventory.json', 'exports.json', 'core_api.json',
              'core_inspection.json', 'core_findings.md', 'parent_inspection.json',
              'qualified_api.json', 'refusal_sites.json', 'refusals.json',
              'diagnostic_findings.md', 'scientific_contracts.md',
              'documentation_architecture.md', 'readme_plan.md',
              'hessian_question_outline.md', 'wiki_questions.json', 'wiki_questions.md',
              'recovery_validation.json']
    inputs += [str(p.relative_to(OUT)) for p in sorted((OUT / 'batches').glob('*.json'))]
    save('preserved_inputs.json', {'baseline': BASELINE, 'policy': 'Existing immutable findings and batches remain unchanged. Mutable checkpoint is separately snapshotted before final reconciliation.',
                                'files': [{'path': name, 'sha256': sha(OUT / name)} for name in inputs]})
    inv = load('repository_inventory.json')['files']
    evidence = evidence_records()
    coverage = []
    for rec in inv:
        reviews = evidence[rec['path']]
        full = any(full_read(r, rec.get('lines') or 0) for r in reviews)
        coverage.append({**rec, 'inspection_status': 'FULL_SEMANTIC_READ' if full else 'INDEXED_NOT_FULL_SEMANTIC_READ',
                         'review_evidence': reviews, 'runtime_verification': 'NOT_RUN_IN_M10D_6A'})
    save('coverage.json', {'baseline': BASELINE, 'files': coverage,
                          'scope': 'Complete repository index; full source/test/example semantic review is separate from historical bookends, manifest/data enumeration and hash-only assets.'})

    reviews = defaultdict(list)
    for rec in load('core_api.json')['symbols']:
        reviews[rec['symbol']].append({'audit_artifact': 'core_api.json', **rec})
    for path in sorted((OUT / 'batches').glob('*.json')):
        for rec in json.loads(path.read_text())['apis']:
            reviews[rec['symbol']].append({'audit_artifact': str(path.relative_to(OUT)), **rec})
    owned = load('exports.json')['exports']
    apis = []
    for owner in owned:
        variants = reviews[owner['symbol']]
        if not variants:
            raise AssertionError('Missing semantic API record: ' + owner['symbol'])
        record = {**owner, 'source_review': 'SEMANTICALLY_REVIEWED',
                  'documentation_coverage': 'PARTIAL_REFERENCE_IMPLEMENTATION_DEFERRED',
                  'runtime_verification': 'NOT_RUN_IN_M10D_6A',
                  'documentation_target': FAMILY_PAGES[owner['family']],
                  'reviewed_variants': variants}
        for field in CORE_FIELDS:
            if field == 'documentation_target':
                continue
            record[field] = [v[field] for v in variants if field in v]
        paths = set()
        for location in strings(record['source_location']):
            paths.update(re.findall(r'((?:src|ext)/[^\s:]+\.jl)', location))
        record['source_hashes'] = [{'path': p, 'sha256': sha(ROOT / p)} for p in sorted(paths)]
        if owner['symbol'] == 'diffusion_estimate':
            record['contract_correction'] = 'Index-time MSD is not explicitly rejected. A fitted per-index quantity is not a physical diffusion coefficient. Caller must justify the time scale and diffusive interval; source/test evidence overrides the stronger historical synopsis.'
        apis.append(record)
    save('api.json', {'baseline': BASELINE, 'export_count': len(apis),
                      'scope': 'All explicit exports; multiple reviews preserve shared overload contracts. Source-grounded signatures, not a freshly introspected Julia method table or claim of native-backend keyword completeness.',
                      'coverage_policy': 'Semantic audit complete for owned symbols; current documentation remains partial. Test/example lexical references are mentions, not branch coverage.',
                      'apis': apis, 'qualified_apis': load('qualified_api.json')['apis'],
                      'internal_family': load('exports.json')['families'][-1]})
    save('examples_tests_inventory.json', {'baseline': BASELINE, 'scope': 'All tracked tests, examples and notebooks; source inspection not execution.',
        'files': [{**r, 'role': category(r['path'])} for r in coverage if r['path'].startswith(('test/', 'examples/', 'notebooks/'))]})
    docs = []
    for rec in coverage:
        if not (rec['path'].startswith('docs/') or rec['path'] == 'README.md' or rec['path'] == 'examples/scaling/README.md'):
            continue
        headers = []
        if rec['path'].endswith('.md'):
            headers = [{'line': i, 'heading': line.lstrip('#').strip()} for i, line in enumerate((ROOT / rec['path']).read_text().splitlines(), 1) if line.startswith('#')]
        role = 'CURRENT_GUIDE' if rec['inspection_status'] == 'FULL_SEMANTIC_READ' else 'FROZEN_HISTORICAL_REFERENCE'
        if '/m10c_measurements/' in rec['path']:
            role = 'FROZEN_MEASUREMENT_ASSET'
        docs.append({**rec, 'documentation_role': role, 'headings': headers})
    save('documentation_inventory.json', {'baseline': BASELINE, 'scope': 'All existing docs/readme artifacts; history indexed without fresh gate validation or migration.', 'files': docs})
    site = load('refusal_sites.json')
    save('refusal_review.json', {'baseline': BASELINE,
        'scope': 'All source files reviewed and all public API refusal contracts indexed. Lexical sites remain candidates, not individually path-executed exceptions or a resolved Julia call graph.',
        'grouped_contracts': load('refusals.json')['groups'],
        'lexical_site_count': len(site['sites']), 'lexical_site_index': 'refusal_sites.json',
        'source_review_coverage': [{'path': r['path'], 'sha256': r['sha256'], 'inspection': r['inspection_status']} for r in coverage if r['path'].startswith(('src/', 'ext/'))],
        'public_error_contracts': [{'symbol': a['symbol'], 'source_location': a['source_location'], 'errors': a['errors'], 'numerical_limitations': a['numerical_limitations']} for a in apis],
        'actual_public_controls': 'resource_controls.json', 'runtime_verification': 'NOT_RUN_IN_M10D_6A'})
    wiki = load('wiki_questions.json')
    for q in wiki['questions']:
        q['documentation_target'] = next((FAMILY_PAGES[a['family']] for a in owned if a['symbol'] in q['public_apis']), q['documentation_target'])
        q['evidence_level'] = 'SOURCE_SUPPORTED_OUTLINE_NOT_PUBLISHED_OR_EXECUTED'
        if q['id'] == 'Q049':
            q['question'] = 'What time scale and fit-window assumptions are needed to interpret a diffusion estimate?'
            q['qualification'] = 'Implementation fits eligible index-time MSD as well; this does not establish a physical transport coefficient. Do not claim a direct physical-clock refusal.'
            q['evidence_references'] = ['src/trajectory/transport.jl:39-102', 'test/trajectory_transport.jl:17-40', 'docs/trajectory_statistics.md']
        if q['id'] in {'Q066', 'Q067', 'Q068', 'Q069', 'Q070'}:
            q['answer_readiness'] = 'SOURCE_SUPPORTED_OUTLINE_PENDING_IMPLEMENTATION'
            q['complete_answer_currently_possible'] = True
            q['qualification'] = 'Bounded answer from reviewed resource contracts is now possible; no global memory setter, RSS guarantee or generic matrix-free escape hatch.'
            q['audit_evidence'] = ['resource_controls.json', 'refusal_review.json', 'hessian_question_outline.md']
    additional = [
        ('Q086', 'Which pair-output limits are public, and does RDF remove quadratic work?', ['pair_distances', 'radial_distribution', 'coordination'], ['src/atomistic/core.jl:87-123', 'src/atomistic/distributions.jl']),
        ('Q087', 'Does prediction batch_size bound the returned output or training memory?', ['predict'], ['ext/AnalyticMathLabPINNExt.jl:155-200', 'ext/AnalyticMathLabSurrogateExt.jl:32-52']),
        ('Q088', 'Which histories retain earliest entries and which retain the most recent?', ['PINNHistory', 'train', 'infer_parameters'], ['ext/AnalyticMathLabPINNExt.jl:89-152', 'ext/AnalyticMathLabInferenceExt.jl:6-49', 'ext/AnalyticMathLabSurrogateExt.jl:77-104']),
        ('Q089', 'When does summary_only avoid output arrays, and are public iterators one-pass?', ['field_errors', 'heat_residual', 'sampled_summary'], ['src/scientific_ml/diagnostics.jl:23-48', 'src/scientific_ml/generalization.jl:39-57', 'test/m10c_chunking.jl']),
        ('Q090', 'What provenance is intentionally omitted with source_retention=:descriptor?', ['ScientificDataset'], ['src/scientific_ml/trajectory_dataset.jl:28-104', 'test/m10d_semantics_review.jl'])]
    for ident, question, symbols, refs in additional:
        wiki['questions'].append({'id': ident, 'question': question, 'category': 'Memory and Performance', 'public_apis': symbols,
            'evidence_references': refs, 'audit_evidence': ['resource_controls.json'],
            'answer_readiness': 'SOURCE_SUPPORTED_OUTLINE_PENDING_IMPLEMENTATION', 'complete_answer_currently_possible': True,
            'qualification': 'Scoped source-based answer; no global guarantee or fresh execution.',
            'documentation_target': 'guides/resource-limits.md', 'priority': 'P1', 'evidence_level': 'SOURCE_SUPPORTED_OUTLINE_NOT_PUBLISHED_OR_EXECUTED'})
    wiki['scope'] = 'Reconciled question inventory, not Wiki answers or publication. Q049 premise corrected; memory questions grounded by completed source audit.'
    wiki['baseline'] = BASELINE
    save('wiki_inventory.json', wiki)
    readme = (ROOT / 'README.md').read_text().splitlines()
    save('readme_inventory.json', {'baseline': BASELINE, 'path': 'README.md', 'sha256': sha(ROOT / 'README.md'),
         'headings': [{'line': i, 'heading': l.lstrip('#').strip()} for i, l in enumerate(readme, 1) if l.startswith('#')],
         'reuse_plan': 'readme_plan.md', 'reconciled_architecture': 'documentation_architecture_reconciled.md',
         'scope': 'Inventory/design only; README has not been rewritten and snippets have not been executed.',
         'required_corrections': ['Physical diffusion interpretation is distinct from index-time numerical acceptance',
                                  'No global AML memory setter or generic partial Hessian route',
                                  'Full public reference still partial; no Documenter/Wiki deployment claimed'],
         'reference_assignment': FAMILY_PAGES})
    counts = Counter(r['inspection_status'] for r in coverage)
    stable = Counter(r['stability'] for r in owned)
    save('reconciliation.json', {'baseline': BASELINE, 'status': 'STATIC_AUDIT_COMPLETE_VERIFICATION_PENDING',
        'repository_entries': len(inv), 'export_count': len(owned), 'family_count': len(load('exports.json')['families']),
        'export_stability': dict(stable), 'qualified_interfaces': len(load('qualified_api.json')['apis']),
        'inspection_counts': dict(counts), 'sequential_batches': len(list((OUT / 'batches').glob('*.json'))),
        'source_files': sum(r['path'].startswith(('src/', 'ext/')) for r in coverage),
        'test_julia_files': sum(r['path'].startswith('test/') and r['path'].endswith('.jl') for r in coverage),
        'example_julia_files': sum(r['path'].startswith('examples/') and r['path'].endswith('.jl') for r in coverage),
        'notebook_julia_files': sum(r['path'].startswith('notebooks/') and r['path'].endswith('.jl') for r in coverage),
        'refusal_groups': len(load('refusals.json')['groups']), 'lexical_refusal_candidates': len(site['sites']),
        'wiki_questions': len(wiki['questions']), 'public_byte_estimate_controls': 2,
        'runtime_or_test_changes': False, 'dependency_updates': False, 'canonical_rerun': False,
        'documenter_build': 'NOT_RUN_NOT_IMPLEMENTED', 'wiki_publication': 'NOT_STARTED', 'M10D_6B': 'NOT_STARTED'})


def verify():
    errors, checked_citations, checked_paths = [], set(), set()
    inv = load('repository_inventory.json')['files']
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    # After a separately authorized audit commit, source remains checked against the
    # original baseline. A descendant is allowed only if its diff is audit-only.
    paths = subprocess.check_output(['git', 'diff', '--name-only', BASELINE, 'HEAD'], cwd=ROOT, text=True).splitlines()
    if any(not p.startswith('reports/m10d6/') for p in paths):
        errors.append('HEAD changes outside audit directory')
    for rec in inv:
        path = ROOT / rec['path']
        if not path.exists() or sha(path) != rec['sha256']:
            errors.append('Source inventory hash mismatch: ' + rec['path'])
    for rec in load('preserved_inputs.json')['files']:
        if sha(OUT / rec['path']) != rec['sha256']:
            errors.append('Preserved input changed: ' + rec['path'])
    all_json = sorted(OUT.rglob('*.json'))
    for path in all_json:
        data = json.loads(path.read_text())
        for s in strings(data):
            if 'HERMES-CONTEXT-COMPRESSION' in s or '[SKILL_PRUNED]' in s:
                errors.append('Compression marker in ' + str(path))
    cov = load('coverage.json')['files']
    if len(inv) != 311 or len(cov) != 311:
        errors.append('Repository enumeration count not 311')
    if {r['path'] for r in cov} != {r['path'] for r in inv}:
        errors.append('Coverage path-set mismatch')
    for rec in cov:
        if not rec['review_evidence']:
            errors.append('No inventory/review disposition: ' + rec['path'])
        for review in rec['review_evidence']:
            if review['sha256'] != rec['sha256']:
                errors.append('Review hash mismatch: ' + rec['path'])
        required = rec['path'].startswith(('src/', 'ext/')) or (rec['path'].startswith(('test/', 'examples/', 'notebooks/')) and rec['path'].endswith('.jl'))
        if required and rec['inspection_status'] != 'FULL_SEMANTIC_READ':
            errors.append('Mandatory semantic-review gap: ' + rec['path'])
    api = load('api.json')['apis']
    exports = load('exports.json')['exports']
    actual = []
    for line in (ROOT / 'src/AnalyticMathLab.jl').read_text().splitlines():
        if line.startswith('export '):
            actual.extend(s.strip() for s in line[7:].split(','))
    if len(exports) != 177 or len(api) != 177 or {r['symbol'] for r in api} != {r['symbol'] for r in exports} or set(actual) != {r['symbol'] for r in exports}:
        errors.append('Export/API reconciliation mismatch')
    if len(set(r['symbol'] for r in api)) != len(api):
        errors.append('Duplicate aggregate export records')
    owners = {r['symbol']: r for r in exports}
    for rec in api:
        for field in CORE_FIELDS:
            if field not in rec or not rec[field]:
                errors.append(f"Missing field {field}: {rec['symbol']}")
        if rec['family'] != owners[rec['symbol']]['family'] or rec['stability'] != owners[rec['symbol']]['stability']:
            errors.append('Ownership/stability mismatch: ' + rec['symbol'])
        for review in rec['reviewed_variants']:
            if review['family'] != rec['family'] or review['stability'] != rec['stability']:
                errors.append('Variant ownership/stability mismatch: ' + rec['symbol'])
    if len(load('exports.json')['families']) != 36:
        errors.append('Family count mismatch')
    wiki = load('wiki_inventory.json')['questions']
    if len({q['id'] for q in wiki}) != len(wiki):
        errors.append('Duplicate Wiki IDs')
    qualified = {r['symbol'] for r in load('qualified_api.json')['apis']}
    public_symbols = set(owners) | qualified
    for q in wiki:
        if any(s not in public_symbols for s in q['public_apis']):
            errors.append('Unknown public Wiki symbol: ' + q['id'])
    # Existing source citations are checked; proposed technical destinations are
    # explicitly not deployed links and therefore not treated as missing files.
    cite = re.compile(r'((?:src|ext|test|docs|examples|notebooks)/[^\s`:,;()]+\.(?:jl|md|toml|py)|README\.md|Project\.toml):(\d+)(?:-(\d+))?')
    for name in ['api.json', 'qualified_api.json', 'refusal_review.json', 'resource_controls.json', 'wiki_inventory.json']:
        for text in strings(load(name)):
            for path in re.findall(r'((?:src|ext|test|docs|examples|notebooks)/[A-Za-z0-9_./-]+\.(?:jl|md|toml|py|csv|json))', text):
                checked_paths.add(path)
                if not (ROOT / path).is_file():
                    errors.append('Missing existing evidence path: ' + path)
            for path, start, stop in cite.findall(text):
                key = (path, int(start), int(stop or start))
                if key in checked_citations:
                    continue
                checked_citations.add(key)
                target = ROOT / path
                if not target.exists():
                    errors.append('Missing cited file: ' + path)
                    continue
                n = len(target.read_text().splitlines())
                if not (1 <= key[1] <= key[2] <= n):
                    errors.append(f'Invalid citation range {key}; file lines={n}')
    results = {'baseline': BASELINE, 'checked_head': head, 'verification': 'PASSED' if not errors else 'FAILED',
               'errors': errors, 'source_hashes_checked': len(inv), 'preserved_inputs_checked': len(load('preserved_inputs.json')['files']),
               'json_files_parsed': len(all_json), 'unique_existing_citation_ranges_checked': len(checked_citations),
               'unique_existing_evidence_paths_checked': len(checked_paths),
               'scope': 'Static audit/artifact validation only; no Julia tests, documentation build, installation, benchmark or scientific workload.',
               'counts': load('reconciliation.json')}
    print(json.dumps(results, indent=2))
    if errors:
        raise SystemExit(1)
    return results


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--build', action='store_true')
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if args.build:
        build()
    if args.verify:
        verify()
