#!/usr/bin/env python3
# diff_files.py
from pathlib import Path
import argparse, sys, difflib, webbrowser

def read_text_safely(p: Path) -> list[str]:
    try:
        return p.read_text(encoding="utf-8", errors="replace").splitlines()
    except Exception as e:
        sys.stderr.write(f"[!] Could not read {p}: {e}\n")
        return []

def main():
    ap = argparse.ArgumentParser(description="Unified + HTML diff for two text files.")
    ap.add_argument("left", help="First file (baseline/original)")
    ap.add_argument("right", help="Second file (revised/target)")
    ap.add_argument("--no-html", action="store_true", help="Skip writing HTML diff")
    ap.add_argument("--html-out", default="diff.html", help="HTML output filename (default: diff.html)")
    ap.add_argument("--open", action="store_true", help="Open the HTML diff after creating it")
    args = ap.parse_args()

    left = Path(args.left)
    right = Path(args.right)

    if not left.exists() or not right.exists():
        sys.stderr.write("[!] One or both paths do not exist.\n")
        sys.exit(1)

    a = read_text_safely(left)
    b = read_text_safely(right)

    # Terminal unified (git-style) diff
    diff = difflib.unified_diff(
        a, b, fromfile=left.name, tofile=right.name, lineterm=""
    )
    for line in diff:
        print(line)

    if not args.no_html:
        html = difflib.HtmlDiff().make_file(a, b, left.name, right.name)
        Path(args.html_out).write_text(html, encoding="utf-8")
        print(f"\n✅ HTML diff written to {args.html_out}")
        if args.open:
            try:
                webbrowser.open_new_tab(Path(args.html_out).absolute().as_uri())
                print("🌐 Opened in your browser.")
            except Exception as e:
                print(f"[!] Could not auto-open browser: {e}")

if __name__ == "__main__":
    main()

