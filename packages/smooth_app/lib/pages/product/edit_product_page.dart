import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  // TODO(monsieurtanuki): translations
  int _changes = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.productName ?? appLocalizations.unknownProductName,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // cf. https://stackoverflow.com/questions/51927885/flutter-back-button-with-return-data
          // we want the same returned value for the app back button and the android back button
          final bool result = _changes > 0;
          Navigator.pop(context, result);
          return result;
        },
        child: ListView(
          children: <ListTile>[
            _getListTile(
              title: 'Basic details',
              subtitle: 'Product name, brand, quantity',
            ),
            _getListTile(
              title: 'Photos',
              subtitle: 'Add or refresh photos',
            ),
            _getListTile(
              title: 'Labels & Certifications',
              subtitle: 'Environmental, Quality labels, ...',
            ),
            _getListTile(
              title: 'Ingredients & Origins',
            ),
            _getListTile(
              title: 'Packaging',
            ),
            _getListTile(
              title: 'Nutrition facts',
              subtitle: 'Nutrition, alcohol content, ...',
              onTap: () async {
                final OrderedNutrientsCache? cache =
                    await OrderedNutrientsCache.getCache(context);
                if (cache == null) {
                  return;
                }
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => NutritionPageLoaded(
                      widget.product,
                      cache.orderedNutrients,
                    ),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            )
          ],
        ),
      ),
    );
  }

  ListTile _getListTile({
    required final String title,
    final String? subtitle,
    final VoidCallback? onTap,
  }) =>
      ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        leading: ElevatedButton(
          child: const Text('Edit'),
          onPressed: onTap,
        ),
      );
}
