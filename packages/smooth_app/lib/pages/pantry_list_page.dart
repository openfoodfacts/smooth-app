import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/pantry_preview.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry_dialog_helper.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:provider/provider.dart';

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
            onPressed: () async {
              if (await PantryDialogHelper.openNew(
                context,
                widget.pantries,
                widget.pantryType,
              )) {
                Pantry.putAll(
                  userPreferences,
                  widget.pantries,
                  widget.pantryType,
                );
              }
            },
          )
        ],
      ),
      body: (widget.pantries.isEmpty)
          ? const Center(child: Text('Empty'))
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
}
