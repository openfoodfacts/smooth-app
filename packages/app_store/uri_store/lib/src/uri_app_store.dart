import 'dart:async';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:url_launcher/url_launcher.dart';

class URIAppStore extends AppStore {
  const URIAppStore(this.appUri, {this.appReviewUri});

  final Uri appUri;
  final Uri? appReviewUri;

  @override
  Future<void> openAppDetails() {
    return launchUrl(appUri);
  }

  @override
  Future<bool> openAppReview() {
    return launchUrl(appReviewUri ?? appUri);
  }
}
