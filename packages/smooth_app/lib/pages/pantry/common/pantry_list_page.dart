// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/pantry_preview.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry/common/pantry_dialog_helper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A page where all the pantries are displayed as previews
class PantryListPage extends StatefulWidget {
  const PantryListPage(this.title, this.pantries, this.pantryType);

  final String title;
  final List<Pantry> pantries;
  final PantryType pantryType;

  @override
  _PantryListPageState createState() => _PantryListPageState();

  static String getCreateListLabel(final PantryType pantryType) {
    switch (pantryType) {
      case PantryType.PANTRY:
        return 'Create a pantry';
      case PantryType.SHOPPING:
        return 'Create a shopping list';
    }
    throw Exception('unknow pantry type $pantryType');
  }
}

class _PantryListPageState extends State<PantryListPage> {
  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconSize = screenSize.width / 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async => await _add(userPreferences),
          )
        ],
      ),
      body: (widget.pantries.isEmpty)
          ? Center(
              child: _addButtonWhenEmpty(
                iconSize,
                themeData,
                userPreferences,
              ),
            )
          : ListView.builder(
              itemCount: widget.pantries.length,
              itemBuilder: (final BuildContext context, final int index) =>
                  PantryPreview(
                pantries: widget.pantries,
                index: index,
                nbInPreview: 5,
              ),
            ),
    );
  }

  Future<void> _add(final UserPreferences userPreferences) async {
    final String newPantryName = await PantryDialogHelper.openNew(
      context,
      widget.pantries,
      widget.pantryType,
      userPreferences,
    );
    if (newPantryName == null) {
      return;
    }
    setState(() {});
  }

  Widget _addButtonWhenEmpty(
    final double iconSize,
    final ThemeData themeData,
    final UserPreferences userPreferences,
  ) =>
      SizedBox(
        height: iconSize * 3,
        child: SmoothCard(
          background: SmoothTheme.getColor(
            themeData.colorScheme,
            Colors.blue,
            ColorDestination.SURFACE_BACKGROUND,
          ),
          content: ListTile(
            leading: Icon(Icons.add, size: iconSize),
            onTap: () async => await _add(userPreferences),
            title: Text(
              PantryListPage.getCreateListLabel(widget.pantryType),
              style: themeData.textTheme.headline3,
            ),
          ),
        ),
      );
}
