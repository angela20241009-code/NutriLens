#!/usr/bin/env bash
# Add NutriLens test food photos to the booted iOS Simulator photo library.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/images/test_food"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun not found. Install Xcode command line tools."
  exit 1
fi

BOOTED="$(xcrun simctl list devices booted | awk -F '[()]' '/Booted/ {print $2; exit}')"
if [[ -z "$BOOTED" ]]; then
  echo "No booted iOS Simulator found. Start an iOS simulator first."
  exit 1
fi

for image in "$SRC"/test_food_*.png; do
  echo "Adding $(basename "$image") to simulator $BOOTED ..."
  xcrun simctl addmedia "$BOOTED" "$image"
done

echo "Done. Open Photos on the iOS Simulator to find salad, hamburger, and soup test images."
