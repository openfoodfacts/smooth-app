import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/pantry_preview.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry_dialog_helper.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:provider/provider.dart';

/// A page where all the pantries are displayed as previews
class PantryListPage extends StatefulWidget {
  const PantryListPage(this.title, this.pantries);

  final String title;
  final List<Pantry> pantries;

  @override
  _PantryListPageState createState() => _PantryListPageState();
}

class _PantryListPageState extends State<PantryListPage> {
  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onBackground),
            onPressed: () async {
              if (await PantryDialogHelper.openNew(
                context,
                widget.pantries,
              )) {
                Pantry.putAll(userPreferences, widget.pantries);
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
