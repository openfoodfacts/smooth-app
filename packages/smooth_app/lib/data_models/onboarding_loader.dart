import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Helper around data we download, store and reuse at onboarding.
class OnboardingLoader {
  OnboardingLoader(this._localDatabase);

  final LocalDatabase _localDatabase;

  /// To be called first thing when we click on "next" during onboarding.
  ///
  /// The [page] parameter refers to the current page (before the next).
  Future<void> runAtNextTime(
    final OnboardingPage page,
    final BuildContext context,
  ) async {
    switch (page) {
      case OnboardingPage.WELCOME:
        await LoadingDialog.run<bool>(
          context: context,
          future: _downloadData().timeout(const Duration(seconds: 4)),
          title: AppLocalizations.of(context)
              .onboarding_welcome_loading_dialog_title,
          dismissible: false,
        );
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.HOME_PAGE:
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
      case OnboardingPage.ECO_CARD_EXAMPLE:
      case OnboardingPage.PREFERENCES_PAGE:
      case OnboardingPage.PERMISSIONS_PAGE:
        // that was the last page of onboarding: after that, we clean up
        await _unloadData();
        return;
      case OnboardingPage.ONBOARDING_COMPLETE:
        // will never happen: we never click "next" on a "complete" page
        return;
    }
  }

  /// Actual download of all data.
  Future<bool> _downloadData() async =>
      OnboardingDataProduct.forProduct(_localDatabase).downloadData();

  /// Unloads all data that are no longer required.
  Future<void> _unloadData() async =>
      OnboardingDataProduct.forProduct(_localDatabase).clear();
}
