# smooth_app

A new Flutter application by Open Food Facts

## Presentation

This new mobile application aims to showcase Open Food Facts's power to a broad range of users through a smooth user experience and sleek user interface.

*mockups coming soon*

Smooth-app is developed in parallel to the [openfoodfacts-dart](https://github.com/openfoodfacts/openfoodfacts-dart) plugin, which provides a high level interface with the Open Food Facts API.
Every new interaction with the API should be implemented in the plugin in order to provide these new features to other developers.

## Contributing

Are you a developer? A graphic designer? Full of innovative ideas to help users improve their mode of consumption? Then join us!
We are always looking for new contributors, if you're willing to help please let us know, we'll be pleased to introduce you to the project.

You can join the Open Food Facts's Slack here : [Our Slack](openfoodfacts.slack.com).

*full project documentation will be added here when ready*

## Building

In order to build the application, make sure you are in the packages/smooth_app directory and run these commands :
 - flutter pub get
 - flutter run
 
### Android
### iOS
We need to change the supported architectures for iOS when we open the project in Xcode. There, in the settings, you can specify which ones you want to build for, and only specify the ones that are 64 bit. After that it should build fine for the MLKit component.

## Thank you
Smooth_app is made possible thanks to a grant by the Mozilla Foundation, after pitching them the idea at FOSDEM. a HUGE thank you :-) 
