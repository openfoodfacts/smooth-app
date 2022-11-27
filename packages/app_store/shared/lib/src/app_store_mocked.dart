import 'package:app_store_shared/src/app_store.dart';

/// Empty implementation for an [AppStore]
class MockedAppStore extends AppStore {
  const MockedAppStore();

  @override
  Future<void> openAppDetails() async {}

  @override
  Future<bool> openAppReview() async {
    return false;
  }
}
