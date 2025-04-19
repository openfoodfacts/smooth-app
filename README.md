## Smooth App: The new Open Food Facts mobile app for Android and iPhone

![GitHub language count](https://img.shields.io/github/languages/count/openfoodfacts/smooth-app)
![GitHub top language](https://img.shields.io/github/languages/top/openfoodfacts/smooth-app)
![GitHub last commit](https://img.shields.io/github/last-commit/openfoodfacts/smooth-app)
![Github Repo Size](https://img.shields.io/github/repo-size/openfoodfacts/smooth-app)

## Presentation

- This new mobile application aims to showcase Open Food Facts's power to a broad range of users through a smooth user experience and sleek user interface. It is a <b> Flutter application </b> by [Open Food Facts](https://github.com/openfoodfacts).
- We pioneered the collaborative scanning app in 2012. With this experimental app, we’re reinventing it from the ground up.

### Stable version
- Install it on **Android** ([Google Play](https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner), [F-Droid](https://f-droid.org/fr/packages/openfoodfacts.github.scrachx.openfood/) or [Amazon App Store](https://www.amazon.com/Open-Food-Facts-food-Nutriscore/dp/B00U49IVIU)) or [iPhone/iPad](https://apps.apple.com/app/open-food-facts/id588797948).

### Beta version
- Google Play offers a Beta version you can join freely. We typically push to beta a couple of days before final release.

### Testing version
- Note that a internal development build ([Android](https://play.google.com/apps/internaltest/4699092342921529278) or **iPhone/iPad** ([App Store](https://testflight.apple.com/join/c2tiBHgd)) if you'd like to use the results of your PRs quicker.

<img alt="app showcase" height='175' src="https://user-images.githubusercontent.com/1689815/168430524-3adc923a-1ce3-4233-9af5-02e9d49a76ca.png" align="left" hspace="1" vspace="1">

- Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API and [openfoodfacts_flutter_lints](https://github.com/openfoodfacts/openfoodfacts_flutter_lints) which provides specific linting
- We also have [smooth-app_assets](https://github.com/openfoodfacts/smooth-app_assets) to host assets used by the app (currently the tagline)
- Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.
- We support desktop platforms (Linux, macOS and Windows), but **only for development**

## Weekly meetings

- We e-meet Thursdays at 12:30 Paris Time (11:30 London Time, 17:00 IST, 03:30 AM PT)
- ![Google Meet](https://img.shields.io/badge/Google%20Meet-00897B?logo=google-meet&logoColor=white) Video call link: <https://meet.google.com/gnp-frks-esc>
- Join by phone: <https://tel.meet/gnp-frks-esc?pin=1110549945262>
- Add the Event to your Calendar by [adding the Open Food Facts community calendar to your calendar](https://wiki.openfoodfacts.org/Events)
- [Weekly Agenda](https://docs.google.com/document/d/1MGQqMV7M4JTjFcRsiRvMZ8bnmd9vJWdSyRR3wJHUBMk/edit): please add the Agenda items as early as you can. Make sure to check the Agenda items in advance of the meeting, so that we have the most informed discussions possible, leading to argumented decisions.
- The meeting will handle Agenda items first, and if time permits, collaborative bug triage.
- We strive to timebox the core of the meeting (decision making) to 30 minutes, with an optional free discussion/live debugging afterwards.
- We take comprehensive notes in the Weekly Agenda of agenda item discussions and of decisions taken.

## Current Release
- https://github.com/openfoodfacts/smooth-app/releases
- Latest commit deployed to Apple App Store: Released on March 10th, 2025 as Version 4.19.0
- Latest commit deployed to PlayStore: March 10th, 2025 as Version 4.19.0
- Latest commit deployed to F-Droid: March 10th, 2025 as Version 4.19.0

## 📚 Code documentation
- [Code documentation on GitHub pages](https://openfoodfacts.github.io/smooth-app/).

## 🎨 Design & User interface
- We strive to thoughfully design every feature before we move on to implementation, so that we respect Open Food Facts' graphic charter and nascent design system, while having efficient user flows.
- [![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?logo=figma&logoColor=white) Mockups on the current app and future plans to discuss](https://www.figma.com/file/nFMjewFAOa8c4ahtob7CAB/Mobile-App-Design-(Quentin)?node-id=0%3A1&t=SrBuT7gBdhapUerx-0)
- [![Sketch](https://img.shields.io/badge/Sketch-%23F24E1E.svg?logo=sketch&logoColor=white) Recent Sketch mockups by @g123k](https://www.sketch.com/s/11375b6d-9c02-4920-846d-a2b1376600b9/p/95D14BAF-AD1E-449F-9AB7-27E328773827/canvas)

<details><summary><h2>Features of the app</h2></summary>

## ✨ Features

Full list of features on the wiki: https://wiki.openfoodfacts.org/Mobile_App/Features

- a scan that truly matches who you are (Green: the product matches your criteria, Red: there is a problem, Gray: Help us answer you by photographing the products)
- a product page that's knowledgeable, building on the vast amount of food facts we collect collaboratively, and other sources of knowledge, to help you make better food decisions

### You can

- scan and compare in 15 seconds the 3 brands of tomato sauces left on the shelf, on your terms.
- get a tailored comparison of any food category
- set your preferences without ruining your privacy

### Criteria you can pick

- Environment: Eco-Score
- Health: Additives & Ultra processed foods, Salt, Allergens, Nutri-Score

</details>

## 🚀 How to run the project
- Make sure you have installed Flutter and all the requirements
  - [Official Flutter installation guide](https://docs.flutter.dev/get-started/install)
- Currently, the app uses the following version of Flutter: **3.27**.
We have predefined run configurations for Android Studio and Visual Studio Code
In order to run the application, make sure you are in the `packages/smooth_app` directory and run these commands:
- `flutter pub get .`
- On Android 🤖: `flutter run -t lib/entrypoints/android/main_google_play.dart`
- On iOS/macOS 🍎: `flutter run -t lib/entrypoints/ios/main_ios.dart`
- Troubleshooting : If you get an error like `App depends on scanner shared from path which depends on camera_platform_interface from git, version solving failed.`  then run
  - `flutter pub cache clean` or manually delete  the  
  - `C:\Users\~\AppData\Local\Pub\Cache`  file.
 Then redo the above procedure to run the app.

- [Contributing Guidelines](https://github.com/openfoodfacts/smooth-app/blob/develop/CONTRIBUTING.md)

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
