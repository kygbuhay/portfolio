#!/bin/bash
# Jupyter Notebook Tab Manager
# Launches multiple notebooks as tabs in a single terminal window
# Auto-closes terminal when all notebook servers stop

set -e

# Auto-detect script location (works from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find portfolio root by looking for scripts directory
find_portfolio_root() {
    local current_dir="$PWD"

    # If we're already in portfolio/scripts, go up one level
    if [[ "$current_dir" == */portfolio/scripts ]]; then
        echo "$(dirname "$current_dir")"
        return
    fi

    # Look for portfolio directory in common locations
    local search_paths=(
        "$HOME/Documents/portfolio"
        "$HOME/portfolio"
        "$current_dir/portfolio"
        "$(find "$HOME" -name "portfolio" -type d -path "*/Documents/*" 2>/dev/null | head -1)"
    )

    for path in "${search_paths[@]}"; do
        if [[ -d "$path/scripts" && -f "$path/scripts/jn" ]]; then
            echo "$path"
            return
        fi
    done

    echo "Error: Could not find portfolio directory" >&2
    exit 1
}

PORTFOLIO_ROOT="$(find_portfolio_root)"
CASE_STUDIES_DIR="$PORTFOLIO_ROOT/coursework/google-advanced-data-analytics"

# Cache file for remembering last selected case study
CACHE_FILE="$PORTFOLIO_ROOT/.claude/jn_cache"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Helper function to select case study
select_case_study() {
    # Find all case studies using a more reliable method
    local case_studies=()

    if [[ -d "$CASE_STUDIES_DIR" ]]; then
        for dir in "$CASE_STUDIES_DIR"/*; do
            if [[ -d "$dir" && -d "$dir/notebooks" ]]; then
                case_studies+=("$dir")
            fi
        done
    fi

    if [[ ${#case_studies[@]} -eq 0 ]]; then
        echo "No case studies found in $CASE_STUDIES_DIR" >&2
        echo "Looking for directories with 'notebooks' subdirectories" >&2
        exit 1
    fi

    # If only one case study, use it
    if [[ ${#case_studies[@]} -eq 1 ]]; then
        echo "${case_studies[0]}"
        return
    fi

    # Multiple case studies - let user choose
    echo -e "${PURPLE}📚 Select Case Study:${NC}" >&2
    echo >&2
    for i in "${!case_studies[@]}"; do
        local name=$(basename "${case_studies[$i]}")
        printf "  %2d) %s\n" $((i+1)) "${name//_/ }" >&2
    done
    echo >&2

    while true; do
        read -rp "Choose case study (1-${#case_studies[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#case_studies[@]} ]]; then
            local selected="${case_studies[$((choice-1))]}"
            # Cache the selection
            mkdir -p "$(dirname "$CACHE_FILE")"
            echo "$selected" > "$CACHE_FILE"
            echo "$selected"
            return
        fi
        echo "Please enter a number between 1 and ${#case_studies[@]}" >&2
    done
}

# Get the case study to work with
PROJECT_ROOT="$(select_case_study)"
NOTEBOOKS_DIR="$PROJECT_ROOT/notebooks"

if [[ ! -d "$NOTEBOOKS_DIR" ]]; then
    echo "No notebooks directory found in: $PROJECT_ROOT"
    exit 1
fi

# Get list of notebooks (excluding checkpoint files)
mapfile -t NOTEBOOKS < <(find "$NOTEBOOKS_DIR" -name "*.ipynb" -type f ! -path "*/.ipynb_checkpoints/*" | sort)

if [ ${#NOTEBOOKS[@]} -eq 0 ]; then
    echo "No notebooks found in $NOTEBOOKS_DIR"
    exit 1
fi

echo -e "${BLUE}=== Jupyter Notebook Tab Manager ===${NC}"
echo -e "${GREEN}Case Study: ${NC}$(basename "$PROJECT_ROOT" | sed 's/_/ /g')"
echo
echo "Available notebooks:"
for i in "${!NOTEBOOKS[@]}"; do
    NB_NAME=$(basename "${NOTEBOOKS[$i]}")
    printf "  %2d) %s\n" $((i+1)) "$NB_NAME"
done
echo
echo -e "${YELLOW}Options:${NC}"
echo "  - Enter numbers (space-separated): 1 3 5"
echo "  - Enter 'all' to open all notebooks"
echo "  - Enter single number for one notebook"
echo
read -rp "Selection: " SELECTION

# Parse selection
if [[ "$SELECTION" == "all" ]]; then
    SELECTED=("${NOTEBOOKS[@]}")
else
    SELECTED=()
    for NUM in $SELECTION; do
        IDX=$((NUM - 1))
        if [ $IDX -ge 0 ] && [ $IDX -lt ${#NOTEBOOKS[@]} ]; then
            SELECTED+=("${NOTEBOOKS[$IDX]}")
        fi
    done
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
    echo "No valid selection."
    exit 1
fi

echo
echo -e "${GREEN}Opening ${#SELECTED[@]} notebook(s) in tabbed terminal...${NC}"

# Determine terminal emulator and launch strategy
launch_notebooks() {
    if command -v gnome-terminal &> /dev/null; then
        # GNOME Terminal (Ubuntu default)
        TABS=""
        for NB in "${SELECTED[@]}"; do
            TABS="$TABS --tab --title='$(basename "$NB")' -- bash -c 'cd \"$PROJECT_ROOT\" && jupyter notebook \"$NB\" --no-browser; exec bash'"
        done
        eval "gnome-terminal $TABS"

    elif command -v konsole &> /dev/null; then
        # KDE Konsole
        for NB in "${SELECTED[@]}"; do
            konsole --new-tab -e bash -c "cd '$PROJECT_ROOT' && jupyter notebook '$NB' --no-browser; exec bash" &
        done

    elif command -v xterm &> /dev/null; then
        # Fallback: xterm with tabs
        for NB in "${SELECTED[@]}"; do
            xterm -T "$(basename "$NB")" -e "cd '$PROJECT_ROOT' && jupyter notebook '$NB' --no-browser; bash" &
        done

    else
        echo "No supported terminal emulator found (gnome-terminal, konsole, xterm)"
        exit 1
    fi
}

launch_notebooks

echo -e "${GREEN}✅ Launched!${NC}"
echo
echo "Tips:"
echo "  - All notebooks are in tabs in a single terminal window"
echo "  - Close notebook in browser → Ctrl+C in corresponding tab to stop server"
echo "  - Close entire terminal → stops all servers"
