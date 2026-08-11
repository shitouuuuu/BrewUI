#!/bin/bash

set -e

echo "🔨 Building BrewUI (Release Build)..."
swift build -c release

BUILD_PATH=".build/release/BrewUI"
APP_NAME="BrewUI.app"
CONTENTS_DIR="$APP_NAME/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 Packaging $APP_NAME..."
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$BUILD_PATH" "$MACOS_DIR/BrewUI"

cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BrewUI</string>
    <key>CFBundleIdentifier</key>
    <string>com.vibecoding.brewui</string>
    <key>CFBundleName</key>
    <string>BrewUI</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
</dict>
</plist>
EOF

chmod +x "$MACOS_DIR/BrewUI"
echo "✅ Successfully built $APP_NAME in workspace!"

echo "📲 Installing $APP_NAME to /Applications..."
rm -rf "/Applications/$APP_NAME"
cp -R "$APP_NAME" "/Applications/$APP_NAME"
echo "🎉 BrewUI installed successfully to /Applications/$APP_NAME!"
echo "🚀 You can open it from Launchpad or run: open /Applications/$APP_NAME"

