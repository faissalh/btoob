#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "${PROJECT_ROOT}"

FLUTTER_VERSION="3.47.8"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
elif [[ -n "${FLUTTER_ROOT:-}" && -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  FLUTTER_BIN="${FLUTTER_ROOT}/bin/flutter"
else
  FLUTTER_CACHE_DIR="${FLUTTER_CACHE_DIR:-${HOME}/.cache/flutter-${FLUTTER_VERSION}}"
  FLUTTER_SDK="${FLUTTER_CACHE_DIR}/flutter"
  FLUTTER_ARCHIVE="${FLUTTER_CACHE_DIR}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

  mkdir -p "${FLUTTER_CACHE_DIR}"
  if [[ ! -x "${FLUTTER_SDK}/bin/flutter" ]]; then
    curl --fail --location --retry 3 \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      --output "${FLUTTER_ARCHIVE}"
    tar -xJf "${FLUTTER_ARCHIVE}" -C "${FLUTTER_CACHE_DIR}"
  fi
  FLUTTER_BIN="${FLUTTER_SDK}/bin/flutter"
fi

"${FLUTTER_BIN}" pub get --enforce-lockfile
"${FLUTTER_BIN}" build web --release --no-pub

rm -rf web/dist
mkdir -p web/dist
cp -R build/web/. web/dist/
