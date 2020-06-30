
import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {

  const SmoothSimpleButton({@required this.text, @required this.onPressed, this.width, this.height});

  final String text;
  final Function onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: MaterialButton(
        color: Colors.black,
        textColor: Colors.white,
        child: Text(text),
        height: height,
        minWidth: double.infinity,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        onPressed: () => onPressed(),
      ),
    );
  }
}