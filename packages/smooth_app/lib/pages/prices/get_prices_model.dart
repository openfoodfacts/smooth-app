import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Model that stores what we need to know for "get latest prices" queries.
class GetPricesModel {
  const GetPricesModel({
    required this.parameters,
    this.displayEachOwner = true,
    this.displayEachProduct = true,
    this.displayEachLocation = true,
    required this.uri,
    required this.title,
    this.lazyCounterPrices,
    this.enableCountButton = true,
    this.subtitle,
    this.addButton,
  });

  /// Gets latest prices for a product.
  factory GetPricesModel.product({
    required final PriceMetaProduct product,
    required final BuildContext context,
  }) => GetPricesModel(
    parameters: getStandardPricesParameters()..productCode = product.barcode,
    displayEachProduct: false,
    uri: OpenPricesAPIClient.getUri(
      path: 'products/${product.barcode}',
      uriHelper: ProductQuery.uriPricesHelper,
    ),
    title: product.getName(AppLocalizations.of(context)),
    subtitle: product.barcode,
    addButton: () async => ProductPriceAddPage.showProductPage(
      context: context,
      product: product,
      proofType: ProofType.priceTag,
    ),
    enableCountButton: false,
  );

  static GetPricesParameters getStandardPricesParameters() =>
      GetPricesParameters()
        ..orderBy = const <OrderBy<GetPricesOrderField>>[
          OrderBy<GetPricesOrderField>(
            field: GetPricesOrderField.created,
            ascending: false,
          ),
          OrderBy<GetPricesOrderField>(
            field: GetPricesOrderField.date,
            ascending: false,
          ),
        ]
        ..pageSize = 10
        ..pageNumber = 1;

  /// Query parameters.
  final GetPricesParameters parameters;

  /// Should we display the owner for each price? No if it's an owner query.
  final bool displayEachOwner;

  /// Should we display the product for each price? No if it's a product query.
  final bool displayEachProduct;

  /// Should we display the location for each price? No if it's a location query.
  final bool displayEachLocation;

  /// Related web app URI.
  final Uri uri;

  /// Page title.
  final String title;

  /// Page subtitle.
  final String? subtitle;

  /// "Add a price" callback.
  final VoidCallback? addButton;

  /// "Enable the count button?". Typically "false" for product price pages.
  final bool enableCountButton;

  /// Lazy Counter to refresh.
  final LazyCounterPrices? lazyCounterPrices;
}
