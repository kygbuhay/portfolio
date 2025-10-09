#!/bin/bash

# Folder Structure Mapper - Interactive Script
# Generates markdown documentation of folder structures

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}=================================${NC}"
    echo -e "${CYAN}  Folder Structure Mapper${NC}"
    echo -e "${CYAN}=================================${NC}"
    echo
}

print_menu() {
    echo -e "${BLUE}Choose an option:${NC}"
    echo "1) Use current directory ($(pwd))"
    echo "2) Browse and select a different directory"
    echo "3) Enter directory path manually"
    echo "4) Exit"
    echo
}

print_options_menu() {
    echo -e "${BLUE}Configure mapping options:${NC}"
    echo "1) Set maximum depth (current: ${depth:-unlimited})"
    echo "2) Include files: ${include_files:-yes}"
    echo "3) Include hidden files/folders: ${include_hidden:-no}"
    echo "4) File filter pattern: ${file_pattern:-none}"
    echo "5) Check for duplicate directories: ${check_duplicates:-no}"
    echo "6) Generate folder structure"
    echo "7) Back to main menu"
    echo
}

select_directory() {
    while true; do
        echo -e "${YELLOW}Current directory: $(pwd)${NC}"
        print_menu
        read -p "Enter your choice (1-4): " choice

        case $choice in
            1)
                target_dir="$(pwd)"
                echo -e "${GREEN}Using current directory: $target_dir${NC}"
                break
                ;;
            2)
                echo -e "${YELLOW}Enter directory path to browse (or 'cancel' to go back):${NC}"
                read -p "> " browse_path
                if [[ "$browse_path" == "cancel" ]]; then
                    continue
                fi
                if [[ -d "$browse_path" ]]; then
                    cd "$browse_path"
                    echo -e "${GREEN}Changed to: $(pwd)${NC}"
                    echo "Press Enter to confirm this directory, or continue browsing..."
                    read
                    target_dir="$(pwd)"
                    break
                else
                    echo -e "${RED}Directory not found: $browse_path${NC}"
                fi
                ;;
            3)
                read -p "Enter full directory path: " manual_path
                if [[ -d "$manual_path" ]]; then
                    target_dir="$manual_path"
                    echo -e "${GREEN}Using directory: $target_dir${NC}"
                    break
                else
                    echo -e "${RED}Directory not found: $manual_path${NC}"
                fi
                ;;
            4)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
        echo
    done
}

configure_options() {
    while true; do
        echo
        print_options_menu
        read -p "Enter your choice (1-6): " option

        case $option in
            1)
                echo "Enter maximum depth (number, or 'unlimited'):"
                read -p "> " new_depth
                if [[ "$new_depth" == "unlimited" ]] || [[ "$new_depth" =~ ^[0-9]+$ ]]; then
                    depth="$new_depth"
                    echo -e "${GREEN}Depth set to: $depth${NC}"
                else
                    echo -e "${RED}Invalid input. Please enter a number or 'unlimited'${NC}"
                fi
                ;;
            2)
                if [[ "$include_files" == "yes" ]]; then
                    include_files="no"
                else
                    include_files="yes"
                fi
                echo -e "${GREEN}Include files set to: $include_files${NC}"
                ;;
            3)
                if [[ "$include_hidden" == "yes" ]]; then
                    include_hidden="no"
                else
                    include_hidden="yes"
                fi
                echo -e "${GREEN}Include hidden files/folders set to: $include_hidden${NC}"
                ;;
            4)
                echo "Enter file pattern (e.g., '*.js', '*.md', or 'none' to clear):"
                read -p "> " new_pattern
                if [[ "$new_pattern" == "none" ]]; then
                    file_pattern=""
                else
                    file_pattern="$new_pattern"
                fi
                echo -e "${GREEN}File pattern set to: ${file_pattern:-none}${NC}"
                ;;
            5)
                if [[ "$check_duplicates" == "yes" ]]; then
                    check_duplicates="no"
                else
                    check_duplicates="yes"
                fi
                echo -e "${GREEN}Check for duplicate directories set to: $check_duplicates${NC}"
                ;;
            6)
                generate_structure
                return
                ;;
            7)
                return
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
    done
}

