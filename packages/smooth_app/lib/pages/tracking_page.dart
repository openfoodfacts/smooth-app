import 'package:flutter/material.dart';
import 'package:smooth_app/generated/l10n.dart';

class TrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(S.of(context).trackingPage),
      ),
    );
  }
}
