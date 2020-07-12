import 'package:flutter/material.dart';
import 'package:smooth_app/generated/l10n.dart';

class OrganizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(S.of(context).organizationPage),
      ),
    );
  }
}
