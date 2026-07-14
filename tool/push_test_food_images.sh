#!/usr/bin/env bash
# Push NutriLens test food photos into a running Android emulator gallery.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/images/test_food"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools or open Android Studio."
  exit 1
fi

DEVICE_COUNT="$(adb devices | awk 'NR>1 && $2=="device" {print $1}' | wc -l | tr -d ' ')"
if [[ "$DEVICE_COUNT" == "0" ]]; then
  echo "No Android emulator/device connected. Start an emulator first."
  exit 1
fi

for image in "$SRC"/test_food_*.png; do
  name="$(basename "$image")"
  echo "Pushing $name ..."
  adb push "$image" "/sdcard/Pictures/$name" >/dev/null
  adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Pictures/$name" >/dev/null || true
done

echo "Done. Open Photos/Gallery on the emulator to find salad, hamburger, and soup test images."
