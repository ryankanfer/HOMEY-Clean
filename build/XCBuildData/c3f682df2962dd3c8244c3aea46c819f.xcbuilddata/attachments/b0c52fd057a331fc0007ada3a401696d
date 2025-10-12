#!/bin/sh
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --quiet
else
  echo "warning: SwiftLint not installed; skipping lint."
fi

