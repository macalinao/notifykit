#!/bin/bash
# Updates the Homebrew cask with new version and checksums
# Usage: ./scripts/update-homebrew.sh <version>
#
# This script:
# 1. Downloads release tarballs
# 2. Calculates SHA256 checksums
# 3. Updates the cask formula
# 4. Optionally commits and pushes to homebrew-tap

set -e

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.0"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CASK_FILE="$PROJECT_DIR/homebrew/Casks/notifykit.rb"
REPO="macalinao/notifykit"

echo "Updating Homebrew cask for version $VERSION..."

# Create temp directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and checksum arm64
ARM64_URL="https://github.com/$REPO/releases/download/v$VERSION/NotifyKit-aarch64-apple-darwin.tar.gz"
echo "Downloading arm64 release..."
curl -fsSL "$ARM64_URL" -o "$TMP_DIR/arm64.tar.gz"
ARM64_SHA=$(shasum -a 256 "$TMP_DIR/arm64.tar.gz" | cut -d' ' -f1)
echo "arm64 SHA256: $ARM64_SHA"

# Download and checksum x86_64
X86_64_URL="https://github.com/$REPO/releases/download/v$VERSION/NotifyKit-x86_64-apple-darwin.tar.gz"
echo "Downloading x86_64 release..."
curl -fsSL "$X86_64_URL" -o "$TMP_DIR/x86_64.tar.gz"
X86_64_SHA=$(shasum -a 256 "$TMP_DIR/x86_64.tar.gz" | cut -d' ' -f1)
echo "x86_64 SHA256: $X86_64_SHA"

# Update cask file
echo "Updating cask formula..."
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$CASK_FILE"
sed -i '' "s/sha256 \".*\" # arm64/sha256 \"$ARM64_SHA\" # arm64/" "$CASK_FILE"
sed -i '' "s/sha256 \".*\" # x86_64/sha256 \"$X86_64_SHA\" # x86_64/" "$CASK_FILE"

# Also handle placeholder format
sed -i '' "s/PLACEHOLDER_ARM64_SHA256/$ARM64_SHA/" "$CASK_FILE"
sed -i '' "s/PLACEHOLDER_X86_64_SHA256/$X86_64_SHA/" "$CASK_FILE"

echo ""
echo "Cask updated successfully!"
echo ""
echo "Next steps:"
echo "1. Copy homebrew/Casks/notifykit.rb to your homebrew-tap repo"
echo "2. Commit and push to homebrew-tap"
echo ""
echo "Or if homebrew-tap is a sibling directory:"
echo "  cp $CASK_FILE ../homebrew-tap/Casks/"
