import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/product_cards/product_list_preview.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/list_page.dart';
import 'package:smooth_app/pages/pantry/common/pantry_button.dart';
import 'package:smooth_app/pages/pantry/common/pantry_dialog_helper.dart';
import 'package:smooth_app/pages/pantry/common/pantry_list_page.dart';
import 'package:smooth_app/pages/product/common/product_list_button.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/settings_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/pages/text_search_widget.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const ColorDestination _COLOR_DESTINATION_FOR_ICON =
      ColorDestination.SURFACE_FOREGROUND;
  static const Icon _ICON_ARROW_FORWARD = Icon(Icons.arrow_forward);

  DaoProductList _daoProductList;
  DaoProduct _daoProduct;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    _daoProductList = DaoProductList(localDatabase);
    _daoProduct = DaoProduct(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const <Widget>[
            Icon(Icons.pets),
            SizedBox(width: 10.0),
            Text('Smoothie'),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          TextSearchWidget(
            color: SmoothTheme.getColor(
              colorScheme,
              Colors.red,
              _COLOR_DESTINATION_FOR_ICON,
            ),
            daoProduct: _daoProduct,
          ),
          _getProductListCard(
            <String>[ProductList.LIST_TYPE_USER_DEFINED],
            appLocalizations.my_lists,
            Icon(
              Icons.list,
              color: SmoothTheme.getColor(
                colorScheme,
                Colors.purple,
                _COLOR_DESTINATION_FOR_ICON,
              ),
            ),
            appLocalizations,
          ),
          _getPantryCard(
            userPreferences,
            _daoProduct,
            PantryType.PANTRY,
            appLocalizations,
          ),
          _getPantryCard(
            userPreferences,
            _daoProduct,
            PantryType.SHOPPING,
            appLocalizations,
          ),
          _getRankingPreferences(
            productPreferences,
            appLocalizations,
          ),
          ProductListPreview(
            daoProductList: _daoProductList,
            productList: ProductList(
              listType: ProductList.LIST_TYPE_HISTORY,
              parameters: '',
            ),
            nbInPreview: 5,
          ),
          GestureDetector(
            child: SmoothCard(
              child: ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: SmoothTheme.getColor(
                    colorScheme,
                    Colors.orange,
                    _COLOR_DESTINATION_FOR_ICON,
                  ),
                ),
                title: Text(appLocalizations.food_categories,
                    style: Theme.of(context).textTheme.subtitle2),
                subtitle: Text(
                  '${PnnsGroup1.BEVERAGES.name}'
                  ', ${PnnsGroup1.CEREALS_AND_POTATOES.name}'
                  ', ${PnnsGroup1.COMPOSITE_FOODS.name}'
                  ', ${PnnsGroup1.FAT_AND_SAUCES.name}'
                  ', ${PnnsGroup1.FISH_MEAT_AND_EGGS.name}'
                  ', ...',
                ),
              ),
            ),
            onTap: () async {
              await Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => ChoosePage(),
                ),
              );
            },
          ),
          _getProductListCard(
            <String>[
              ProductList.LIST_TYPE_HTTP_SEARCH_GROUP,
              ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS,
              ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY,
            ],
            appLocalizations.search_history,
            Icon(
              Icons.youtube_searched_for,
              color: SmoothTheme.getColor(
                colorScheme,
                Colors.yellow,
                _COLOR_DESTINATION_FOR_ICON,
              ),
            ),
            appLocalizations,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const ScanPage(
                contributionMode: false,
              ),
            ),
          );
        },
        child: SvgPicture.asset(
          'assets/actions/scanner_alt_2.svg',
          height: 25,
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _getProductListCard(final List<String> typeFilter, final String title,
          final Icon leadingIcon, final AppLocalizations appLocalizations) =>
      FutureBuilder<List<ProductList>>(
        future: _daoProductList.getAll(
          withStats: false,
          reverse: true,
          typeFilter: typeFilter,
        ),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<ProductList>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<ProductList> list = snapshot.data;
            final List<Widget> cards = <Widget>[];
            if (list != null) {
              for (final ProductList item in list) {
                cards.add(
                  ProductListButton(
                    productList: item,
                    onPressed: () async => await _goToProductListPage(item),
                  ),
                );
              }
            }
            final Widget addButton = ProductListButton.add(
              onlyIcon: cards.isNotEmpty,
              onPressed: () async {
                final ProductList newProductList =
                    await ProductListDialogHelper.openNew(
                  context,
                  _daoProductList,
                  list,
                );
                if (newProductList == null) {
                  return;
                }
                await _goToProductListPage(newProductList);
              },
            );
            Widget ifEmpty;
            if (typeFilter.contains(ProductList.LIST_TYPE_USER_DEFINED)) {
              if (cards.isEmpty) {
                ifEmpty = addButton;
              } else {
                cards.add(addButton);
              }
            } else {
              if (cards.isEmpty) {
                ifEmpty = Text(appLocalizations.empty);
              }
            }
            return SmoothCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    onTap: () async {
                      await Navigator.push<Widget>(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (BuildContext context) => ListPage(
                            typeFilter: typeFilter,
                            title: title,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    leading: leadingIcon,
                    trailing: _ICON_ARROW_FORWARD,
                    title: Text(title,
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  _getHorizontalList(cards, ifEmpty),
                ],
              ),
            );
          }
          return SmoothCard(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text(title),
              subtitle: Text(
                appLocalizations.searching,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );

  Widget _getRankingPreferences(final ProductPreferences productPreferences,
      final AppLocalizations appLocalizations) {
    final List<String> orderedAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> attributes = <Widget>[];
    final Map<String, MaterialColor> colors = <String, MaterialColor>{
      PreferenceImportance.ID_IMPORTANT: Colors.green,
      PreferenceImportance.ID_VERY_IMPORTANT: Colors.orange,
      PreferenceImportance.ID_MANDATORY: Colors.red,
    };
    final Function onTap = () => UserPreferencesView.showModal(context);

    for (final String attributeId in orderedAttributeIds) {
      final Attribute attribute =
          productPreferences.getReferenceAttribute(attributeId);
      final String importanceId =
          productPreferences.getImportanceIdForAttributeId(attributeId);
      attributes.add(
        SmoothChip(
          onPressed: () => onTap(),
          label: attribute.name,
          materialColor: colors[importanceId],
        ),
      );
    }

    return SmoothCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () => onTap(),
            leading: Icon(
              Icons.bar_chart,
              color: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                Colors.green,
                _COLOR_DESTINATION_FOR_ICON,
              ),
            ),
            trailing: _ICON_ARROW_FORWARD,
            title: Text(
              'Food ranking parameters',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          _getHorizontalList(
              attributes,
              SmoothChip(
                onPressed: () => onTap(),
                iconData: Icons.settings,
                label: appLocalizations.configurePreferences,
              )),
        ],
      ),
    );
  }

  Widget _getPantryCard(
    final UserPreferences userPreferences,
    final DaoProduct daoProduct,
    final PantryType pantryType,
    final AppLocalizations appLocalizations,
  ) =>
      FutureBuilder<List<Pantry>>(
        future: Pantry.getAll(userPreferences, daoProduct, pantryType),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<Pantry>> snapshot,
        ) {
          final String title = pantryType == PantryType.PANTRY
              ? appLocalizations.my_pantrie_lists
              : appLocalizations.my_shopping_lists;
          final IconData iconData = pantryType == PantryType.PANTRY
              ? Icons.home
              : Icons.shopping_cart;
          final MaterialColor materialColor =
              pantryType == PantryType.PANTRY ? Colors.orange : Colors.blueGrey;
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Pantry> pantries = snapshot.data;
            final List<Widget> cards = <Widget>[];
            for (int index = 0; index < pantries.length; index++) {
              cards.add(
                PantryButton(
                  pantries: pantries,
                  index: index,
                  onPressed: () async => await _goToPantryPage(
                    pantries[index],
                    pantries,
                  ),
                ),
              );
            }
            final Widget addButton = PantryButton.add(
              pantries: pantries,
              pantryType: pantryType,
              onlyIcon: cards.isNotEmpty,
              onPressed: () async {
                final Pantry newPantry = await PantryDialogHelper.openNew(
                  context,
                  pantries,
                  pantryType,
                  userPreferences,
                );
                if (newPantry == null) {
                  return;
                }
                await _goToPantryPage(newPantry, pantries);
              },
            );
            if (cards.isNotEmpty) {
              cards.add(addButton);
            }
            return SmoothCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    onTap: () async {
                      await Navigator.push<Widget>(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (BuildContext context) => PantryListPage(
                            title,
                            pantries,
                            pantryType,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    leading: Icon(
                      iconData,
                      color: SmoothTheme.getColor(
                        Theme.of(context).colorScheme,
                        materialColor,
                        _COLOR_DESTINATION_FOR_ICON,
                      ),
                    ),
                    trailing: _ICON_ARROW_FORWARD,
                    title: Text(title,
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  _getHorizontalList(cards, addButton),
                ],
              ),
            );
          }
          return SmoothCard(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text(title),
              subtitle: Text(
                appLocalizations.searching,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );

  Future<void> _goToProductListPage(final ProductList productList) async {
    await _daoProductList.get(productList);
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductListPage(productList),
      ),
    );
    setState(() {});
  }

  Future<void> _goToPantryPage(
    final Pantry pantry,
    final List<Pantry> pantries,
  ) async {
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => PantryPage(
          pantries: pantries,
          pantry: pantry,
        ),
      ),
    );
    setState(() {});
  }

  Widget _getHorizontalList(
    final List<Widget> children,
    final Widget ifEmpty,
  ) =>
      Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: children.isEmpty
            ? ifEmpty
            : SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: children.length,
                  itemBuilder: (final BuildContext context, final int index) =>
                      children[index],
                  separatorBuilder:
                      (final BuildContext context, final int index) =>
                          const SizedBox(width: 8.0),
                  //children: cards,
                ),
              ),
      );
}
