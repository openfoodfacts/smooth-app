import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Ingredient.dart';
//import 'package:openfoodfacts/model/Product.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:provider/provider.dart';
//import 'package:smooth_app/data_models/product_preferences.dart';

/// Page for editing the ingredients of a product.
class EditIngredientsPage extends StatelessWidget {
  const EditIngredientsPage({
    required this.ingredients,
  });

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    //final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    print('justin ingredients $ingredients');

    return Scaffold(
      appBar: AppBar(
        // TODO(justinmc): Localize this text.
        title: const Text('Edit a product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            // TODO(justinmc): Localize this text.
            tooltip: 'Save',
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
