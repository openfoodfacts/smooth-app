import 'package:flutter/widgets.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

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

    return SmoothButtonsBar2(
      positiveButton: SmoothActionButton2(
        text: appLocalizations.save,
        onPressed: onSave,
      ),
      negativeButton: SmoothActionButton2(
        text: appLocalizations.cancel,
        onPressed: onCancel,
      ),
    );
  }
}
