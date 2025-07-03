import 'package:app_store_shared/app_store_shared.dart';
import 'package:smooth_app/services/smooth_service.dart';

class AppStoreService extends SmoothService<AppStoreWrapper> {
  Future<void> openAppDetails() {
    assert(
      impls.isNotEmpty,
      'Please attach an [AppStore] before calling this method!',
    );
    return impls.first.openAppDetails();
  }

  Future<bool> openAppReview() {
    assert(
      impls.length == 1,
      'Please attach an [AppStore] before calling this method!',
    );
    return impls.first.openAppReview();
  }
}

class AppStoreWrapper implements SmoothServiceImpl {
  AppStoreWrapper(AppStore appStore) : _appStore = appStore;
  final AppStore _appStore;

  @override
  Future<void> init() async {}

  Future<void> openAppDetails() => _appStore.openAppDetails();

  Future<bool> openAppReview() => _appStore.openAppReview();
}
