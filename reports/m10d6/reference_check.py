#!/usr/bin/env python3
"""Independent inventory, manual-contract and generated-site checks; no scientific suite."""
import argparse
from collections import Counter
import hashlib
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]
AUDIT = ROOT / 'reports/m10d6'
SOURCE = ROOT / 'docs/src'
BASELINE = 'b327e43485d5d0e06b6fffb537e74a846455dc0b'
GROUPS = {
    'core': [1, 2], 'scalar': [3, 4], 'derivatives': [5, 6], 'vector': [7],
    'dynamics': [8, 9], 'mechanics': [10, 11, 12, 13, 14],
    'atomistic': [15, 16, 17, 18], 'statistics': [19, 20, 21, 22, 24],
    'transport': [23], 'comparison': [25],
    'scientific-ml': [26, 27, 28, 29, 30, 33, 34],
    'datasets': [31, 32], 'plots': [35],
}
OWNER = {f'F{n:02}': f'reference/{page}.md' for page, nums in GROUPS.items() for n in nums}
SHARED = {'analyze', 'evaluate', 'normal_modes', 'train', 'predict', 'plot',
          'observable_series', 'loss_breakdown'}
SHARED_DESTINATIONS = {
    'scalar': {'plot'}, 'derivatives': {'analyze','evaluate','plot'},
    'vector': {'analyze','evaluate','plot'},
    'dynamics': {'analyze','evaluate','observable_series','predict'},
    'mechanics': {'analyze','normal_modes'},
    'atomistic': {'analyze','evaluate','normal_modes','observable_series','plot'},
    'statistics': {'analyze','observable_series'}, 'datasets': {'train','predict'},
    'scientific-ml': {'analyze','train','predict','loss_breakdown'}, 'plots': {'plot'},
}
SECTIONS = ['Purpose and output', 'Inputs', 'Keywords', 'Failure and refusal',
            'Numerical limitations', 'Units', 'Ownership', 'Dependencies', 'Evidence']


def load(name):
    return json.loads((AUDIT / name).read_text())


def anchor(name, qualified=False):
    return 'api-' + ('qualified-' if qualified else '') + name.replace('@', 'macro-').replace('_', '-')


