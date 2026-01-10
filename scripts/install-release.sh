#!/bin/bash
# Build and install the release version of notifykit locally
# Usage: ./scripts/install-release.sh
#
# This is a convenience wrapper around install.sh --release

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Run install with release flag
"$SCRIPT_DIR/install.sh" --release

# Verify installation
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
