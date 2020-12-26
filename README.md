<img height='175' src="https://static.openfoodfacts.org/images/svg/openfoodfacts-logo-en.svg" align="left" hspace="1" vspace="1">

# Open Food Facts - smooth_app

A new Flutter application by Open Food Facts

## Presentation

This new mobile application aims to showcase Open Food Facts's power to a broad range of users through a smooth user experience and sleek user interface.

<img height='175' src="https://fr.blog.openfoodfacts.org/images/smoothie2.jpg" align="left" hspace="1" vspace="1">

Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API.
Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.

## Contributing - What can I work on ?

Are you a developer? A graphic designer? Full of innovative ideas to help users improve their mode of consumption? Then join us!
We are always looking for new contributors, if you're willing to help please let us know, we'll be pleased to introduce you to the project.

You can join the Open Food Facts's Slack here : [Get an invite](https://slack.openfoodfacts.org) - [Open our Slack](https://openfoodfacts.slack.com).

*full project documentation will be added here when ready*

## Roadmap
- [ ] Add Eco-Score support
- [ ] Add Fastlane publishing to the AppStore and the Play Store and GitHub Actions
- [ ] Add multilingual screenshot generation using Fastlane
- [ ] Fix navigation for the iOS build (iOS does not have a back button, and gestures are not intuitive for most people)
- [ ] Remove the hack on the category explorer
- [ ] User management + Small point system for contributions

## Building

In order to build the application, make sure you are in the packages/smooth_app directory and run these commands :
 - flutter pub get
 - flutter run
 
### Android
### iOS
We need to change the supported architectures for iOS when we open the project in Xcode. There, in the settings, you can specify which ones you want to build for, and only specify the ones that are 64 bit. After that it should build fine for the MLKit component.

## Internationalization

Translations of the interface are managed using the [Flutter Intl plugin / intl_utils Dart package](https://github.com/localizely/flutter-intl-plugin-sample-app) by localizely.
New strings need to be added to lib/l10n/intl_en.arb and the corresponding translations in the other intl_*.arb files will come from CrowdIn.

## Thank you
Smooth_app is made possible thanks to a grant by the Mozilla Foundation, after pitching them the idea at FOSDEM. a HUGE thank you :-) 
