#!/usr/bin/env bash
# Usage:
#   ./build.sh                        Build the book + slides for every chapter listed in _quarto.yml
#                                     (Book -> docs/   Slides -> slides/ and docs/slides/)
#   ./build.sh _drafts/02-name.ipynb  Preview one notebook's slides without publishing
#                                     (saved to preview/, which git ignores)
#   Answers: chapters listed in hide-answers.txt are published WITHOUT their exercise solutions.
#            Preview builds always include the solutions (use those to present).
#   ./build.sh --only chapters/04-name.ipynb
#                                     Quick rebuild of ONE published chapter (its slides + book page).
#                                     Use after editing that notebook only. After changing shared files
#                                     (CSS, copy-code.html, _quarto.yml) or adding a chapter, run ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

render_slides() {   # $1 = notebook, $2 = output folder
  local nb="$1" out="$2" name tmp
  name=$(basename "$nb" .ipynb)
  tmp=$(mktemp -d)   # outside the book folder, so Quarto treats it as its own project
  cp slides-format.yml "$tmp/_quarto.yml"
  cp "$nb" slides.css annotations.css copy-code.html "$tmp/"
  mkdir -p "$tmp/images"
  [ -d chapters/images ] && cp -r chapters/images/. "$tmp/images/"
  [ -d "$(dirname "$nb")/images" ] && cp -r "$(dirname "$nb")/images/." "$tmp/images/"   # draft-only images
  (cd "$tmp" && quarto render "$name.ipynb" --quiet)
  mkdir -p "$out"
  cp "$tmp/$name.html" "$out/$name.html"
  rm -rf "$tmp"
  echo "Slides: $out/$name.html"
}

# Hide solutions for chapters listed in hide-answers.txt (published builds only).
# Each listed notebook is backed up, stripped for the build, and always restored afterwards.
BACKUP=$(mktemp -d)
restore_notebooks() {
  for f in "$BACKUP"/*.ipynb; do
    [ -e "$f" ] || continue
    cp "$f" "chapters/$(basename "$f")"
  done
  rm -rf "$BACKUP"
}
trap restore_notebooks EXIT INT TERM
hide_answers() {
  [ -f hide-answers.txt ] || return 0
  { grep -vE '^[[:space:]]*(#|$)' hide-answers.txt || true; } | while read -r nb; do
    nb=$(echo "$nb" | sed -E 's/[[:space:]]+$//')
    [ -f "$nb" ] || { echo "hide-answers.txt: not found: $nb"; continue; }
    cp "$nb" "$BACKUP/"
    python3 tools/hide_answers.py "$nb"
  done
}

# Quick mode: rebuild only the given chapter(s), slides and book page
if [ "${1:-}" = "--only" ]; then
  shift
  [ $# -gt 0 ] || { echo "Usage: ./build.sh --only chapters/NN-name.ipynb"; exit 1; }
  hide_answers
  for nb in "$@"; do
    [ -f "$nb" ] || { echo "Not found: $nb"; exit 1; }
    grep -q "$nb" _quarto.yml || { echo "$nb is not listed in _quarto.yml; run ./build.sh instead"; exit 1; }
    render_slides "$nb" slides
    mkdir -p docs/slides && cp "slides/$(basename "$nb" .ipynb).html" docs/slides/
    quarto render "$nb" --quiet
    echo "Book:   docs/chapters/$(basename "$nb" .ipynb).html"
  done
  touch docs/.nojekyll
  exit 0
fi

# Preview mode: just the notebooks given
if [ $# -gt 0 ]; then
  for nb in "$@"; do render_slides "$nb" preview; done
  exit 0
fi

hide_answers

# 1) Slides for the chapters listed (not commented out) in _quarto.yml
rm -rf slides && mkdir slides
for nb in $(grep -E '^[[:space:]]*-[[:space:]]*chapters/.*\.ipynb' _quarto.yml | sed -E 's/^[[:space:]]*-[[:space:]]*//'); do
  render_slides "$nb" slides
done

# 2) Book (copies slides/ in too, via 'resources' in _quarto.yml)
quarto render --quiet
touch docs/.nojekyll   # tells GitHub Pages to serve the files as-is
echo "Book:   docs/index.html"
