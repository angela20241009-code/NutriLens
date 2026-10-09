#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
PACKAGE_SWIFT="$ROOT/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"

if [ ! -f "$PACKAGE_SWIFT" ]; then
  exit 0
fi

/usr/bin/python3 - "$PACKAGE_SWIFT" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

def replace(match: re.Match[str]) -> str:
    major, minor = map(int, match.group(1).split("."))
    return '.iOS("16.0")' if (major, minor) < (15, 0) else match.group(0)

updated = re.sub(r'\.iOS\("(\d+\.\d+)"\)', replace, text)
if updated != text:
    path.write_text(updated)
    print("Updated FlutterGeneratedPluginSwiftPackage minimum iOS to 16.0")
PY
