#!/usr/bin/env bash
# Usage:
#   ./build.sh                        Build the book + slides for every chapter listed in _quarto.yml
#                                     (Book -> docs/   Slides -> slides/ and docs/slides/)
#   ./build.sh _drafts/02-name.ipynb  Preview one notebook's slides without publishing
#                                     (saved to preview/, which git ignores)
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

# Preview mode: just the notebooks given
if [ $# -gt 0 ]; then
  for nb in "$@"; do render_slides "$nb" preview; done
  exit 0
fi

# 1) Slides for the chapters listed (not commented out) in _quarto.yml
rm -rf slides && mkdir slides
for nb in $(grep -E '^[[:space:]]*-[[:space:]]*chapters/.*\.ipynb' _quarto.yml | sed -E 's/^[[:space:]]*-[[:space:]]*//'); do
  render_slides "$nb" slides
done

# 2) Book (copies slides/ in too, via 'resources' in _quarto.yml)
quarto render --quiet
touch docs/.nojekyll   # tells GitHub Pages to serve the files as-is
echo "Book:   docs/index.html"
