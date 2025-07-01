import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_existing_amount_field.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays an existing amount.
class PriceExistingAmountCard extends StatefulWidget {
  const PriceExistingAmountCard(this.price);

  final Price price;

  @override
  State<PriceExistingAmountCard> createState() =>
      _PriceExistingAmountCardState();
}

class _PriceExistingAmountCardState extends State<PriceExistingAmountCard> {
  String? _categoryTag;
  String? _categoryName;
  List<String>? _originTags;
  List<String>? _originNames;

  @override
  void initState() {
    super.initState();
    _categoryTag = widget.price.categoryTag;
    _originTags = widget.price.originsTags;
    unawaited(_loadCategoryName());
    unawaited(_loadOriginNames());
  }

  Future<void> _loadCategoryName() async {
    if (_categoryTag == null) {
      return;
    }
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final Map<String, TaxonomyCategory>? map =
        await OpenFoodAPIClient.getTaxonomyCategories(
          TaxonomyCategoryQueryConfiguration(
            tags: <String>[_categoryTag!],
            country: ProductQuery.getCountry(),
            languages: <OpenFoodFactsLanguage>[language],
            fields: <TaxonomyCategoryField>[TaxonomyCategoryField.NAME],
            includeChildren: false,
          ),
        );
    if (map == null) {
      return;
    }
    final TaxonomyCategory? category = map[_categoryTag];
    if (category == null) {
      return;
    }
    final Map<OpenFoodFactsLanguage, String>? categoryNames = category.name;
    if (categoryNames == null || categoryNames.isEmpty) {
      return;
    }
    _categoryName = categoryNames[language];
    if (_categoryName != null) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadOriginNames() async {
    if (_originTags == null || _originTags!.isEmpty) {
      return;
    }
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final Map<String, TaxonomyOrigin>? map =
        await OpenFoodAPIClient.getTaxonomyOrigins(
          TaxonomyOriginQueryConfiguration(
            tags: _originTags!,
            country: ProductQuery.getCountry(),
            languages: <OpenFoodFactsLanguage>[language],
            fields: <TaxonomyOriginField>[TaxonomyOriginField.NAME],
            includeChildren: false,
          ),
        );
    if (map == null) {
      return;
    }
    final List<String> result = <String>[];
    for (final String originTag in _originTags!) {
      String? toBeAdded;
      final TaxonomyOrigin? origin = map[originTag];
      if (origin != null) {
        final Map<OpenFoodFactsLanguage, String>? names = origin.name;
        if (names != null && names.isNotEmpty) {
          toBeAdded ??= names[language];
        }
      }
      toBeAdded ??= originTag;
      result.add(toBeAdded);
    }
    _originNames = result;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDiscounted = widget.price.priceIsDiscounted ?? false;
    final String? category = _categoryName ?? _categoryTag;
    final String? origins = _originNames?.join(', ') ?? _originTags?.join(', ');
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_amount_existing_subtitle,
      leading: const Icon(Icons.history),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: SMALL_SPACE,
      ),
      child: Column(
        children: <Widget>[
          if (widget.price.product != null)
            PriceProductListTile(
              product: PriceMetaProduct.priceProduct(widget.price.product!),
            ),
          if (category != null || origins != null)
            ListTile(
              title: category == null ? null : Text(category),
              subtitle: origins == null ? null : Text(origins),
            ),
          SwitchListTile(
            value: isDiscounted,
            onChanged: null,
            title: Text(appLocalizations.prices_amount_is_discounted),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            children: <Widget>[
              Expanded(
                child: PriceExistingAmountField(
                  value: widget.price.price,
                  pricePer: widget.price.pricePer,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !isDiscounted
                    ? Container()
                    : PriceExistingAmountField(
                        value: widget.price.priceWithoutDiscount,
                        pricePer: widget.price.pricePer,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
