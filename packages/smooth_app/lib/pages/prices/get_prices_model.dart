import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Model that stores what we need to know for "get latest prices" queries.
class GetPricesModel {
  const GetPricesModel({
    required this.parameters,
    required this.displayOwner,
    required this.displayProduct,
    required this.uri,
    required this.title,
    this.enableCountButton = true,
    this.subtitle,
    this.addButton,
  });

  /// Gets latest prices for a product.
  factory GetPricesModel.product({
    required final Product product,
    required final BuildContext context,
  }) =>
      GetPricesModel(
        parameters: _getProductPricesParameters(product.barcode!),
        displayOwner: true,
        displayProduct: false,
        uri: _getProductPricesUri(product.barcode!),
        title: getProductNameAndBrands(
          product,
          AppLocalizations.of(context),
        ),
        subtitle: product.barcode,
        addButton: () async => ProductPriceAddPage.showProductPage(
          context: context,
          product: product,
        ),
        enableCountButton: false,
      );

  /// Gets latest prices for a barcode.
  factory GetPricesModel.barcode({
    required final String barcode,
    required final String name,
    required final BuildContext context,
  }) =>
      GetPricesModel(
        parameters: _getProductPricesParameters(barcode),
        displayOwner: true,
        displayProduct: false,
        uri: _getProductPricesUri(barcode),
        title: name,
        subtitle: barcode,
        addButton: () async => ProductPriceAddPage.showBarcodePage(
          context: context,
          barcode: barcode,
          title: name,
        ),
        enableCountButton: false,
      );

  static GetPricesParameters _getProductPricesParameters(
    final String barcode,
  ) =>
      GetPricesParameters()
        ..productCode = barcode
        ..orderBy = <OrderBy<GetPricesOrderField>>[
          const OrderBy<GetPricesOrderField>(
            field: GetPricesOrderField.created,
            ascending: false,
          ),
        ]
        ..pageSize = pageSize
        ..pageNumber = 1;

  static Uri _getProductPricesUri(
    final String barcode,
  ) =>
      OpenPricesAPIClient.getUri(
        path: 'app/products/$barcode',
        uriHelper: ProductQuery.uriProductHelper,
      );

  /// Query parameters.
  final GetPricesParameters parameters;

  /// Should we display the owner for each price? No if it's an owner query.
  final bool displayOwner;

  /// Should we display the product for each price? No if it's a product query.
  final bool displayProduct;

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

  static const int pageSize = 10;
}
