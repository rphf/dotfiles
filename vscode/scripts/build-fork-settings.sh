#!/bin/bash

# Build script to merge fork-specific settings with base VS Code settings
# Usage: ./build-fork-settings.sh <fork-name>
# Example: ./build-fork-settings.sh kiro

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VSCODE_DIR="$DOTFILES_DIR/vscode"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <fork-name>"
    echo "Example: $0 kiro"
    exit 1
fi

FORK_NAME="$1"
FORK_DIR="$DOTFILES_DIR/$FORK_NAME"
BASE_SETTINGS="$VSCODE_DIR/settings.json"
BASE_KEYBINDINGS="$VSCODE_DIR/keybindings.json"
BASE_EXTENSIONS="$VSCODE_DIR/extensions.txt"

# Check if fork directory exists
if [ ! -d "$FORK_DIR" ]; then
    echo "Error: Fork directory $FORK_DIR does not exist"
    exit 1
fi

# Check if base settings exist
if [ ! -f "$BASE_SETTINGS" ]; then
    echo "Error: Base settings file $BASE_SETTINGS does not exist"
    exit 1
fi

echo "Building settings for $FORK_NAME..."

# Function to merge JSON settings
merge_json_settings() {
    local fork_settings="$1"
    local base_settings="$2"
    local output_file="$3"

    # Start with opening brace
    echo "{" > "$output_file"

    local has_fork_content=false

    # Add fork-specific settings if they exist
    if [ -f "$fork_settings" ] && [ -s "$fork_settings" ]; then
        # Check if fork settings has actual JSON content (not just empty object)
        local fork_content=$(sed -n '2,${/^}$/d;p;}' "$fork_settings" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*//.*$')
        if [ -n "$fork_content" ]; then
            echo "  // $FORK_NAME specific settings" >> "$output_file"
            sed -n '2,${/^}$/d;p;}' "$fork_settings" | sed 's/^/  /' >> "$output_file"
            has_fork_content=true
        fi
    fi

    # Add base settings
    if [ -f "$base_settings" ] && [ -s "$base_settings" ]; then
        # Add comma if we had fork content
        if [ "$has_fork_content" = true ]; then
            # Remove trailing whitespace and add comma to last non-empty line
            sed -i '' '/^[[:space:]]*$/d' "$output_file"
            sed -i '' '$s/$/,/' "$output_file"
            echo "" >> "$output_file"
        fi

        echo "  // ========================================" >> "$output_file"
        echo "  // Base VS Code settings" >> "$output_file"
        echo "  // ========================================" >> "$output_file"

        # Extract content between braces from base settings, add proper indentation
        sed -n '2,${/^}$/d;p;}' "$base_settings" | sed 's/^/  /' >> "$output_file"
    fi

    # End with closing brace
    echo "}" >> "$output_file"
}

# Function to merge extensions
merge_extensions() {
    local fork_extensions="$1"
    local base_extensions="$2"
    local output_file="$3"

    # Start with fork-specific extensions if they exist
    if [ -f "$fork_extensions" ] && [ -s "$fork_extensions" ]; then
        echo "# $FORK_NAME specific extensions" > "$output_file"
        cat "$fork_extensions" >> "$output_file"
        echo "" >> "$output_file"
    else
        # Create empty output file
        > "$output_file"
    fi

    # Add base extensions
    if [ -f "$base_extensions" ] && [ -s "$base_extensions" ]; then
        cat "$base_extensions" >> "$output_file"
    fi
}

# Merge settings.json
merge_json_settings "$FORK_DIR/settings.fork.json" "$BASE_SETTINGS" "$FORK_DIR/settings.json"

# Merge keybindings.json if base exists
if [ -f "$BASE_KEYBINDINGS" ]; then
    merge_json_settings "$FORK_DIR/keybindings.fork.json" "$BASE_KEYBINDINGS" "$FORK_DIR/keybindings.json"
fi

# Merge extensions.txt
if [ -f "$BASE_EXTENSIONS" ]; then
    merge_extensions "$FORK_DIR/extensions.fork.txt" "$BASE_EXTENSIONS" "$FORK_DIR/extensions.txt"
fi

echo "Successfully built settings for $FORK_NAME"
echo "Files updated in $FORK_DIR:"
echo "  - settings.json (merged from settings.fork.json + base)"
[ -f "$FORK_DIR/keybindings.json" ] && echo "  - keybindings.json (merged from keybindings.fork.json + base)"
echo "  - extensions.txt (merged)"
