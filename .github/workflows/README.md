📦 Existing
App Store Release(TestFlight): 
 Process: deliver the IOS version onto TestFlight [.github/release.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/release.yml)
 Event: Push on [release/*]


Crowdin Action：
 Process: Dump sources and download translations from Crowdin [.github/crowdin.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/crowdin.yml)
 Event: Push onto [crowdin-trigger]


Labeler:
 Process: add tags to PR according to configuration file [.github/labeler.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/labeler.yml)
 Event: Creation PR


Google Play Release:
 Process: deliver Android version onto Google Play [.github/release.yml](https://github.com/openfoodfacts/smooth-app/blob/develop/.github/release.yml)
 Event: Push on [release/*]


Github Pages Deploy Action:
 Process: Deploy auto-generated APIs document in GitHub Pages https://openfoodfacts.github.io/smooth-app/
 Event: Push onto [develop]


Release please:
 Process: Update version.txt and CHANGELOG.md by setting release-type=simple
 Event: Push onto [develop]
