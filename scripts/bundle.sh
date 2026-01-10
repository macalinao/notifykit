#!/bin/bash
# Creates a macOS .app bundle for notifykit
# Usage: ./scripts/bundle.sh [debug|release]

set -e

PROFILE="${1:-debug}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ "$PROFILE" = "release" ]; then
    BINARY_PATH="$PROJECT_DIR/target/release/notifykit"
    cargo build --release
else
    BINARY_PATH="$PROJECT_DIR/target/debug/notifykit"
    cargo build
fi

APP_NAME="NotifyKit.app"
APP_DIR="$PROJECT_DIR/target/$PROFILE/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Create .app structure
echo "Creating $APP_NAME bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BINARY_PATH" "$MACOS_DIR/notifykit"

# Copy Info.plist
cp "$PROJECT_DIR/resources/Info.plist" "$CONTENTS_DIR/Info.plist"

# Copy icon
cp "$PROJECT_DIR/resources/NotifyKit.icns" "$RESOURCES_DIR/NotifyKit.icns"

# Sign the app bundle (ad-hoc)
echo "Signing bundle..."
codesign --sign - --force --deep "$APP_DIR"

echo "Bundle created at: $APP_DIR"
echo ""
echo "To use from CLI:"
echo "  $APP_DIR/Contents/MacOS/notifykit send -t 'Test' -b 'Hello'"
echo ""
echo "Or create a symlink:"
echo "  ln -sf '$APP_DIR/Contents/MacOS/notifykit' /usr/local/bin/notifykit"
