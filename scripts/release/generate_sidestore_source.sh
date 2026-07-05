#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

PUBSPEC_VERSION_LINE="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n 1)"
if [[ -z "${PUBSPEC_VERSION_LINE}" ]]; then
  echo "Unable to determine version from pubspec.yaml"
  exit 1
fi

APP_VERSION="${PUBSPEC_VERSION_LINE%%+*}"
RELEASE_TAG="v${APP_VERSION}"
RELEASE_DATE="$(date -u +%F)"

REPO_SLUG="${GITHUB_REPOSITORY:-}"
if [[ -z "${REPO_SLUG}" ]]; then
  REMOTE_URL="$(git config --get remote.origin.url || true)"
  if [[ "${REMOTE_URL}" =~ github\.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
    REPO_SLUG="${BASH_REMATCH[1]}"
  fi
fi

if [[ -z "${REPO_SLUG}" ]]; then
  echo "Unable to determine GitHub repository slug."
  exit 1
fi

IPA_PATH="dist/kynos-ios-unsigned.ipa"
IPA_SIZE=0
if [[ -f "${IPA_PATH}" ]]; then
  IPA_SIZE="$(stat -f%z "${IPA_PATH}")"
elif command -v gh >/dev/null 2>&1; then
  RELEASE_ASSET_SIZE="$(
    gh release view "${RELEASE_TAG}" \
      --repo "${REPO_SLUG}" \
      --json assets \
      --jq '.assets[] | select(.name == "kynos-ios-unsigned.ipa") | .size' \
      2>/dev/null || true
  )"
  if [[ -n "${RELEASE_ASSET_SIZE}" ]]; then
    IPA_SIZE="${RELEASE_ASSET_SIZE}"
  fi
fi

SOURCE_URL="https://raw.githubusercontent.com/${REPO_SLUG}/main/docs/sidestore-source.json"
ICON_URL="https://raw.githubusercontent.com/${REPO_SLUG}/main/web/icons/Icon-512.png"
IPA_URL="https://github.com/${REPO_SLUG}/releases/download/${RELEASE_TAG}/kynos-ios-unsigned.ipa"

mkdir -p docs dist

cat > docs/sidestore-source.json <<EOF
{
  "name": "KYNOS",
  "identifier": "com.kynos.source",
  "sourceURL": "${SOURCE_URL}",
  "apps": [
    {
      "name": "KYNOS",
      "bundleIdentifier": "com.kynos.kynos",
      "developerName": "Youri Bontekoe",
      "subtitle": "Privacy-first on-device running coach",
      "localizedDescription": "KYNOS is a privacy-first running coach built with on-device AI, HealthKit insights, and biomechanical analysis. No raw biometric data leaves the device.",
      "iconURL": "${ICON_URL}",
      "tintColor": "#0F766E",
      "downloadURL": "${IPA_URL}",
      "versions": [
        {
          "version": "${APP_VERSION}",
          "date": "${RELEASE_DATE}",
          "downloadURL": "${IPA_URL}",
          "size": ${IPA_SIZE},
          "minOSVersion": "16.0"
        }
      ]
    }
  ]
}
EOF

cp docs/sidestore-source.json dist/sidestore-source.json

echo "Generated docs/sidestore-source.json for ${RELEASE_TAG}"
