/// Base class for Apple App Store, Google Play…
abstract class AppStore {
  const AppStore();

  Future<void> openAppDetails();

  /// Open a screen/dialog… (depending on the store) to rate the app
  Future<bool> openAppReview();
}