def variant_digest(variant):
    return hashlib.sha256(json.dumps(variant, sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def keyword_leaves(value):
    for key, item in value.items():
        if isinstance(item, dict):
            yield from keyword_leaves(item)
        else:
            yield key, str(item)


def protected_files():
    listing = subprocess.check_output(['git', 'ls-tree', '-r', '--format=%(objectname) %(path)', BASELINE], cwd=ROOT).decode()
    baseline = [line.split(' ', 1) for line in listing.splitlines()]
    protected = [(oid, path) for oid, path in baseline if path != 'README.md']
    missing = [path for _, path in protected if not (ROOT / path).is_file()]
    present = [(oid, path) for oid, path in protected if (ROOT / path).is_file()]
    hashes = subprocess.check_output(['git', 'hash-object', '--stdin-paths'], input=('\n'.join(p for _, p in present)+'\n').encode(), cwd=ROOT).decode().splitlines()
    changed = [path for (expected, path), actual in zip(present, hashes) if expected != actual]
    if len(hashes) != len(present):
        changed.append('INCOMPLETE_GIT_HASH_OUTPUT')
    return {'count': len(protected), 'changed': changed, 'missing': missing}


class SiteParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.links = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.append(attrs['id'])
        for key in ('href', 'src'):
            if key in attrs:
                self.links.append(attrs[key])


def site_check(expected_entries, expected_pages):
    build = ROOT / 'docs/build'
    parsed = {}
    for path in build.rglob('*.html'):
        parser = SiteParser()
        parser.feed(path.read_text())
        parsed[path.resolve()] = parser
    failures = []
    local_links = 0
    external = 0
    for page, parser in parsed.items():
        duplicate_api = [x for x, n in Counter(parser.ids).items() if x.startswith('api-') and n != 1]
        failures.extend(f'{page.relative_to(build)} duplicate id {x}' for x in duplicate_api)
        for link in parser.links:
            parts = urlsplit(link)
            if parts.scheme or parts.netloc:
                external += 1
                continue
            if not parts.path and not parts.fragment:
                continue
            local_links += 1
            relative = unquote(parts.path)
            target = ((build / relative.lstrip('/')) if relative.startswith('/') else (page.parent / relative)).resolve() if parts.path else page
            if target.is_dir():
                target = target / 'index.html'
            if not target.is_relative_to(build.resolve()):
                failures.append(f'{page.relative_to(build)} link escapes site {link}')
            elif not target.is_file():
                failures.append(f'{page.relative_to(build)} missing {link}')
            elif parts.fragment and target.suffix == '.html':
                if target not in parsed or unquote(parts.fragment) not in parsed[target].ids:
                    failures.append(f'{page.relative_to(build)} absent anchor {link}')
    for name, owner, aid in expected_entries:
        target = (build / owner).with_suffix('.html').resolve()
        if target not in parsed or parsed[target].ids.count(aid) != 1:
            failures.append(f'{name}: primary HTML anchor absent or duplicated')
    for path in expected_pages:
        if not (build / path).with_suffix('.html').is_file():
            failures.append(f'{path}: navigation output absent')
    page_sizes = {str(path.relative_to(build)): path.stat().st_size for path in parsed}
    for path, size in page_sizes.items():
        if size > 200*1024:
            failures.append(f'{path}: exceeds 200 KiB hard page budget')
        if path != 'reference/scientific-ml.html' and size > 100*1024:
            failures.append(f'{path}: exceeds default 100 KiB advisory page budget')
    search_size = (build/'search_index.js').stat().st_size
    if search_size > 640*1024:
        failures.append('Search index exceeds explicit 640 KiB budget')
    resources = list((build / 'repository').rglob('*'))
    resources = [p for p in resources if p.is_file()]
    for path in resources:
        original = ROOT / path.relative_to(build / 'repository')
        if not original.is_file() or original.read_bytes() != path.read_bytes():
            failures.append(f'{path}: resource differs from checkout')
    return {'html_pages': len(parsed), 'local_link_occurrences': local_links,
            'external_links_not_network_checked': external, 'raw_repository_resources': len(resources),
            'page_sizes_bytes': page_sizes, 'search_index_bytes': search_size, 'failures': failures}


def check(checkpoint='D5', build=False):
    exports = load('exports.json')['exports']
    apis = load('api.json')['apis']
    qualified = load('qualified_api.json')['apis']
    exp = {r['symbol']: r for r in exports}
    audit = {r['symbol']: r for r in apis}
    bindings = {r['symbol']: r for r in load('reference_verification.json')['binding_inspection']['bindings']}
    errors = []
    if len(exports) != 177 or len(exp) != 177 or set(exp) != set(audit):
        errors.append('Export inventory is not exactly 177 unique symbols matching api.json')
    counts = Counter(r['stability'] for r in exports)
    if counts != {'PUBLIC_STABLE': 130, 'PUBLIC_EXPERIMENTAL': 47}:
        errors.append('Audit stability counts do not match 130/47')
    if set(r['symbol'] for r in qualified) != {'scientific_metadata', 'scientific_origin'}:
        errors.append('Qualified inventory differs from the two authorized interfaces')
    if set(exp) & set(r['symbol'] for r in qualified):
        errors.append('Qualified interfaces incorrectly counted as exports')
    max_family = {'D1': 0, 'D2': 9, 'D3': 25, 'D4': 35, 'D5': 35}[checkpoint]
    required = {n for n, r in exp.items() if int(r['family'][1:]) <= max_family}
    entries = []
    text_by_page = {str(p.relative_to(SOURCE)): p.read_text() for p in SOURCE.rglob('*.md')}
    all_text = '\n'.join(text_by_page.values())
    ids = re.findall(r'\(@id ([^)]+)\)', all_text)
    errors += [f'duplicate source anchor: {x}' for x, n in Counter(ids).items() if n != 1]
    metadata = re.compile(r'<!-- aml-api: (.*?) -->', re.S)
    for owner, text in text_by_page.items():
        matches = list(metadata.finditer(text))
        for i, match in enumerate(matches):
            data = json.loads(match.group(1))
            content = text[match.end():matches[i+1].start() if i+1<len(matches) else len(text)]
            name = data['symbol']
            is_qualified = data['qualified']
            record = next((r for r in qualified if r['symbol']==name), None) if is_qualified else audit.get(name)
            if record is None:
                errors.append(f'{name}: unaudited public entry')
                continue
            intended = 'reference/evidence.md' if is_qualified else OWNER.get(record['family'])
            if owner != intended:
                errors.append(f'{name}: wrong primary owner {owner} != {intended}')
            if data['stability'] != record['stability'] or data['family'] != record['family']:
                errors.append(f'{name}: misclassified stability/family')
            if data['kind'] != bindings[name]['kind']:
                errors.append(f'{name}: wrong Julia symbol kind')
            aid = anchor(name, is_qualified)
            if f'(@id {aid})' not in content:
                errors.append(f'{name}: missing explicit primary anchor')
            variants = [record] if is_qualified else record['reviewed_variants']
            contract_matches = list(re.finditer(r'<!-- aml-contract: (.*?) -->', content))
            found = [json.loads(m.group(1)) for m in contract_matches]
            if [v['digest'] for v in found] != [variant_digest(v) for v in variants]:
                errors.append(f'{name}: omitted, duplicate or reordered audited dispatch contracts')
            if data['variant_count'] != len(variants):
                errors.append(f'{name}: wrong variant count')
            fields = bindings[name].get('fields', [])
            if fields and ', '.join('`'+f+'`' for f in fields) not in content:
                errors.append(f'{name}: stored field ordering/layout drift')
            for vi, variant in enumerate(variants):
                section = content[contract_matches[vi].end():contract_matches[vi+1].start() if vi+1<len(contract_matches) else len(content)] if vi<len(contract_matches) else ''
                for label in SECTIONS:
                    if f'**{label}' not in section:
                        errors.append(f'{name} variant {vi}: incomplete {label} section')
                signatures = variant['public_signature']
                signatures = [signatures] if isinstance(signatures, str) else signatures
                if signatures and '\n\n'.join(signatures) not in section:
                    errors.append(f'{name}: signature drift')
                for key in ('inputs', 'returns', 'units', 'ownership'):
                    if variant[key] not in section:
                        errors.append(f'{name}: missing or changed audited {key}')
                for key in ('errors', 'numerical_limitations'):
                    vals = variant[key] if isinstance(variant[key], list) else [variant[key]]
                    errors += [f'{name}: missing audited {key}: {val}' for val in vals if val not in section]
                for key in ('required_dependencies', 'optional_dependencies'):
                    vals = variant.get(key, [])
                    vals = vals if isinstance(vals, list) else [vals]
                    errors += [f'{name}: missing dependency requirement {val}' for val in vals if val not in section]
                keywords = variant.get('keywords', {})
                if isinstance(keywords, dict):
                    for key, value in keyword_leaves(keywords):
                        if f'`{key}`' not in section or value not in section:
                            errors.append(f'{name}: omitted keyword/default {key}')
            for label in SECTIONS:
                if f'**{label}' not in content:
                    errors.append(f'{name}: incomplete {label} section')
            if len(content.split()) < 65:
                errors.append(f'{name}: empty or superficial contract')
            entries.append((name, owner, aid, is_qualified))
    seen = Counter(name for name, _, _, q in entries if not q)
    duplicates = sorted(n for n, c in seen.items() if c != 1)
    missing = sorted(required-set(seen))
    errors += [f'missing export: {n}' for n in missing]
    errors += [f'duplicate primary owner: {n}' for n in duplicates]
    if any(audit[n]['family']=='F36' for n in seen if n in audit):
        errors.append('F36 internal promoted to export')
    q_seen = Counter(name for name, _, _, q in entries if q)
    if checkpoint in ('D4','D5') and q_seen != {'scientific_metadata':1,'scientific_origin':1}:
        errors.append('Qualified coverage missing or duplicated')
    for name in SHARED & set(seen):
        owner = OWNER[audit[name]['family']]
        text = text_by_page[owner]
        tables = re.findall(r'<!-- aml-dispatch: (.*?) -->', text)
        if not any(json.loads(t)['symbol']==name and json.loads(t)['variants']==len(audit[name]['reviewed_variants']) for t in tables):
            errors.append(f'{name}: missing complete dispatch table')
        if '| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |' not in text:
            errors.append(f'{name}: missing dispatch columns')
    pages = ['index.md', 'reference/index.md'] + sorted(set(OWNER.values())) + ['reference/evidence.md','guides/api-boundaries.md']
    markdown_links = 0
    readme_links = 0
    if checkpoint == 'D5':
        for p in pages:
            if p not in text_by_page:
                errors.append(f'missing intended page {p}')
            if '"'+p+'"' not in (ROOT/'docs/make.jl').read_text():
                errors.append(f'{p}: absent explicit Documenter navigation')
        for page, names in SHARED_DESTINATIONS.items():
            text = text_by_page.get(f'reference/{page}.md', '')
            for name in names:
                if f'](@ref dispatch-{name})' not in text:
                    errors.append(f'{page}: missing cross-family dispatch link {name}')
        for owner, text in text_by_page.items():
            for ref in re.findall(r'\]\(@ref ([^)]+)\)', text):
                markdown_links += 1
                if ref not in ids:
                    errors.append(f'{owner}: unresolved source @ref {ref}')
            for link in re.findall(r'\]\(([^)]+)\)', text):
                if link.startswith(('@ref','@id')) or urlsplit(link).scheme:
                    continue
                markdown_links += 1
                path, _, frag = link.partition('#')
                target = (SOURCE/owner).parent / path
                if path and not target.is_file():
                    errors.append(f'{owner}: broken Markdown path {link}')
            if re.search(r'^```(?:julia|@example|@repl|@eval|jldoctest)', text, re.M):
                errors.append(f'{owner}: unexpected new executable scientific example')
        for link in re.findall(r'\]\(([^)]+)\)', (ROOT/'README.md').read_text()):
            if urlsplit(link).scheme or link.startswith('#'):
                continue
            readme_links += 1
            if not (ROOT/link.split('#',1)[0]).exists():
                errors.append(f'README.md: broken navigation path {link}')
    integrity = protected_files()
    errors += [f'protected file changed: {p}' for p in integrity['changed']+integrity['missing']]
    source_hashes = {(r['path'],r['sha256']) for a in apis for r in a.get('source_hashes',[])}
    for path, expected in source_hashes:
        if hashlib.sha256((ROOT/path).read_bytes()).hexdigest() != expected:
            errors.append(f'{path}: M10D.6A source hash differs')
    site = site_check([(n,p,a) for n,p,a,q in entries], pages) if build else None
    if site:
        errors += site['failures']
    return {'checkpoint':checkpoint,'status':'PASS' if not errors else 'FAIL',
            'audit_exports':len(exp),'audit_stability':dict(counts), 'covered_exports':len(seen),
            'qualified_covered':len(q_seen),'missing':missing,'duplicate_owners':duplicates,
            'misclassified':[e for e in errors if 'misclassified' in e or 'wrong Julia symbol kind' in e],
            'wrong_primary_owners':[e for e in errors if 'wrong primary owner' in e],
            'classified_kinds':dict(Counter(json.loads(m)['kind'] for text in text_by_page.values() for m in metadata.findall(text))),
            'manual_entries':len(entries),'audited_contract_variants':sum(len(audit[n]['reviewed_variants']) for n in seen if n in audit),
            'covered_export_stability':dict(Counter(audit[n]['stability'] for n in seen if n in audit)),
            'source_hashes_verified':len(source_hashes),'source_explicit_anchors':len(ids),
            'readme_relative_link_occurrences':readme_links,
            'markdown_link_occurrences':markdown_links,'protected_integrity':integrity,'site':site,'errors':errors}


def self_test():
    """Negative coverage fixtures live only in TMPDIR, never in scientific source."""
    global SOURCE
    original = SOURCE
    baseline = check()
    if baseline['status'] != 'PASS':
        return {'status':'FAIL','reason':'Baseline manual is not passing','errors':baseline['errors']}
    results = []
    cases = [
        ('missing', lambda s: s.replace('<!-- aml-api:', '<!-- removed-api:', 1), 'missing export: AbstractAnalysis'),
        ('duplicate', lambda s: s+s[s.index('<!-- aml-api:'):s.index('<!-- aml-api:',s.index('<!-- aml-api:')+1)], 'duplicate primary owner: AbstractAnalysis'),
        ('misclassified', lambda s: s.replace('"stability": "PUBLIC_STABLE"','"stability": "PUBLIC_EXPERIMENTAL"',1), 'misclassified stability/family'),
        ('signature', lambda s: s.replace('abstract type AbstractAnalysis end','abstract type AbstractAnalysis <: Any end',1), 'signature drift'),
        ('output', lambda s: s.replace('**Purpose and output:** Not applicable (abstract marker).','**Purpose and output:** Unjustified execution protocol.',1), 'missing or changed audited returns'),
        ('fields', lambda s: s.replace('`value`, `status`, `method`, `notes`','`value`, `status`, `method`, `fictional_field`',1), 'stored field ordering/layout drift'),
    ]
    try:
        scratch = Path(os.environ.get('TMPDIR', str(Path.home()/'.cache/analyticmath-lab')))
        scratch.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=scratch,prefix='aml-reference-check-') as directory:
            for name, mutate, expected in cases:
                SOURCE = Path(directory)/name
                shutil.copytree(original,SOURCE)
                path=SOURCE/'reference/core.md'
                path.write_text(mutate(path.read_text()))
                result=check()
                detected=result['status']=='FAIL' and any(expected in error for error in result['errors'])
                results.append({'case':name,'expected_refusal_detected':detected})
            SOURCE=Path(directory)/'wrong-owner'
            shutil.copytree(original,SOURCE)
            core=SOURCE/'reference/core.md'
            text=core.read_text()
            start=text.index('<!-- aml-api:')
            end=text.index('<!-- aml-api:',start+1)
            entry=text[start:end]
            core.write_text(text[:start]+text[end:])
            vector=SOURCE/'reference/vector.md'
            vector.write_text(vector.read_text()+entry)
            result=check()
            results.append({'case':'wrong-owner','expected_refusal_detected':any('wrong primary owner' in x for x in result['errors'])})
    finally:
        SOURCE=original
    return {'status':'PASS' if all(r['expected_refusal_detected'] for r in results) else 'FAIL', 'cases':results}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--checkpoint', choices=['D1','D2','D3','D4','D5'], default='D5')
    parser.add_argument('--build', action='store_true')
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    result = self_test() if args.self_test else check(args.checkpoint,args.build)
    print(json.dumps(result,indent=2))
    raise SystemExit(0 if result['status']=='PASS' else 1)
