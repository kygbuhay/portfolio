#!/usr/bin/env bash
# diff_menu.sh
# Interactive wrapper to pick two files and run diff_files.py

set -euo pipefail

DIR="."
EXT_FILTER=""
HTML_OUT="diff.html"
AUTO_OPEN_HTML=false
NO_HTML=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [-d DIR] [-e EXT] [--no-html] [--open]
  -d DIR     Directory to browse (default: current)
  -e EXT     Only show files matching extension (e.g. sql, md, py)
  --no-html  Skip writing HTML diff
  --open     Auto-open HTML diff in your browser
EOF
}

# Parse args
while (( "$#" )); do
  case "$1" in
    -d) DIR="$2"; shift 2 ;;
    -e) EXT_FILTER="$2"; shift 2 ;;
    --no-html) NO_HTML=true; shift ;;
    --open) AUTO_OPEN_HTML=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[!] Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ ! -d "$DIR" ]]; then
  echo "[!] Directory not found: $DIR" >&2
  exit 1
fi

# Build the file list
shopt -s nullglob
if [[ -n "$EXT_FILTER" ]]; then
  mapfile -t FILES < <(find "$DIR" -maxdepth 1 -type f -name "*.${EXT_FILTER}" | sort)
else
  mapfile -t FILES < <(find "$DIR" -maxdepth 1 -type f | sort)
fi

if (( ${#FILES[@]} < 2 )); then
  echo "[!] Need at least two files in $DIR${EXT_FILTER:+ matching *.$EXT_FILTER}." >&2
  exit 1
fi

pick_with_fzf() {
  # Pick exactly two files with fzf multi-select
  local selection
  selection=$(printf "%s\n" "${FILES[@]}" | fzf --multi --prompt="Select TWO files > " --height=80% --min-height=20 --layout=reverse --bind "enter:toggle+down" --preview 'bat --style=plain --line-range=1:200 --color=always {} 2>/dev/null || head -n 200 {}' )
  # Ensure two lines
  local count
  count=$(printf "%s\n" "$selection" | sed '/^$/d' | wc -l | tr -d ' ')
  if [[ "$count" -ne 2 ]]; then
    echo "[!] Please select exactly TWO files." >&2
    exit 1
  fi
  printf "%s\n" "$selection"
}

pick_with_select() {
  echo "Select the FIRST file:"
  select f1 in "${FILES[@]}"; do
    [[ -n "${f1:-}" ]] && break
  done
  echo "Select the SECOND file:"
  select f2 in "${FILES[@]}"; do
    [[ -n "${f2:-}" ]] && break
  done
  printf "%s\n%s\n" "$f1" "$f2"
}

# Choose picker
LEFT=""
RIGHT=""

if command -v fzf >/dev/null 2>&1; then
  SEL=$(pick_with_fzf)
  LEFT=$(echo "$SEL" | sed -n '1p')
  RIGHT=$(echo "$SEL" | sed -n '2p')
else
  # Fallback to Bash select
  SEL=$(pick_with_select)
  LEFT=$(echo "$SEL" | sed -n '1p')
  RIGHT=$(echo "$SEL" | sed -n '2p')
fi

echo ""
echo "You chose:"
echo "  1) $LEFT"
echo "  2) $RIGHT"
read -r -p "Proceed? [Y/n] " ans
ans=${ans:-Y}
if [[ "$ans" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Ensure python helper exists (same dir as this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/diff_files.py"
if [[ ! -x "$PY" && ! -f "$PY" ]]; then
  echo "[!] Could not find diff_files.py in $SCRIPT_DIR" >&2
  exit 1
fi

# Build python args
PY_ARGS=()
$NO_HTML && PY_ARGS+=("--no-html") || PY_ARGS+=("--html-out" "$HTML_OUT")
$AUTO_OPEN_HTML && PY_ARGS+=("--open")

echo ""
echo "=== Unified diff (terminal) ==="
python3 "$PY" "$LEFT" "$RIGHT" "${PY_ARGS[@]}"

# Pretty pager if available
if command -v less >/dev/null 2>&1; then
  echo ""
  read -r -p "View diff again in pager? [y/N] " pager
  if [[ "$pager" =~ ^[Yy]$ ]]; then
    python3 "$PY" "$LEFT" "$RIGHT" --no-html | less -R
  fi
fi

# If HTML generated but not auto-opened, offer to open
if ! $NO_HTML && ! $AUTO_OPEN_HTML; then
  if [[ -f "$HTML_OUT" ]]; then
    read -r -p "Open $HTML_OUT in browser? [y/N] " op
    if [[ "$op" =~ ^[Yy]$ ]]; then
      if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$HTML_OUT" >/dev/null 2>&1 &
      else
        python3 - <<'PYEOF'
import webbrowser, sys, pathlib
webbrowser.open_new_tab(pathlib.Path("diff.html").absolute().as_uri())
PYEOF
      fi
    fi
  fi
fi

