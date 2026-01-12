#!/bin/bash
set -e

# Verify that the NotifyKit app bundle contains all required resources
# Usage: ./scripts/verify-bundle-resources.sh [bundle_path]
# Default bundle path: target/release/bundle/osx/NotifyKit.app

BUNDLE_PATH="${1:-target/release/bundle/osx/NotifyKit.app}"

echo "Verifying bundle: $BUNDLE_PATH"
echo "================================"

# Check bundle exists
if [ ! -d "$BUNDLE_PATH" ]; then
    echo "ERROR: Bundle not found at $BUNDLE_PATH"
    exit 1
fi

# Check icon exists
ICON_PATH="$BUNDLE_PATH/Contents/Resources/NotifyKit.icns"
if [ ! -f "$ICON_PATH" ]; then
    echo "ERROR: Icon not found at $ICON_PATH"
    echo ""
    echo "Contents/Resources/ contains:"
    ls -la "$BUNDLE_PATH/Contents/Resources/" 2>/dev/null || echo "  (directory does not exist)"
    exit 1
fi
echo "✓ Icon found: $ICON_PATH"

# Check Info.plist exists
PLIST_PATH="$BUNDLE_PATH/Contents/Info.plist"
if [ ! -f "$PLIST_PATH" ]; then
    echo "ERROR: Info.plist not found at $PLIST_PATH"
    exit 1
fi

# Check Info.plist has icon reference
if ! grep -q "CFBundleIconFile" "$PLIST_PATH"; then
    echo "ERROR: CFBundleIconFile not found in Info.plist"
    echo ""
    echo "Info.plist contents:"
    cat "$PLIST_PATH"
    exit 1
fi
echo "✓ CFBundleIconFile found in Info.plist"

# Check Info.plist has alert style
if ! grep -q "NSUserNotificationAlertStyle" "$PLIST_PATH"; then
    echo "ERROR: NSUserNotificationAlertStyle not found in Info.plist"
    echo ""
    echo "Info.plist contents:"
    cat "$PLIST_PATH"
    exit 1
fi
echo "✓ NSUserNotificationAlertStyle found in Info.plist"

echo ""
echo "Bundle verification passed!"
