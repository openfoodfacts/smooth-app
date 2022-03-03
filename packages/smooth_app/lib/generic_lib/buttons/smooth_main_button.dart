import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothMainButton extends StatelessWidget {
  const SmoothMainButton({
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.important = true,
    this.height = 56.0,
  });

  final String text;
  final VoidCallback onPressed;
  final double width;
  final bool important;
  final double height;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              important ? Colors.black : Colors.white),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
          ),
          minimumSize: MaterialStateProperty.all(
            Size(
              width,
              height,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: important ? Colors.white : Colors.black),
        ),
        onPressed: () => onPressed(),
      );
}
