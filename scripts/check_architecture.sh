#!/usr/bin/env bash
# Clean Architecture layer import checks.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

status=0

fail() {
  echo "ERROR: $1"
  status=1
}

if ! command -v rg >/dev/null 2>&1; then
  fail 'ripgrep (rg) is required but not installed.'
  exit "$status"
fi

if rg 'package:kynos/infrastructure/' lib/features/ --glob '!**/*_test.dart' -q; then
  fail 'features/ must not import infrastructure/ — use shared/providers/.'
  rg 'package:kynos/infrastructure/' lib/features/ --glob '!**/*_test.dart' || true
fi

if rg 'package:(flutter|flutter_riverpod|riverpod)' lib/domain/ -q; then
  fail 'domain/ must not import Flutter or Riverpod.'
  rg 'package:(flutter|flutter_riverpod|riverpod)' lib/domain/ || true
fi

# Cross-feature provider imports: features/X importing features/Y/providers/
if rg "package:kynos/features/[^/]+/providers/" lib/features/ --glob '!**/*_test.dart' -q; then
  # Allow same-feature imports; flag imports where feature folder differs
  while IFS= read -r match; do
    file="${match%%:*}"
    import_line="${match#*:}"
    feature_dir="$(echo "$file" | sed -n 's#lib/features/\([^/]*\)/.*#\1#p')"
    imported_feature="$(echo "$import_line" | sed -n "s/.*package:kynos\\/features\\/\\([^/]*\\)\\/providers.*/\\1/p")"
    if [[ -n "$feature_dir" && -n "$imported_feature" && "$feature_dir" != "$imported_feature" ]]; then
      fail "Cross-feature provider import: $file imports $imported_feature/providers/"
      echo "$match"
      status=1
    fi
  done < <(rg 'package:kynos/features/[^/]+/providers/' lib/features/ --glob '!**/*_test.dart' || true)
fi

exit "$status"
