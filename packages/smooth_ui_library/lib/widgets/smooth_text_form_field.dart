import 'package:flutter/material.dart';

enum TextFieldTypes {
  PLAIN_TEXT,
  PASSWORD,
}

class SmoothTextFormField extends StatefulWidget {
  const SmoothTextFormField({
    Key? key,
    required this.type,
    required this.controller,
    this.enabled,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.textColor,
    this.backgroundColor,
    required this.hintText,
    this.hintTextFontSize,
    this.prefixIcon,
  }) : super(key: key);

  final TextFieldTypes type;
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final Color? textColor;
  final double? hintTextFontSize;
  final Color? backgroundColor;

  @override
  State<SmoothTextFormField> createState() => _SmoothTextFormFieldState();
}

class _SmoothTextFormFieldState extends State<SmoothTextFormField> {
  bool isEmpty = true;

  @override
  Widget build(BuildContext context) {
    bool _obscureText = widget.type == TextFieldTypes.PASSWORD;
    final bool _enableSuggestions = widget.type == TextFieldTypes.PLAIN_TEXT;
    final bool _autocorrect = widget.type == TextFieldTypes.PLAIN_TEXT;

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      obscureText: _obscureText,
      enableSuggestions: _enableSuggestions,
      autocorrect: _autocorrect,
      autofillHints: widget.autofillHints,
      onChanged: (String data) {
        // Rebuilds for changing the eye icon
        if (widget.type == TextFieldTypes.PASSWORD) {
          if (data.isEmpty) {
            setState(() {});
          } else if (data.isNotEmpty && data.length > 1) {
            setState(() {});
          }
        }
      },
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        filled: true,
        hintStyle: TextStyle(
          color: widget.textColor,
          fontSize: widget.hintTextFontSize ?? 20.0,
        ),
        hintText: widget.hintText,
        fillColor: widget.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 5.0,
          ),
        ),
        suffixIcon: widget.type == TextFieldTypes.PASSWORD
            ? IconButton(
                splashRadius: 10.0,
                onPressed: () => setState(() {
                  _obscureText = !_obscureText;
                }),
                icon: _obscureText
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
              )
            : null,
      ),
    );
  }
}
