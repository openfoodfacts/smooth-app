import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/color_extension.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    const Color color = Color(0xFFB81D1D);

    return showSmoothListOfChoicesModalSheet<bool>(
      context: context,
      title: title ?? appLocalizations.edit_product_form_item_exit_title,
      headerBackgroundColor: color,
      header: ColoredBox(
        color: context.lightTheme(listen: false)
            ? color.lighten(0.55)
            : color.darken(0.3),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: Text(
            appLocalizations.edit_product_form_item_exit_confirmation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
      labels: <String>[
        appLocalizations
            .edit_product_form_item_exit_confirmation_positive_button,
        appLocalizations
            .edit_product_form_item_exit_confirmation_negative_button,
      ],
      values: <bool>[
        true,
        false,
      ],
      prefixIcons: <Widget>[
        Icon(Icons.save_rounded, color: extension.success),
        Icon(Icons.cancel_rounded, color: extension.error),
      ],
      dividerPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: MEDIUM_SPACE,
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      safeArea: true,
    );
  }
}
