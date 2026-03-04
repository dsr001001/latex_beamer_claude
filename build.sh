#!/bin/bash
# Build Beamer slides to PDF (run twice to resolve references)
pdflatex -interaction=nonstopmode slides.tex && pdflatex -interaction=nonstopmode slides.tex
echo "Build complete: slides.pdf"
