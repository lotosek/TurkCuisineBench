"""Offline checks for public aggregates, file integrity, and release boundaries.

Run from any directory with: python evaluation/test_public_release.py
This test does not read private inputs or call provider endpoints.
"""
import ast
import csv
import hashlib
import io
import json
import math
import re
import subprocess
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / 'results' / 'main_study'
NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}


def rows(name):
    with (RESULTS / name).open(encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))


def main():
    checks = 0

    def require(condition, message):
        nonlocal checks
        checks += 1
        if not condition:
            raise AssertionError(message)

    tracked = subprocess.check_output(
        ['git', '-c', 'safe.directory=' + ROOT.as_posix(), 'ls-files', '-z'], cwd=ROOT
    ).decode('utf-8').split('\0')[:-1]
    # Check newly added audit code and documentation before the first commit too.
    tracked = sorted(set(tracked) | {
        'evaluation/test_public_release.py', 'docs/README.md',
        'data/dev/README.md', 'workbooks/README.md'
    })
    known_hyperlink_cache_files = {
        f'workbooks/TurkCuisineBench_Pilot_Execution_{v}.xlsx'
        for v in ('v0.1', 'v0.2', 'v0.3_configured')
    }
    credential = re.compile(
        r'(?:sk-(?:proj-|ant-)?[A-Za-z0-9_-]{24,}|gsk_[A-Za-z0-9]{24,}'
        r'|AIza[A-Za-z0-9_-]{30,}|gh[pousr]_[A-Za-z0-9]{30,}'
        r'|-----BEGIN [A-Z ]*PRIVATE KEY-----)'
    )
    for rel in tracked:
        p = ROOT / rel
        require(p.exists(), f'Missing tracked file: {rel}')
        require(not any(x in rel.lower() for x in (
            '.env', 'home_computer_handoff', 'confidential_editorial',
            'final_consensus_private', 'student_outputs/', 'posthoc_outputs/'
        )), f'Private/unrelated output is tracked: {rel}')
        text = ''
        if p.suffix in {'.xlsx', '.docx'}:
            with zipfile.ZipFile(p) as z:
                require(z.testzip() is None, f'ZIP integrity: {rel}')
                errors = []
                for part in z.namelist():
                    require(not any(x in part for x in ('vbaProject', 'externalLinks/', 'embeddings/')),
                            f'Unexpected embedded/external object: {rel}:{part}')
                    if part.endswith(('.xml', '.rels')):
                        el = ET.fromstring(z.read(part))
                        text += '\n'.join(t.text for t in el.iter() if t.text)
                        if re.match(r'xl/worksheets/sheet\d+\.xml$', part):
                            for c in el.findall('.//s:c[@t="e"]', NS):
                                errors.append((part, c.get('r'), c.findtext('s:v', namespaces=NS)))
                if rel in known_hyperlink_cache_files:
                    require(len(errors) == 36 and all(
                        part == 'xl/worksheets/sheet3.xml'
                        and cell in {f'Q{i}' for i in range(4, 40)}
                        and value.startswith('HYPERLINK is not implemented.')
                        for part, cell, value in errors
                    ), f'Historical cache defect changed: {rel}')
                else:
                    require(not errors, f'Unexpected cached cell errors: {rel}')
        elif p.suffix != '.png':
            text = p.read_text(encoding='utf-8-sig')
            if p.suffix == '.py':
                ast.parse(text)
            elif p.suffix == '.json':
                json.loads(text)
            elif p.suffix == '.jsonl':
                for line in text.splitlines():
                    if line.strip(): json.loads(line)
            elif p.suffix == '.csv':
                table = list(csv.reader(io.StringIO(text)))
                require(bool(table) and all(len(r) == len(table[0]) for r in table),
                        f'CSV shape: {rel}')
            elif p.suffix == '.md':
                for link in re.findall(r'\[[^\]]*\]\(([^)]+)\)', text):
                    target = link.split('#')[0]
                    if target and '://' not in target and not target.startswith('mailto:'):
                        require((p.parent / target).exists(), f'Broken local link: {rel} -> {target}')
        require(not credential.search(text), f'Credential-like content found: {rel}')
        if p.name.startswith('SHA256SUMS'):
            for expected, target in re.findall(r'(?m)^([a-fA-F0-9]{64})\s+\*?(.+)$', text):
                dest = p.parent / target.strip()
                require(dest.is_file() and hashlib.sha256(dest.read_bytes()).hexdigest() == expected.lower(),
                        f'Release checksum mismatch: {rel}')

    manifest = (ROOT / 'docs/m4_methods_manifest_v0.1.md').read_text(encoding='utf-8')
    for target, expected in re.findall(r'`([^`]+\.(?:py|md|json|jsonl))` \| `([A-F0-9]{64})`', manifest):
        require(hashlib.sha256((ROOT / target).read_bytes()).hexdigest() == expected.lower(),
                f'M4 frozen artifact changed: {target}')
    performance = rows('13_table1_model_performance.csv')
    require(len(performance) == 8, 'Expected eight model slots')
    for name, total in {'expected_n': 576, 'valid_n': 574, 'invalid_n': 2,
                        'semantic_correct_n': 230, 'exact_correct_n': 187,
                        'explicit_abstention_n': 61, 'manual_review_n': 326,
                        'correct_non_exact_n': 43}.items():
        require(sum(int(r[name]) for r in performance) == total, f'Aggregate total: {name}')
    for r in performance:
        require(int(r['semantic_correct_n']) == int(r['exact_correct_n']) + int(r['correct_non_exact_n']),
                f'Recovery identity: {r["model_slot"]}')
        require(math.isclose(float(r['semantic_accuracy']), int(r['semantic_correct_n']) / int(r['valid_n'])),
                f'Accuracy denominator: {r["model_slot"]}')
    for filename in ('model_error_operations_v1.1.csv', 'model_error_targets_v1.1.csv'):
        table = rows(filename)
        require(len(table) == 8 and sum(int(r['error_responses']) for r in table) == 283, filename)
        for r in table:
            categories = set(r) - {'model_slot', 'model_id', 'valid_responses', 'error_responses'}
            require(sum(int(r[k]) for k in categories) == int(r['error_responses']),
                    f'Error composition: {filename}:{r["model_slot"]}')
    current = {r['hypothesis']: r for r in rows('submission_interpretation_v1.1.csv')}
    original = {r['hypothesis']: r for r in rows('13_table2_confirmatory_H1_H3.csv')}
    for h in ('H1', 'H2', 'H3'):
        for col in ('statistic', 'df', 'raw_p', 'holm_p', 'effect_estimate', 'effect_ci_low', 'effect_ci_high'):
            require(current[h][col] == original[h][col], f'Frozen numerical output changed: {h}:{col}')
    require(current['H3']['reporting_status'] == 'RECOVERY_ESTIMATED_CONFIRMATORY_DECISION_WITHHELD',
            'H3 interpretation amendment missing')
    require(len(rows('13_table3_H1_pairwise_comparisons.csv')) == 28, 'Pairwise family must remain 28')
    config = json.loads((ROOT / 'configs/main_study_config_v1.0.json').read_text())
    require(config['execution_authorized'] is False, 'Public execution lock must remain closed')
    print(f'PASS: {checks} offline public-release checks across {len(tracked)} files; '
          '108 documented historical hyperlink-cache errors retained, not numerical errors.')


if __name__ == '__main__':
    main()
