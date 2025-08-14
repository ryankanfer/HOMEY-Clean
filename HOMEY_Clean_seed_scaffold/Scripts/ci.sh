#!/usr/bin/env bash
set -euo pipefail

echo "Formatting Swift..."
if command -v swiftformat >/dev/null 2>&1; then
  swiftformat .
else
  echo "swiftformat not installed; skipping."
fi

echo "Linting Swift..."
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint
else
  echo "swiftlint not installed; skipping."
fi

echo "✅ CI script finished"
