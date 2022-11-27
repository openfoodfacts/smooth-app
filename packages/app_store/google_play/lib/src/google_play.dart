import 'dart:io';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:in_app_review/in_app_review.dart';

/// Google Play implementation
class GooglePlayStore extends AppStore {
  GooglePlayStore() : assert(Platform.isAndroid);

  final InAppReview _inAppReview = InAppReview.instance;

  @override
  Future<void> openAppDetails() {
    return _inAppReview.openStoreListing();
  }

  @override
  Future<bool> openAppReview() async {
    await _inAppReview.requestReview();
    return true;
  }
}
