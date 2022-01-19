import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/onboarding_data_knowledge_panels.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

/// Helper around data we download, store and reuse at onboarding.
class OnboardingLoader {
  OnboardingLoader(this._localDatabase);

  final LocalDatabase _localDatabase;

  /// To be called first thing when we click on "next" during onboarding.
  Future<void> runAtNextTime(
    final OnboardingPage page,
    final BuildContext context,
  ) async {
    switch (page) {
      case OnboardingPage.WELCOME:
        await _loadDialog(context);
        return;
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.SCAN_EXAMPLE:
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
      case OnboardingPage.ECO_CARD_EXAMPLE:
      case OnboardingPage.PREFERENCES_PAGE:
        return;
      case OnboardingPage.ONBOARDING_COMPLETE:
        await _unloadData();
        return;
    }
  }

  /// Displays "downloading" dialog while actually downloading
  Future<void> _loadDialog(final BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        _downloadData().then<void>(
          (_) => _popDialog(context),
        );
        return _getDialog(context);
      },
    );
  }

  /// Is the dialog already pop'ed?
  bool _popEd = false;

  void _popDialog(final BuildContext context) {
    if (_popEd) {
      return;
    }
    _popEd = true;
    // Here we use the root navigator so that we can pop dialog while using multiple navigators.
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Displayed dialog during download.
  Widget _getDialog(final BuildContext context) => SmoothAlertDialog(
        close: false,
        body: const ListTile(
          leading: CircularProgressIndicator(),
          title:
              Text('Loading internet data'), // TODO(monsieurtanuki): localize
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: 'stop',
            onPressed: () => _popDialog(context),
          ),
        ],
      );

  /// Actual download of all data.
  Future<void> _downloadData() async {
    await OnboardingDataProduct(_localDatabase).downloadData();
    await OnboardingDataKnowledgePanels(_localDatabase).downloadData();
  }

  /// Unloads all data that are no longer required.
  Future<void> _unloadData() async {
    await OnboardingDataProduct(_localDatabase).clear();
    await OnboardingDataKnowledgePanels(_localDatabase).clear();
  }
}
