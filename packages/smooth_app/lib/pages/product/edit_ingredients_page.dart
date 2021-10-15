import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:provider/provider.dart';
//import 'package:smooth_app/data_models/product_preferences.dart';

/// Page for editing the ingredients of a product.
class EditIngredientsPage extends StatelessWidget {
  const EditIngredientsPage();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.myPreferences),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: appLocalizations.reset,
            onPressed: () {
              // TODO(justinmc): Save.
            },
          ),
        ],
      ),
      body: ListView(
        children: List<Widget>.generate(
          // TODO(justinmc): Real data from somewhere.
          20,
          (int index) {
            return Text('Hello $index');
          },
        ),
      ),
    );
  }
}
