import 'package:flutter/material.dart';

import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:openfoodfacts/model/Product.dart';

import 'package:smooth_app/pages/pantry_dialog_helper.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A page for one pantry where we can change all the data
class PantryPage extends StatelessWidget {
  const PantryPage(
    this.pantries,
    this.index,
  );

  final List<Pantry> pantries;
  final int index;

  static const String _EMPTY_DATE = '';
  static const String _TRANSLATE_ME_RENAME = 'Rename';
  static const String _TRANSLATE_ME_DELETE = 'Delete';
  static const String _TRANSLATE_ME_CHANGE = 'Change icon';
  static const String _TRANSLATE_ME_PASTE = 'paste';
  static const String _TRANSLATE_ME_CLEAR = 'clear';
  static const String _TRANSLATE_ME_GROCERY = 'grocery';
  static const String _TRANSLATE_ME_ANOTHER_DATE = 'Add another date';
  static const String _TRANSLATE_ME_NO_DATE = 'No date';

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const TextStyle textStyle = TextStyle(fontSize: 16);
    if (index >= pantries.length) {
      return const CircularProgressIndicator();
    }
    final Pantry pantry = pantries[index];
    final List<Product> products = pantry.products.values.toList();
    return Scaffold(
      bottomNavigationBar: Builder(
        builder: (BuildContext context) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.paste), label: _TRANSLATE_ME_PASTE),
            BottomNavigationBarItem(
                icon: Icon(Icons.highlight_remove), label: _TRANSLATE_ME_CLEAR),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_grocery_store),
                label: _TRANSLATE_ME_GROCERY),
          ],
          onTap: (final int index) async {
            if (index == 0) {
              final List<String> barcodes = await daoProductList
                  .getBarcodes(userPreferences.getProductListCopy());
              final Map<String, Product> products =
                  await daoProduct.getAll(barcodes);
              pantry.add(barcodes, products);
              await save(userPreferences);
              return;
            }
            if (index == 1) {
              pantry.clear();
              await save(userPreferences);
              return;
            }
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor:
            SmoothTheme.getBackgroundColor(colorScheme, pantry.materialColor),
        title: Row(
          children: <Widget>[
            pantry.getIcon(colorScheme),
            const SizedBox(width: 8.0),
            Text(
              pantry.name,
              style: TextStyle(color: colorScheme.onBackground),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (final BuildContext context) =>
                <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'rename',
                child: Text(_TRANSLATE_ME_RENAME),
                enabled: true,
              ),
              const PopupMenuItem<String>(
                value: 'change',
                child: Text(_TRANSLATE_ME_CHANGE),
                enabled: true,
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(_TRANSLATE_ME_DELETE),
                enabled: true,
              ),
            ],
            onSelected: (final String value) async {
              switch (value) {
                case 'rename':
                  if (await PantryDialogHelper.openRename(
                      context, pantries, index)) {
                    await save(userPreferences);
                  }
                  break;
                case 'delete':
                  if (await PantryDialogHelper.openDelete(
                      context, pantries, index)) {
                    await save(userPreferences);
                    Navigator.pop(context);
                  }
                  break;
                case 'change':
                  if (await PantryDialogHelper.openChangeIcon(
                      context, pantries, index)) {
                    await save(userPreferences);
                  }
                  break;
                default:
                  throw Exception('Unknown value: $value');
              }
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Text('There is no product in this list',
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final Product product = products[index];
                final String barcode = product.barcode;
                final List<Widget> children = <Widget>[
                  SmoothProductCardFound(
                    heroTag: barcode,
                    product: product,
                    backgroundColor: SmoothTheme.getBackgroundColor(
                      colorScheme,
                      Colors.grey,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                ];
                final Map<String, int> dates = pantry.data[barcode];
                final String now = DateTime.now().toIso8601String();
                final List<String> sortedDays = <String>[...dates.keys];
                sortedDays.sort();
                final bool alreadyHasNoDate = sortedDays.contains(_EMPTY_DATE);
                for (final String day in sortedDays) {
                  children.add(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              onPressed: () async {
                                pantry.increaseItem(barcode, day, -1);
                                await save(userPreferences);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${dates[day]}', style: textStyle),
                            IconButton(
                              onPressed: () async {
                                pantry.increaseItem(barcode, day, 1);
                                await save(userPreferences);
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        Text(
                          day != _EMPTY_DATE ? day : _TRANSLATE_ME_NO_DATE,
                          style: textStyle,
                        ),
                        Container(
                          width: 60,
                          child: Center(
                            child: Text(
                              day == _EMPTY_DATE
                                  ? ''
                                  : '(${_getDayDifference(now, day)}d)',
                              style: textStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final Widget dateButton = ElevatedButton(
                  onPressed: () async {
                    final DateTime dateTime = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026),
                      builder: (BuildContext context, Widget child) {
                        final Color color = SmoothTheme.getForegroundColor(
                            colorScheme, pantry.materialColor);
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: color,
                            accentColor: color,
                            colorScheme: ColorScheme.light(primary: color),
                            buttonTheme: const ButtonThemeData(
                                textTheme: ButtonTextTheme.primary),
                          ),
                          child: child,
                        );
                      },
                    );
                    if (dateTime == null) {
                      return;
                    }
                    final String date =
                        dateTime.toIso8601String().substring(0, 10);
                    pantry.increaseItem(barcode, date, 1);
                    await save(userPreferences);
                  },
                  child: const Text(
                    _TRANSLATE_ME_ANOTHER_DATE,
                    style: textStyle,
                  ),
                );
                final Widget noDateButton = ElevatedButton(
                  onPressed: () async {
                    pantry.increaseItem(barcode, _EMPTY_DATE, 1);
                    await save(userPreferences);
                  },
                  child: const Text(
                    _TRANSLATE_ME_NO_DATE,
                    style: textStyle,
                  ),
                );
                children.add(
                  ListTile(
                    title: alreadyHasNoDate
                        ? dateButton
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              dateButton,
                              noDateButton,
                            ],
                          ),
                    trailing: Container(
                      width: 54,
                      child: sortedDays.isNotEmpty
                          ? null
                          : IconButton(
                              onPressed: () async {
                                pantry.removeBarcode(barcode);
                                await save(userPreferences);
                              },
                              icon:
                                  Icon(Icons.delete, color: colorScheme.error),
                            ),
                    ),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Card(
                    color: SmoothTheme.getBackgroundColor(
                      colorScheme,
                      Colors.grey,
                    ),
                    child: Column(children: children),
                  ),
                );
              },
            ),
    );
  }

  static int _getDayDifference(final String reference, final String value) {
    final DateTime referenceDateTime = DateTime.parse(reference);
    final DateTime valueDateTime = DateTime.parse(value);
    final Duration difference = valueDateTime.difference(referenceDateTime);
    return (difference.inHours / 24).round();
  }

  Future<void> save(final UserPreferences userPreferences) async =>
      Pantry.putAll(userPreferences, pantries);
}
