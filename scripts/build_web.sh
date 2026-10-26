#!/usr/bin/env bash
# Builds the Flutter web app on hosts that only provide Node (e.g. Sevalla static sites).
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter-sdk}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

export FLUTTER_SUPPRESS_ANALYTICS=true
flutter config --no-analytics >/dev/null 2>&1 || true
flutter pub get
flutter build web --release
