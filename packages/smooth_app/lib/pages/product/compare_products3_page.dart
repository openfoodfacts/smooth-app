import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

// cf. SummaryCard
const List<String> _ATTRIBUTE_GROUP_ORDER = <String>[
  AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
  AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
  AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
  AttributeGroup.ATTRIBUTE_GROUP_LABELS,
  AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
];

/// Test page about comparing 3 products. Work in progress.
class CompareProducts3Page extends StatefulWidget {
  const CompareProducts3Page({
    required this.products,
    required this.orderedNutrientsCache,
  });

  final List<Product> products;
  final OrderedNutrientsCache orderedNutrientsCache;

  @override
  State<CompareProducts3Page> createState() => _CompareProducts3PageState();
}

class _CompareProducts3PageState extends State<CompareProducts3Page> {
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};

  static const List<String> _sortedImportances = <String>[
    PreferenceImportance.ID_MANDATORY,
    PreferenceImportance.ID_VERY_IMPORTANT,
    PreferenceImportance.ID_IMPORTANT,
  ];

  final List<NutritionContainerHelper> _nutritionContainers =
      <NutritionContainerHelper>[];

  @override
  void initState() {
    super.initState();
    for (final Product product in widget.products) {
      _nutritionContainers.add(
        NutritionContainerHelper(
          orderedNutrients: widget.orderedNutrientsCache.orderedNutrients,
          product: product,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();

    final ProductPreferences productPreferences = context
        .watch<ProductPreferences>();
    final List<List<Attribute>> scoreAttributesArray = <List<Attribute>>[];
    final List<Widget> scoreWidgets = <Widget>[];
    for (final Product product in widget.products) {
      final MatchedProductV2 matchedProduct = MatchedProductV2(
        product,
        productPreferences,
      );
      final ProductCompatibilityHelper helper =
          ProductCompatibilityHelper.product(matchedProduct);
      scoreWidgets.add(
        Expanded(
          child: Container(
            color: helper.getColor(context),
            child: Center(
              child: Text(
                matchedProduct.score.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final List<String> names = <String>[];
    final List<String> brands = <String>[];
    final List<String> quantities = <String>[];
    final List<Widget> pictures = <Widget>[];
    final Size screenSize = MediaQuery.sizeOf(context);
    for (final Product product in widget.products) {
      names.add(getProductName(product, appLocalizations));
      brands.add(getProductBrands(product, appLocalizations));
      quantities.add(product.quantity ?? '');
      pictures.add(
        Expanded(
          child: Center(
            child: SmoothMainProductImage(
              product: product,
              width: screenSize.width * 0.20,
              height: screenSize.width * 0.20,
            ),
          ),
        ),
      );
    }
    for (final Product product in widget.products) {
      final List<Attribute> tmp = <Attribute>[];
      for (final String importance in _sortedImportances) {
        final List<Attribute> attributes = getSortedAttributes(
          product,
          _ATTRIBUTE_GROUP_ORDER,
          _attributesToExcludeIfStatusIsUnknown,
          productPreferences,
          importance,
          excludeMainScoreAttributes: false,
        );
        tmp.addAll(attributes);
      }
      scoreAttributesArray.add(tmp);
    }

    final List<Widget> nutrientValues = <Widget>[];
    final NutritionContainerHelper backBone = _nutritionContainers.first;
    for (final OrderedNutrient orderedNutrient in backBone.allNutrients) {
      final Nutrient nutrient = _getNutrient(orderedNutrient);
      final List<double?> values = <double?>[];
      bool notNull = false;
      for (final NutritionContainerHelper nutritionContainer
          in _nutritionContainers) {
        final double? value = nutritionContainer.getValue(nutrient);
        values.add(value);
        if (value != null) {
          notNull = true;
        }
      }
      if (notNull) {
        nutrientValues.add(_getNutrientRow(values: values, nutrient: nutrient));
      }
    }
    return SmoothScaffold(
      contentBehindStatusBar: true,
      spaceBehindStatusBar: false,
      statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
      appBar: SmoothAppBar(
        title: Text('Compare ${widget.products.length} products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            const Center(child: Text('Personal compatibility score')),
            _getWidgetRow(scoreWidgets),
            _getTextRow(names),
            const SizedBox(height: 8.0),
            _getTextRow(brands),
            const SizedBox(height: 8.0),
            _getTextRow(quantities),
            _getWidgetRow(pictures),
            const Divider(),
            for (int i = 0; i < scoreAttributesArray.first.length; i++)
              _getAttributeRow(
                attributesArray: scoreAttributesArray,
                index: i,
                products: widget.products,
              ),
            ...nutrientValues,
          ],
        ),
      ),
    );
  }

  Row _getTextRow(final List<String> texts) => _getWidgetRow(<Widget>[
    for (final String text in texts) Expanded(child: Text(text)),
  ]);

  Row _getWidgetRow(final List<Widget> widgets) {
    final List<Widget> children = <Widget>[];
    bool first = true;
    for (final Widget widget in widgets) {
      if (first) {
        first = false;
      } else {
        children.add(const VerticalDivider());
      }
      children.add(widget);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Nutrient? _getAttributeNutrient(final String attributeId) {
    switch (attributeId) {
      case Attribute.ATTRIBUTE_LOW_FAT:
        return Nutrient.fat;
      case Attribute.ATTRIBUTE_LOW_SATURATED_FAT:
        return Nutrient.saturatedFat;
      case Attribute.ATTRIBUTE_LOW_SALT:
        return Nutrient.salt;
      case Attribute.ATTRIBUTE_LOW_SUGARS:
        return Nutrient.sugars;
    }
    return null;
  }

  Widget? _getChild(final Attribute attribute, final Product product) {
    final Nutrient? nutrient = _getAttributeNutrient(attribute.id!);
    if (nutrient != null) {
      if (product.nutriments == null) {
        return null;
      }
      final double? value = product.nutriments!.getValue(
        nutrient,
        PerSize.oneHundredGrams,
      );
      if (value == null) {
        return null;
      }
      return Text(
        '${value.toStringAsFixed(2)} ${UnitHelper.unitToString(nutrient.typicalUnit)}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      );
    }
    switch (attribute.id) {
      case Attribute.ATTRIBUTE_NOVA:
      case Attribute.ATTRIBUTE_NUTRISCORE:
      case Attribute.ATTRIBUTE_ECOSCORE:
        return SvgIconChip(attribute.iconUrl!, height: 30);
    }
    return null;
  }

  Widget _getAttributeRow({
    required final List<List<Attribute>> attributesArray,
    required final int index,
    required final List<Product> products,
  }) {
    final List<Widget> children = <Widget>[];
    late String title;
    for (int i = 0; i < widget.products.length; i++) {
      final Attribute attribute = attributesArray[i][index];
      title = attribute.name!;
      final Product product = products[i];
      Widget? child = _getChild(attribute, product);
      child = Expanded(
        child: Container(
          height: 36,
          color: getAttributeDisplayBackgroundColor(attribute),
          child: child,
        ),
      );
      final bool first = children.isEmpty;
      if (!first) {
        children.add(const VerticalDivider());
      }
      children.add(child);
    }
    return Column(
      children: <Widget>[
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: SMALL_SPACE),
          child: AutoSizeText('$title (?)', maxLines: 2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ],
    );
  }

  Widget _getNutrientRow({
    required final List<double?> values,
    required final Nutrient nutrient,
  }) {
    final List<Widget> children = <Widget>[];
    for (final double? value in values) {
      Widget? child = value == null
          ? null
          : Center(
              child: Text(
                '${value.toStringAsFixed(2)} ${UnitHelper.unitToString(nutrient.typicalUnit)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
      child = Expanded(child: SizedBox(height: 36, child: child));
      children.add(child);
    }
    return Column(
      children: <Widget>[
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: SMALL_SPACE),
          child: AutoSizeText(nutrient.name, maxLines: 2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ],
    );
  }

  Nutrient _getNutrient(final OrderedNutrient orderedNutrient) {
    if (orderedNutrient.nutrient != null) {
      return orderedNutrient.nutrient!;
    }
    if (orderedNutrient.id == 'energy') {
      return Nutrient.energyKJ;
    }
    throw Exception('unknown nutrient for "${orderedNutrient.id}"');
  }
}
