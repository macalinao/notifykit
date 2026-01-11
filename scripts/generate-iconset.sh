#!/usr/bin/env bash
set -euo pipefail

# Generate macOS iconset from SVG
# Requires: ImageMagick (brew install imagemagick)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RESOURCES_DIR="$PROJECT_ROOT/resources"

SVG_FILE="$RESOURCES_DIR/icon.svg"
ICONSET_DIR="$RESOURCES_DIR/NotifyKit.iconset"
ICNS_FILE="$RESOURCES_DIR/NotifyKit.icns"

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick not found."
    echo "Install with: brew install imagemagick"
    exit 1
fi

# Check SVG exists
if [[ ! -f "$SVG_FILE" ]]; then
    echo "Error: SVG file not found at $SVG_FILE"
    exit 1
fi

echo "Generating iconset from $SVG_FILE..."

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# macOS iconset sizes: name -> pixel size
declare -A SIZES=(
    ["icon_16x16.png"]=16
    ["icon_16x16@2x.png"]=32
    ["icon_32x32.png"]=32
    ["icon_32x32@2x.png"]=64
    ["icon_128x128.png"]=128
    ["icon_128x128@2x.png"]=256
    ["icon_256x256.png"]=256
    ["icon_256x256@2x.png"]=512
    ["icon_512x512.png"]=512
    ["icon_512x512@2x.png"]=1024
)

# Generate each size
for name in "${!SIZES[@]}"; do
    size=${SIZES[$name]}
    output="$ICONSET_DIR/$name"
    echo "  Generating $name (${size}x${size})..."
    magick -background none -density 1024 "$SVG_FILE" -resize "${size}x${size}" "$output"
done

echo "Creating .icns file..."
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

echo "Done!"
echo "  Iconset: $ICONSET_DIR"
echo "  ICNS:    $ICNS_FILE"
