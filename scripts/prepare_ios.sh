#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

flutter pub get
flutter build ios --config-only --no-codesign

echo "iOS project is ready for Xcode."
