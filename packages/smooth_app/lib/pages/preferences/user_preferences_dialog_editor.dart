import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// Generic value editor
/// The result will be sent through the [Navigator]
class UserPreferencesEditValueDialog<T> extends StatefulWidget {
  const UserPreferencesEditValueDialog({
    required this.label,
    required this.initialValue,
    required this.converter,
    this.validator,
    this.keyboardType,
    this.textAlignment,
    Key? key,
  }) : super(key: key);

  /// Title of the dialog
  final String label;

  /// Mandatory field to convert between the [String] entered by the user
  /// and the expected type [T]. This is also the result passed to the
  /// [Navigator].
  final EditorValueConverter<T?> converter;

  /// Initial value of type [T], which may be null.
  /// In that case the [label] will be used as the hint.
  final T? initialValue;

  /// Current value validator.
  /// The "OK" button will be disabled until [false] is returned.
  /// Without passing this validator, all values are considered as correct.
  final EditorValueValidator<T>? validator;
  final TextInputType? keyboardType;
  final TextAlign? textAlignment;

  @override
  State<UserPreferencesEditValueDialog<T>> createState() =>
      _UserPreferencesEditValueDialogState<T>();
}

class _UserPreferencesEditValueDialogState<T>
    extends State<UserPreferencesEditValueDialog<T>> {
  late TextEditingController _controller;
  late bool _isValid;
  T? _currentValue;

  @override
  void initState() {
    super.initState();

    _currentValue = widget.initialValue;
    _controller = TextEditingController(
      text: widget.initialValue?.toString(),
    );

    _isValid = widget.validator?.call(_currentValue) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return SmoothAlertDialog(
      title: widget.label,
      body: TextField(
        autofocus: true,
        controller: _controller,
        onChanged: (String value) {
          _currentValue = widget.converter(value);

          setState(() {
            _isValid = widget.validator?.call(_currentValue) ?? true;
          });
        },
        decoration: InputDecoration(
          hintText: widget.label,
        ),
        textAlign: widget.textAlignment ?? TextAlign.start,
        keyboardType: widget.keyboardType ?? TextInputType.text,
      ),
      actions: <SmoothActionButton>[
        SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SmoothActionButton(
          text: appLocalizations.okay,
          onPressed:
              _isValid ? () => Navigator.of(context).pop(_currentValue) : null,
        )
      ],
    );
  }
}

typedef EditorValueConverter<T> = T Function(String newValue);
typedef EditorValueValidator<T> = bool Function(T? newValue);
