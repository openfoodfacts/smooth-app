import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/location_query_page.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';

/// Search helper dedicated to location search.
class SearchLocationHelper extends SearchHelper {
  SearchLocationHelper();

  @override
  String get historyKey => DaoStringList.keySearchLocationHistory;

  @override
  String getHintText(final AppLocalizations appLocalizations) =>
      appLocalizations.search_store;

  @override
  void search(
    BuildContext context,
    String query, {
    required SearchQueryCallback searchQueryCallback,
  }) {
    query = query.trim();
    if (query.isEmpty) {
      return;
    }

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    addQuery(localDatabase, query);

    // await
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            LocationQueryPage(query: query, editableAppBarTitle: true),
      ),
    );
  }
}
