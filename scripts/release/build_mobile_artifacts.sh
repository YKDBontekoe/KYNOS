#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

mkdir -p dist

cp .env.example .env
flutter pub get

echo "Building Android release APK..."
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk dist/kynos-android.apk

if [[ -n "${IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64:-}" ]]; then
  echo "Building iOS release IPA..."
  flutter build ipa \
    --release \
    --export-options-plist=ios/ExportOptions.plist

  ipa_path="$(find build/ios/ipa -maxdepth 1 -name '*.ipa' -print -quit)"
  if [[ -z "${ipa_path}" ]]; then
    echo "IPA build completed but no .ipa file was found."
    exit 1
  fi

  cp "${ipa_path}" dist/kynos-ios.ipa
else
  echo "Skipping iOS IPA build: set IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64 to enable signed IPA releases."
fi

echo "Release artifacts prepared in dist/:"
ls -la dist/
