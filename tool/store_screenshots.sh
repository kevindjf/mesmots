#!/usr/bin/env bash
# Regenerates the Play Store visuals (docs/play/screenshots/ and
# docs/play/feature-graphic.png) from the current app.
#
#   tool/store_screenshots.sh
#
# 1. test/store/store_screenshots_test.dart renders the screens with
#    realistic lists into build/store_screenshots/raw/;
# 2. tool/store_screenshots.py frames them (needs Pillow: pip install pillow).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
FLUTTER_ROOT="$(cd "$(dirname "$(readlink -f "$(command -v flutter)")")/.." && pwd)"
rm -rf build/store_screenshots/raw
flutter test test/store/store_screenshots_test.dart \
  --dart-define=STORE_SCREENSHOTS=true \
  --dart-define=FLUTTER_ROOT="$FLUTTER_ROOT"
python3 tool/store_screenshots.py
