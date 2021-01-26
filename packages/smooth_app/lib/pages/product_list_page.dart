import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:openfoodfacts/model/Product.dart';

import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage(
    this.productList, {
    this.unique = true,
    this.reverse = false,
  });

  final ProductList productList;
  final bool unique;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<bool>(
      future: daoProductList.get(productList),
      builder:
          (final BuildContext context, final AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<Product> products = _compact(productList.getList());

          return Scaffold(
            appBar: AppBar(
              title: Text(
                ProductQueryPageHelper.getProductListLabel(productList),
                style: TextStyle(color: colorScheme.onBackground),
              ),
              iconTheme: IconThemeData(color: colorScheme.onBackground),
            ),
            floatingActionButton: products.isEmpty
                ? null
                : FloatingActionButton(
                    child: SvgPicture.asset(
                      'assets/actions/smoothie.svg',
                      width: 24.0,
                      height: 24.0,
                      color: colorScheme.onSecondary,
                    ),
                    onPressed: () => Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            PersonalizedRankingPage(productList),
                      ),
                    ),
                  ),
            body: products.isEmpty
                ? Center(
                    child: Text('There is no product in this list',
                        style: Theme.of(context).textTheme.subtitle1),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: SmoothProductCardFound(
                          backgroundColor: Colors.white,
                          heroTag: products[index].barcode,
                          product: products[index],
                        ),
                      );
                    },
                  ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  List<Product> _compact(final List<Product> products) {
    if (!unique) {
      if (!reverse) {
        return products;
      }
      final List<Product> result = <Product>[];
      products.reversed.forEach(result.add);
      return result;
    }
    final List<Product> result = <Product>[];
    final Set<String> barcodes = <String>{};
    final Iterable<Product> iterable = reverse ? products.reversed : products;
    for (final Product product in iterable) {
      final String barcode = product.barcode;
      if (barcodes.contains(barcode)) {
        continue;
      }
      barcodes.add(barcode);
      result.add(product);
    }
    return result;
  }
}
