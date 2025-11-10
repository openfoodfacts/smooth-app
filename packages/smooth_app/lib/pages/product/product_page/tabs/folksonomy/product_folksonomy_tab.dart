import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_list_attributes_card.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/product/product_page/tabs/folksonomy/product_folksonomy_explainer.dart';

class ProductFolksonomyTab extends StatelessWidget {
  const ProductFolksonomyTab(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (BuildContext context) =>
          FolksonomyProvider(product.barcode!, context.read<LocalDatabase>()),
      child: Provider<Product>.value(
        value: product,
        child: ListView(
          padding: EdgeInsetsDirectional.zero,
          children: const <Widget>[
            FolksonomyExplanationBanner(),
            FolksonomyListAttributesCard(),
          ],
        ),
      ),
    );
  }
}
