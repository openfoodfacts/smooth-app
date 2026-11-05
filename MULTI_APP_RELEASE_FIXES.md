# Multi-App Release Configuration Fixes

## Summary of Changes

This document describes the fixes made to address issues in PR #7261 related to releasing Open Beauty Facts (OBF), Open Pet Food Facts (OPFF), and Open Products Facts (OPF) apps from the same codebase.

## Issues Fixed

### 1. Android Package Name Configuration
**Problem**: The Android `build.gradle.kts` had the package name hardcoded to `org.openfoodfacts.scanner`, preventing builds for other apps with different package names.

**Solution**: Modified `packages/smooth_app/android/app/build.gradle.kts` to read the package name from the `PACKAGE_NAME` environment variable:
```kotlin
applicationId = System.getenv("PACKAGE_NAME") ?: "org.openfoodfacts.scanner"
```

### 2. Android Workflow Package Name Propagation
**Problem**: The `android-release-to-org-openxfacts-scanner.yml` workflow wasn't passing the `PACKAGE_NAME` to the build step.

**Solution**: Added `PACKAGE_NAME` environment variable to the "Build app" step in the workflow.

### 3. iOS Bundle Identifier Configuration
**Problem**: The iOS Xcode project had the bundle identifier hardcoded to `org.openfoodfacts.scanner`.

**Solution**: Updated `packages/smooth_app/ios/fastlane/Fastfile` to dynamically set the bundle identifier using the `update_app_identifier` fastlane action before building:
```ruby
update_app_identifier(
  xcodeproj: "Runner.xcodeproj",
  plist_path: "Runner/Info.plist",
  app_identifier: APP_IDENTIFIER
)
```

### 4. Android Keystore File Naming
**Problem**: The `decrypt_secrets_multi.sh` script referenced `obf_keystore.jks.gpg` which doesn't exist in the repository.

**Solution**: Updated the script to use `scanner_keystore.jks.gpg` for OBF and OPFF builds. Added TODO comment to rename this file once properly migrated.

### 5. Android Fastlane Google Play API JSON
**Problem**: The `release` lane wasn't explicitly specifying which Google Play API JSON file to use for uploads.

**Solution**: Added explicit `json_key` parameter to the `upload_to_play_store` call. Currently points to the OFF API JSON file with a TODO for supporting separate files per app.

## Remaining Issues and Required External Actions

### 1. iOS Certificates for OBF, OPFF, and OPF
**Status**: ⚠️ BLOCKED - Requires external action

