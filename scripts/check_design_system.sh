#!/usr/bin/env bash
# Design system regression checks — warnings until migration is complete.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

status=0

warn() {
  echo "WARNING: $1"
  status=1
}

if rg 'GoogleFonts\.' lib/features/ --glob '!**/*_test.dart' -q; then
  warn 'Inline GoogleFonts found in lib/features/ — prefer Theme.of(context).textTheme or KynosThemeExtension.'
  rg 'GoogleFonts\.' lib/features/ --glob '!**/*_test.dart' || true
fi

if rg 'Gap\([0-9]' lib/features/ -q; then
  warn 'Raw Gap(N) literals found — use Gap(tokens.Spacing.*).'
  rg 'Gap\([0-9]' lib/features/ || true
fi

if rg 'Colors\.(red|blue|white|black)' lib/features/ --glob '!**/*_test.dart' -q; then
  warn 'Raw Colors.* found in features — prefer AppTheme or context.kynosTheme.'
  rg 'Colors\.(red|blue|white|black)' lib/features/ --glob '!**/*_test.dart' || true
fi

exit $status
