<img height='175' src="https://static.openfoodfacts.org/images/svg/openfoodfacts-logo-en.svg" align="left" hspace="1" vspace="1">

# Open Food Facts - Codename: "Smooth App"

A new Flutter application by Open Food Facts. You can install it on [Android](https://play.google.com/store/apps/details?id=org.openfoodfacts.app) or [iPhone/iPad](https://apps.apple.com/us/app/smooth-app/id1526747703). Note that a internal development build ([Android](https://play.google.com/apps/internaltest/4700279390303733107) or [iPhone/iPad](https://testflight.apple.com/join/dIhF6Gi4) )if you'd like to use the results of your PRs quicker.

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

<img height='175' src="https://fr.blog.openfoodfacts.org/images/smoothie2.jpg" align="left" hspace="1" vspace="1">

Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API.
Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.

## Contributing - What can I work on ?

Are you a developer? A graphic designer? Full of innovative ideas to help users improve their mode of consumption? Then join us!
We are always looking for new contributors, if you're willing to help please let us know, we'll be pleased to introduce you to the project.

- On GitHub, [you can start here to get some inspiration](https://github.com/openfoodfacts/smooth-app/issues/525) 
- You can join the Open Food Facts's Slack here : [Get an invite](https://slack.openfoodfacts.org) - [Open our Slack](https://openfoodfacts.slack.com).

## Wiki & Doc 
- [Project Smoothie - Open Food Facts wiki](https://wiki.openfoodfacts.org/Project_Smoothie)
- [Documentation (from code), on GitHub Pages](https://openfoodfacts.github.io/smooth-app/)
- [Smoothie GitHub wiki](https://github.com/openfoodfacts/smooth-app/wiki)

## V1 Roadmap
- [ ] Revamped and knowledgeable product page (Jasmeet)
- [ ] Minimal editing/addition value proposition, including by deep linking to the classic Android/iOS apps. (up for grabs)
- [ ] [Automation of marketing texts](https://github.com/openfoodfacts/fastlane-descriptions-smoothie) (mostly done)

## V2 - Later Roadmap
### Screenshot automation (High priority)
- [ ] [Add multilingual screenshot generation using Fastlane (Scan screen, settings screen, personalized ranking screen, home screen)](https://github.com/openfoodfacts/smooth-app/issues/217)

### Navigation
- [ ] [Fix navigation for the iOS build (iOS does not have a back button, and gestures are not intuitive for most people)](https://github.com/openfoodfacts/smooth-app/issues/17)

### Debt removal
- [ ] [Remove the hack on the category explorer](https://github.com/openfoodfacts/smooth-app/issues/19)

### Personalized results
- [ ] [Allow to filter results by country and by store](https://github.com/openfoodfacts/smooth-app/issues/99)

### Gamification
- [ ] User management + Small point system for contributions

### Product page

### Scanning
- [ ] [Allow the user to find alternatives products on a scan even if (s)he has scanned only 1 product](https://github.com/openfoodfacts/smooth-app/issues/23)
- [ ] [Add offline scanning to ensure results in all conditions](https://github.com/openfoodfacts/smooth-app/issues/18)

## Building

In order to build the application, make sure you are in the packages/smooth_app directory and run these commands :
 - flutter pub get
 - flutter run
 
### Android & iOS
- Nothing to report

## Internationalization

- Translations of the interface are managed using the new [Flutter internationalization](https://github.com/openfoodfacts/openfoodfacts-hungergames/blob/master/src/i18n/common.json) introduced in Flutter 1.22.
- New strings need to be added to lib/l10n/app_en.arb and the [corresponding translations can be added through CrowdIn](https://translate.openfoodfacts.org/translate/openfoodfacts/1322). Do not edit the other app_*.arb files as they will be overwritten by CrowdIn.

![Crowdin Action](https://github.com/openfoodfacts/smooth-app/workflows/Crowdin%20Action/badge.svg)

## Thank you
Smooth_app is made possible thanks to a grant by the Mozilla Foundation, after pitching them the idea at FOSDEM. a HUGE thank you :-) 
