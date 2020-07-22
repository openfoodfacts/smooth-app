import 'package:flutter/material.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_group_query_model.dart';

class ProductGroupQueryPage extends StatelessWidget {
  const ProductGroupQueryPage({@required this.group});

  final PnnsGroup2 group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<ProductGroupQueryModel>(
      create: (BuildContext context) => ProductGroupQueryModel(group),
      child: Consumer<ProductGroupQueryModel>(
        builder: (BuildContext context,
            ProductGroupQueryModel productGroupQueryModel, Widget child) {
          if (productGroupQueryModel.products != null) {
            return ListView.builder(
              itemCount: productGroupQueryModel.products.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 24.0),
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: SmoothProductCardFound(
                            heroTag: productGroupQueryModel
                                .products[index - 1].barcode,
                            product: productGroupQueryModel.products[index - 1],
                    elevation: 8.0)
                        .build(context),
                  );
                }
              },
            );
          } else {
            return Center(
              child: Container(
                child: const CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    ));
  }
}
