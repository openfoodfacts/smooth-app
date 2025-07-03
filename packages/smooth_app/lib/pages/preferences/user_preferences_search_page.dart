import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Search page for preferences, with TextField filter.
class UserPreferencesSearchPage extends StatefulWidget {
  const UserPreferencesSearchPage({super.key});

  @override
  State<UserPreferencesSearchPage> createState() =>
      _UserPreferencesSearchPageState();
}

class _UserPreferencesSearchPageState extends State<UserPreferencesSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final List<Widget> items = _getItems(_controller.text, userPreferences);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences Search')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                border: const OutlineInputBorder(
                  borderRadius: ANGULAR_BORDER_RADIUS,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SMALL_SPACE,
                  vertical: SMALL_SPACE,
                ),
                hintText: 'Looking for...',
                suffix: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _controller.text = ''),
                ),
              ),
            ),
            if (items.isNotEmpty && _controller.text.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (final BuildContext context, final int index) =>
                      items[index],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getItems(
    final String searchString,
    final UserPreferences userPreferences,
  ) {
    final String needle = searchString.getComparisonSafeString();
    final List<Widget> result = <Widget>[];
    final List<PreferencePageType> types =
        PreferencePageType.getPreferencePageTypes(userPreferences);
    for (final PreferencePageType type in types) {
      final AbstractUserPreferences abstractUserPreferences = type
          .getUserPreferences(
            userPreferences: userPreferences,
            context: context,
          );
      // we find the label in the page description: we add all the page items.
      if (_findLabels(needle, abstractUserPreferences.getLabels())) {
        for (final UserPreferencesItem item
            in abstractUserPreferences.getChildren()) {
          result.add(item.builder(context));
        }
      } else {
        // we try to find the label in each page item.
        for (final UserPreferencesItem item
            in abstractUserPreferences.getChildren()) {
          if (_findLabels(needle, item.labels)) {
            result.add(item.builder(context));
          }
        }
      }
    }
    return result;
  }

  bool _findLabels(final String needle, final Iterable<String> labels) {
    for (final String label in labels) {
      if (label.getComparisonSafeString().contains(needle)) {
        return true;
      }
    }
    return false;
  }
}
