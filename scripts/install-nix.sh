#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"

echo "Building NotifyKit with Nix..."
nix build

APP_NAME="NotifyKit.app"
INSTALL_DIR="$HOME/Applications"
DEST_APP="$INSTALL_DIR/$APP_NAME"
BIN_DIR="/usr/local/bin"
BIN_LINK="$BIN_DIR/notifykit"

echo "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# Remove existing install (may have read-only files from Nix store)
if [[ -d "$DEST_APP" ]]; then
  chmod -R u+w "$DEST_APP"
  rm -rf "$DEST_APP"
fi

cp -r result/Applications/NotifyKit.app "$DEST_APP"

# Create symlink (may need sudo)
echo "Creating symlink at $BIN_LINK..."
if [[ -w "$BIN_DIR" ]]; then
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

# Verify installation
echo ""
echo "Verifying installation..."
if command -v notifykit &> /dev/null; then
    echo ""
    notifykit --version
    echo ""
    echo "Installation verified successfully!"
else
    echo "Warning: notifykit not found in PATH"
    echo "You may need to restart your terminal or add /usr/local/bin to PATH"
fi
