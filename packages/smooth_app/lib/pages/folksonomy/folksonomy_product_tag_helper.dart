import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Helper around Folksonomy's [ProductTag].
class FolksonomyProductTagHelper {
  FolksonomyProductTagHelper(this.productTag);

  final ProductTag productTag;

  bool isAnUrl() => productTag.value.startsWith('https://');

  Future<void> visitUrl(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: 'Open external link',
        body: Column(
          spacing: SMALL_SPACE,
          children: [
            Text('About to open the following external link:'),
            Text(productTag.value),
            Text(
              'External links may be unsafe. Do you really want to visit it?',
            ),
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
    await LaunchUrlHelper.launchURL(productTag.value);
  }
}
