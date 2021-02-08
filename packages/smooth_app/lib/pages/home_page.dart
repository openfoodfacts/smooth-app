import 'package:flutter/material.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/scan_page.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/list_page.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:smooth_app/pages/product_list_button.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/cards/product_cards/product_list_preview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _TRANSLATE_ME_SEARCHING = 'Searching...';

  DaoProductList _daoProductList;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    _daoProductList = DaoProductList(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final bool mlKitState = userPreferences.getMlKitState();
    final Color notYetColor = SmoothTheme.getBackgroundColor(
      colorScheme,
      Colors.grey,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smoothie',
          style: TextStyle(color: colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
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
                  color: SmoothTheme.getForegroundColor(
                    colorScheme,
                    Colors.red,
                  ),
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
                  color: SmoothTheme.getForegroundColor(
                    colorScheme,
                    Colors.orange,
                  ),
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
                color: SmoothTheme.getForegroundColor(
                  colorScheme,
                  Colors.yellow,
                ),
              ),
            ),
            _getRankingPreferences(userPreferencesModel, userPreferences),
            ProductListPreview(
              daoProductList: _daoProductList,
              productList: ProductList(
                listType: ProductList.LIST_TYPE_HISTORY,
                parameters: '',
              ),
              nbInPreview: 10,
            ),
            _getProductListCard(
              <String>[ProductList.LIST_TYPE_USER_DEFINED],
              'Your food lists',
              Icon(
                Icons.list,
                color: SmoothTheme.getForegroundColor(
                  colorScheme,
                  Colors.purple,
                ),
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
          color: colorScheme.onSecondary,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _getProductListCard(
    final List<String> typeFilter,
    final String title,
    final Icon leadingIcon,
  ) =>
      FutureBuilder<List<ProductList>>(
        future: _daoProductList.getAll(
          limit: 5,
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
            List<Widget> cards;
            final bool empty = list == null || list.isEmpty;
            if (empty) {
              cards = null;
            } else {
              cards = <Widget>[];
              for (final ProductList item in list) {
                cards.add(ProductListButton(item, _daoProductList));
              }
            }
            return Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: () async {
                      await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => ListPage(
                            typeFilter: typeFilter,
                            title: title,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    leading: leadingIcon,
                    subtitle: cards == null ? const Text('Empty list') : null,
                    title: Text(title,
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    children: cards,
                    spacing: 8.0,
                  ),
                ],
              ),
            );
          }
          return Card(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text(title),
              subtitle: Text(
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
          color: SmoothTheme.getForegroundColor(
            Theme.of(context).colorScheme,
            Colors.green,
          ),
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
