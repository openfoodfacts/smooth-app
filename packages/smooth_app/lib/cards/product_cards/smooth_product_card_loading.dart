import 'dart:ui';
import 'package:flutter/material.dart';

class SmoothProductCardLoading extends StatelessWidget {
  const SmoothProductCardLoading({@required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(barcode),
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
