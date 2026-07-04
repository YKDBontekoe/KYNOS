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

ios_certificate="${IOS_SIDELOAD_CERTIFICATE_P12_BASE64:-${IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64:-}}"
if [[ -n "${ios_certificate}" ]]; then
  echo "Building iOS sideload IPA (development export)..."
  flutter build ipa \
    --release \
    --export-method development \
    --export-options-plist=ios/ExportOptions.plist

  ipa_path="$(find build/ios/ipa -maxdepth 1 -name '*.ipa' -print -quit)"
  if [[ -z "${ipa_path}" ]]; then
    echo "IPA build completed but no .ipa file was found."
    exit 1
  fi

  cp "${ipa_path}" dist/kynos-ios-sideload.ipa
else
  echo "Skipping iOS sideload IPA: set IOS_SIDELOAD_CERTIFICATE_P12_BASE64 to enable sideload builds."
fi

echo "Release artifacts prepared in dist/:"
ls -la dist/
