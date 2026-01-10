#!/bin/bash
# Install notifykit from GitHub releases
# Usage: curl -fsSL https://raw.githubusercontent.com/macalinao/notifykit/master/scripts/install-remote.sh | bash
#
# This script:
# 1. Detects your architecture
# 2. Downloads the latest release
# 3. Extracts to ~/Applications
# 4. Creates a symlink in /usr/local/bin

set -e

REPO="macalinao/notifykit"
INSTALL_DIR="$HOME/Applications"
BIN_DIR="/usr/local/bin"

echo "Installing NotifyKit..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    arm64|aarch64)
        TARGET="aarch64-apple-darwin"
        ;;
    x86_64)
        TARGET="x86_64-apple-darwin"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected architecture: $TARGET"

# Get latest release URL
RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"
echo "Fetching latest release..."

DOWNLOAD_URL=$(curl -fsSL "$RELEASE_URL" | grep "browser_download_url.*$TARGET" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find release for $TARGET"
    echo "Check releases at: https://github.com/$REPO/releases"
    exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"

# Create temp directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and extract
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/notifykit.tar.gz"
tar -xzf "$TMP_DIR/notifykit.tar.gz" -C "$TMP_DIR"

# Install
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/NotifyKit.app"
mv "$TMP_DIR/NotifyKit.app" "$INSTALL_DIR/"

# Create symlink (may need sudo)
if [ -w "$BIN_DIR" ]; then
    ln -sf "$INSTALL_DIR/NotifyKit.app/Contents/MacOS/notifykit" "$BIN_DIR/notifykit"
else
    echo "Need sudo to create symlink in $BIN_DIR..."
    sudo mkdir -p "$BIN_DIR"
    sudo ln -sf "$INSTALL_DIR/NotifyKit.app/Contents/MacOS/notifykit" "$BIN_DIR/notifykit"
fi

echo ""
echo "NotifyKit installed successfully!"
echo ""
echo "Usage: notifykit send -t 'Title' -b 'Body' -s default"
echo ""
echo "Note: First run may require enabling notifications in:"
echo "  System Settings → Notifications → NotifyKit"
