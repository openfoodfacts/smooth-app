import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/category_card.dart';
import 'package:smooth_app/cards/category_cards/category_chip.dart';
import 'package:smooth_app/cards/category_cards/subcategory_card.dart';
import 'package:smooth_app/database/group_product_query.dart';
import 'package:smooth_app/database/keywords_product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/product_page.dart';

class ChoosePage extends StatefulWidget {
  const ChoosePage({Key? key}) : super(key: key);

  @override
  State<ChoosePage> createState() => _ChoosePageState();

  static Future<void> onSubmitted(
    final String value,
    final BuildContext context,
    final LocalDatabase localDatabase,
  ) async {
    if (int.tryParse(value) != null) {
      final ProductDialogHelper productDialogHelper = ProductDialogHelper(
        barcode: value,
        context: context,
        localDatabase: localDatabase,
        refresh: false,
      );
      final Product? product = await productDialogHelper.openBestChoice();
      if (product == null) {
        productDialogHelper.openProductNotFoundDialog();
        return;
      }
      Navigator.push<Widget>(
        context,
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => ProductPage(
            product: product,
          ),
        ),
      );
      return;
    }
    await ProductQueryPageHelper().openBestChoice(
      color: Colors.deepPurple,
      heroTag: 'search_bar',
      name: value,
      localDatabase: localDatabase,
      productQuery: KeywordsProductQuery(
        keywords: value,
        languageCode: ProductQuery.getCurrentLanguageCode(context),
        countryCode: ProductQuery.getCurrentCountryCode(),
        size: 500,
      ),
      context: context,
    );
  }
}

class _ChoosePageState extends State<ChoosePage> {
  static const Map<PnnsGroup1, String> _CATEGORY_ICONS = <PnnsGroup1, String>{
    PnnsGroup1.BEVERAGES: 'beverages.svg',
    PnnsGroup1.CEREALS_AND_POTATOES: 'cereals_and_potatoes.svg',
    PnnsGroup1.COMPOSITE_FOODS: 'composite_foods.svg',
    PnnsGroup1.FAT_AND_SAUCES: 'fat_and_sauces.svg',
    PnnsGroup1.FISH_MEAT_AND_EGGS: 'fish_meat_and_eggs.svg',
    PnnsGroup1.FRUITS_AND_VEGETABLES: 'fruits_and_vegetables.svg',
    PnnsGroup1.MILK_AND_DAIRIES: 'milk_and_dairies.svg',
    PnnsGroup1.SALTY_SNACKS: 'salty_snacks.svg',
    PnnsGroup1.SUGARY_SNACKS: 'sugary_snacks.svg',
  };

  static const List<Color> _COLORS = <Color>[
    Colors.deepPurpleAccent,
    Colors.deepOrangeAccent,
    Colors.blueAccent,
    Colors.brown,
    Colors.redAccent,
    Colors.lightGreen,
    Colors.amber,
    Colors.indigoAccent,
    Colors.pink,
  ];

  PnnsGroup1? _selectedCategory;
  Color? _selectedColor;

  void _selectCategory(final PnnsGroup1 group, final Color color) {
    _selectedCategory = group;
    _selectedColor = color;
  }

  void _unSelectCategory() {
    if (_selectedCategory != null) {
      _selectedCategory = null;
      _selectedColor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedCategory == null
                ? AppLocalizations.of(context)!.categories
                : _selectedCategory!.name,
          ),
        ),
        body: Column(
          children: <Widget>[
            if (_selectedCategory == null)
              Container()
            else
              Container(
                padding: EdgeInsets.zero,
                width: MediaQuery.of(context).size.width,
                height: 100.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List<Widget>.generate(
                    PnnsGroup1.values.length,
                    (int index) {
                      final PnnsGroup1 group = PnnsGroup1.values[index];
                      final Color color = _getColor(index);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 250),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: CategoryChip(
                              title: group.name,
                              color: color,
                              onTap: () async =>
                                  setState(() => _selectCategory(group, color)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: _selectedCategory == null
                  ? _showAllPnnsGroup1()
                  : _showPnnsGroup2(
                      _selectedCategory!,
                      _selectedColor!,
                      localDatabase,
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _showAllPnnsGroup1() => GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        padding: const EdgeInsets.only(
            top: 10.0, bottom: 80.0, right: 10.0, left: 10.0),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 10.0,
        children: List<Widget>.generate(
          PnnsGroup1.values.length,
          (int index) {
            final PnnsGroup1 group = PnnsGroup1.values[index];
            final Color color = _getColor(index);
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: CategoryCard(
                    title: group.name,
                    color: color,
                    iconName: _CATEGORY_ICONS[group]!,
                    onTap: () => setState(() => _selectCategory(group, color)),
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _showPnnsGroup2(
    final PnnsGroup1 category,
    final Color color,
    final LocalDatabase localDatabase,
  ) =>
      ListView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        children: List<Widget>.generate(
          category.subGroups!.length,
          (int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 250),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: SubcategoryCard(
                    heroTag: category.subGroups![index].name,
                    title: category.subGroups![index].name,
                    color: color,
                    onTap: () async {
                      final PnnsGroup2 group = category.subGroups![index];
                      await ProductQueryPageHelper().openBestChoice(
                        productQuery: GroupProductQuery(
                          group,
                          ProductQuery.getCurrentLanguageCode(context),
                        ),
                        heroTag: group.id,
                        color: color,
                        name: group.name,
                        localDatabase: localDatabase,
                        context: context,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

  Color _getColor(final int index) => _COLORS[index % _COLORS.length];

  Future<bool> _onWillPop() async {
    if (_selectedCategory != null) {
      setState(() => _unSelectCategory());
      return false;
    }
    return true;
  }
}
