import 'package:flutter/material.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';


class SmoothAlertDialog extends StatelessWidget {

  const SmoothAlertDialog({
    @required this.body,
    @required this.actions,
    this.height,
  });

  final Widget body;
  final List<SmoothSimpleButton> actions;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height,
            child: body,
          ),
        ]
      ),



      actions: [
        SizedBox(
          height: 58,
            width: MediaQuery.of(context).size.width,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Credits to https://stackoverflow.com/a/64697189/13313941
                children: actions,
            ),
        ),



      ],
    );
  }
}