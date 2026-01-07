import 'dart:async';
import 'dart:io';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:in_app_review/in_app_review.dart';

/// Apple App Store implementation
class AppleAppStore extends AppStore {
  AppleAppStore(this.appId)
    : assert(appId.isNotEmpty),
      assert(!appId.startsWith('id')),
      assert(Platform.isIOS || Platform.isMacOS);

  final String appId;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  Future<void> openAppDetails() {
    return _inAppReview.openStoreListing(appStoreId: appId);
  }

  @override
  Future<bool> openAppReview() async {
    await _inAppReview.requestReview();
    return true;
  }

  @override
  String getEnrollInBetaURL() =>
      'https://appstoreconnect.apple.com/apps/588797948/testflight/ios';
}
