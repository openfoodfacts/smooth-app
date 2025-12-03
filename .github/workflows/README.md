📦 Existing

Crowdin Action：
 Process: Dump sources and download translations from Crowdin [.github/crowdin.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/crowdin.yml)
 Event: Push onto [crowdin-trigger]


Labeler:
 Process: add tags to PR according to configuration file [.github/labeler.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/labeler.yml)
 Event: Creation PR


Github Pages Deploy Action:
 Process: Deploy auto-generated APIs document in GitHub Pages https://openfoodfacts.github.io/smooth-app/
 Event: Push onto [develop]


Release:
 The release process is triggered by release please (by merging a generated "chore(develop): release x.x.x" pull request).
 This triggers the release to the Play- and App-Store using [Fastlane](https://fastlane.tools/).
 [Release please](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/release-please.yml)
 [Android release](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/android-release-to-org-openfoodfacts-scanner.yml)
 [iOS please](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/ios-release-to-org-openfoodfacts-scanner.yml)

## Open Beauty Facts, Open Pet Food Facts, and Open Products Facts Releases

To release Open Beauty Facts (OBF), Open Pet Food Facts (OPFF), or Open Products Facts (OPF), use the workflow dispatch:
- Go to Actions → "Create releases for Open Beauty Facts, Open Pet Food Facts, and Open Products Facts"
- Select the app to release and the platforms (Android, iOS, or both)
- The workflow uses [openxfacts-release.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/workflows/openxfacts-release.yml)

### Required Secrets for Open*Facts Releases

The following secrets need to be configured in the repository:

#### Android (for OBF and OPFF - uses OBF signing key)
- `OBF_STORE_JKS_DECRYPTKEY`: Decryption key for the OBF keystore file
- `OBF_SIGN_STORE_PASSWORD`: Keystore password for OBF signing key
- `OBF_SIGN_KEY_ALIAS`: Key alias for OBF signing key
- `OBF_SIGN_KEY_PASSWORD`: Key password for OBF signing key

#### Android (for OPF - uses OFF signing key)
Uses the existing OFF secrets:
- `NEW_CYPHER` (STORE_JKS_DECRYPTKEY)
- `DECRYPT_FOR_SCANNER_FILE` (SIGN_STORE_PASSWORD)
- `ALIAS_FOR_SCANNER` (SIGN_KEY_ALIAS)
- `KEY_FOR_SCANNER` (SIGN_KEY_PASSWORD)

#### iOS (all apps)
Uses the existing iOS secrets (same as OFF):
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

#### Encrypted Keystore Files Required
The following encrypted keystore files need to be added to `packages/smooth_app/android/fastlane/envfiles/`:
- `obf_keystore.jks.gpg`: The OBF/OPFF signing keystore (encrypted with `OBF_STORE_JKS_DECRYPTKEY`)

### App Package Names
- Open Beauty Facts: `org.openbeautyfacts.scanner`
- Open Pet Food Facts: `org.openpetfoodfacts.scanner`
- Open Products Facts: `org.openproductsfacts.scanner`

### Signing Key Mapping
| App | Android Keystore | Reason |
|-----|-----------------|--------|
| Open Food Facts (OFF) | `keystore.jks` | Primary app |
| Open Beauty Facts (OBF) | `obf_keystore.jks` | Different signing key |
| Open Pet Food Facts (OPFF) | `obf_keystore.jks` | Uses OBF signing key |
| Open Products Facts (OPF) | `keystore.jks` | Uses OFF signing key |
