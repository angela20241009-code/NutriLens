#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

flutter pub get
"$ROOT/tool/fix_ios_swift_package.sh"
(
  cd ios
  pod install
)

echo "iOS project is ready for Xcode."
