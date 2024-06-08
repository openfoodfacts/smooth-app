import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Model that stores what we need to know for "get latest prices" queries.
class GetPricesModel {
  const GetPricesModel({
    required this.parameters,
    required this.displayOwner,
    required this.displayProduct,
    required this.uri,
    required this.title,
    this.subtitle,
    this.addButton,
  });

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

  static const int pageSize = 10;
}
