import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton(
      {@required this.text, @required this.onPressed, this.width, this.height});

  final String text;
  final Function onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.secondary,
        child: Text(text, style: Theme.of(context).textTheme.bodyText2
            .copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSecondary),
        ),
        height: height,
        minWidth: double.infinity,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
        ),
        onPressed: () => onPressed(),
      ),
    );
  }
}
