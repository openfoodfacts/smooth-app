<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-dark.png?refresh_github_cache=1">
  <source media="(prefers-color-scheme: light)" srcset="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-light.png?refresh_github_cache=1">
  <img height="48" src="https://static.openfoodfacts.org/images/logos/off-logo-horizontal-light.svg">
</picture>

<br>

## Smooth App : The new Open Food Facts mobile app for Android and iPhone

[![SmoothApp Post-Submit Tests](https://github.com/openfoodfacts/smooth-app/actions/workflows/postsubmit.yml/badge.svg)](https://github.com/openfoodfacts/smooth-app/actions/workflows/postsubmit.yml)
[![Create internal releases](https://github.com/openfoodfacts/smooth-app/actions/workflows/internal-release.yml/badge.svg)](https://github.com/openfoodfacts/smooth-app/actions/workflows/internal-release.yml)

## Weekly meetings
- We e-meet Thursdays at 17:30 Paris Time (16:30 London Time, 22:00 IST, 08:30 AM PT)
- Video call link: https://meet.google.com/gnp-frks-esc
- Join by phone: https://tel.meet/gnp-frks-esc?pin=1110549945262
- Add the Event to your Calendar by [adding the Open Food Facts community calendar to your calendar](https://wiki.openfoodfacts.org/Events)
- [Weekly Agenda](https://docs.google.com/document/d/1MGQqMV7M4JTjFcRsiRvMZ8bnmd9vJWdSyRR3wJHUBMk/edit): please add the Agenda items as early as you can. Make sure to check the Agenda items in advance of the meeting, so that we have the most informed discussions possible, leading to argumented decisions. 
- The meeting will handle Agenda items first, and if time permits, collaborative bug triage.
- We strive to timebox the core of the meeting (decision making) to 30 minutes, with an optional free discussion/live debugging afterwards.
- We take comprehensive notes in the Weekly Agenda of agenda item discussions and of decisions taken.

## Feature Sprint 
- We use feature-based sprints, [tracked here](https://github.com/orgs/openfoodfacts/projects/83)

## Alert!

We are currently using Flutter 3.0.5 as the new 3.3.0 [has some bugs](https://github.com/openfoodfacts/smooth-app/issues/2919).

Running `flutter downgrade 3.0.5` downgrades the version.

------

Latest commit deployed to Apple App Store: (Released on Sep 6 6:29 PM as Build 731 (3.13.1)) https://github.com/openfoodfacts/smooth-app/compare/v3.8.1...v3.13.1
Latest commit deployed to PlayStore: 792 from Nov 6th 11AM
- A <b> Flutter application </b> by [Open Food Facts](https://github.com/openfoodfacts). 

- We pioneered the collaborative scanning app in 2012. With this experimental app, we’re reinventing it from the ground up.

- Install it on [Android](https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner) or [iPhone/iPad](https://apps.apple.com/app/open-food-facts/id588797948). Note that a internal development build ([Android](https://play.google.com/apps/internaltest/4699092342921529278) or [iPhone/iPad](https://testflight.apple.com/join/c2tiBHgd) )if you'd like to use the results of your PRs quicker.



<br>

<details><summary><h2> More Info </h2></summary>

## You get : 
- a scan that truly matches who you are (Green: the product matches your criteria, Red: there is a problem, Gray: Help us answer you by photographing the products)
- a product page that's knowledgeable, building on the vast amount of food facts we collect collaboratively, and other sources of knowledge, to help you make better food decisions
## You can : 
- scan and compare in 15 seconds the 3 brands of tomato sauces left on the shelf, on your terms.
- get a tailored comparison of any food category
- set your preferences without ruining your privacy

## Criteria you can pick : 
- Environment: Eco-Score
- Health: Additives & Ultra processed foods, Salt, Allergens, Nutri-Score

</details>

<br>

## About this Repository

![GitHub language count](https://img.shields.io/github/languages/count/openfoodfacts/smooth-app?style=for-the-badge&color=brightgreen)
![GitHub top language](https://img.shields.io/github/languages/top/openfoodfacts/smooth-app?style=for-the-badge&color=aqua)
![GitHub last commit](https://img.shields.io/github/last-commit/openfoodfacts/smooth-app?style=for-the-badge&color=blue)
![Github Repo Size](https://img.shields.io/github/repo-size/openfoodfacts/smooth-app?style=for-the-badge&color=aqua)

<br>

<b>How to run the project:</b>

In order to run the application, make sure you are in the `packages/app` directory and run these commands :

- `flutter pub get .`
  
- On Android 🤖: `flutter run -t lib/entrypoints/android/main_google_play.dart`

- On iOS 🍎: `flutter run -t lib/entrypoints/ios/main_ios.dart`

- [Contributing Guidelines](https://github.com/openfoodfacts/smooth-app/blob/develop/CONTRIBUTING.md)

<br>

## Presentation

This new mobile application aims to showcase Open Food Facts's power to a broad range of users through a smooth user experience and sleek user interface.

<img alt="app showcase" height='175' src="https://user-images.githubusercontent.com/1689815/168430524-3adc923a-1ce3-4233-9af5-02e9d49a76ca.png" align="left" hspace="1" vspace="1">

Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API.
Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.
<br>

<details><summary><h3>Thanks</h3></summary>
The app was initially created by Primael. The new Open Food Facts app (smooth_app) was then made possible thanks to an initial grant by the Mozilla Foundation in February 2020, after Pierre pitched them the idea at FOSDEM. A HUGE THANKS 🧡
In addition to the core role of the community, we also had the support from several Google.org fellows and a ShareIt fellow that helped us eventually release the app in June 2022.
</details>
<br>

## Contributors

<a href="https://github.com/openfoodfacts/smooth-app/graphs/contributors">
  <img alt="List of contributors to this repository" src="https://contrib.rocks/image?repo=openfoodfacts/smooth-app" />
</a>
