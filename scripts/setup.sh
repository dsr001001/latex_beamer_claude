#!/usr/bin/env bash
# setup.sh — deckpipe environment check
# Detects OS, checks dependencies, prints install instructions.
# Does NOT auto-install anything.

set -euo pipefail

BOLD=$(tput bold 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
GREEN=$(tput setaf 2 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)

PASS=0
FAIL=0

# ── Helpers ───────────────────────────────────────────────────────────────────
ok()   { echo "  ${GREEN}✓${RESET} $*"; ((PASS++)) || true; }
fail() { echo "  ${RED}✗${RESET} $*"; ((FAIL++)) || true; }
hint() { echo "    ${YELLOW}→${RESET} $*"; }
hr()   { echo "──────────────────────────────────────────"; }

# ── Detect OS ─────────────────────────────────────────────────────────────────
detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    OS_NAME=$(. /etc/os-release && echo "$PRETTY_NAME")
  elif [[ "$(uname)" == "Darwin" ]]; then
    OS_NAME="macOS $(sw_vers -productVersion)"
  else
    OS_NAME=$(uname -s)
  fi

  WSL=""
  if grep -qiE "(microsoft|WSL)" /proc/version 2>/dev/null; then
    WSL=" (WSL2)"
  fi

  echo "${OS_NAME}${WSL}"
}

# ── Install hints by OS ───────────────────────────────────────────────────────
hint_pandoc() {
  case "$1" in
    ubuntu|debian) hint "sudo apt install pandoc" ;;
    fedora|rhel)   hint "sudo dnf install pandoc" ;;
    arch)          hint "sudo pacman -S pandoc" ;;
    macos)         hint "brew install pandoc" ;;
    *)             hint "See https://pandoc.org/installing.html" ;;
  esac
}

hint_xelatex() {
  case "$1" in
    ubuntu|debian)
      hint "sudo apt install texlive-xetex texlive-fonts-recommended texlive-fonts-extra"
      hint "(or: sudo apt install texlive-full  — larger but complete)" ;;
    fedora|rhel)   hint "sudo dnf install texlive-xetex texlive-collection-fontsrecommended" ;;
    arch)          hint "sudo pacman -S texlive-core texlive-fontsrecommended" ;;
    macos)         hint "brew install --cask mactex  (full)  or  basictex  (minimal)" ;;
    *)             hint "See https://tug.org/texlive/" ;;
  esac
}

hint_make() {
  case "$1" in
    ubuntu|debian) hint "sudo apt install make" ;;
    fedora|rhel)   hint "sudo dnf install make" ;;
    arch)          hint "sudo pacman -S make" ;;
    macos)         hint "xcode-select --install" ;;
    *)             hint "Install GNU Make for your OS" ;;
  esac
}

os_family() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    ID=$(. /etc/os-release && echo "${ID_LIKE:-$ID}" | tr '[:upper:]' '[:lower:]')
    case "$ID" in
      *ubuntu*|*debian*) echo "ubuntu" ;;
      *fedora*|*rhel*)   echo "fedora" ;;
      *arch*)            echo "arch"   ;;
      *)                 echo "linux"  ;;
    esac
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo
echo "${BOLD}deckpipe environment check${RESET}"
hr

OS=$(detect_os)
FAMILY=$(os_family)
echo "  OS:  $OS"
echo

# ── Dependency checks ─────────────────────────────────────────────────────────
echo "${BOLD}Dependencies${RESET}"

# pandoc
if command -v pandoc >/dev/null 2>&1; then
  PANDOC_VER=$(pandoc --version | head -1)
  ok "pandoc    $PANDOC_VER"
else
  fail "pandoc    not found"
  hint_pandoc "$FAMILY"
fi

# xelatex
if command -v xelatex >/dev/null 2>&1; then
  ok "xelatex   found"
else
  fail "xelatex   not found  (required for: make pdf, make rpdf)"
  hint_xelatex "$FAMILY"
fi

# make
if command -v make >/dev/null 2>&1; then
  MAKE_VER=$(make --version | head -1)
  ok "make      $MAKE_VER"
else
  fail "make      not found"
  hint_make "$FAMILY"
fi

echo

# ── Template checks ───────────────────────────────────────────────────────────
echo "${BOLD}Templates${RESET}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

check_file() {
  local path="$ROOT_DIR/$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    ok "$label"
  else
    fail "$label  (missing)"
    hint "Run: make init-templates"
  fi
}

check_file "templates/deck-template.pptx"                    "deck-template.pptx"
check_file "templates/report-template.docx"                  "report-template.docx"
check_file "templates/beamer-theme/beamerthemedeckpipe.sty"  "beamerthemedeckpipe.sty"
check_file "templates/beamer-theme/beamercolorthemedeckpipe.sty" "beamercolorthemedeckpipe.sty"
check_file "templates/latex-preamble.tex"                    "latex-preamble.tex"

echo

# ── Content checks ────────────────────────────────────────────────────────────
echo "${BOLD}Content${RESET}"
check_file "content/example-deck.md"   "example-deck.md"
check_file "content/example-report.md" "example-report.md"
check_file "filters/columns.lua"       "filters/columns.lua"

echo

# ── Assets ────────────────────────────────────────────────────────────────────
echo "${BOLD}Assets${RESET}"
LOGO="$ROOT_DIR/assets/logo.png"
if [[ -f "$LOGO" ]]; then
  ok "assets/logo.png"
else
  echo "  ${YELLOW}~${RESET} assets/logo.png  not found (optional — slides work without it)"
  hint "Add your logo as assets/logo.png (PNG recommended for LaTeX/PPTX)"
  hint "Or replace the image reference in content/example-deck.md"
fi

echo

# ── Summary ───────────────────────────────────────────────────────────────────
hr
if [[ $FAIL -eq 0 ]]; then
  echo "${GREEN}${BOLD}All checks passed.${RESET} Run: make deck"
else
  echo "${RED}${BOLD}$FAIL check(s) failed.${RESET} Install missing dependencies, then run again."
  echo
  echo "Quick start (after installing deps):"
  echo "  make init-templates   # extract pandoc reference templates (once)"
  echo "  make check            # re-verify environment"
  echo "  make deck             # build example PPTX"
fi
echo
