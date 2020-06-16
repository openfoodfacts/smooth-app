
import 'package:flutter/material.dart';

class SmoothMainButton extends StatelessWidget {

  const SmoothMainButton({@required this.text, @required this.onPressed});

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.black,
      textColor: Colors.white,
      child: Text(text),
      height: 56.0,
      minWidth: double.infinity,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      onPressed: () => onPressed(),
    );
  }
}