**Issue**: The iOS certificates repository (https://github.com/openfoodfacts/ios-certificates) doesn't contain certificates for:
- `org.openbeautyfacts.scanner`
- `org.openpetfoodfacts.scanner`
- `org.openproductsfacts.scanner`

**Required Action**: Create and upload iOS distribution certificates and provisioning profiles for these bundle identifiers to the ios-certificates repository.

**Impact**: iOS builds for OBF, OPFF, and OPF will fail during the code signing step until certificates are available.

### 2. Android Keystore for Open Beauty Facts
**Status**: ⚠️ PARTIALLY ADDRESSED - Requires migration

**Issue**: The Android keystore for OBF and OPFF is in the old repository (https://github.com/openfoodfacts/openfoodfacts-androidapp/tree/develop/fastlane/envfiles) where it's named `OpenBeautyFactsProd.key`.

**Current Workaround**: The script now uses `scanner_keystore.jks.gpg` as a temporary solution, but this needs to be replaced with the proper OBF keystore.

**Required Action**: 
1. Obtain the `OpenBeautyFactsProd.key` file from the old repository (it may need to be decrypted first)
2. Encrypt it with the appropriate passphrase (same as `OBF_STORE_JKS_DECRYPTKEY` secret)
3. Add it as `obf_keystore.jks.gpg` in `packages/smooth_app/android/fastlane/envfiles/`
   - Note: The new codebase uses `.jks` extension instead of `.key` for consistency
4. Update `decrypt_secrets_multi.sh` to decrypt `obf_keystore.jks.gpg` instead of `scanner_keystore.jks.gpg`
5. Remove the TODO comment from `decrypt_secrets_multi.sh`

**Reference**: The old repository's decrypt script at https://github.com/openfoodfacts/openfoodfacts-androidapp/blob/develop/fastlane/envfiles/decrypt_secrets.sh shows that OBF/OPFF use `OpenBeautyFactsProd.key` with the `OBF_STORE_JKS_DECRYPTKEY` passphrase.

### 3. Google Play Console API JSON Files per App
**Status**: ⚠️ TODO - Requires new files

**Issue**: Currently all apps (OFF, OBF, OPFF, OPF) use the same Google Play API JSON file (`api-4712693179220384697-162836-33ea08672303.json`), which only has access to the OFF Play Console.

**Required Action**:
1. Create separate service accounts in Google Play Console for OBF, OPFF, and OPF
2. Download their API JSON files
3. Encrypt them using GPG
4. Add them to `packages/smooth_app/android/fastlane/envfiles/` with descriptive names (e.g., `api-obf.json.gpg`, `api-opff.json.gpg`, `api-opf.json.gpg`)
5. Update `decrypt_secrets_multi.sh` to select the appropriate JSON file based on `PACKAGE_NAME`
6. Update `android/fastlane/Fastfile` to use the correct JSON file

**Impact**: Until separate API JSON files are available, releases for OBF, OPFF, and OPF will fail when attempting to upload to their respective Play Store listings.

### 4. Version Code Management
**Status**: ℹ️ INFORMATIONAL - Works but not ideal

**Issue**: The `getOldVersionCode` lane in Android Fastfile is hardcoded to use OFF's package name and always queries the OFF Play Store listing for the version code.

**Current Behavior**: All apps (OFF, OBF, OPFF, OPF) will share the same version code sequence as OFF.

**Recommendation**: Consider whether each app should have independent version codes or continue sharing them. If independent version codes are desired, update the `getOldVersionCode` lane to support querying different package names.

## Testing Checklist

Once the external actions are completed, test the following:

- [ ] Android build for Open Beauty Facts with package name `org.openbeautyfacts.scanner`
- [ ] Android build for Open Pet Food Facts with package name `org.openpetfoodfacts.scanner`
- [ ] Android build for Open Products Facts with package name `org.openproductsfacts.scanner`
- [ ] iOS build for Open Beauty Facts with bundle ID `org.openbeautyfacts.scanner`
- [ ] iOS build for Open Pet Food Facts with bundle ID `org.openpetfoodfacts.scanner`
- [ ] iOS build for Open Products Facts with bundle ID `org.openproductsfacts.scanner`
- [ ] Upload to correct Play Store listing for each app
- [ ] Upload to correct App Store listing for each app

## References

- Original PR: https://github.com/openfoodfacts/smooth-app/pull/7261
- iOS Certificates Repo: https://github.com/openfoodfacts/ios-certificates
- Old Android Keystore Location: https://github.com/openfoodfacts/openfoodfacts-androidapp/tree/develop/fastlane/envfiles
- Old Android Release Workflow: https://github.com/openfoodfacts/openfoodfacts-androidapp/blob/develop/.github/workflows/android-release.yml

## Secrets Configuration

The workflows use the following GitHub secrets:

### For Open Food Facts and Open Products Facts (uses OFF key)
- `API_JSON_FILE_DECRYPTKEY` - Decrypts the Google Play API JSON file
- `NEW_CYPHER` / `STORE_JKS_DECRYPTKEY` - Decrypts keystore.jks
- `DECRYPT_FOR_SCANNER_FILE` / `SIGN_STORE_PASSWORD` - Keystore password
- `ALIAS_FOR_SCANNER` / `SIGN_KEY_ALIAS` - Key alias
- `KEY_FOR_SCANNER` / `SIGN_KEY_PASSWORD` - Key password

### For Open Beauty Facts and Open Pet Food Facts (uses OBF key)
- `API_JSON_FILE_DECRYPTKEY` - Same as above (currently)
- `OBF_STORE_JKS_DECRYPTKEY` - Decrypts obf_keystore.jks (was OpenBeautyFactsProd.key in old repo)
- `OBF_SIGN_STORE_PASSWORD` - OBF keystore password
- `OBF_SIGN_KEY_ALIAS` - OBF key alias
- `OBF_SIGN_KEY_PASSWORD` - OBF key password

### For iOS (all apps)
- `SENTRY_AUTH_TOKEN`
- `FASTLANE_USER`
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION`
- `MATCH_GIT_URL`
- `MATCH_KEYCHAIN_PASSWORD`
- `MATCH_PASSWORD`
- `PILOT_APPLE_ID`
- `SPACESHIP_CONNECT_API_ISSUER_ID`
- `SPACESHIP_CONNECT_API_KEY_ID`
- `AUTH_KEY_FILE_DECRYPTKEY`
