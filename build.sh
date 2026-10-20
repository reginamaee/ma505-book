#!/usr/bin/env bash
# Builds the book AND a slide deck for every chapter notebook.
#   Book   -> docs/index.html  (this folder is what GitHub Pages publishes)
#   Slides -> slides/<chapter>.html  (also copied into docs/slides/)
set -euo pipefail
cd "$(dirname "$0")"

# 1) Slides: render each notebook to reveal.js in a temporary folder
mkdir -p slides
for nb in chapters/*.ipynb; do
  name=$(basename "$nb" .ipynb)
  tmp=$(mktemp -d)   # outside the book folder, so Quarto treats it as its own project
  cp slides-format.yml "$tmp/_quarto.yml"
  cp "$nb" slides.css annotations.css "$tmp/"
  [ -d chapters/images ] && cp -r chapters/images "$tmp/"
  (cd "$tmp" && quarto render "$name.ipynb" --quiet)
  cp "$tmp/$name.html" "slides/$name.html"
  rm -rf "$tmp"
  echo "Slides: slides/$name.html"
done

# 2) Book (copies slides/ in too, via 'resources' in _quarto.yml)
quarto render --quiet
touch docs/.nojekyll   # tells GitHub Pages to serve the files as-is
echo "Book:   docs/index.html"
