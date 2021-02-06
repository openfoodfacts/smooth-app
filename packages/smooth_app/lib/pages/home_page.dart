import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/scan_page.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/list_page.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _NB_IN_PREVIEW = 5;
  static const String _TRANSLATE_ME_SEARCHING = 'Searching...';

  DaoProductList _daoProductList;
  ProductList _productListHistory;
  int _colorIntensity;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    _daoProductList = DaoProductList(localDatabase);
    _productListHistory = ProductList(
      listType: ProductList.LIST_TYPE_HISTORY,
      parameters: '',
    );
    final ThemeData themeData = Theme.of(context);
    final bool mlKitState = userPreferences.getMlKitState();
    final bool dark = themeData.colorScheme.brightness != Brightness.light;
    _colorIntensity = dark ? 200 : 800;
    final Color notYetColor = dark ? Colors.grey[700] : Colors.grey[200];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smoothie',
          style: TextStyle(color: themeData.colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: themeData.colorScheme.onBackground),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => ProfilePage(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.search,
                  color: Colors.red[_colorIntensity],
                ),
                title: TextField(
                  onSubmitted: (final String value) => ChoosePage.onSubmitted(
                    value,
                    context,
                    localDatabase,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => ChoosePage(),
                    ),
                  );
                  setState(() {});
                },
                leading: Icon(
                  Icons.fastfood,
                  color: Colors.orange[_colorIntensity],
                ),
                subtitle: const Text('Food category search'),
                title: Text(
                  '${PnnsGroup1.BEVERAGES.name}'
                  ', ${PnnsGroup1.CEREALS_AND_POTATOES.name}'
                  ', ${PnnsGroup1.COMPOSITE_FOODS.name}'
                  ', ${PnnsGroup1.FAT_AND_SAUCES.name}'
                  ', ${PnnsGroup1.FISH_MEAT_AND_EGGS.name}'
                  ', ...',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ),
            _getProductListCard(
              <String>[
                ProductList.LIST_TYPE_HTTP_SEARCH_GROUP,
                ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS,
              ],
              'Search history',
              Icon(
                Icons.youtube_searched_for,
                color: Colors.yellow[_colorIntensity],
              ),
            ),
            _getRankingPreferences(userPreferencesModel, userPreferences),
            _getHistoryCard(),
            _getProductListCard(
              <String>[ProductList.LIST_TYPE_USER_DEFINED],
              'Your food lists',
              Icon(
                Icons.list,
                color: Colors.purple[_colorIntensity],
              ),
            ),
            Card(
              color: notYetColor,
              child: const ListTile(
                leading: Icon(
                  Icons.score,
                ),
                title: Text('Your current score: 14 points'),
                subtitle: Text('The next level is at 20 points'),
              ),
            ),
            Card(
              color: notYetColor,
              child: const ListTile(
                leading: Icon(
                  Icons.build,
                ),
                title: Text('Contribute'),
                subtitle: Text('Help us list more and more foods!'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ScanPage(
                contributionMode: false,
                mlKit: mlKitState,
              ),
            ),
          );
          setState(() {});
        },
        child: SvgPicture.asset(
          'assets/actions/scanner_alt_2.svg',
          height: 25,
          color: themeData.colorScheme.onSecondary,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _getHistoryCard() => FutureBuilder<List<Product>>(
        future: _daoProductList.getFirstProducts(
            _productListHistory, _NB_IN_PREVIEW, true),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<Product>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Product> list = snapshot.data;
            String title;
            final bool empty = list == null || list.isEmpty;
            if (empty) {
              title = 'Empty list';
            } else {
              final List<String> names = <String>[];
              for (final Product item in list) {
                names.add(item.productName);
              }
              title = names.join(', ') + ', ...';
            }
            return Card(
              child: ListTile(
                onTap: () async {
                  await _daoProductList.get(_productListHistory);
                  await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => ProductListPage(
                        _productListHistory,
                        reverse: true,
                      ),
                    ),
                  );
                  setState(() {});
                },
                leading: Icon(
                  Icons.history,
                  color: Colors.blue[_colorIntensity],
                ),
                subtitle: const Text('Food history'),
                title:
                    Text(title, style: Theme.of(context).textTheme.subtitle2),
              ),
            );
          }
          return Card(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              subtitle: const Text('Food history'),
              title: Text(
                _TRANSLATE_ME_SEARCHING,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );

  Widget _getProductListCard(
    final List<String> typeFilter,
    final String subtitle,
    final Icon leadingIcon,
  ) =>
      FutureBuilder<List<ProductList>>(
        future: _daoProductList.getAll(
          limit: _NB_IN_PREVIEW,
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
            String title;
            final bool empty = list == null || list.isEmpty;
            if (empty) {
              title = 'Empty list';
            } else {
              final List<String> names = <String>[];
              for (final ProductList item in list) {
                switch (item.listType) {
                  case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
                    // TODO(monsieurtanuki): faster and nicer algorithm, please
                    for (final PnnsGroup2 pnnsGroup2 in PnnsGroup2.values) {
                      if (item.parameters == pnnsGroup2.id) {
                        names.add(pnnsGroup2.name);
                      }
                    }
                    break;
                  case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
                    names.add('"${item.parameters}"');
                    break;
                  default:
                    names.add(item.parameters);
                }
              }
              title = names.join(', ') + ', ...';
            }
            return Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => ListPage(
                        typeFilter: typeFilter,
                        title: subtitle,
                      ),
                    ),
                  );
                  setState(() {});
                },
                leading: leadingIcon,
                subtitle: Text(subtitle),
                title:
                    Text(title, style: Theme.of(context).textTheme.subtitle2),
              ),
            );
          }
          return Card(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              subtitle: Text(subtitle),
              title: Text(
                _TRANSLATE_ME_SEARCHING,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );

  Widget _getRankingPreferences(
    final UserPreferencesModel userPreferencesModel,
    final UserPreferences userPreferences,
  ) {
    final List<String> orderedVariables =
        userPreferencesModel.getOrderedVariables(userPreferences);
    final List<String> attributes = <String>[];
    for (final String variable in orderedVariables) {
      final Attribute attribute =
          userPreferencesModel.getReferenceAttribute(variable);
      final PreferencesValue importance =
          userPreferencesModel.getPreferencesValue(
        variable,
        userPreferences,
      );
      attributes.add('${attribute.name} (${importance.name})');
    }
    return Card(
      child: ListTile(
        onTap: () => UserPreferencesView.showModal(context),
        leading: Icon(
          Icons.bar_chart,
          color: Colors.green[_colorIntensity],
        ),
        title: Text(
          attributes.isEmpty
              ? 'Nothing set for the moment'
              : attributes.join(', '),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: const Text('Food ranking parameters'),
      ),
    );
  }
}
