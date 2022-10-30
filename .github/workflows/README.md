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
