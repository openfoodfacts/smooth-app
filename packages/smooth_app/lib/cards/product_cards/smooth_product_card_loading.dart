import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothProductCardLoading extends StatelessWidget {
  const SmoothProductCardLoading({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeData.brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(barcode, style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          const SizedBox(
            height: 12.0,
          ),
          const CircularProgressIndicator()
        ],
      ),
    );
  }
}
