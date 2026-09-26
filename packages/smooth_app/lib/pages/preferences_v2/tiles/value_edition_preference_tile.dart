import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class ValueEditionPreferenceTile extends PreferenceTile {
  const ValueEditionPreferenceTile({
    required super.title,
    required String dialogAction,
    required this.onNewValue,
    super.icon,
    this.value,
    this.hint,
    this.subtitleWithEmptyValue,
    this.validator,
  }) : assert(dialogAction.length > 0),
       super(subtitleText: dialogAction);

  final String? value;
  final String? hint;
  final String? subtitleWithEmptyValue;
  final bool Function(String)? validator;
  final Function(String) onNewValue;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      trailing: const Icon(Icons.edit),
      onTap: () => _showInputTextDialog(context),
    );
  }

  Future<void> _showInputTextDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: value ?? '',
    );

    final dynamic res = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return SmoothAlertDialog(
              title: title,
              close: true,
              body: Column(
                spacing: BALANCED_SPACE,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title),
                  TextField(
                    controller: controller,
                    autocorrect: false,
                    autofocus: true,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: hint,
                      suffix: Semantics(
                        button: true,
                        label: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: () => controller.clear(),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsetsDirectional.all(SMALL_SPACE),
                            child: Icon(Icons.clear),
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: (String value) =>
                        Navigator.of(context).pop(value),
                  ),
                ],
              ),
              positiveAction: SmoothActionButton(
                text: appLocalizations.okay,
                onPressed: validator?.call(controller.text) != false
                    ? () => Navigator.of(context).pop(controller.text)
                    : null,
              ),
              negativeAction: SmoothActionButton(
                text: appLocalizations.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );

    if (res != value) {
      onNewValue.call(res);
    }
  }
}
