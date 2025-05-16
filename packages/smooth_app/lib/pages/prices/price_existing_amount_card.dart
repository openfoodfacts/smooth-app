import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_existing_amount_field.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays an existing amount.
class PriceExistingAmountCard extends StatefulWidget {
  const PriceExistingAmountCard(
    this.price,
  );

  final Price price;

  @override
  State<PriceExistingAmountCard> createState() =>
      _PriceExistingAmountCardState();
}

class _PriceExistingAmountCardState extends State<PriceExistingAmountCard> {
  String? _categoryTag;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _categoryTag = widget.price.categoryTag;
    unawaited(_loadCategoryName());
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDiscounted = widget.price.priceIsDiscounted ?? false;
    return SmoothCardWithRoundedHeader(
      // TODO(monsieurtanuki): localize
      title: 'Price previously added',
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
          if (_categoryName != null || _categoryTag != null)
            ListTile(
              title: Text((_categoryName ?? _categoryTag)!),
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
