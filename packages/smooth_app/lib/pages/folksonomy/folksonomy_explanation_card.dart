import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class FolksonomyExplanationCard extends StatelessWidget {
  const FolksonomyExplanationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConsumerFilter<UserPreferences>(
      buildWhen: (UserPreferences? old, UserPreferences prefs) =>
          old?.shouldShowFolksonomyExplanationCard !=
          prefs.shouldShowFolksonomyExplanationCard,
      builder: (BuildContext context, UserPreferences prefs, _) {
        if (!prefs.shouldShowFolksonomyExplanationCard) {
          return EMPTY_WIDGET;
        }

        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: VERY_LARGE_SPACE),
          child: SmoothCardWithRoundedHeader(
            title: appLocalizations.folksonomy_explanation_card_title,
            leading: const icons.Compass(),
            trailing: IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: prefs.hideFolksonomyExplanationCard,
              icon: const icons.Close.bold(size: 12.0),
            ),
            contentPadding: const EdgeInsetsDirectional.only(
              start: LARGE_SPACE,
              end: LARGE_SPACE,
              top: BALANCED_SPACE,
              bottom: MEDIUM_SPACE,
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextWithBoldParts(
                text: appLocalizations.folksonomy_explanation_card_body,
                textStyle: const TextStyle(fontSize: 15.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