build_tree_command() {
    local cmd="tree"

    # Add directory
    cmd="$cmd \"$target_dir\""

    # Add depth option
    if [[ "$depth" != "unlimited" ]] && [[ -n "$depth" ]]; then
        cmd="$cmd -L $depth"
    fi

    # Include/exclude files
    if [[ "$include_files" == "no" ]]; then
        cmd="$cmd -d"
    fi

    # Include/exclude hidden files
    if [[ "$include_hidden" == "yes" ]]; then
        cmd="$cmd -a"
    fi

    # File pattern
    if [[ -n "$file_pattern" ]]; then
        cmd="$cmd -P \"$file_pattern\""
    fi

    # Don't follow symbolic links to avoid confusing duplicate entries
    cmd="$cmd -l"

    echo "$cmd"
}

check_for_duplicates() {
    echo -e "${YELLOW}Checking for duplicate directory structures...${NC}"

    # Find directories with the same name at different depths
    local duplicates=$(find "$target_dir" -type d -printf '%f %p\n' 2>/dev/null | sort | uniq -d -f1 | head -10)

    if [[ -n "$duplicates" ]]; then
        echo -e "${RED}⚠️  Potential duplicate directory structures detected:${NC}"
        echo "$duplicates" | while read -r line; do
            echo -e "${YELLOW}  • $line${NC}"
        done
        echo
        echo -e "${CYAN}This may cause confusing tree output where directories appear nested within themselves.${NC}"
        echo
    else
        echo -e "${GREEN}✓ No obvious duplicate directory structures detected.${NC}"
        echo
    fi
}

generate_structure() {
    echo
    echo -e "${YELLOW}Generating folder structure...${NC}"

    # Check if tree command exists
    if ! command -v tree &> /dev/null; then
        echo -e "${RED}Error: 'tree' command not found.${NC}"
        echo "Please install tree: sudo apt-get install tree (Ubuntu/Debian) or brew install tree (macOS)"
        return 1
    fi

    # Check for duplicates if requested
    if [[ "$check_duplicates" == "yes" ]]; then
        check_for_duplicates
    fi

    # Generate filename
    local dir_name=$(basename "$target_dir")
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="${dir_name}_structure_${timestamp}.md"

    # Build tree command
    local tree_cmd=$(build_tree_command)

    # Create markdown content
    cat > "$output_file" << EOF
# Folder Structure: $dir_name

**Generated on:** $(date)
**Directory:** $target_dir
**Depth:** ${depth:-unlimited}
**Include files:** $include_files
**Include hidden:** $include_hidden
**File pattern:** ${file_pattern:-none}

## Directory Tree

\`\`\`
EOF

    # Execute tree command and append to file
    eval "$tree_cmd" >> "$output_file" 2>/dev/null || {
        echo "Error: Failed to generate tree structure" >> "$output_file"
        echo -e "${RED}Error generating tree structure${NC}"
        return 1
    }

    # Close code block
    echo '```' >> "$output_file"

    # Add summary
    local total_items=$(eval "$tree_cmd" 2>/dev/null | tail -1 | grep -o '[0-9]\+' | head -1 || echo "unknown")
    cat >> "$output_file" << EOF

## Summary

- **Total items scanned:** $total_items
- **Generated by:** Folder Structure Mapper
- **Command used:** \`$tree_cmd\`

EOF

    echo -e "${GREEN}✓ Structure saved to: $output_file${NC}"
    echo
    read -p "Press Enter to continue..."
}

main() {
    print_header

    # Default settings
    include_files="yes"
    include_hidden="no"
    depth="unlimited"
    file_pattern=""
    check_duplicates="no"

    # Select directory
    select_directory

    # Configure options and generate
    configure_options

    echo
    echo -e "${GREEN}Thank you for using Folder Structure Mapper!${NC}"
}

# Run main function
main