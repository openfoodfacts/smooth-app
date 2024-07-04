import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

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
  }) async =>
      showDialog<bool>(
        context: context,
        builder: (final BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            close: true,
            actionsAxis: Axis.vertical,
            body:
                Text(appLocalizations.edit_product_form_item_exit_confirmation),
            title: title ?? appLocalizations.edit_product_label,
            negativeAction: SmoothActionButton(
              text: appLocalizations
                  .edit_product_form_item_exit_confirmation_negative_button,
              onPressed: () => Navigator.pop(context, false),
            ),
            positiveAction: SmoothActionButton(
              text: appLocalizations
                  .edit_product_form_item_exit_confirmation_positive_button,
              onPressed: () => Navigator.pop(context, true),
            ),
            actionsOrder: SmoothButtonsBarOrder.numerical,
          );
        },
      );
}
