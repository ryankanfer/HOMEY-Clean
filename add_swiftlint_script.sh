#!/bin/bash

# Script to add SwiftLint Run Script Build Phase to Xcode project
echo "Adding SwiftLint Run Script Build Phase to HOMEY Clean target..."

# The SwiftLint script content
SWIFTLINT_SCRIPT='if [[ "$(uname -m)" == arm64 ]]; then export PATH="/opt/homebrew/bin:$PATH"; fi
if command -v swiftlint >/dev/null 2>&1; then
    swiftlint --fix
    swiftlint
else
    echo "warning: swiftlint not found"
fi'

echo "SwiftLint script content:"
echo "$SWIFTLINT_SCRIPT"
echo ""
echo "Please manually add this as a Run Script Build Phase in Xcode:"
echo "1. Open HOMEY Clean.xcodeproj in Xcode"
echo "2. Select the HOMEY Clean target"
echo "3. Go to Build Phases tab"
echo "4. Click + and select 'New Run Script Phase'"
echo "5. Move it after 'Compile Sources'"
echo "6. Paste the script above"
echo "7. Uncheck 'Based on dependency analysis'"
echo "8. In Build Settings, set ENABLE_USER_SCRIPT_SANDBOXING = NO"
