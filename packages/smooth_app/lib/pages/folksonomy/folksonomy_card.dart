import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_explanation_card.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_list_attributes_card.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyCard extends StatelessWidget {
  const FolksonomyCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (BuildContext context) =>
          FolksonomyProvider(product.barcode!, context.read<LocalDatabase>()),
      child: Provider<Product>.value(
        value: product,
        child: const _FolksonomyCard(),
      ),
    );
  }
}

class _FolksonomyCard extends StatelessWidget {
  const _FolksonomyCard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: VERY_LARGE_SPACE,
      ),
      children: const <Widget>[
        FolksonomyExplanationCard(),
        FolksonomyListAttributesCard(),
      ],
    );
  }
}
