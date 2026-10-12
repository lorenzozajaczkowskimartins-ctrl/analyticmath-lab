"""Bounded M10D.6C runner and Markdown/script integrity checker; no full suite."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time
import tomllib

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "reports/m10d6/tutorial_verification.json"
EVIDENCE = Path.home() / ".hermes/logs/analyticmath-lab/m10d6c"
GROUPS = {
    "C2": ("calculus", "multivariate", "vector_calculus"),
    "C3": ("mechanics", "normal_modes", "odes"),
    "C4": ("trajectories", "atomistics", "one_system_many_methods", "canonical"),
}
PAGES: dict[str, str] = {"vector_calculus": "vector-calculus", "normal_modes": "normal-modes",
         "one_system_many_methods": "one-system-many-methods"}
MARKERS = {name: name.upper() + "_OK" for group in GROUPS.values() for name in group}
MARKERS["canonical"] = "Analytical oracle: same physical model, NOT descended from the trajectory."
ENV = dict(os.environ, JULIA_LOAD_PATH="@:@stdlib", JULIA_NUM_THREADS="1",
           OPENBLAS_NUM_THREADS="1", JULIA_PKG_PRECOMPILE_AUTO="0")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(data):
    MANIFEST.write_text(json.dumps(data, indent=2) + "\n")


def run(group):
    data = json.loads(MANIFEST.read_text())
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    probe = ['julia', '+1.12.7', '--startup-file=no', '--project=.', '-e',
             'using AnalyticMathLab, Symbolics, LinearAlgebra; '
             'println("Julia=", VERSION); println("Project=", Base.active_project()); '
             'println("AML=", pkgversion(AnalyticMathLab)); '
             'println("Symbolics=", pkgversion(Symbolics)); '
             '@assert VERSION == v"1.12.7"; '
             '@assert Base.active_project() == joinpath(pwd(), "Project.toml")']
    info = subprocess.run(probe, cwd=ROOT, env=ENV, text=True,
                          capture_output=True, timeout=180)
    assert info.returncode == 0, info.stderr
    data["runtime"] = {"probe_command": probe, "output": info.stdout,
                       "exit_status": info.returncode, "environment": {
                           k: ENV[k] for k in ("JULIA_LOAD_PATH", "JULIA_NUM_THREADS",
                                               "OPENBLAS_NUM_THREADS", "JULIA_PKG_PRECOMPILE_AUTO")},
                       "dependency_resolution": "NOT_PERFORMED; existing root Manifest and depot"}
    for name in GROUPS[group]:
        path = ("examples/integration/one_system_many_methods.jl" if name == "canonical"
                else f"docs/tutorials/scripts/{name}.jl")
        # This is the actual command published in the tutorial, without REPL state.
        command = ['julia', '+1.12.7', '--project=.', path]
        log = EVIDENCE / (name + ".log")
        previous = next((r for r in data["executions"] if r["name"] == name), None)
        if (previous and previous["status"] == "PASS" and
                previous["script_sha256"] == digest(ROOT / path) and
                log.exists() and previous["log_sha256"] == digest(log)):
            print(name, "PASS reused unchanged execution", flush=True)
            continue
        if previous:
            old_log = EVIDENCE / (name + "-initial.log")
            if log.exists():
                old_log.write_bytes(log.read_bytes())
            history = dict(previous, log=str(old_log))
            data.setdefault("previous_attempts", []).append(history)
        record = {"name": name, "command": command, "cwd": str(ROOT),
                  "script_sha256": digest(ROOT / path), "log": str(log),
                  "status": "RUNNING", "start_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
        data["executions"] = [r for r in data["executions"] if r["name"] != name] + [record]
        save(data)
        started = time.monotonic()
        try:
            with log.open("w") as out:
                child = subprocess.run(command, cwd=ROOT, env=ENV,
                                       stdout=out, stderr=subprocess.STDOUT, timeout=240)
            record["exit_status"] = child.returncode
        except subprocess.TimeoutExpired:
            record["exit_status"] = None
            record["status"] = "TIMEOUT"
            save(data)
            raise
        record.update(duration_seconds=round(time.monotonic()-started, 3), log_sha256=digest(log))
        output = log.read_text()
        record["completion_marker"] = MARKERS[name]
        record["marker_present"] = MARKERS[name] in output
        record["status"] = "PASS" if child.returncode == 0 and record["marker_present"] else "FAIL"
        record["observed_output"] = output
        save(data)
        print(name, record["status"], "exit", child.returncode, flush=True)
        print(output, flush=True)
        if record["status"] != "PASS":
            raise SystemExit(1)
    data["checkpoints"][group] = {"status": "COMPLETE", "evidence": list(GROUPS[group])}
    save(data)


def static():
    data = json.loads(MANIFEST.read_text())
    deps = tomllib.loads((ROOT / "Project.toml").read_text())["deps"]
    blocks, links = [], []
    pages = [ROOT / "docs/tutorials/index.md"]
    for names in GROUPS.values():
        for name in names:
            if name == "canonical":
                continue
            page = ROOT / "docs/tutorials" / (PAGES.get(name, name) + ".md")
            pages.append(page)
            script = ROOT / "docs/tutorials/scripts" / (name + ".jl")
            text = page.read_text()
            matches = re.findall(r"```julia\n(.*?)```", text, re.S)
            assert len(matches) == 1, (page, "expected one complete Julia block")
            assert matches[0] == script.read_text(), (page, "snippet drift")
            execution = next(r for r in data["executions"] if r["name"] == name)
            assert execution["status"] == "PASS" and execution["exit_status"] == 0
            assert execution["script_sha256"] == digest(script), (name, "stale execution")
            assert execution["log_sha256"] == digest(Path(execution["log"]))
            imports = re.findall(r"^using (.+)$", script.read_text(), re.M)
            direct = [s.strip() for line in imports for s in line.split(",")]
            assert all(s in deps or s in ("AnalyticMathLab", ".HarmonicTutorial") for s in direct), direct
            commands = re.findall(r"```sh\n(.*?)```", text, re.S)
            assert all(c.strip() in (" ".join(r["command"]) for r in data["executions"])
                       for c in commands), (page, "unexecuted command")
            blocks.append({"page": str(page.relative_to(ROOT)), "script": str(script.relative_to(ROOT)),
                           "sha256": digest(script), "imports": direct})
    canonical = next(r for r in data["executions"] if r["name"] == "canonical")
    assert canonical["status"] == "PASS" and canonical["exit_status"] == 0
    assert canonical["script_sha256"] == digest(ROOT / canonical["command"][-1])
    assert canonical["log_sha256"] == digest(Path(canonical["log"]))
    tutorial_page_count = len(pages)
    pages.extend([ROOT / "README.md", ROOT / "reports/m10d6/tutorial_implementation_report.md"])
    for page in pages:
        text = page.read_text()
        for target in re.findall(r"!?\[[^\]]*\]\(([^\s)]+)\)", text):
            if re.match(r"(?:https?://|mailto:)", target):
                continue
            path, _, anchor = target.partition("#")
            dest = page.parent / path if path else page
            assert dest.exists(), (page, target)
            if anchor and dest.suffix == ".md":
                headings = re.findall(r"^#{1,6} (.+)$", dest.read_text(), re.M)
                anchors = [re.sub(r"[^\w\- ]", "", h.lower()).replace(" ", "-") for h in headings]
                assert anchor in anchors, (page, target)
            links.append((str(page.relative_to(ROOT)), target))
    protected = json.loads((EVIDENCE / "protected_snapshot.json").read_text())
    assert all(digest(ROOT / p) == h for p, h in protected.items()), "protected-file mutation"
    assert len((ROOT / "README.md").read_text().splitlines()) <= 305
    baseline_readme = subprocess.check_output(
        ['git', 'show', data['baseline'] + ':README.md'], cwd=ROOT).decode()
    nav = '- [Executable scientific tutorials and learning path](docs/tutorials/index.md).\n'
    current_readme = (ROOT / "README.md").read_text()
    assert current_readme.count(nav) == 1
    assert current_readme.replace(nav, '', 1) == baseline_readme, "README scope expanded"
    data["static_validation"] = {"status": "PASS", "script_equivalence": blocks,
        "julia_blocks": len(blocks), "tutorial_pages_including_index": tutorial_page_count,
        "markdown_files_link_checked": len(pages), "readme_only_one_navigation_line": True,
        "relative_link_occurrences": len(links), "unique_relative_targets": len(set(t for _, t in links)),
        "protected_baseline_files": len(protected), "all_protected_hashes_match": True,
        "readme_lines": len((ROOT / "README.md").read_text().splitlines()),
        "scope": "new tutorials plus all README links; no full-repository semantic re-audit"}
    save(data)
    print(json.dumps(data["static_validation"], indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["run", "static"])
    parser.add_argument("group", nargs="?", choices=list(GROUPS))
    args = parser.parse_args()
    os.chdir(ROOT)
    if args.action == "run":
        assert args.group is not None
        run(args.group)
    else:
        static()
