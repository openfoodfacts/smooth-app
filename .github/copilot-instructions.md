# Open Food Facts Mobile App (Smooth App) - Flutter Development Guide

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This is a comprehensive Flutter mobile application for Open Food Facts, supporting Android and iOS platforms. The app uses a multi-package architecture with scanner integrations, app store variations, and extensive testing infrastructure.

## Essential Setup and Environment

### Flutter Version Management
- **CRITICAL**: This app requires Flutter version **3.35.1** exactly (as specified in `flutter-version.txt`)
- **ALWAYS** use FVM (Flutter Version Management) for consistent Flutter versions:
  ```bash
  # Install FVM first: https://fvm.app/documentation/getting-started/installation
  fvm install 3.35.1
  fvm use 3.35.1
  fvm flutter --version  # Should show Flutter 3.35.1
  ```
- Export Flutter to PATH: `export PATH="$(fvm flutter sdk-path)/bin:$PATH"`

### Initial Repository Setup
- **NEVER CANCEL**: Initial Flutter setup takes 5-10 minutes. WAIT for completion.
- Navigate to the main app directory: `cd packages/smooth_app`
- Install dependencies: `fvm flutter pub get .` (takes 2-3 minutes)

### Required System Dependencies
- Java JDK 21 (for Android builds)
- Android SDK (if building for Android)
- Xcode (if building for iOS on macOS)
- Git (for dependency management)

## Build Commands - VALIDATED

### Dependency Management
```bash
# Update all package dependencies (PREFERRED method)
./ci/pub_upgrade.sh
# NEVER CANCEL: Takes 3-5 minutes across all packages
```

### Running the Application
```bash
cd packages/smooth_app

# Android (Google Play variant) - DEFAULT
fvm flutter run -t lib/entrypoints/android/main_google_play.dart
# NEVER CANCEL: Initial build takes 10-15 minutes, subsequent builds 2-3 minutes

# iOS variant
fvm flutter run -t lib/entrypoints/ios/main_ios.dart  
# NEVER CANCEL: Initial build takes 15-20 minutes, subsequent builds 3-5 minutes

# Debug mode (faster startup)
fvm flutter run --debug -t lib/entrypoints/android/main_google_play.dart
```

### Scanner Dependencies Configuration
The app supports different barcode scanner implementations. Choose one:

```bash
# Enable ML Kit scanner (default, requires Google services)
./ci/dependencies/scanner/enable_mlkit_dependency.sh

# Enable ZXing scanner (open source alternative)  
./ci/dependencies/scanner/enable_zxing_dependency.sh

# ALWAYS run flutter pub get after changing scanner dependencies
cd packages/smooth_app && fvm flutter pub get .
```

### App Store Variants Configuration
Choose the appropriate app store configuration:

```bash
# Google Play Store (default)
./ci/dependencies/app_store/enable_google_play_dependency.sh

# Apple App Store  
./ci/dependencies/app_store/enable_apple_app_store_dependency.sh

# URI store (for F-Droid and others)
./ci/dependencies/app_store/enable_uri_store_dependency.sh
```

## Testing and Quality Assurance

### Code Formatting and Analysis
```bash
# Format code (REQUIRED before commits)
dart format --set-exit-if-changed .
# Returns exit code 1 if formatting needed

# Analyze code for issues (REQUIRED before commits)
fvm flutter analyze --fatal-infos --fatal-warnings .
# NEVER CANCEL: Analysis takes 1-2 minutes
```

### Running Tests
```bash
# Run all tests with coverage
./ci/testing.sh
# NEVER CANCEL: Complete test suite takes 5-8 minutes

# Run tests for specific package
cd packages/smooth_app && fvm flutter test --coverage
# NEVER CANCEL: Main app tests take 3-4 minutes

# Integration tests (with screenshots)
fvm flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/app_test.dart
# NEVER CANCEL: Integration tests take 2-3 minutes
```

## Development Workflow

### Pre-Commit Validation (MANDATORY)
**ALWAYS** run these commands before committing changes:
```bash
# 1. Format code
dart format --set-exit-if-changed .

# 2. Analyze for issues  
fvm flutter analyze --fatal-infos --fatal-warnings .

# 3. Run relevant tests
./ci/testing.sh

# Total time: 8-12 minutes. NEVER CANCEL any of these steps.
```

### Build Troubleshooting
If you encounter build issues:

