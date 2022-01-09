import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';

// TODO(monsieurtanuki): load the ordered nutrients somewhere else
/// Preparatory nutrition page where data is loaded.
class NutritionPage extends StatefulWidget {
  const NutritionPage(this.product);

  final Product product;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  late Future<OrderedNutrients> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<OrderedNutrients> _init() async =>
      OpenFoodAPIClient.getOrderedNutrients(
        cc: ProductQuery.getCountry()!.iso2Code,
        language: ProductQuery.getLanguage()!,
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<OrderedNutrients>(
        future: _initFuture,
        builder:
            (BuildContext context, AsyncSnapshot<OrderedNutrients> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return NutritionPageLoaded(widget.product, snapshot.data!);
        },
      );
}
