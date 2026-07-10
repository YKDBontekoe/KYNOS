#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ ! "$VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  echo "A stable semantic version is required (received: ${VERSION:-<empty>})." >&2
  exit 1
fi

python3 - "$VERSION" <<'PY'
import pathlib
import re
import sys

version = sys.argv[1]
major, minor, patch = (int(part) for part in version.split('.'))
build = major * 100_000_000 + minor * 100_000 + patch * 1_000
path = pathlib.Path('pubspec.yaml')
contents = path.read_text()
updated, replacements = re.subn(
    r'^version:\s*\S+',
    f'version: {version}+{build}',
    contents,
    count=1,
    flags=re.MULTILINE,
)
if replacements != 1:
    raise SystemExit('pubspec.yaml must contain exactly one version line')
path.write_text(updated)
print(f'Updated pubspec.yaml to {version}+{build}')
PY
