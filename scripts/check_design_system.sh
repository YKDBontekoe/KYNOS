#!/usr/bin/env bash
# Design system regression checks.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

status=0

warn() {
  echo "WARNING: $1"
}

fail() {
  echo "ERROR: $1"
  status=1
}

if ! command -v rg >/dev/null 2>&1; then
  fail 'ripgrep (rg) is required but not installed.'
  exit "$status"
fi

if rg 'GoogleFonts\.' lib/features/ --glob '!**/*_test.dart' -q; then
  warn 'Inline GoogleFonts found in lib/features/ — prefer Theme.of(context).textTheme or KynosThemeExtension.'
  rg 'GoogleFonts\.' lib/features/ --glob '!**/*_test.dart' || true
fi

if rg 'Gap\([0-9]' lib/features/ -q; then
  fail 'Raw Gap(N) literals found — use Gap(tokens.Spacing.*).'
  rg 'Gap\([0-9]' lib/features/ || true
fi

COLOR_PATTERN='Colors\.(red|blue|white|black|green|grey|gray|orange|amber|purple|teal)'
if rg "$COLOR_PATTERN" lib/features/ --glob '!**/*_test.dart' -q; then
  fail 'Raw Colors.* found in features — prefer AppTheme or context.kynosTheme.'
  rg "$COLOR_PATTERN" lib/features/ --glob '!**/*_test.dart' || true
fi

exit "$status"
