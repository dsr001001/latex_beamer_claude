# CLAUDE.md — AI Assistant Guide for latex_beamer_claude

## Project Overview

This repository contains **LaTeX Beamer presentations** — professional slide decks compiled to PDF using `pdflatex`. It is a minimal, content-focused repository with no application code, tests, or CI/CD pipelines.

---

## Repository Structure

```
latex_beamer_claude/
├── CLAUDE.md            # This file
├── .gitignore           # Ignores LaTeX build artifacts
├── build.sh             # Build script for slides.tex → slides.pdf
├── slides.tex           # Presentation: India–Canada Summit (March 2026)
├── slides.pdf           # Compiled output (committed to repo)
├── ms_linux_cli.tex     # Presentation: Microsoft Embraces Linux & CLI (2015–2026)
└── ms_linux_cli.pdf     # Compiled output (committed to repo)
```

---

## Presentations

### `slides.tex` — India–Canada Summit: A New Chapter
- **Subject:** PM Modi & Canadian PM Mark Carney delegation-level talks
- **Date:** March 2, 2026 — Hyderabad House, New Delhi
- **Slides:** 4 (title, key highlights, economic/strategic outcomes, new chapter)
- **Theme:** Madrid / seahorse color scheme

### `ms_linux_cli.tex` — Microsoft Embraces Linux & CLI (2015–2026)
- **Subject:** Timeline of Microsoft's embrace of Linux and open-source CLI tools
- **Layout:** Single slide, two-column (Foundation 2015–2020 | Recent Advances 2023–2026)
- **Theme:** Madrid / seahorse color scheme

---

## Building Presentations

### Prerequisites

`pdflatex` must be installed (part of a TeX distribution such as TeX Live or MiKTeX).

```bash
# Debian/Ubuntu
sudo apt-get install texlive-latex-extra

# macOS (Homebrew)
brew install --cask mactex
```

### Build `slides.tex`

```bash
./build.sh
```

This runs `pdflatex` twice (required to resolve internal cross-references such as navigation bars):

```bash
pdflatex -interaction=nonstopmode slides.tex && pdflatex -interaction=nonstopmode slides.tex
```

### Build any other `.tex` file

Run `pdflatex` twice manually:

```bash
pdflatex -interaction=nonstopmode ms_linux_cli.tex && pdflatex -interaction=nonstopmode ms_linux_cli.tex
```

### Output

Compiled PDFs are committed alongside their source `.tex` files. Always regenerate and commit the PDF after editing a `.tex` file.

---

## LaTeX / Beamer Conventions

- **Document class:** `\documentclass{beamer}`
- **Theme:** `\usetheme{Madrid}` — provides header/footer navigation bars
- **Color theme:** `\usecolortheme{seahorse}` — blue/teal palette
- **Frame structure:** Each slide is a `\begin{frame}...\end{frame}` block
- **Title slide:** Use `\titlepage` inside a plain frame
- **Bullet lists:** `\begin{itemize}` with `\item`; nested itemize for sub-points
- **Bold text:** `\textbf{...}`, italic: `\textit{...}`
- **Multi-column layouts:** Use `\begin{columns}[T]` / `\begin{column}{0.48\textwidth}`
- **Special characters:** Escape `&` as `\&`, use `--` for en-dash, `---` for em-dash
- **Small text:** `\small` or `{\small ...}` for compact itemize content

---

## Git Conventions

- **Branch naming:** `claude/<description>-<id>` (e.g., `claude/add-claude-documentation-Yl2Bp`)
- **Commit messages:** Descriptive single-line summary; may include a Claude Code session URL as a trailer
- **Committed artifacts:** PDFs are committed to the repository alongside `.tex` sources
- **Ignored files:** LaTeX build artifacts (`*.aux`, `*.log`, `*.nav`, `*.out`, `*.snm`, `*.toc`) are git-ignored

---

## Development Workflow

1. **Edit** the relevant `.tex` file
2. **Build** the PDF (`./build.sh` for `slides.tex`, or run `pdflatex` twice for others)
3. **Verify** the generated PDF looks correct
4. **Stage and commit** both the `.tex` and the updated `.pdf`
5. **Push** to the appropriate `claude/` feature branch

---

## Adding a New Presentation

1. Create `<name>.tex` using the standard Beamer preamble:
   ```latex
   \documentclass{beamer}
   \usetheme{Madrid}
   \usecolortheme{seahorse}

   \title{Your Title}
   \subtitle{Optional Subtitle}
   \author{Author or Location}
   \date{Date}
   \institute{Institution or Event}

   \begin{document}
   \begin{frame}
     \titlepage
   \end{frame}
   % ... additional frames ...
   \end{document}
   ```
2. Compile with `pdflatex` (twice):
   ```bash
   pdflatex -interaction=nonstopmode <name>.tex && pdflatex -interaction=nonstopmode <name>.tex
   ```
3. Commit both `<name>.tex` and `<name>.pdf`.
4. If the new file should be the default build target, update `build.sh`.

---

## Notes for AI Assistants

- There is no test suite — successful PDF generation is the verification step.
- Always run `pdflatex` **twice** to ensure navigation bars and references resolve correctly.
- Do not delete or regenerate PDFs without also updating the corresponding `.tex` source.
- Commit PDFs alongside their sources — they are part of the deliverable.
- Keep presentations thematically consistent: Madrid theme + seahorse colors unless explicitly asked to change.
