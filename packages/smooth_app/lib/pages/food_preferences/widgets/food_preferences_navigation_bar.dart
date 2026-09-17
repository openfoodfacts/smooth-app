import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

class FoodPreferencesNavigationBar extends StatelessWidget {
  const FoodPreferencesNavigationBar({
    required this.isFirstPage,
    required this.isLastPage,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
    required this.onLater,
    this.isSummaryPage = false,
    super.key,
  });

  final bool isFirstPage;
  final bool isLastPage;
  final bool isSummaryPage;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothButtonsBar2(
      positiveButton: SmoothActionButton2(
        text: _getPositiveButtonText(appLocalizations),
        onPressed: _getPositiveButtonAction(),
      ),
      negativeButton: _getNegativeButton(appLocalizations),
    );
  }

  String _getPositiveButtonText(AppLocalizations appLocalizations) {
    if (isSummaryPage) {
      return appLocalizations.validate;
    } else if (isLastPage) {
      return appLocalizations.finish;
    } else {
      return appLocalizations.continue_label;
    }
  }

  VoidCallback _getPositiveButtonAction() {
    if (isSummaryPage || isLastPage) {
      return onFinish;
    } else {
      return onNext;
    }
  }

  SmoothActionButton2? _getNegativeButton(AppLocalizations appLocalizations) {
    if (isSummaryPage) {
      return null;
    } else if (isFirstPage) {
      return SmoothActionButton2(
        text: appLocalizations.ask_me_later_button_label,
        onPressed: onLater,
      );
    } else {
      return SmoothActionButton2(
        text: appLocalizations.previous_label,
        onPressed: onPrevious,
      );
    }
  }
}
