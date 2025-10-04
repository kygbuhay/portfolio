# Jupyter Notebook Terminal Manager Setup ✅

## Problem Solved
- ❌ Multiple terminal windows cluttering desktop
- ❌ Orphaned terminals after closing browser tabs
- ❌ Manual cleanup required

## Solution
- ✅ All notebooks in tabs within single terminal
- ✅ Auto-closes terminal when browser closes
- ✅ Quick launcher: `jn 01` or `jn 01 03 05`

---

## 🚀 Quick Setup (30 seconds)

### 1. Add to PATH
```bash
echo 'export PATH="$HOME/Documents/portfolio/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Test it
```bash
# Open single notebook
jn 01

# Open multiple in tabs
jn 01 03 05

# Interactive menu
jn
```

---

## 📖 Usage Examples

### Single Notebook (Auto-Close)
```bash
jn 01                    # Opens 01_data_dictionary_setup.ipynb
jn baseline              # Pattern matching: 04_baseline_logreg.ipynb
jn tree                  # Opens 05_tree_models.ipynb
```

**Behavior:**
- Opens notebook in browser
- Terminal stays open while you work
- Close browser tab → terminal auto-closes within 5-10 seconds
- No manual cleanup needed!

### Multiple Notebooks (Tabs)
```bash
jn 01 03 05             # Opens notebooks 1, 3, 5
jn all                  # Opens ALL notebooks
```

**Behavior:**
- Single terminal window with tabs
- Each tab = one notebook server
- Close individual tabs or entire terminal
- All servers shut down cleanly

### Interactive Menu
```bash
jn                      # No arguments = menu
```

Shows numbered list, you choose which to open.

---

## 🛠️ How It Works

### Scripts Created
1. **`jn`** - Main launcher (you run this)
2. **`jupyter_auto_close.py`** - Monitors browser connections
3. **`jupyter_tab_manager.sh`** - Manages tabbed terminal

### Auto-Close Mechanism
1. Starts Jupyter server
2. Monitors process every 5 seconds
3. Detects when browser disconnects
4. Gracefully shuts down server
5. Closes terminal automatically

### Tab Management
- Uses `gnome-terminal` (Ubuntu default)
- Each tab runs independent server
- Shared terminal window = less clutter
- Close any tab individually or all at once

---

## 🎯 Benefits

### Before
- 7 notebooks open = 7 terminal windows
- Forget to close terminals = processes keep running
- Desktop cluttered with terminal windows
- Manual cleanup: Ctrl+C each one

### After
- 7 notebooks open = 1 terminal with 7 tabs
- Close browser tab = terminal auto-closes
- Clean desktop
- Zero manual cleanup

---

## 🔧 Customization

### Change Auto-Close Delay
Edit `jupyter_auto_close.py`:
```python
check_interval=5  # Change to 10 for longer grace period
```

### Support Other Terminals
Edit `jn` and add your terminal emulator:
```bash
elif command -v konsole &> /dev/null; then
    # KDE support
```

### Change Project Path
Edit `jn`:
```bash
PROJECT_ROOT="/your/custom/path"
```

---

## 🐛 Troubleshooting

### "jn: command not found"
```bash
# Check PATH
echo $PATH | grep portfolio/scripts

# If missing, add to ~/.bashrc
export PATH="$HOME/Documents/portfolio/scripts:$PATH"
source ~/.bashrc
```

### Terminal doesn't auto-close
- Requires `pgrep` (usually pre-installed)
- Check: `which pgrep`
- Install: `sudo apt install procps` (Ubuntu/Debian)

### "No notebook found matching: X"
```bash
# Check what exists
ls notebooks/

# Use exact prefix
jn 01_data_dictionary  # Full name works
jn 01                   # Prefix matching works
```

### Tabs not working
- Requires `gnome-terminal` (Ubuntu default)
- Check: `which gnome-terminal`
- Alternative: Edit `jn` to use your terminal

---

## 📋 Files Created

```
portfolio/scripts/
├── jn                          # Main launcher ⭐
├── jupyter_auto_close.py       # Auto-close monitor
├── jupyter_tab_manager.sh      # Tab manager
└── README.md                   # Full docs
```

---

## ✅ Recommendations

### For Daily Use
```bash
# Add to ~/.bashrc for convenience
export PATH="$HOME/Documents/portfolio/scripts:$PATH"
alias nb='jn'  # Even shorter!
```

Then:
```bash
nb 01           # Super quick!
nb 01 03 05     # Multiple tabs
nb              # Interactive
```

### For Team Sharing
If you share this setup with others, they just need:
1. Copy `scripts/` folder
2. Add to PATH
3. Done!

---

**Status:** ✅ Ready to use
**Created:** 2025-10-04
**Location:** `~/Documents/portfolio/scripts/`
