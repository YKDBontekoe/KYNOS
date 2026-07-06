#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

mkdir -p dist

cp .env.example .env
flutter pub get

echo "Building unsigned iOS IPA..."
flutter build ios --release --no-codesign

app_path="${ROOT_DIR}/build/ios/iphoneos/Runner.app"
if [[ ! -d "${app_path}" ]]; then
  echo "Runner.app not found at ${app_path}"
  exit 1
fi

ipa_staging="${ROOT_DIR}/build/ios/unsigned-ipa"
rm -rf "${ipa_staging}"
mkdir -p "${ipa_staging}/Payload"
ditto "${app_path}" "${ipa_staging}/Payload/Runner.app"

(
  cd "${ipa_staging}"
  zip -qr "${ROOT_DIR}/dist/kynos-ios-unsigned.ipa" Payload
)

echo "Release artifacts prepared in dist/:"
ls -la dist/

echo "Generating SideStore source..."
bash scripts/release/generate_sidestore_source.sh
