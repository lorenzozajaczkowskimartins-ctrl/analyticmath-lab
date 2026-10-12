#!/usr/bin/env python3
"""Validate the reconciled FAQ source, publication mappings and rendered Wiki links.

No Julia examples, optional installations, scientific tests or remote writes.
GitHub /markdown POST is a stateless rendering request, not Wiki publication.
"""
import argparse
from collections import Counter, deque
from html.parser import HTMLParser
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import tomllib
from urllib.parse import urlsplit, unquote
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
WIKI = ROOT / 'wiki'
BASELINE = '4e2143953baf23542d91ab62ee08c7673d5ce6cb'
REPOSITORY = 'lorenzozajaczkowskimartins-ctrl/analyticmath-lab'
BASE_URL = 'https://github.com/'+REPOSITORY+'/blob/'+BASELINE+'/'
REPORTS = ROOT/'reports/m10d6'
LABELS = ['Short answer','Explanation','Practical action','Scientific boundary']
INVENTORY = json.loads((REPORTS/'wiki_inventory.json').read_text())['questions']
PAGES = {q['category']:q['category'].replace(' ','-')+'.md' for q in INVENTORY}
REQUIRED = {
    'Q007':['FunctionAnalysis','domain'], 'Q016':['rectangular','Jacobian'],
    'Q027':['FirstOrderODE','AutonomousSystem'], 'Q049':['index-time','physical','window'],
    'Q066':['32','3000','1,728,000,000','536,870,912','RSS'],
    'Q067':['no','global'], 'Q071':['value','status','method','notes'],
    'Q074':['process-local','hash'], 'Q076':['NeuralOperators','SymbolicIndexingInterface'],
    'Q080':['CairoMakie','backend'], 'Q086':['max_pairs','max_bytes','quadratic'],
    'Q087':['batch_size','output','training'], 'Q088':['earliest','rolling'],
    'Q089':['summary_only','streaming'], 'Q090':['descriptor','omits','hash'],
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def baseline_integrity():
    items=subprocess.check_output(['git','ls-tree','-r','--format=%(objectname) %(path)',BASELINE],cwd=ROOT).decode().splitlines()
    pairs=[line.split(' ',1) for line in items]
    missing=[p for _,p in pairs if not (ROOT/p).is_file()]
    present=[(oid,p) for oid,p in pairs if (ROOT/p).is_file()]
    actual=subprocess.check_output(['git','hash-object','--stdin-paths'],input=('\n'.join(p for _,p in present)+'\n').encode(),cwd=ROOT).decode().splitlines()
    changed=[p for (oid,p),now in zip(present,actual) if oid!=now]
    if len(actual)!=len(present):changed.append('incomplete hash output')
    return {'protected_files':len(pairs),'changed':changed,'missing':missing}


class Rendered(HTMLParser):
    def __init__(self):
        super().__init__()
        self.anchors=[]
        self.links=[]
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        for key in ('id','name'):
            if key in attrs:self.anchors.append(attrs[key])
        if tag=='a' and 'href' in attrs:self.links.append(attrs['href'])


def links(text):
    return re.findall(r'\[[^\]\n]+\]\(([^)\s]+)\)',text)


def question_blocks(text):
    matches=list(re.finditer(r'<!-- aml-faq: (.*?) -->',text))
    return [(json.loads(m.group(1)),text[m.end():matches[i+1].start() if i+1<len(matches) else len(text)]) for i,m in enumerate(matches)]


def check(checkpoint='F5',evidence=None):
    errors=[]
    counts=Counter(q['priority'] for q in INVENTORY)
    ids={q['id'] for q in INVENTORY}
    expected={f'Q{n:03}' for n in range(1,91)}
    if len(INVENTORY)!=90 or ids!=expected:errors.append('Inventory must contain exactly Q001–Q090')
    if len(PAGES)!=17 or counts!={'P0':25,'P1':65}:errors.append('Inventory category/priority totals differ')
    lookup={q['id']:q for q in INVENTORY}
    mapping=json.loads((REPORTS/'wiki_target_reconciliation.json').read_text())['mappings']
    mc=Counter(m['id'] for m in mapping)
    if set(mc)!=ids or any(n!=1 for n in mc.values()):errors.append('Target reconciliation missing/duplicate IDs')
    by_id={m['id']:m for m in mapping}
    filenames=sorted(p.name for p in WIKI.glob('*.md'))
    if len(set(p.casefold() for p in filenames))!=len(filenames):errors.append('Case-insensitive filename collision')
    for p in filenames:
        if not re.fullmatch(r'(?:[A-Za-z0-9][A-Za-z0-9-]*|_Sidebar)\.md',p):errors.append('Invalid flat Wiki filename '+p)
    pages={p.name:p.read_text() for p in WIKI.glob('*.md')}
    slugs={Path(p).stem:p for p in pages}
    for p in ('Home.md','_Sidebar.md','FAQ-Index.md'):
        if p not in pages:errors.append('Missing navigation page '+p)
    limit={'F1':0,'F2':40,'F3':65,'F4':90,'F5':90}[checkpoint]
    required={f'Q{n:03}' for n in range(1,limit+1)}
    primary=[]
    blocks={}
    anchor_map={}
    declared_anchors=[]
    resources=set()
    for filename,text in pages.items():
        names=re.findall(r'<a name="([^"]+)"></a>',text)
        if len(names)!=len(set(names)):errors.append('Duplicate question anchor in '+filename)
        anchor_map[filename]={'user-content-'+name for name in names}
        declared_anchors.extend(names)
        headings=re.findall(r'^## (Q\d{3})$',text,re.M)
        declared=[data['id'] for data,_ in question_blocks(text)]
        if Counter(headings)!=Counter(declared):errors.append('Unstructured/duplicate question heading in '+filename)
        if re.search(r'^```(?:julia|jldoctest|@example|@repl|@eval)',text,re.M):errors.append('Unexpected new executable Julia block in '+filename)
        if '](@ref ' in text or '](@id ' in text:errors.append('Documenter link syntax in Wiki '+filename)
        for data,body in question_blocks(text):
            qid=data['id']
            if qid not in lookup:
                errors.append('Unaudited question '+qid)
                continue
            q=lookup[qid]
            if filename!=PAGES[q['category']]:errors.append(qid+' wrong category page')
            if data['category']!=q['category'] or data['priority']!=q['priority']:errors.append(qid+' classification drift')
            if data['question_sha256']!=digest(q['question'].encode()) or '**Question:** '+q['question']+'\n' not in body:errors.append(qid+' wording drift')
            if '<a name="'+qid.lower()+'"></a>' not in body or '## '+qid+'\n' not in body:errors.append(qid+' anchor/header absent')
            for label in LABELS:
                m=re.search(r'\*\*'+label+r':\*\* (.*?)(?:\n\n|$)',body,re.S)
                if not m or len(m.group(1).split())<8:errors.append(qid+' empty/insubstantial '+label)
                elif m.group(1).strip().lower() in ('see documentation.','not supported.','consult source.'):errors.append(qid+' placeholder '+label)
            if '**Related documentation:**' not in body or 'SOURCE_SUPPORTED' not in body:errors.append(qid+' missing links/evidence')
            for phrase in REQUIRED.get(qid,[]):
                if phrase.casefold() not in body.casefold():errors.append(qid+' missing high-risk distinction '+phrase)
            primary.append(qid)
            blocks[qid]=body
    pc=Counter(primary)
    if Counter(declared_anchors)!=Counter(qid.lower() for qid in primary):errors.append('Question anchors must be globally unique and match primary answers')
    if lookup['Q049']['question']!='What time scale and fit-window assumptions are needed to interpret a diffusion estimate?':errors.append('Corrected Q049 wording lost')
    missing=sorted(required-set(pc))
    duplicate=sorted(qid for qid,n in pc.items() if n!=1)
    errors += ['Missing answer '+qid for qid in missing]+['Duplicate answer '+qid for qid in duplicate]
    for m in mapping:
        q=lookup.get(m['id'])
        if not q:continue
        for key in ('question','category','priority'):
            if m[key]!=q[key]:errors.append(m['id']+' reconciled '+key+' drift')
        if m['original_documentation_target']!=q['documentation_target']:errors.append(m['id']+' historical target modified')
        if m['answer_page']!=PAGES[q['category']] or m['answer_anchor']!=q['id'].lower() or m['answer_fragment']!='user-content-'+q['id'].lower():errors.append(m['id']+' invalid authoritative destination')
        if m['repository_revision']!=BASELINE or not m['mapping_decision'].strip():errors.append(m['id']+' missing version/decision')
        paths=[m['primary_technical_destination']]+m['additional_technical_destinations']+m['tutorial_readme_destinations']
        for p in paths:
            if not (ROOT/p).is_file():errors.append(m['id']+' missing technical destination '+p)
            if m['id'] in blocks and BASE_URL+p not in blocks[m['id']]:errors.append(m['id']+' linked destination does not match reconciliation '+p)
        if not m.get('evidence') or not m['evidence'].get('current_documents'):errors.append(m['id']+' missing mapping evidence')
        for p,sha in m.get('evidence',{}).get('document_sha256',{}).items():
            if not (ROOT/p).is_file() or digest((ROOT/p).read_bytes())!=sha:errors.append(m['id']+' stale technical mapping evidence '+p)
        if checkpoint=='F5':
            evidence_paths=set(m.get('evidence',{}).get('document_sha256',{}))
            if evidence_paths!=set(paths):errors.append(m['id']+' incomplete technical mapping hashes')
            if m.get('evidence',{}).get('mapping_review')!='SOURCE_SUPPORTED':errors.append(m['id']+' missing semantic mapping review')
    # A partial checkpoint permits links to the named categories scheduled later,
    # but never reports them as resolved. Full F4/F5 checks require every target.
    planned={Path(p).stem:p for p in PAGES.values()}
    planned.update({Path(p).stem:p for p in ('Home.md','_Sidebar.md','FAQ-Index.md')})
    graph={p:set() for p in pages}
    internal=0; pending=[]; external=set()
    for filename,text in pages.items():
        for link in links(text):
            parts=urlsplit(link)
            if parts.scheme or parts.netloc:
                external.add(link)
                if link.startswith(BASE_URL):
                    p=unquote(link[len(BASE_URL):].split('#',1)[0])
                    resources.add(p)
                    if parts.fragment:errors.append('Guessed repository fragment '+link)
                    if not (ROOT/p).is_file():errors.append('Missing repository file '+p)
                else:errors.append('Unapproved/unversioned external documentation URL '+link)
                continue
            internal+=1
            slug=unquote(parts.path) if parts.path else Path(filename).stem
            if '/' in slug or slug.endswith('.md'):errors.append('Non-flat/non-Wiki slug '+link)
            target=planned.get(slug)
            if target not in pages:
                if checkpoint in ('F1','F2','F3') and target in planned.values():pending.append(link)
                else:errors.append(filename+' unresolved Wiki link '+link)
                continue
            graph[filename].add(target)
            if parts.fragment and unquote(parts.fragment) not in anchor_map[target]:errors.append(filename+' unresolved answer fragment '+link)
    reachable=set();queue=deque(['Home.md'])
    while queue:
        p=queue.popleft()
        if p in reachable:continue
        reachable.add(p);queue.extend(graph.get(p,set())-reachable)
    for qid in required:
        m=by_id.get(qid)
        if m is None:continue  # Missing mapping already produces a coverage error.
        link=Path(m['answer_page']).stem+'#'+m['answer_fragment']
        if link not in links(pages.get('FAQ-Index.md','')):errors.append(qid+' absent from FAQ index')
    if checkpoint in ('F4','F5'):
        wanted=set(PAGES.values())|{'Home.md','_Sidebar.md','FAQ-Index.md'}
        if set(pages)!=wanted:errors.append('Wiki must contain exactly 20 planned flat Markdown pages')
        # GitHub injects _Sidebar automatically; it is not an ordinary linked page.
        ordinary=wanted-{'_Sidebar.md'}
        if not ordinary<=reachable:errors.append('Unreachable categories/pages '+str(sorted(ordinary-reachable)))
        for p in PAGES.values():
            if Path(p).stem not in links(pages['_Sidebar.md']):errors.append('Missing sidebar category '+p)
            if 'FAQ-Index' not in links(pages[p]) or 'Home' not in links(pages[p]):errors.append('Missing category return navigation '+p)
        index=links(pages['FAQ-Index.md'])
        for qid,m in by_id.items():
            target=Path(m['answer_page']).stem+'#'+m['answer_fragment']
            if index.count(target)!=1:errors.append(qid+' must have exactly one FAQ-index destination')
        extension_names={
            'AnalyticMathLabMollyExt':'Molly adapter',
            'AnalyticMathLabInferenceExt':'Inference fitting',
            'AnalyticMathLabDynamicsExt':'Learned dynamics',
            'AnalyticMathLabSurrogateExt':'Surrogate/operator learning',
            'AnalyticMathLabPINNExt':'PINNs',
        }
        project=tomllib.loads((ROOT/'Project.toml').read_text())
        for name,label in extension_names.items():
            triggers=project['extensions'][name]
            if isinstance(triggers,str):triggers=[triggers]
            expected_row='| '+label+' | '+', '.join(triggers)+' |'
            if expected_row not in blocks.get('Q076',''):errors.append('Q076 incorrect extension triggers '+name)
        prohibited=[r'AML automatically (?:chooses|selects|activates) (?:a |the )?(?:backend|CairoMakie)',r'origin tokens? (?:is|are) (?:a )?persistent (?:reproducibility )?hash',r'sparse inputs? (?:automatically )?(?:activates?|selects?) (?:a )?sparse eigensolver',r'diffusion_estimate refuses (?:all )?index-time',r'(?:global_memory_budget|set_memory_budget!)']
        for filename,text in pages.items():
            for expression in prohibited:
                if re.search(expression,text,re.I):errors.append('Unsupported semantic guarantee in '+filename)
        for qid in ('Q081','Q082','Q083','Q084','Q085'):
            if 'defect' not in blocks.get(qid,'').lower():errors.append(qid+' missing supported-input defect boundary')
    integrity=baseline_integrity()
    errors += ['Protected changed '+p for p in integrity['changed']+integrity['missing']]
    rendered=None
    if evidence:
        evidence=Path(evidence)
        result_path=evidence/'render_manifest.json'
        if not result_path.is_file():errors.append('Missing GitHub rendering evidence')
        else:
            manifest=json.loads(result_path.read_text())
            if Counter(row['page'] for row in manifest['pages'])!=Counter(pages.keys()):errors.append('Rendered manifest must cover every page exactly once')
            parsed={}
            for row in manifest['pages']:
                p=row['page']
                if p not in pages or row['source_sha256']!=digest((WIKI/p).read_bytes()):errors.append('Stale rendering evidence '+p)
                html=(evidence/row['html_file']).read_bytes()
                if digest(html)!=row['html_sha256']:errors.append('Rendered HTML hash mismatch '+p)
                parser=Rendered();parser.feed(html.decode());parsed[p]=parser
                if sorted(a for a in parser.anchors if a.startswith('user-content-q'))!=sorted(anchor_map.get(p,set())):errors.append('Rendered question anchors differ '+p)
            for p,parser in parsed.items():
                for link in parser.links:
                    parts=urlsplit(link)
                    if parts.scheme or parts.netloc:continue
                    target=planned.get(parts.path) if parts.path else p
                    if target not in parsed:errors.append('Rendered missing page '+link)
                    elif parts.fragment and parts.fragment not in parsed[target].anchors:errors.append('Rendered missing fragment '+link)
            rendered={'pages':len(parsed),'question_anchors':sum(len([a for a in p.anchors if a.startswith('user-content-q')]) for p in parsed.values()),'stateless_rendering_only':True}
        resource_path=evidence/'resource_readback.json'
        if not resource_path.is_file():errors.append('Missing published resource read-back evidence')
        else:
            records=json.loads(resource_path.read_text())['records']
            if Counter(row['path'] for row in records)!=Counter(resources):errors.append('Published resource evidence must cover every linked path exactly once')
            for row in records:
                path=ROOT/row['path']
                if row['status']!=200 or row['version']!=BASELINE or not path.is_file() or digest(path.read_bytes())!=row['sha256']:errors.append('Stale published resource evidence '+row['path'])
    return {'checkpoint':checkpoint,'status':'PASS' if not errors else 'FAIL','inventory_questions':len(INVENTORY),'required_answers':len(required),'covered_answers':len(pc),'categories_covered':len({lookup[i]['category'] for i in pc}),'priorities_covered':dict(Counter(lookup[i]['priority'] for i in pc)),'missing':missing,'duplicates':duplicate,'mapping_rows':len(mapping),'pages':len(pages),'internal_link_occurrences':internal,'pending_planned_links':len(pending),'repository_resources':sorted(resources),'external_unique_urls':len(external),'reachable_pages':sorted(reachable),'protected_integrity':integrity,'rendered':rendered,'errors':errors}


def render(evidence):
    evidence=Path(evidence);evidence.mkdir(parents=True,exist_ok=True)
    records=[]
    for path in sorted(WIKI.glob('*.md')):
        payload={'text':path.read_text(),'mode':'gfm','context':REPOSITORY}
        request=evidence/(path.stem+'.request.json')
        request.write_text(json.dumps(payload))
        response=subprocess.run(['gh','api','markdown','--method','POST','--input',str(request)],capture_output=True,text=True)
        if response.returncode:
            raise RuntimeError('GitHub render failed for '+path.name+': '+response.stderr)
        html=evidence/(path.stem+'.html');html.write_text(response.stdout)
        records.append({'page':path.name,'source_sha256':digest(path.read_bytes()),'html_file':html.name,'render_exit':response.returncode,'html_sha256':digest(html.read_bytes())})
    manifest={'renderer':'GitHub REST /markdown, gfm, stateless POST','publication':False,'pages':records}
    (evidence/'render_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    return {'status':'PASS','pages_rendered':len(records),'publication':False}


def verify_resources(evidence):
    evidence=Path(evidence);evidence.mkdir(parents=True,exist_ok=True)
    result=check()
    records=[]
    for path in result['repository_resources']:
        url='https://raw.githubusercontent.com/'+REPOSITORY+'/'+BASELINE+'/'+path
        with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'AnalyticMathLab-Wiki-verification'}),timeout=25) as response:
            data=response.read();status=response.status
        if status!=200 or data!=(ROOT/path).read_bytes():raise RuntimeError('Published source mismatch '+path)
        records.append({'path':path,'status':status,'sha256':digest(data),'version':BASELINE})
    (evidence/'resource_readback.json').write_text(json.dumps({'records':records,'source_only':True},indent=2)+'\n')
    return {'status':'PASS','published_resources_verified':len(records),'wiki_published':False}


