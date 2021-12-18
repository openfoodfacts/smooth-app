import 'package:flutter/material.dart';

enum TextFieldTypes {
  PLAIN_TEXT,
  PASSWORD,
  EMAIL,
}

class SmoothTextFormField extends StatefulWidget {
  const SmoothTextFormField({
    Key? key,
    required this.type,
    this.controller,
    this.enabled,
    this.textInputAction,
    this.validator,
    this.textColor,
    this.backgroundColor,
  }) : super(key: key);

  final TextFieldTypes type;
  final TextEditingController? controller;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  State<SmoothTextFormField> createState() => _SmoothTextFormFieldState();
}

class _SmoothTextFormFieldState extends State<SmoothTextFormField> {
  late bool _obscureText;
  late final bool _enableSuggestions;
  late final bool _autocorrect;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == TextFieldTypes.PASSWORD;
    _enableSuggestions = widget.type == TextFieldTypes.PLAIN_TEXT;
    _autocorrect = widget.type == TextFieldTypes.PLAIN_TEXT;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      obscureText: _obscureText,
      enableSuggestions: _enableSuggestions,
      autocorrect: _autocorrect,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        filled: true,
        hintStyle: TextStyle(
          color: widget.textColor,
          fontSize: 20.0,
        ),
        hintText: 'Login',
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
                icon: const Icon(Icons.remove_red_eye),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
