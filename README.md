# MA505 – Introduction to SAS (book + slides)

**One notebook per class day** is the single source. The same file produces:

- the **slide deck** for that day (reveal.js, one self-contained `.html`)
- a **chapter of the course book** (a website you can host on GitHub Pages)

```
ma505-book/
├── _quarto.yml              book settings + chapter list
├── index.qmd                book home page (links to slide decks)
├── chapters/
│   ├── 01-intro-to-sas.ipynb   <- Day 1 (edit this)
│   └── images/
├── slides-format.yml        slide settings (theme, size)
├── slides.css               slide styling
├── build.sh                 builds slides + book
└── setup/sascfg_personal.py connects Jupyter to SAS OnDemand
```

## How a notebook becomes slides

- Each `##` heading starts a new slide (and a new section in the book).
- Code cells are real SAS. Their **saved output** (tables, plots) appears on the slides and in the book.
- The book build does **not** run SAS. It uses whatever output is saved in the notebook, so you only need SAS when you change code.

## 1. One-time setup

1. Install [Quarto](https://quarto.org/docs/get-started/) and [Java](https://adoptium.net/) (Java is needed for the SAS connection).
2. Install Jupyter and the SAS kernel:
   ```bash
   pip install jupyterlab saspy sas_kernel
   ```
3. Connect to your SAS OnDemand account:
   - Copy `setup/sascfg_personal.py` to `~/.config/saspy/sascfg_personal.py`
     (check the server names against your ODA dashboard).
   - Create a file `~/.authinfo` with one line:
     ```
     oda user YOUR_ODA_USERID password YOUR_ODA_PASSWORD
     ```
     then run `chmod 600 ~/.authinfo`.
4. Test it: open JupyterLab (`jupyter lab`), choose the **SAS** kernel, and run `proc print data=sashelp.class; run;`.
   If the SAS kernel isn't listed, run `python -m sas_kernel.install --user`.

## 2. Each week

1. Copy the last chapter, e.g. `chapters/02-<topic>.ipynb`, and edit it in JupyterLab.
2. **Run all cells** (Kernel → Restart & Run All) so the SAS output is saved, then save the file.
3. Add the new chapter to `_quarto.yml` and a slide link in `index.qmd`.
4. Build:
   ```bash
   ./build.sh
   ```
   - Slides: `slides/<chapter>.html` (opens in any browser; you can also upload it to Moodle)
   - Book: `docs/index.html`

## 3. Publish to GitHub Pages

The built book lives in `docs/`, which GitHub Pages can serve directly.

1. In GitHub Desktop: **File → Add Local Repository**, choose this folder, and create a repository if asked.
2. **Publish repository** (uncheck "Keep this code private" so students can see the site).
3. On github.com, open the repo → **Settings → Pages** → Source: **Deploy from a branch** → Branch: `main`, folder: `/docs` → Save.
4. After a minute the book is live at `https://<your-username>.github.io/<repo-name>/`, and the slides at `.../slides/01-intro-to-sas.html`.

Each week: run `./build.sh`, then **Commit** and **Push** in GitHub Desktop.
