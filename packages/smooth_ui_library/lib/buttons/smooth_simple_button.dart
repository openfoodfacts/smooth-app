import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    @required this.text,
    @required this.onPressed,
    this.width,
    this.height,
    this.important = true,
  });

  final String text;
  final Function onPressed;
  final double width;
  final double height;
  final bool important;

  @override
  Widget build(BuildContext context) => MaterialButton(
        color: important
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSecondary,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: important
                    ? Theme.of(context).colorScheme.onSecondary
                    : Theme.of(context).colorScheme.secondary,
              ),
        ),
        height: height,
        minWidth: width,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        onPressed: () => onPressed(),
      );
}
