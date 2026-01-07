import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Helper class about the "You're leaving the page with unsaved changes" case.
class MayExitPageHelper {
  /// Opens a confirmation dialog about saving the changes before leaving.
  ///
  /// Returned values:
  /// * `null` means the user's dismissed the dialog and doesn't want to leave.
  /// * `true` means the user wants to save the changes and leave.
  /// * `false` means the user wants to ignore the changes and leave.
  Future<bool?> openSaveBeforeLeavingDialog(
    final BuildContext context, {
    final String? title,
    final bool unfocus = true,
  }) async {
    if (unfocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return showSmoothAlertModalSheet<bool>(
      context: context,
      title: title ?? appLocalizations.edit_product_form_item_exit_title,
      message: Text(appLocalizations.edit_product_form_item_exit_confirmation),
      type: SmoothModalSheetType.error,
      actionLabels: <String>[
        appLocalizations
            .edit_product_form_item_exit_confirmation_positive_button,
        appLocalizations
            .edit_product_form_item_exit_confirmation_negative_button,
      ],
      actionIcons: <Widget>[
        Icon(Icons.save_rounded, color: extension.success),
        Icon(Icons.cancel_rounded, color: extension.error),
      ],
      actionValues: <bool>[true, false],
    );
  }
}
