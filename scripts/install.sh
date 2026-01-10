#!/bin/bash
# Install notifykit locally
# Usage: ./scripts/install.sh [--release]
#
# This script:
# 1. Builds the app bundle
# 2. Copies it to ~/Applications
# 3. Creates a symlink in /usr/local/bin

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PROFILE="debug"
if [ "$1" = "--release" ]; then
    PROFILE="release"
fi

# Build the bundle
"$SCRIPT_DIR/bundle.sh" "$PROFILE"

APP_NAME="NotifyKit.app"
SOURCE_APP="$PROJECT_DIR/target/$PROFILE/$APP_NAME"
INSTALL_DIR="$HOME/Applications"
DEST_APP="$INSTALL_DIR/$APP_NAME"
BIN_DIR="/usr/local/bin"
BIN_LINK="$BIN_DIR/notifykit"

echo ""
echo "Installing NotifyKit..."

# Create ~/Applications if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Remove old installation if present
if [ -d "$DEST_APP" ]; then
    echo "Removing old installation..."
    rm -rf "$DEST_APP"
fi

# Copy new app bundle
echo "Copying $APP_NAME to $INSTALL_DIR..."
cp -R "$SOURCE_APP" "$DEST_APP"

# Create symlink (may need sudo)
echo "Creating symlink at $BIN_LINK..."
if [ -w "$BIN_DIR" ]; then
    ln -sf "$DEST_APP/Contents/MacOS/notifykit" "$BIN_LINK"
else
    echo "Need sudo to create symlink in $BIN_DIR..."
    sudo mkdir -p "$BIN_DIR"
    sudo ln -sf "$DEST_APP/Contents/MacOS/notifykit" "$BIN_LINK"
fi

echo ""
echo "Installation complete!"
echo ""
echo "You can now use: notifykit send -t 'Title' -b 'Body' -s default"
echo ""
echo "Note: First run may require enabling notifications in:"
echo "  System Settings → Notifications → NotifyKit"
