import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Product Card when an exception is caught
class SmoothProductCardError extends StatelessWidget {
  const SmoothProductCardError({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
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
          const Icon(Icons.error_outline, color: Colors.red),
        ],
      ),
    );
  }
}
