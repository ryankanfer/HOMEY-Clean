#!/bin/bash

# SwiftLint Build Script for HOMEY Clean
# This script should be added to Xcode Build Phases

# Add Homebrew path for Apple Silicon Macs
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Check if SwiftLint is available and run it
if command -v swiftlint >/dev/null 2>&1; then
    echo "Running SwiftLint..."
    swiftlint --fix
    swiftlint
else
    echo "warning: swiftlint not found"
fi