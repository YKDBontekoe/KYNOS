#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-}"
if [[ -z "${VERSION}" ]]; then
  echo "Release version argument is required."
  exit 1
fi

if [[ ! -d dist ]] || [[ -z "$(find dist -maxdepth 1 -type f -print -quit)" ]]; then
  echo "No release artifacts found in dist/."
  exit 1
fi

# gh CLI expects the release tag (semantic-release uses tagFormat v${version}).
if [[ "${VERSION}" == v* ]]; then
  TAG="${VERSION}"
else
  TAG="v${VERSION}"
fi

export GH_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

gh release upload "${TAG}" dist/* --clobber
