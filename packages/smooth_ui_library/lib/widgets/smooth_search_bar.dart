import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmoothSearchBar extends StatelessWidget {
  const SmoothSearchBar({
    this.controller,
    this.hintText,
    this.shadowColor = Colors.black,
    this.textColor = Colors.black,
    this.borderRadius = 20.0,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final Color shadowColor;
  final Color textColor;
  final double borderRadius;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: 24.0,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      shadowColor: shadowColor.withAlpha(160),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              borderSide: BorderSide.none),
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.subtitle1,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/navigation/search.svg',
              color: Colors.grey,
            ),
          ),
          focusColor: surface,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
