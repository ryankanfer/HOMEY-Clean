# HOMEY

## Build, Lint, CI

### Setup
```bash
# Install dependencies
brew bundle

# Configure Ruby bundler
bundle config set path vendor/bundle
bundle install
```

### Development Commands
```bash
# Format and lint code
make format && make lint

# Run tests
bundle exec fastlane test

# Build development version
bundle exec fastlane build

# Deploy to TestFlight
bundle exec fastlane beta
```

### Tools Included
- **SwiftLint**: Code linting and style enforcement
- **SwiftFormat**: Automatic code formatting
- **Fastlane**: iOS build automation and deployment
- **Xcodes**: Xcode version management
- **GitHub Actions**: Continuous integration and deployment

### Configuration Files
- `Brewfile`: Homebrew dependencies
- `.swiftlint.yml`: SwiftLint configuration
- `.swiftformat`: SwiftFormat configuration
- `ios/Config/Debug.xcconfig`: Debug build configuration
- `ios/Config/Release.xcconfig`: Release build configuration
- `fastlane/Appfile`: App Store Connect configuration
- `fastlane/Fastfile`: Build and deployment lanes
- `Makefile`: Development shortcuts
