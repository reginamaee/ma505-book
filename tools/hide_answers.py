#!/usr/bin/env python3
"""Remove exercise solutions from a notebook IN PLACE (build.sh backs it up and restores it).

Everything after a <div class="solution-start"></div> marker, up to the next "## " slide,
is deleted, and the marker is replaced with a short "posted after class" note.
Usage: python3 tools/hide_answers.py chapters/04-name.ipynb
"""
import json, sys

MARK = '<div class="solution-start"></div>'
NOTE = '<div class="answers-later">Solutions will be posted after class.</div>'

path = sys.argv[1]
nb = json.load(open(path))
keep, hiding, n = [], False, 0
for c in nb['cells']:
    src = ''.join(c['source'])
    if c['cell_type'] == 'markdown' and src.lstrip().startswith('## '):
        hiding = False
    if hiding:
        continue                     # a solution cell: drop it
    if MARK in src:
        head = src.split(MARK)[0]    # keep the question, drop anything after the marker
        c['source'] = (head + NOTE + '\n').splitlines(keepends=True)
        hiding, n = True, n + 1
    keep.append(c)
nb['cells'] = keep
json.dump(nb, open(path, 'w'), indent=1)
print(f"Answers hidden: {path} ({n} exercise{'s' if n != 1 else ''})")
