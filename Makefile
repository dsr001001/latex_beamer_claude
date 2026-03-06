# deckpipe Makefile
# Dependencies: pandoc, texlive-xetex (for PDF/Beamer), make

# Configurable — override per project:
#   DECK_SRC=my-deck.md make deck
DECK_SRC     ?= content/example-deck.md
REPORT_SRC   ?= content/example-report.md
DECK_TPL     := templates/deck-template.pptx
REPORT_TPL   := templates/report-template.docx
BEAMER_DIR   := templates/beamer-theme
PREAMBLE     := templates/latex-preamble.tex
OUTPUT       := output
LOGO         := assets/logo.png

# Pandoc common flags
PANDOC_COMMON := --resource-path=.:assets

.PHONY: deck pdf report rpdf all clean check init-templates

# All outputs
all: deck pdf report rpdf

# PowerPoint deck from markdown
deck: $(DECK_SRC) $(DECK_TPL)
	@mkdir -p $(OUTPUT)
	pandoc $(DECK_SRC) -o $(OUTPUT)/deck.pptx \
		--reference-doc=$(DECK_TPL) \
		--lua-filter=filters/columns.lua \
		$(PANDOC_COMMON)
	@echo "→ $(OUTPUT)/deck.pptx"

# Beamer PDF slides from markdown
pdf: $(DECK_SRC)
	@mkdir -p $(OUTPUT)
	TEXINPUTS="$(BEAMER_DIR):$$TEXINPUTS" \
	pandoc $(DECK_SRC) -t beamer -o $(OUTPUT)/deck.pdf \
		-V theme:deckpipe \
		-V aspectratio:169 \
		-H $(PREAMBLE) \
		--pdf-engine=xelatex \
		$(PANDOC_COMMON)
	@echo "→ $(OUTPUT)/deck.pdf"

# Word document from markdown
report: $(REPORT_SRC) $(REPORT_TPL)
	@mkdir -p $(OUTPUT)
	pandoc $(REPORT_SRC) -o $(OUTPUT)/report.docx \
		--reference-doc=$(REPORT_TPL) \
		--toc \
		$(PANDOC_COMMON)
	@echo "→ $(OUTPUT)/report.docx"

# PDF document from markdown (via LaTeX)
rpdf: $(REPORT_SRC)
	@mkdir -p $(OUTPUT)
	pandoc $(REPORT_SRC) -o $(OUTPUT)/report.pdf \
		-V geometry:margin=2.54cm \
		-V fontsize:11pt \
		-H $(PREAMBLE) \
		--pdf-engine=xelatex \
		--toc \
		$(PANDOC_COMMON)
	@echo "→ $(OUTPUT)/report.pdf"

# Extract pandoc default reference templates
# Run once after cloning: make init-templates
init-templates:
	@mkdir -p templates
	@echo "Extracting pandoc default reference templates..."
	pandoc --print-default-data-file reference.pptx > $(DECK_TPL)
	pandoc --print-default-data-file reference.docx > $(REPORT_TPL)
	@echo "→ $(DECK_TPL)"
	@echo "→ $(REPORT_TPL)"
	@echo "Templates created. Open in PowerPoint/Word to apply branding,"
	@echo "or use as-is for functional (unstyled) output."

# Dependency check
check:
	@echo "Checking dependencies..."
	@command -v pandoc    >/dev/null 2>&1 \
		&& echo "✓ pandoc    $$(pandoc --version | head -1)" \
		|| echo "✗ pandoc    not found"
	@command -v xelatex   >/dev/null 2>&1 \
		&& echo "✓ xelatex   found" \
		|| echo "✗ xelatex   not found  (needed for PDF targets)"
	@command -v make      >/dev/null 2>&1 \
		&& echo "✓ make      found" \
		|| echo "✗ make      not found"
	@test -f $(DECK_TPL)   && echo "✓ $(DECK_TPL)"   || echo "✗ $(DECK_TPL) missing — run: make init-templates"
	@test -f $(REPORT_TPL) && echo "✓ $(REPORT_TPL)" || echo "✗ $(REPORT_TPL) missing — run: make init-templates"
	@echo "Done."

clean:
	rm -rf $(OUTPUT)/*
	@echo "Cleaned output/"
