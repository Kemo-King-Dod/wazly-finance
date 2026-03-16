#!/bin/bash
# Wazly — Flutter SDK codesign patch for macOS Sequoia
# Fixes: "resource fork, Finder information, or similar detritus not allowed"
# Run this after every `flutter upgrade`

set -e

FLUTTER_SDK=$(dirname "$(dirname "$(which flutter)")")
echo "Flutter SDK: $FLUTTER_SDK"

IOS_DART="$FLUTTER_SDK/packages/flutter_tools/lib/src/build_system/targets/ios.dart"
NATIVE_DART="$FLUTTER_SDK/packages/flutter_tools/lib/src/isolated/native_assets/macos/native_assets_host.dart"

patch_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "⚠️  File not found: $file"
    return 1
  fi

  if grep -q "strip-disallowed-xattrs" "$file" 2>/dev/null; then
    echo "✅ Already patched: $(basename "$file")"
    return 0
  fi

  sed -i '' "s/'--force',/'--force',\n    '--strip-disallowed-xattrs',/" "$file"

  if grep -q "strip-disallowed-xattrs" "$file" 2>/dev/null; then
    echo "✅ Patched: $(basename "$file")"
  else
    echo "❌ Patch failed: $(basename "$file")"
    return 1
  fi
}

echo ""
echo "Patching Flutter codesign commands..."
echo "────────────────────────────────────"
patch_file "$IOS_DART"
patch_file "$NATIVE_DART"

echo ""
echo "Clearing Flutter tools cache..."
rm -f "$FLUTTER_SDK/bin/cache/flutter_tools.stamp"
rm -f "$FLUTTER_SDK/bin/cache/flutter_tools.snapshot"
echo "✅ Cache cleared"

echo ""
echo "Done. Now run:"
echo "  flutter clean"
echo "  rm -rf ios/Pods ios/Podfile.lock"
echo "  flutter pub get"
echo "  cd ios && pod install && cd .."
echo "  flutter build ios --debug --simulator"
