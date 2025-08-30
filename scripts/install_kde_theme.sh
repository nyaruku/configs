#!/bin/bash

# ---------------------------
# KDE Plasma Theme Installer
# ---------------------------

# Function to display usage
usage() {
    echo "Usage: $0 <theme-tar.gz-url|theme-tar.gz-file>"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

INPUT="$1"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit 1

# Determine if input is a URL or a local file
if [[ "$INPUT" =~ ^https?:// ]]; then
    echo "Downloading theme from $INPUT..."
    curl -LO "$INPUT" || { echo "Download failed!"; exit 1; }
    TAR_FILE=$(basename "$INPUT")
elif [ -f "$INPUT" ]; then
    echo "Using local file $INPUT..."
    TAR_FILE=$(basename "$INPUT")
    cp "$INPUT" "$TMP_DIR/" || { echo "Failed to copy file!"; exit 1; }
else
    echo "Invalid input. Must be a URL or an existing .tar.gz file."
    exit 1
fi

# Extract the tar.gz
echo "Extracting $TAR_FILE..."
tar -xzf "$TAR_FILE" || { echo "Extraction failed!"; exit 1; }

# Find the extracted folder
THEME_FOLDER=$(find . -maxdepth 1 -type d ! -name '.' | head -n 1)
if [ -z "$THEME_FOLDER" ]; then
    echo "Could not find theme folder after extraction!"
    exit 1
fi

# Destination directory for Plasma themes
DEST_DIR="$HOME/.local/share/plasma/desktoptheme"
mkdir -p "$DEST_DIR"

# Move the theme
echo "Installing theme..."
mv "$THEME_FOLDER" "$DEST_DIR/" || { echo "Failed to install theme!"; exit 1; }

# Cleanup
cd ~
rm -rf "$TMP_DIR"

echo "Theme installed successfully! Open System Settings → Appearance → Global Theme → Installed to apply it."

