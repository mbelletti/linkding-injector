#!/usr/bin/env bash
set -euo pipefail

# Build and package the extension for Chrome (Manifest V3).
# The Firefox build (build.sh) uses the MV2 manifest.json; this script uses the
# MV3 manifest.chrome.json, staged into dist-chrome/ as manifest.json.

DIST="dist-chrome"
ZIP="linkding-injector-chrome.zip"

# Install dependencies
npm install

# Run rollup + sass build (outputs to build/)
npm run build

# Stage a clean Chrome package
rm -rf "$DIST" "$ZIP"
mkdir -p "$DIST"
cp -r build icons options styles "$DIST"/
cp manifest.chrome.json "$DIST"/manifest.json

# Zip the staged folder contents (so manifest.json is at the archive root)
( cd "$DIST" && zip -r -q "../$ZIP" . )

echo "✅ Done -> $DIST/ (load unpacked) and $ZIP"
