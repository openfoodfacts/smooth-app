<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-dark.png?refresh_github_cache=1">
  <source media="(prefers-color-scheme: light)" srcset="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-light.png?refresh_github_cache=1">
  <img height="48" src="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-light.svg">
</picture>

# New Open Food Facts mobile app for Android and iPhone - Codename: "Smooth App"
[![SmoothApp Post-Submit Tests](https://github.com/openfoodfacts/smooth-app/actions/workflows/postsubmit.yml/badge.svg)](https://github.com/openfoodfacts/smooth-app/actions/workflows/postsubmit.yml)

## Alert!

We are currently using Flutter 3.0.5 as the new 3.3.0 [has some bugs](https://github.com/openfoodfacts/smooth-app/issues/2919).

Running `flutter downgrade 3.0.5` downgrades the version.

------

Latest commit deployed to App Stores: (Released on Sep 6 6:29 PM as Build 731 (3.13.1)) https://github.com/openfoodfacts/smooth-app/compare/v3.8.1...v3.13.1

A new Flutter application by [Open Food Facts](https://github.com/openfoodfacts). You can install it on [Android](https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner) or [iPhone/iPad](https://apps.apple.com/app/open-food-facts/id588797948). Note that a internal development build ([Android](https://play.google.com/apps/internaltest/4699092342921529278) or [iPhone/iPad](https://testflight.apple.com/join/c2tiBHgd) )if you'd like to use the results of your PRs quicker.

Smoothie. We pioneered the collaborative scanning app in 2012. With this experimental app, we’re reinventing it from the ground up, and this time, it’s personal.

## You get: 
- a scan that truly matches who you are (Green: the product matches your criteria, Red: there is a problem, Gray: Help us answer you by photographing the products)
- a product page that's knowledgeable, building on the vast amount of food facts we collect collaboratively, and other sources of knowledge, to help you make better food decisions
## You can: 
- scan and compare in 15 seconds the 3 brands of tomato sauces left on the shelf, on your terms.
- get a tailored comparison of any food category
- set your preferences without ruining your privacy

## Criteria you can pick: 
- Environment: Eco-Score
- Health: Additives & Ultra processed foods, Salt, Allergens, Nutri-Score

## Presentation

This new mobile application aims to showcase Open Food Facts's power to a broad range of users through a smooth user experience and sleek user interface.

<img height='175' src="https://user-images.githubusercontent.com/1689815/168430524-3adc923a-1ce3-4233-9af5-02e9d49a76ca.png" align="left" hspace="1" vspace="1">

Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API.
Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.

## Contributing - What can I work on ?

Are you a developer? A graphic designer? Full of innovative ideas to help users improve their mode of consumption? Then join us!
We are always looking for new contributors, if you're willing to help please let us know, we'll be pleased to introduce you to the project.

- On GitHub, [you can start here to get some inspiration](https://github.com/openfoodfacts/smooth-app/issues/525) 
- You can join the Open Food Facts's Slack here : [Get an invite](https://slack.openfoodfacts.org) - [Open our Slack](https://openfoodfacts.slack.com).

### Weekly meetings
 We usually meet on Thursdays at 15:30 GMT (UTC) at https://meet.google.com/gnp-frks-esc. Please email pierre@openfoodfacts.org if you want to be added to the Calendar invite for convenience

## Wiki & Doc 
- [Project Smoothie - Open Food Facts wiki](https://wiki.openfoodfacts.org/Project_Smoothie)
- [Documentation (from code), on GitHub Pages](https://openfoodfacts.github.io/smooth-app/)
- [Project Smoothie GitHub wiki](https://github.com/openfoodfacts/smooth-app/wiki)
- [Project Smoothie marketing automation repository](https://github.com/openfoodfacts/fastlane-descriptions-smoothie/pulls)
- [UX mockups are located here](https://www.figma.com/file/lhRhMulB4Ek9NYDWl3FxAo/Fellowship-Jam-file?node-id=12%3A358). Please be aware that some of them have not been validated, so don't rush in implementing them. 
- [Continuous Integration documentation](.github/workflows/README.md)
- [Project Smoothie Landing page](https://github.com/openfoodfacts/smoothielanding)
- Private app signing for iOS certificates repository - please ask @teolemon

## Custom dependencies (forked versions)
- [g123k/plugins](https://github.com/g123k/plugins) - We use our own fork of the camera plugin to be able to hotfix problems in it we find.


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

## Building

In order to build the application, make sure you are in the packages/smooth_app directory and run these commands :
 - flutter pub get
 - flutter run

## Contributing

Please name your pull request following this scheme: `type: What you did` this allows us to automatically generate the changelog
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
  - example: https://github.com/openfoodfacts/smooth-app/pull/834

## Internationalization

- Translations of the interface are managed using the new [Flutter internationalization](https://github.com/openfoodfacts/openfoodfacts-hungergames/blob/master/src/i18n/common.json) introduced in Flutter 1.22.
- New strings need to be added to lib/l10n/app_en.arb and the [corresponding translations can be added through CrowdIn](https://translate.openfoodfacts.org/translate/openfoodfacts/1322). Do not edit the other app_*.arb files as they will be overwritten by CrowdIn.

![Crowdin Action](https://github.com/openfoodfacts/smooth-app/workflows/Crowdin%20Action/badge.svg)

### Error reporting - Sentry
[Track crashes](https://sentry.io/organizations/openfoodfacts/issues/?project=5376745)


## Thank you
The app was initially created by Primael. The new Open Food Facts app (smooth_app) was then made possible thanks to an initial grant by the Mozilla Foundation in February 2020, after Pierre pitched them the idea at FOSDEM. a HUGE thank you :-)
In addition to the core role of the community, we also had the support from several Google.org fellows and a ShareIt fellow that helped us eventually release the app in June 2022.
