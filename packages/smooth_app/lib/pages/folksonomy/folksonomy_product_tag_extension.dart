import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Extension on Folksonomy's [ProductTag].
extension FolksonomyProductTagExtension on ProductTag {
  bool isAnUrl() => value.startsWith('https://');

  Future<void> visitUrl(final BuildContext context) async {
    if (!isAnUrl()) {
      // Not supposed to happen
      return;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.folksonomy_action_external_link_title,
        body: Column(
          spacing: SMALL_SPACE,
          children: <Widget>[
            Text(value, style: const TextStyle(color: Colors.blue)),
            Text(appLocalizations.folksonomy_action_external_link_warning),
          ],
        ),
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context),
          text: appLocalizations.cancel,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context, true),
          text: appLocalizations.yes,
        ),
      ),
    );
    if (accepted != true) {
      return;
    }
    await LaunchUrlHelper.launchURL(value);
  }
}
