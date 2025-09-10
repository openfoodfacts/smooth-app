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
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
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

enum ProductRankingMethod {
  personalScore,
  nutriScore,
  ecoScore,
}

extension ProductRankingMethodExtension on ProductRankingMethod {
  String getDisplayName(AppLocalizations appLocalizations) {
    switch (this) {
      case ProductRankingMethod.personalScore:
        return 'Personal Score';
      case ProductRankingMethod.nutriScore:
        return 'Nutri-Score';
      case ProductRankingMethod.ecoScore:
        return 'Eco-Score';
    }
  }
}

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

  // Ranking system
  ProductRankingMethod _rankingMethod = ProductRankingMethod.personalScore;
  List<Product> _sortedProducts = <Product>[];

  @override
  void initState() {
    super.initState();
    _sortedProducts = List<Product>.from(widget.products);
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
    
    // Sort products based on current ranking method
    _sortProductsByRanking(productPreferences);
    
    final List<List<Attribute>> scoreAttributesArray = <List<Attribute>>[];
    for (final Product product in _sortedProducts) {
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
      for (int i = 0; i < _sortedProducts.length; i++) {
        final Product product = _sortedProducts[i];
        // Find the nutrition container for this specific product
        final int originalIndex = widget.products.indexOf(product);
        final NutritionContainerHelper nutritionContainer = _nutritionContainers[originalIndex];
        final double? value = nutritionContainer.getValue(nutrient);
        values.add(value);
        if (value != null) {
          notNull = true;
        }
      }
      if (notNull) {
        nutrientValues.add(_getNutrientRow(
          values: values,
          nutrient: nutrient,
          orderedNutrient: orderedNutrient,
        ));
      }
    }
    return SmoothScaffold(
      contentBehindStatusBar: true,
      spaceBehindStatusBar: false,
      statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
      appBar: SmoothAppBar(
        title: Text('Compare ${_sortedProducts.length} products'),
        actions: [
          PopupMenuButton<ProductRankingMethod>(
            icon: const Icon(Icons.sort),
            onSelected: (ProductRankingMethod method) {
              setState(() {
                _rankingMethod = method;
              });
            },
            itemBuilder: (BuildContext context) {
              return ProductRankingMethod.values.map((ProductRankingMethod method) {
                return PopupMenuItem<ProductRankingMethod>(
                  value: method,
                  child: Row(
                    children: [
                      if (_rankingMethod == method)
                        const Icon(Icons.check, size: 16.0),
                      if (_rankingMethod != method)
                        const SizedBox(width: 16.0),
                      const SizedBox(width: 8.0),
                      Text(method.getDisplayName(appLocalizations)),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Fixed header section
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Ranking by: ${_rankingMethod.getDisplayName(appLocalizations)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8.0),
                // Horizontal scrollable area for scores and products
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < _sortedProducts.length; i++)
                          SizedBox(
                            width: 150,
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  color: ProductCompatibilityHelper.product(
                                    MatchedProductV2(
                                      _sortedProducts[i],
                                      productPreferences,
                                    ),
                                  ).getColor(context),
                                  child: Center(
                                    child: Text(
                                      MatchedProductV2(
                                        _sortedProducts[i],
                                        productPreferences,
                                      ).score.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Expanded(
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SmoothMainProductImage(
                                            product: _sortedProducts[i],
                                            width: 60,
                                            height: 60,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Expanded(
                                            child: Text(
                                              getProductName(_sortedProducts[i], appLocalizations),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.0,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            getProductBrands(_sortedProducts[i], appLocalizations),
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_sortedProducts[i].quantity != null && 
                                              _sortedProducts[i].quantity!.isNotEmpty)
                                            Text(
                                              _sortedProducts[i].quantity!,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Add product buttons
                        _buildAddProductButtons(context, appLocalizations),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Scrollable comparison content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < scoreAttributesArray.first.length; i++)
                      _getAttributeRow(
                        attributesArray: scoreAttributesArray,
                        index: i,
                        products: _sortedProducts,
                      ),
                    ...nutrientValues,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
    bool hasUnknownAttribute = false;
    
    for (int i = 0; i < widget.products.length; i++) {
      final Attribute attribute = attributesArray[i][index];
      title = attribute.name!;
      final Product product = products[i];
      
      // Check if this attribute has unknown status for any product
      if (attribute.status == AttributeStatus.UNKNOWN) {
        hasUnknownAttribute = true;
      }
      
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
          child: AutoSizeText(
            hasUnknownAttribute ? '$title (?)' : title,
            maxLines: 2,
          ),
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
    required final OrderedNutrient orderedNutrient,
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
          child: AutoSizeText(
            orderedNutrient.name ?? nutrient.name,
            maxLines: 2,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ],
    );
  }

  void _sortProductsByRanking(ProductPreferences productPreferences) {
    _sortedProducts.sort((Product a, Product b) {
      switch (_rankingMethod) {
        case ProductRankingMethod.personalScore:
          final MatchedProductV2 matchedA = MatchedProductV2(a, productPreferences);
          final MatchedProductV2 matchedB = MatchedProductV2(b, productPreferences);
          // Higher scores first (best on left)
          return matchedB.score.compareTo(matchedA.score);
          
        case ProductRankingMethod.nutriScore:
          final String? scoreA = a.nutriscore;
          final String? scoreB = b.nutriscore;
          if (scoreA == null && scoreB == null) return 0;
          if (scoreA == null) return 1; // Null scores go to the right
          if (scoreB == null) return -1;
          // A is best, E is worst
          return scoreA.compareTo(scoreB);
          
        case ProductRankingMethod.ecoScore:
          final String? scoreA = a.ecoscoreGrade;
          final String? scoreB = b.ecoscoreGrade;
          if (scoreA == null && scoreB == null) return 0;
          if (scoreA == null) return 1; // Null scores go to the right
          if (scoreB == null) return -1;
          // A is best, E is worst
          return scoreA.compareTo(scoreB);
      }
    });
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

  Widget _buildAddProductButtons(BuildContext context, AppLocalizations appLocalizations) {
    return Row(
      children: [
        const SizedBox(width: 8.0),
        // Search button
        SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: InkWell(
                  onTap: () => _addProductBySearch(context),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Search',
                style: const TextStyle(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        // Scan button
        SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: InkWell(
                  onTap: () => _addProductByScan(context),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Scan',
                style: const TextStyle(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addProductBySearch(BuildContext context) {
    AppNavigator.of(context).push(
      AppRoutes.SEARCH,
      extra: SearchPageExtra(
        searchHelper: SearchProductHelper(),
        autofocus: true,
      ),
    );
  }

  void _addProductByScan(BuildContext context) {
    // Navigate to home page which will show the scan tab
    // This is a simplified implementation - in a full implementation
    // you might want to navigate directly to a scan page if available
    Navigator.of(context).pop();
  }
}
