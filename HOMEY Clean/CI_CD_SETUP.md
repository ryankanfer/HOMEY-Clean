# HOMEY Clean - CI/CD Setup Guide

## Current Status ✅

The following components have been successfully configured:

- ✅ Fastlane setup with `test`, `build`, and `beta` lanes
- ✅ GitHub Actions workflows for iOS CI and TestFlight deployment
- ✅ Xcode project configuration with proper code signing
- ✅ Supabase integration with environment-specific configuration
- ✅ SwiftLint integration resolved

## Next Steps - TestFlight Configuration

### Step 4: Configure TestFlight for Continuous Integration

#### 4.1 Generate App Store Connect API Key

1. **Navigate to App Store Connect**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to **Users and Access** → **Keys**

2. **Generate API Key**:
   - Click **Generate API Key**
   - Name: `HOMEY Clean CI/CD`
   - Access: `Developer`
   - Download the `.p8` file and record:
     - **Key ID** (e.g., `ABC123DEFG`)
     - **Issuer ID** (e.g., `00000000-0000-0000-0000-000000000000`)

#### 4.2 Create JSON Configuration

Create a JSON file with this exact format:

```json
{
  "key_id": "ABC123DEFG",
  "issuer_id": "00000000-0000-0000-0000-000000000000",
  "key": "-----BEGIN PRIVATE KEY-----\n<contents of .p8 with newlines escaped>\n-----END PRIVATE KEY-----",
  "in_house": false
}
```

**Important**: Replace `\n` with actual newlines when copying the private key content.

#### 4.3 Configure GitHub Secrets

1. **Navigate to GitHub Repository**:
   - Go to **Settings** → **Secrets and variables** → **Actions**

2. **Add Repository Secret**:
   - Click **New repository secret**
   - **Name**: `ASC_API_KEY_JSON`
   - **Value**: Paste the complete JSON configuration from step 4.2

### Step 5: Execute Continuous Integration Process

#### 5.1 Test CI Pipeline

```bash
# Create and push a feature branch
git checkout -b feature/test-ci
git add .
git commit -m "Test CI pipeline"
git push origin feature/test-ci

# Open a Pull Request
# Verify the "iOS CI" workflow runs successfully
```

#### 5.2 Deploy to TestFlight

```bash
# Merge to main branch
git checkout main
git merge feature/test-ci
git push origin main

# Create and push a version tag
git tag -a v0.1.0 -m "Beta seed release"
git push origin v0.1.0

# Monitor the "Beta Deploy to TestFlight" workflow
```

### Step 6: Code Quality Improvement

#### 6.1 Install SwiftFormat

```bash
brew install swiftformat
```

#### 6.2 Apply Automated Fixes

```bash
# Navigate to project directory
cd "HOMEY Clean"

# Apply SwiftFormat
swiftformat .

# Apply SwiftLint fixes
swiftlint --fix

# Rebuild and test
fastlane test
```

### Step 7: Optional Developer Enhancements

#### 7.1 InjectionIII Setup

1. Install InjectionIII from the Mac App Store
2. Link to your Xcode project for hot reloading during development

#### 7.2 Xcode Version Management

1. Install [Xcodes.app](https://github.com/RobotsAndPencils/XcodesApp)
2. Manage multiple Xcode versions for stability

## Available Fastlane Commands

```bash
# Run tests
fastlane test

# Build for development
fastlane build

# Build and deploy to TestFlight (requires ASC API key)
fastlane beta
```

## GitHub Workflows

### iOS CI Workflow
- **Trigger**: Push to `main`/`develop` or Pull Requests
- **Actions**: Run SwiftLint, execute tests, upload results
- **File**: `.github/workflows/ios-ci.yml`

### Beta Deploy Workflow
- **Trigger**: Push tags matching `v*` pattern
- **Actions**: Build app, upload to TestFlight
- **File**: `.github/workflows/beta-deploy.yml`
- **Requirements**: `ASC_API_KEY_JSON` secret configured

## Troubleshooting

### Common Issues

1. **Code Signing Errors**:
   - Ensure your Apple Developer account has proper certificates
   - Verify team ID in `fastlane/Appfile`

2. **TestFlight Upload Failures**:
   - Check App Store Connect API key configuration
   - Verify the app exists in App Store Connect

3. **CI Pipeline Failures**:
   - Review GitHub Actions logs
   - Ensure all secrets are properly configured

### Support

For issues with this setup, check:
- GitHub Actions workflow logs
- Fastlane logs in `fastlane/logs/`
- Xcode build logs