1. **Clear Flutter cache**: `fvm flutter clean` (takes 30 seconds)
2. **Reinstall dependencies**: `fvm flutter pub get .` (takes 2-3 minutes)
3. **Clear pub cache**: `fvm flutter pub cache clean` (takes 1 minute)
4. **Reset to clean state**: 
   ```bash
   cd packages/smooth_app
   fvm flutter clean
   fvm flutter pub get .
   ```

## Project Structure and Key Locations

### Main Directories
- `packages/smooth_app/` - Main Flutter application
- `packages/scanner/` - Barcode scanning implementations (ML Kit, ZXing, shared)
- `packages/app_store/` - App store specific implementations (Google Play, Apple, URI)
- `ci/` - Continuous integration scripts and utilities
- `.github/workflows/` - GitHub Actions CI/CD pipeline

### Important Files
- `flutter-version.txt` - Specifies required Flutter version (3.35.1)
- `packages/smooth_app/pubspec.yaml` - Main app dependencies
- `packages/smooth_app/lib/entrypoints/` - Platform-specific entry points
- `packages/smooth_app/integration_test/` - End-to-end test scenarios

### Development Features
- **Dev Mode**: Access via Preferences > Contribute > Software Development
  - Enables debugging features and experimental options
  - Useful for testing new features before release

## Validation Scenarios

### MANDATORY Manual Testing After Changes
**ALWAYS** perform these validation steps after making changes:

1. **App Startup**: Verify app launches successfully on target platform
2. **Basic Navigation**: Test main screens (Home, Scan, Search, Profile)
3. **Barcode Scanning**: Test product scanning functionality
4. **Product Details**: Verify product information display
5. **Search Functionality**: Test product search and filters

### Screenshot Requirements
- **ALWAYS** include before/after screenshots for UI changes
- Use integration tests to generate consistent screenshots
- Store screenshots in appropriate test directories

## Common Issues and Solutions

### Build Failures
- **"App depends on scanner shared from path"**: Run `fvm flutter pub cache clean`
- **Version conflicts**: Ensure Flutter version matches `flutter-version.txt`
- **Scanner dependency issues**: Check that only one scanner variant is enabled

### Network-Related Issues  
- **Download failures during setup**: Flutter may have connectivity issues in some environments
- **Pub get failures**: Try `fvm flutter pub cache clean` and retry
- **SDK download failures**: Ensure internet connectivity and retry

### Platform-Specific Notes
- **Desktop platforms**: Supported ONLY for development, not production
- **Android**: Requires Java 21, minimum SDK as defined in build.gradle.kts  
- **iOS**: Requires Xcode and iOS development setup on macOS

## CI/CD Integration

### GitHub Actions Workflow
The repository uses comprehensive CI/CD:
- **Pre-submit**: Format check, analysis, and tests on every PR
- **Post-submit**: Extended validation on main branch
- **Timeouts**: All CI operations have appropriate timeouts (30+ minutes for builds)

### Release Process
- Automated changelog generation
- Multiple release channels: Production (App Store/Play Store), Beta, Internal testing
- F-Droid releases managed separately

## Performance Expectations

### Build Times (NEVER CANCEL)
- **Initial Flutter setup**: 5-10 minutes
- **First Android build**: 10-15 minutes  
- **First iOS build**: 15-20 minutes
- **Subsequent builds**: 2-5 minutes
- **Complete test suite**: 5-8 minutes
- **Code analysis**: 1-2 minutes
- **Dependency installation**: 2-3 minutes per package

### Memory and Storage
- **Minimum RAM**: 8GB recommended for development
- **Storage**: 15+ GB free space (Flutter SDK + dependencies + build cache)

## Documentation and Resources

### Code Documentation
- [Generated documentation](https://openfoodfacts.github.io/smooth-app/) - Updated automatically
- Use `mkdocs serve` to run documentation locally (requires `pip install mkdocs mkdocs-material`)

### External Resources
- [Project Smoothie Wiki](https://wiki.openfoodfacts.org/Project_Smoothie)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Open Food Facts API Documentation](https://openfoodfacts.github.io/openfoodfacts-dart/)

### Community
- Weekly meetings: Thursdays 18:30 Paris Time
- Slack: [Open Food Facts Slack](https://slack.openfoodfacts.org)
- Issues: Use GitHub Issues with appropriate labels

**CRITICAL REMINDERS:**
- NEVER CANCEL long-running build operations - they are expected to take significant time
- ALWAYS validate with the pre-commit steps before submitting changes  
- ALWAYS use the exact Flutter version specified in flutter-version.txt
- ALWAYS test your changes with real user scenarios, not just compilation