import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/strings_helper.dart';

enum TextFieldTypes {
  PLAIN_TEXT,
  PASSWORD,
}

class SmoothTextFormField extends StatefulWidget {
  const SmoothTextFormField({
    super.key,
    required this.type,
    required this.controller,
    this.enabled,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    required this.hintText,
    this.hintTextFontSize,
    this.prefixIcon,
    this.textInputType,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus,
    this.focusNode,
    this.spellCheckConfiguration,
    this.allowEmojis = true,
  });

  final TextFieldTypes type;
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final double? hintTextFontSize;
  final TextInputType? textInputType;
  final void Function(String?)? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? autofocus;
  final FocusNode? focusNode;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final bool allowEmojis;

  @override
  State<SmoothTextFormField> createState() => _SmoothTextFormFieldState();
}

class _SmoothTextFormFieldState extends State<SmoothTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.type == TextFieldTypes.PASSWORD;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableSuggestions = widget.type == TextFieldTypes.PLAIN_TEXT;
    final bool autocorrect = widget.type == TextFieldTypes.PLAIN_TEXT;
    final TextStyle textStyle = DefaultTextStyle.of(context).style;
    final double textSize =
        widget.hintTextFontSize ?? textStyle.fontSize ?? 20.0;
    final AppLocalizations appLocalization = AppLocalizations.of(context);

    return TextFormField(
      keyboardType: widget.textInputType,
      controller: widget.controller,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      obscureText: _obscureText,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      autofocus: widget.autofocus ?? false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged ??
          (String data) {
            // Rebuilds for changing the eye icon
            if (widget.type == TextFieldTypes.PASSWORD && data.length != 1) {
              setState(() {});
            }
          },
      spellCheckConfiguration: widget.spellCheckConfiguration ??
          const SpellCheckConfiguration.disabled(),
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(fontSize: textSize),
      cursorHeight: textSize * (textStyle.height ?? 1.4),
      inputFormatters: <TextInputFormatter>[
        if (!widget.allowEmojis)
          FilteringTextInputFormatter.deny(TextHelper.emojiRegex),
      ],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LARGE_SPACE,
          vertical: SMALL_SPACE,
        ),
        prefixIcon: widget.prefixIcon,
        filled: true,
        hintStyle: TextStyle(
          fontSize: textSize,
          overflow: TextOverflow.ellipsis,
        ),
        hintText: widget.hintText,
        hintMaxLines: 2,
        border: const OutlineInputBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 5.0,
          ),
        ),
        suffixIcon: widget.type == TextFieldTypes.PASSWORD
            ? IconButton(
                tooltip: appLocalization.show_password,
                splashRadius: 10.0,
                onPressed: () => setState(() {
                  _obscureText = !_obscureText;
                }),
                icon: _obscureText
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
              )
            : null,
        errorMaxLines: 2,
      ),
    );
  }
}
