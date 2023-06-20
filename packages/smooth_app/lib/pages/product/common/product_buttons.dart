import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// A button bar containing two actions : Save and Cancel
/// To ensure a fully working scroll, please set the [fixKeyboard] attribute in
/// the [SmoothScaffold] to [true]
class ProductBottomButtonsBar extends StatelessWidget {
  const ProductBottomButtonsBar({
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SafeArea(
      child: SmoothActionButtonsBar(
        axis: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
        positiveAction: SmoothActionButton(
          text: appLocalizations.save,
          onPressed: onSave,
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: onCancel,
        ),
      ),
    );
  }
}