def self_test():
    """Exercise negative fixtures in scratch, never mutate canonical Wiki input."""
    global WIKI, REPORTS
    original_wiki,original_reports=WIKI,REPORTS
    clean=check()
    if clean['status']!='PASS':
        return {'status':'FAIL','errors':['Canonical Wiki must pass before negative fixtures']}
    cases=[]
    with tempfile.TemporaryDirectory(prefix='aml-wiki-check-',dir=os.environ.get('TMPDIR')) as directory:
        directory=Path(directory)
        fixture_wiki=directory/'wiki';fixture_reports=directory/'reports'
        fixture_reports.mkdir()
        mapping_text=(original_reports/'wiki_target_reconciliation.json').read_text()
        try:
            for name in ('missing_answer','duplicate_answer','wording_drift','placeholder','broken_page','broken_fragment','missing_index_question','future_guide','fake_deployment','wrong_triggers','unsupported_backend_guarantee','missing_resource_distinction','missing_mapping','duplicate_anchor'):
                if fixture_wiki.exists():shutil.rmtree(fixture_wiki)
                shutil.copytree(original_wiki,fixture_wiki)
                mapping=fixture_reports/'wiki_target_reconciliation.json'
                mapping.write_text(mapping_text)
                WIKI,REPORTS=fixture_wiki,fixture_reports
                target=fixture_wiki/'Memory-and-Performance.md'
                text=target.read_text()
                if name=='missing_answer':
                    text=text[:text.index('<!-- aml-faq: {"id": "Q090"')]
                    target.write_text(text)
                elif name=='duplicate_answer':
                    start=text.index('<!-- aml-faq: {"id": "Q090"')
                    target.write_text(text+'\n'+text[start:])
                elif name=='wording_drift':
                    target=fixture_wiki/'Statistics.md'
                    target.write_text(target.read_text().replace('What time scale and fit-window assumptions are needed to interpret a diffusion estimate?','Why does diffusion refuse index-time?'))
                elif name=='placeholder':
                    target.write_text(re.sub(r'\*\*Short answer:\*\* [^\n]+','**Short answer:** See documentation.',text,count=1))
                elif name=='broken_page':target.write_text(text+'\n[Bad target](No-Such-Page)\n')
                elif name=='broken_fragment':target.write_text(text+'\n[Bad fragment](Statistics#user-content-q999)\n')
                elif name=='missing_index_question':
                    target=fixture_wiki/'FAQ-Index.md'
                    target.write_text(re.sub(r'^- .*Q066.*\n','',target.read_text(),flags=re.M))
                elif name=='future_guide':target.write_text(text+'\n[Future](guides/resource-limits.md)\n')
                elif name=='fake_deployment':target.write_text(text+'\n[Manual](https://example.invalid/analyticmath-lab/stable/)\n')
                elif name=='wrong_triggers':
                    target=fixture_wiki/'Optional-Extensions.md'
                    target.write_text(target.read_text().replace('| Surrogate/operator learning | Lux, Optimization, NeuralOperators |','| Surrogate/operator learning | Lux, Optimization |'))
                elif name=='unsupported_backend_guarantee':target.write_text(text+'\nAML automatically chooses a backend.\n')
                elif name=='missing_resource_distinction':target.write_text(re.sub('RSS','memory',text,flags=re.I))
                elif name=='missing_mapping':
                    data=json.loads(mapping_text);data['mappings']=data['mappings'][:-1]
                    mapping.write_text(json.dumps(data))
                elif name=='duplicate_anchor':target.write_text(text+'\n<a name="q066"></a>\n')
                result=check()
                cases.append({'fixture':name,'rejected':result['status']=='FAIL','error_count':len(result['errors'])})
        finally:
            WIKI,REPORTS=original_wiki,original_reports
    return {'status':'PASS' if all(row['rejected'] for row in cases) else 'FAIL','canonical_positive_control':'PASS','negative_fixtures':cases,'canonical_files_modified':False}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--checkpoint',choices=['F1','F2','F3','F4','F5'],default='F5')
    parser.add_argument('--render',action='store_true')
    parser.add_argument('--verify-resources',action='store_true')
    parser.add_argument('--self-test',action='store_true')
    parser.add_argument('--evidence-dir')
    args=parser.parse_args()
    if (args.render or args.verify_resources) and not args.evidence_dir:parser.error('Rendering/resource verification requires --evidence-dir')
    result=self_test() if args.self_test else render(args.evidence_dir) if args.render else verify_resources(args.evidence_dir) if args.verify_resources else check(args.checkpoint,args.evidence_dir)
    print(json.dumps(result,indent=2))
    raise SystemExit(0 if result['status']=='PASS' else 1)
