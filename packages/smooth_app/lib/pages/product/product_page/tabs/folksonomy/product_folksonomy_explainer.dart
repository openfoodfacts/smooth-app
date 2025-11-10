import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_explanation_banner.dart';

class FolksonomyExplanationBanner extends StatelessWidget {
  const FolksonomyExplanationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductPageExplanationBanner(
      title: appLocalizations.folksonomy_explanation_card_title,
      text: <String>[
        appLocalizations.folksonomy_explanation_card_line1,
        appLocalizations.folksonomy_explanation_card_line2,
      ],
      shouldShowBanner: (UserPreferences prefs) =>
          prefs.shouldShowFolksonomyExplanationCard,
      hideBanner: (UserPreferences prefs) =>
          prefs.hideFolksonomyExplanationCard(),
    );
  }
}
