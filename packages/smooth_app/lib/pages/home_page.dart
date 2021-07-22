import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/product/common/product_list_add_button.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
import 'package:smooth_app/cards/product_cards/product_list_preview.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/list_page.dart';
import 'package:smooth_app/pages/product/common/product_list_button.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/settings_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/pages/text_search_widget.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const ColorDestination _COLOR_DESTINATION_FOR_ICON =
      ColorDestination.SURFACE_FOREGROUND;
  static const Icon _ICON_ARROW_FORWARD = Icon(Icons.arrow_forward);

  late DaoProductList _daoProductList;
  late DaoProduct _daoProduct;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    _daoProductList = DaoProductList(localDatabase);
    _daoProduct = DaoProduct(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(themeProvider);
    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
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
          _getHeader(
            themeData,
            screenSize.width,
            materialColor,
            themeData.brightness == Brightness.light
                ? 'assets/home/white.svg'
                : 'assets/home/brown.svg',
          ),
          TextSearchWidget(
            color: SmoothTheme.getColor(
              colorScheme,
              Colors.red,
              _COLOR_DESTINATION_FOR_ICON,
            ),
            daoProduct: _daoProduct,
          ),
          _getScanLargeButton(themeData, materialColor),
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
          _getProductListCard(
            <String>[ProductList.LIST_TYPE_USER_PANTRY],
            appLocalizations.my_pantrie_lists,
            Icon(
              Icons.home,
              color: SmoothTheme.getColor(
                colorScheme,
                Colors.orange,
                _COLOR_DESTINATION_FOR_ICON,
              ),
            ),
            appLocalizations,
          ),
          _getProductListCard(
            <String>[ProductList.LIST_TYPE_USER_SHOPPING],
            appLocalizations.my_shopping_lists,
            Icon(
              Icons.shopping_cart,
              color: SmoothTheme.getColor(
                colorScheme,
                Colors.blueGrey,
                _COLOR_DESTINATION_FOR_ICON,
              ),
            ),
            appLocalizations,
          ),
          ProductListPreview(
            daoProductList: _daoProductList,
            productList: ProductList(
              listType: ProductList.LIST_TYPE_HISTORY,
              parameters: '',
            ),
            nbInPreview: 5,
            andThen: () => setState(() {}),
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
    );
  }

  Widget _getProductListCard(
    final List<String> typeFilter,
    final String title,
    final Icon leadingIcon,
    final AppLocalizations appLocalizations,
  ) =>
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
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            final List<ProductList> list = snapshot.data!;
            final List<Widget> cards = <Widget>[];
            for (final ProductList item in list) {
              cards.add(
                ProductListButton(
                  productList: item,
                  onPressed: () async => await _goToProductListPage(item),
                ),
              );
            }

            Widget? ifEmpty;
            final String? userProductListType =
                ProductList.getUniqueUserProductListType(typeFilter);
            if (userProductListType != null) {
              final Widget addButton = ProductListAddButton(
                onlyIcon: cards.isNotEmpty,
                productListType: userProductListType,
                onPressed: () async {
                  final ProductList? newProductList =
                      await ProductListDialogHelper.openNew(
                    context,
                    _daoProductList,
                    list,
                    userProductListType,
                  );
                  if (newProductList == null) {
                    return;
                  }
                  await _goToProductListPage(newProductList);
                },
              );
              if (cards.isEmpty) {
                ifEmpty = addButton;
              } else {
                cards.add(addButton);
              }
            } else {
              if (cards.isEmpty) {
                ifEmpty = Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(appLocalizations.empty),
                  ),
                );
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
                    title: Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
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

  Widget _getHorizontalList(
    final List<Widget> children,
    final Widget? ifEmpty,
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

  Widget _getScanLargeButton(
    final ThemeData themeData,
    final MaterialColor materialColor,
  ) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            primary: SmoothTheme.getColor(
              themeData.colorScheme,
              materialColor,
              ColorDestination.BUTTON_BACKGROUND,
            ),
          ),
          onPressed: () async => await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const ScanPage(
                contributionMode: false,
              ),
            ),
          ),
          icon: SvgPicture.asset(
            'assets/actions/scanner_alt_2.svg',
            height: 32,
            color: SmoothTheme.getColor(
              themeData.colorScheme,
              materialColor,
              ColorDestination.BUTTON_FOREGROUND,
            ),
          ),
          label: Text(
            'Scan and compare products',
            style: themeData.textTheme.headline3!.copyWith(
              color: SmoothTheme.getColor(
                themeData.colorScheme,
                materialColor,
                ColorDestination.BUTTON_FOREGROUND,
              ),
            ),
          ),
        ),
      );

  Widget _getHeader(
    final ThemeData themeData,
    final double screenWidth,
    final MaterialColor materialColor,
    final String assetFilename,
  ) =>
      Row(
        children: <Widget>[
          SizedBox(
            width: screenWidth / 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Find the best food for you!',
                    style: themeData.textTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: SmoothTheme.getColor(
                        themeData.colorScheme,
                        materialColor,
                        ColorDestination.BUTTON_BACKGROUND,
                      ),
                    ),
                    onPressed: () async => await Navigator.push<Widget>(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) =>
                            const UserPreferencesPage(),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/actions/food-cog.svg',
                      color: SmoothTheme.getColor(
                        themeData.colorScheme,
                        materialColor,
                        ColorDestination.BUTTON_FOREGROUND,
                      ),
                    ),
                    label: Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.myPreferences,
                        style: TextStyle(
                          color: SmoothTheme.getColor(
                            themeData.colorScheme,
                            materialColor,
                            ColorDestination.BUTTON_FOREGROUND,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SvgAsyncAsset(
            assetFilename,
            width: screenWidth / 2,
          ),
        ],
      );
}
