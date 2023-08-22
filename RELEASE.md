# Open Food Facts - Flutter App - Release Guide

Welcome to the release guide for the Open Food Facts Flutter App. Below are the steps to guide you through our 2 weeks release process.

## 1. Pre-release Checklist

Before you proceed with the release, ensure the following:

- [ ] All the features and fixes planned for this release are merged into the `develop` branch.
- [ ] All merged features and fixes have corresponding unit and integration tests.
- [ ] Merge the Release Please PR to update version number in the `pubspec.yaml` according to [semantic versioning](https://semver.org/). This will provoke a F-Droid release up to a week later.

## 2. QA Testing

- [ ] Refer to our QA Document to ensure that the app has been thoroughly tested against all release criteria. You can access the QA document [here](https://fake-url-to-QA-document.com).
  
## 3. Run Automated CI for Deployment

1. [Run the CI GitHub Action to release to Internal and Testflight using this URL](https://github.com/openfoodfacts/smooth-app/actions/workflows/internal-release.yml) (only admins can do that).
2. Trigger the automated CI process which will handle the build and deployment for both iOS and Android.
3. [Go to the Play Console](https://play.google.com/console/u/0/developers/4712693179220384697/app/4972942602078310258/tracks/internal-testing), and add a changelog
4. [Go to App Store Connect](https://appstoreconnect.apple.com/apps/588797948/testflight/ios), and select audiences to distribute to in the Testflight section, and add a Testflight changelog
5. You can't test F-Droid until the APK is built. This requires monitoring their GitLab, and dowloading the APK from there after it's generated. Alternatively, you can download the generated vanilla APK from Open Food Facts' GitHub releases which should be relatively close to that.
> **Note**: If there are any failures during the CI process, they must be addressed before proceeding.

## 4. Verify Deployment

- [ ] Once CI indicates successful internal deployment, download the app from both the Apple App Store and Google Play Store to ensure it's the latest version. Note that you need to register to [TestFlight](https://appstoreconnect.apple.com/apps/588797948/testflight/ios) or [Play Console Internal](https://play.google.com/console/u/0/developers/4712693179220384697/app/4972942602078310258/tracks/internal-testing) to do that.
- [ ] Perform quick tests on both platforms to confirm basic functionality, you can use the release process

## 5. Post-release

1. **Documentation**:
    - Ensure that all documentation is up-to-date. This includes user manuals, developer guides, and in-code documentation.
    - Open a new Release train in the App Store developper console
    
2. **Announce**:
    - Edit the merged release notes on the [Open Food Facts GitHub release page](https://github.com/openfoodfacts/smooth-app/releases), detailing the new features, fixes, and any known issues (it's created by release please).
    - Create [a blogpost on the Open Food Facts blog](https://blog.openfoodfacts.org/wp-admin/post-new.php) , detailing the new features, fixes, focusing on the user visible changes, with nice screenshots centered on the feature. [Example here](https://blog.openfoodfacts.org/en/news/introducing-the-v4-9-0-of-the-open-food-facts-app-a-polished-experience)
    - Create [social media assets on Canva](https://www.canva.com/design/DAFHzRJvuHU/yT1P-MPYkgw4eQtzo_TERQ/edit) detailing the changes
    - Set up the blog post for translation on [openfoodfacts-translations](https://github.com/openfoodfacts/openfoodfacts-translations/tree/main/blog/en-US) using this [Guide](https://fake-url-to-guide.com)
    - Publish translations as they arrive back on openfoodfacts-translations
    - Update the tagline in the app for [android](https://github.com/openfoodfacts/openfoodfacts-server/blob/main/html/files/tagline-off-android-v2.json) and [ios](https://github.com/openfoodfacts/openfoodfacts-server/blob/main/html/files/tagline-off-ios-v2.json) on openfoodfacts-server (it's the app's in-built update notification system).
    - Inform the community through our regular communication channels, such as our Slack, Forum, Facebook, Twitter.

3. **Roadmap Review**:
    - With the release out, it's a good time to look ahead.
    - Create a Roadmap Issue for the next release to see what's planned for the next sprint and adjust priorities if needed. Visit this reference [Roadmap Issue](https://github.com/openfoodfacts/smooth-app/issues/4523)  for inspiration.
  
4. Checking the F-Droid release went ok
    - This can take up to a week if we'rev unlucky. [Check here](https://f-droid.org/fr/packages/openfoodfacts.github.scrachx.openfood/)
    
## 6. Troubleshooting

If any issues arise during the release process:

1. Pause if possible the release on the respective app store(s).
2. Address the issue in our codebase in a branch, have it reviewed and merge.
3. Once fixed, return to the QA Testing phase to ensure stability before re-initiating the release process.

---

Thank you for ensuring the smooth (ha ha) release of the Open Food Facts Flutter App. Your diligence helps us maintain a high standard for the large number of users who depend on the app. If you have suggestions for improving this guide or the release process, please submit your feedback via our regular communication channels.
