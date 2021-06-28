import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/pantry_preview.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry/common/pantry_dialog_helper.dart';
import 'package:smooth_app/pages/pantry/common/pantry_button.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// A page where all the pantries are displayed as previews
class PantryListPage extends StatefulWidget {
  const PantryListPage(this.title, this.pantries, this.pantryType);

  final String title;
  final List<Pantry> pantries;
  final PantryType pantryType;

  @override
  _PantryListPageState createState() => _PantryListPageState();
}

class _PantryListPageState extends State<PantryListPage> {
  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
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
              child: PantryButton.add(
                pantries: widget.pantries,
                pantryType: widget.pantryType,
                onlyIcon: false,
                onPressed: () async => await _add(userPreferences),
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
    final Pantry newPantry = await PantryDialogHelper.openNew(
      context,
      widget.pantries,
      widget.pantryType,
      userPreferences,
    );
    if (newPantry == null) {
      return;
    }
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => PantryPage(
          pantries: widget.pantries,
          pantry: newPantry,
        ),
      ),
    );
    setState(() {});
  }
}
