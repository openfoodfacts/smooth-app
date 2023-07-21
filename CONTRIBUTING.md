
## Building

We have predefined run configurations for Android Studio and Visual Studio Code

In order to run the application, make sure you are in the `packages/smooth_app` directory and run these commands:

- `flutter pub get .`
- On Android 🤖: flutter run -t lib/entrypoints/android/main_google_play.dart
- On iOS/macOS 🍎: flutter run -t lib/entrypoints/ios/main_ios.dart

## Contributing

- You don't have to do anything to the CHANGELOG.md yourself, this is done automatically.
  
- Please ensure to add a before/after screenshot when doing a PR that has visual impacts.

- Please name your pull request following this scheme: `type: What you did` this allows us to automatically generate the changelog.
Following `type`s are allowed:

  - `feat`, for Features
  - `fix`, for Bug Fixes
  - `docs`, for Documentation
  - `ci`, for Automation
  - `refactor`, for code Refactoring
  - `chore`, for Miscellaneous things

### Dev Mode

- How to activate it: We now have a in-app dev mode which allows you to debug things faster, or access not-ready-for-primetime features. You can access it by going to Preferences screen > Contribute > Software Development, and then enabling Dev Mode.

- Feel free to file an issue if you'd like new switches in this dev mode.
  
- You can also add new flags for your features.
  - example: <https://github.com/openfoodfacts/smooth-app/pull/834>

## Internationalization

- Translations of the interface are managed using the new [Flutter internationalization](https://github.com/openfoodfacts/openfoodfacts-hungergames/blob/master/src/i18n/common.json) introduced in Flutter 1.22.
- New strings need to be added to lib/l10n/app_en.arb and the [corresponding translations can be added through CrowdIn](https://translate.openfoodfacts.org/translate/openfoodfacts/1322). Do not edit the other app_*.arb files as they will be overwritten by CrowdIn.

![Crowdin Action](https://github.com/openfoodfacts/smooth-app/workflows/Crowdin%20Action/badge.svg)

### Error reporting - Sentry

[Track crashes](https://sentry.io/organizations/openfoodfacts/issues/?project=5376745)

## Contributing - What can I work on ?

Are you a developer? A graphic designer? Full of innovative ideas to help users improve their mode of consumption? Then join us!
We are always looking for new contributors, if you're willing to help please let us know, we'll be pleased to introduce you to the project.

- On GitHub, [you can start here to get some inspiration](https://github.com/openfoodfacts/smooth-app/issues/525)
- You can join the Open Food Facts's Slack here: [Get an invite](https://slack.openfoodfacts.org) - [Open our Slack](https://openfoodfacts.slack.com).

### Weekly meetings

 We usually meet on Thursdays at 15:30 GMT (UTC) at <https://meet.google.com/gnp-frks-esc>. Please email pierre@openfoodfacts.org if you want to be added to the Calendar invite for convenience.

## Wiki & Doc

- [Project Smoothie - Open Food Facts wiki](https://wiki.openfoodfacts.org/Project_Smoothie)
- [Documentation (from code), on GitHub Pages](https://openfoodfacts.github.io/smooth-app/)
- [Project Smoothie GitHub wiki](https://github.com/openfoodfacts/smooth-app/wiki)
- [Project Smoothie marketing automation repository](https://github.com/openfoodfacts/fastlane-descriptions-smoothie/pulls)
- [UX mockups are located here](https://www.figma.com/file/lhRhMulB4Ek9NYDWl3FxAo/Fellowship-Jam-file?node-id=12%3A358). Please be aware that some of them have not been validated, so don't rush in implementing them.
- [Continuous Integration documentation](.github/workflows/README.md)
- [Project Smoothie Landing page](https://github.com/openfoodfacts/smoothielanding)
- Private app signing for iOS certificates repository - please ask @teolemon

## V1 Roadmap (Shipped on June 15th 2022 for Vivatech)

- [x] We should be able to ship the Smoothie code to the main listing on Android and iOS
- [x] The app should be able to scan very well
- [x] Minimal Road to Scores (you should be able to get Nutri-Score and Eco-Score on any unknown/uncomplete product in 2 minutes, using editing and/or product addition
  - [x] Initial photo taking, good ingredient extraction, Nutrition input, Category input (TODO)
- [x] Database migration for existing Android and iOS users (minimum: history, credentials, if possible with allergen alerts, lists)
- [x] A Welcome scan card that can broadcast a message from the Open Food Facts team per country/language (Tagline)
- [x] On-page photo refresh capabilities (Not working well)
- [x] [V1 tracking](https://github.com/orgs/openfoodfacts/projects/7)

## V1.1

- [x] Allow to switch languages
- [x] Allow to expand search results to the world

## Next

### Scanning

- [ ] Ensure no one complains about not being able to scan
- [ ] [Add offline scanning to ensure results in all conditions](https://github.com/openfoodfacts/smooth-app/issues/18)

### Contribution

- [x] Speedup image upload
- [ ] Improve the scan experience when Nutri-Score and Eco-Score are not present (some people don't click on the card even if fully unhelpful)
- [ ] Offer a faster editing system for power users (and potentially all)
  - [ ] Add power edit mode that concatenates all the editable things for faster contribution
- [ ] Add a list of things to do contribution wise on the product (via Knowledge Panels or natively), or introduce a "Raw data" mode for power contributors

### Value added in browsing

- [ ] Clarify the alternative product proposition
- [x] Reintroduce the portion calculator

### Gamification

- [ ] Add the number of contributions when logged in
- [ ] Integration with openfoodfacts-events

### Settings

- [ ] Revamped settings that are less cluttered, and can make way in the future for things the user will go see more often.
- [ ] Personalization system that does not feel weird during setup, where people understand consequence, and where ranking match their expectations even in stretch cases (lack of data on some product, selecting Nutri-Score and all Low-in Nutrients…), where red-lines are clearly shown (allergens) with potential caveats, where solutions are proposed and warning issued in case of lack of data.

### Misc

- [ ] Fix HTTP header and contribution comments
