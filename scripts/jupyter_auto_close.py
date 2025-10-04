#!/usr/bin/env python3
"""
Simple Jupyter Launcher
Just launches Jupyter and runs until user stops it with Ctrl+C
"""

import sys
import os
import subprocess
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("Usage: jupyter_auto_close.py <notebook_path>")
        sys.exit(1)

    notebook_path = Path(sys.argv[1]).resolve()

    if not notebook_path.exists():
        print(f"Error: Notebook not found: {notebook_path}")
        sys.exit(1)

    print(f"🚀 Starting: {notebook_path.name}")
    print(f"📂 Directory: {notebook_path.parent}")
    print("⏳ Launching Jupyter server...")

    try:
        # Simple approach: just exec the jupyter command directly
        os.chdir(str(notebook_path.parent))

        # Use os.execvp to replace this process with jupyter
        os.execvp('jupyter', [
            'jupyter', 'notebook',
            str(notebook_path),
            '--no-browser'
        ])

    except KeyboardInterrupt:
        print("\n⚠️  Stopped by user (Ctrl+C)")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()