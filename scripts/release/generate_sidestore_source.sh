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
  if stat -f%z "${IPA_PATH}" >/dev/null 2>&1; then
    IPA_SIZE="$(stat -f%z "${IPA_PATH}")"
  else
    IPA_SIZE="$(stat -c%s "${IPA_PATH}")"
  fi
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

export APP_VERSION RELEASE_DATE IPA_URL IPA_SIZE REPO_SLUG SOURCE_URL ICON_URL
export EXISTING_SOURCE_PATH="docs/sidestore-source.json"
export OUTPUT_PATH="docs/sidestore-source.json"

python3 - <<'PY'
import json
import os
import re
import shutil
import subprocess
from pathlib import Path

app_version = os.environ["APP_VERSION"]
release_date = os.environ["RELEASE_DATE"]
ipa_url = os.environ["IPA_URL"]
ipa_size = int(os.environ.get("IPA_SIZE") or "0")
repo_slug = os.environ["REPO_SLUG"]
source_url = os.environ["SOURCE_URL"]
icon_url = os.environ["ICON_URL"]
existing_source_path = Path(os.environ["EXISTING_SOURCE_PATH"])
output_path = Path(os.environ["OUTPUT_PATH"])

versions: dict[str, dict] = {}

if existing_source_path.is_file():
    try:
        existing = json.loads(existing_source_path.read_text(encoding="utf-8"))
        for entry in existing.get("apps", [{}])[0].get("versions", []):
            version = entry.get("version")
            if version:
                versions[version] = entry
    except (json.JSONDecodeError, IndexError, TypeError):
        pass

if shutil.which("gh") is not None:
    result = subprocess.run(
        ["gh", "api", f"repos/{repo_slug}/releases", "--paginate"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0:
        for release in json.loads(result.stdout or "[]"):
            tag = release.get("tag_name", "")
            match = re.fullmatch(r"v(.+)", tag)
            if not match:
                continue
            version = match.group(1)
            ipa_asset = next(
                (
                    asset
                    for asset in release.get("assets", [])
                    if asset.get("name") == "kynos-ios-unsigned.ipa"
                ),
                None,
            )
            if ipa_asset is None:
                continue
            published_at = release.get("published_at") or ""
            versions[version] = {
                "version": version,
                "date": published_at[:10] if published_at else release_date,
                "downloadURL": ipa_asset.get("browser_download_url", ""),
                "size": ipa_asset.get("size", 0),
                "minOSVersion": "16.0",
            }

versions[app_version] = {
    "version": app_version,
    "date": release_date,
    "downloadURL": ipa_url,
    "size": ipa_size,
    "minOSVersion": "16.0",
}

def version_key(value: str) -> tuple[int, ...]:
    parts: list[int] = []
    for part in value.split("."):
        try:
            parts.append(int(part))
        except ValueError:
            parts.append(0)
    return tuple(parts)

sorted_versions = sorted(
    versions.values(),
    key=lambda entry: version_key(entry["version"]),
    reverse=True,
)

payload = {
    "name": "KYNOS",
    "identifier": "com.kynos.source",
    "sourceURL": source_url,
    "apps": [
        {
            "name": "KYNOS",
            "bundleIdentifier": "com.kynos.kynos",
            "developerName": "Youri Bontekoe",
            "subtitle": "Privacy-first on-device running coach",
            "localizedDescription": (
                "KYNOS is a privacy-first running coach built with on-device AI, "
                "HealthKit insights, and biomechanical analysis. No raw biometric "
                "data leaves the device."
            ),
            "iconURL": icon_url,
            "tintColor": "#0F766E",
            "downloadURL": ipa_url,
            "versions": sorted_versions,
        }
    ],
}

output_path.write_text(f"{json.dumps(payload, indent=2)}\n", encoding="utf-8")
PY

cp docs/sidestore-source.json dist/sidestore-source.json

echo "Generated docs/sidestore-source.json for ${RELEASE_TAG}"
