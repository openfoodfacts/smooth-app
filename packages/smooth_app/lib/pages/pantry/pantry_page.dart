import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/pantry/common/pantry_dialog_helper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/text_search_widget.dart';
import 'package:smooth_app/pages/multi_select_product_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A page for one pantry where we can change all the data
class PantryPage extends StatelessWidget {
  const PantryPage(
    this.pantries,
    this.index,
    this.pantryType,
  );

  final List<Pantry> pantries;
  final int index;
  final PantryType pantryType;

  static const String _EMPTY_DATE = '';

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const TextStyle textStyle = TextStyle(fontSize: 16);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (index >= pantries.length) {
      return const CircularProgressIndicator();
    }
    final Pantry pantry = pantries[index];
    final List<String> orderedBarcodes = pantry.getOrderedBarcodes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SmoothTheme.getColor(
          colorScheme,
          pantry.materialColor,
          ColorDestination.APP_BAR_BACKGROUND,
        ),
        title: Row(
          children: <Widget>[
            pantry.getIcon(colorScheme, ColorDestination.APP_BAR_FOREGROUND),
            const SizedBox(width: 8.0),
            Text(pantry.name),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (final BuildContext context) =>
                <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'rename',
                child: Text(appLocalizations.rename),
                enabled: true,
              ),
              PopupMenuItem<String>(
                value: 'change',
                child: Text(appLocalizations.change_icon),
                enabled: true,
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(appLocalizations.delete),
                enabled: true,
              ),
            ],
            onSelected: (final String value) async {
              switch (value) {
                case 'rename':
                  if (await PantryDialogHelper.openRename(
                      context, pantries, index)) {
                    await _save(userPreferences);
                  }
                  break;
                case 'delete':
                  if (await PantryDialogHelper.openDelete(
                      context, pantries, index)) {
                    await _save(userPreferences);
                    Navigator.pop(context);
                  }
                  break;
                case 'change':
                  if (await PantryDialogHelper.openChangeIcon(
                      context, pantries, index)) {
                    await _save(userPreferences);
                  }
                  break;
                default:
                  throw Exception('Unknown value: $value');
              }
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        onReorder: (final int oldIndex, final int newIndex) async {
          pantry.reorder(oldIndex, newIndex);
          await _save(userPreferences);
        },
        buildDefaultDragHandles: false,
        header: TextSearchWidget(
          color: Colors.blue,
          daoProduct: daoProduct,
          addProductCallback: (final Product product) async {
            final bool itemAdded = pantry.add(product);
            if (!itemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Already in the pantry!'),
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }
            await _save(userPreferences);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added to the pantry!'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    pantry.removeBarcode(product.barcode);
                    await _save(userPreferences);
                  },
                ),
              ),
            );
          },
        ),
        itemCount: orderedBarcodes.length,
        itemBuilder: (BuildContext context, int index) {
          final Product product = pantry.products[orderedBarcodes[index]];
          final String barcode = product.barcode;
          final List<Widget> children = <Widget>[
            SmoothProductCardFound(
              heroTag: barcode,
              product: product,
              backgroundColor: SmoothTheme.getColor(
                colorScheme,
                Colors.grey,
                ColorDestination.SURFACE_BACKGROUND,
              ),
              handle: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
              onLongPress: () => Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) =>
                      MultiSelectProductPage.pantry(
                    barcode: product.barcode,
                    pantries: pantries,
                    index: this.index,
                    pantryType: pantryType,
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
          ];
          final Map<String, int> dates = pantry.data[barcode];
          if (pantry.pantryType == PantryType.SHOPPING) {
            _addShoppingLines(
              children: children,
              barcode: barcode,
              count: dates[''] ?? 0,
              pantry: pantry,
              textStyle: textStyle,
              userPreferences: userPreferences,
              colorScheme: colorScheme,
            );
          } else {
            _addPantryLines(
              pantry: pantry,
              userPreferences: userPreferences,
              barcode: barcode,
              textStyle: textStyle,
              dates: dates,
              colorScheme: colorScheme,
              children: children,
              context: context,
            );
          }
          return Dismissible(
            background: Container(color: colorScheme.background),
            key: Key(barcode),
            onDismissed: (final DismissDirection direction) async {
              pantry.removeBarcode(barcode);
              await _save(userPreferences);
            },
            child: Padding(
              key: ValueKey<String>(product.barcode),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Card(
                color: SmoothTheme.getColor(
                  colorScheme,
                  Colors.grey,
                  ColorDestination.SURFACE_BACKGROUND,
                ),
                child: Column(children: children),
              ),
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
    return (difference.inHours / 24).ceil();
  }

  Future<void> _save(final UserPreferences userPreferences) async =>
      Pantry.putAll(userPreferences, pantries, pantryType);

  Widget _getPantryDayLine({
    @required final Pantry pantry,
    @required final UserPreferences userPreferences,
    @required final String barcode,
    @required final String day,
    @required final String now,
    @required final TextStyle textStyle,
    @required final Map<String, int> dates,
    @required final BuildContext context,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  pantry.increaseItem(barcode, day, -1);
                  await _save(userPreferences);
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${dates[day]}', style: textStyle),
              IconButton(
                onPressed: () async {
                  pantry.increaseItem(barcode, day, 1);
                  await _save(userPreferences);
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            day != _EMPTY_DATE ? day : AppLocalizations.of(context).no_date,
            style: textStyle,
          ),
          Container(
            width: 60,
            child: Center(
              child: Text(
                day == _EMPTY_DATE ? '' : '(${_getDayDifference(now, day)}d)',
                style: textStyle,
              ),
            ),
          ),
        ],
      );

  void _addPantryLines({
    @required final List<Widget> children,
    @required final Pantry pantry,
    @required final UserPreferences userPreferences,
    @required final String barcode,
    @required final TextStyle textStyle,
    @required final Map<String, int> dates,
    @required final ColorScheme colorScheme,
    @required final BuildContext context,
  }) {
    final String now = DateTime.now().toIso8601String();
    final List<String> sortedDays = <String>[...dates.keys];
    sortedDays.sort();
    final bool alreadyHasNoDate = sortedDays.contains(_EMPTY_DATE);
    for (final String day in sortedDays) {
      children.add(
        _getPantryDayLine(
          barcode: barcode,
          dates: dates,
          day: day,
          now: now,
          pantry: pantry,
          textStyle: textStyle,
          userPreferences: userPreferences,
          context: context,
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
          builder: (BuildContext context, Widget child) => child,
        );
        if (dateTime == null) {
          return;
        }
        final String date = dateTime.toIso8601String().substring(0, 10);
        pantry.increaseItem(barcode, date, 1);
        await _save(userPreferences);
      },
      child: Text(AppLocalizations.of(context).add_date, style: textStyle),
    );
    final Widget noDateButton = ElevatedButton(
      onPressed: () async {
        pantry.increaseItem(barcode, _EMPTY_DATE, 1);
        await _save(userPreferences);
      },
      child: Text(AppLocalizations.of(context).no_date, style: textStyle),
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
      ),
    );
  }

  void _addShoppingLines({
    @required final List<Widget> children,
    @required final Pantry pantry,
    @required final UserPreferences userPreferences,
    @required final String barcode,
    @required final int count,
    @required final TextStyle textStyle,
    @required final ColorScheme colorScheme,
  }) =>
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () async {
                    pantry.increaseItem(barcode, _EMPTY_DATE, -1);
                    await _save(userPreferences);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$count', style: textStyle),
                IconButton(
                  onPressed: () async {
                    pantry.increaseItem(barcode, _EMPTY_DATE, 1);
                    await _save(userPreferences);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      );
}
