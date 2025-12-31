import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class FoodPreferencesNavigationBar extends StatelessWidget {
  const FoodPreferencesNavigationBar({
    required this.isFirstPage,
    required this.isLastPage,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
    super.key,
  });

  final bool isFirstPage;
  final bool isLastPage;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: LARGE_SPACE,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: isFirstPage
                  ? const SizedBox.shrink()
                  : SmoothSimpleButton(
                      onPressed: onPrevious,
                      buttonColor: theme.colorScheme.secondary,
                      child: Text(
                        appLocalizations.previous_label,
                        style: TextStyle(color: theme.colorScheme.onSecondary),
                      ),
                    ),
            ),
            const SizedBox(width: MEDIUM_SPACE),
            Expanded(
              child: SmoothSimpleButton(
                onPressed: isLastPage ? onFinish : onNext,
                buttonColor: theme.primaryColor,
                child: Text(
                  isLastPage
                      ? appLocalizations.finish
                      : appLocalizations.continue_label,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
