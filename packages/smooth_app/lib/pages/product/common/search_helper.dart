import 'package:flutter/material.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

typedef SearchQueryCallback = void Function(String query);

/// Common "text-field + history" search helper.
/// Will emit a [SearchQuery] when a search is performed.
/// By default (with the [null] value), the history will be displayed.
abstract class SearchHelper extends ValueNotifier<SearchQuery?> {
  SearchHelper() : super(null);

  /// Action to perform for a search.
  @protected
  void search(
    BuildContext context,
    String query, {
    required SearchQueryCallback searchQueryCallback,
  });

  /// Key for [DaoStringList], used to store the latest X queries.
  @protected
  String get historyKey;

  /// Hint text for the search field.
  String getHintText(final AppLocalizations appLocalizations);

  Widget? getAdditionalFilter() => null;

  /// Returns all the previous queries, in reverse order.
  List<String> getAllQueries(final LocalDatabase localDatabase) =>
      DaoStringList(localDatabase).getAll(historyKey).reversed.toList();

  /// Adds a query to the history.
  Future<void> addQuery(
    final LocalDatabase localDatabase,
    final String query,
  ) async => DaoStringList(localDatabase).add(historyKey, query);

  /// Removes a query from the history.
  Future<bool> removeQuery(
    final LocalDatabase localDatabase,
    final String query,
  ) async => DaoStringList(localDatabase).remove(historyKey, query);

  /// Typical search when we have a controller+focus.
  void searchWithController(
    BuildContext context,
    String query,
    TextEditingController controller,
    FocusNode focusNode,
  ) => search(
    context,
    query,
    searchQueryCallback: (String query) {
      controller.text = query;
      focusNode.requestFocus();
    },
  );
}

class SearchQuery {
  const SearchQuery({required this.search, required this.widget})
    : assert(search.length > 0);

  final String search;
  final Widget widget;
}
