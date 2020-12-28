import 'package:flutter/material.dart';

class SmoothMainButton extends StatelessWidget {
  const SmoothMainButton({
    @required this.text,
    @required this.onPressed,
    this.minWidth = double.infinity,
    this.important = true,
  });

  final String text;
  final Function onPressed;
  final double minWidth;
  final bool important;

  @override
  Widget build(BuildContext context) => MaterialButton(
        color: important ? Colors.black : Colors.white,
        textColor: important ? Colors.white : Colors.black,
        child: Text(text),
        height: 56.0,
        minWidth: minWidth,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        onPressed: () => onPressed(),
      );
}
