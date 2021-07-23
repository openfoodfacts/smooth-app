import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    required this.text,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
    this.important = true,
    Key? key,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;
  final bool important;

  @override
  Widget build(BuildContext context) => MaterialButton(
        color: important
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSecondary,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: important
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.secondary,
                ),
          ),
        ),
        height: height,
        minWidth: minWidth,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        onPressed: () => onPressed(),
      );
}
