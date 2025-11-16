import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/empty_screen_layout.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';

/// A generic abstract class for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
abstract class InfiniteScrollManager<T> {
  /// Creates an [InfiniteScrollManager] with optional initial state.
  InfiniteScrollManager({
    final List<T>? initialItems,
    final int? totalItems,
    final int? totalPages,
  }) : _items = List<T>.from(initialItems ?? <T>[]),
       _currentPage = initialItems != null && initialItems.isNotEmpty
           ? _initialPage
           : 0,
       _totalPages = totalPages,
       _totalItems = totalItems;

  static const int _initialPage = 1;

  /// Current items in the list
  final List<T> _items;

  /// Current page being fetched
  int _currentPage;

  /// Whether currently loading more items
  bool _isLoading = false;

  /// Additional pagination information
  int? _totalItems;
  int? _totalPages;

  /// Getter for items
  List<T> get items => _items;

  /// Getter for current page
  int get currentPage => _currentPage;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for total items
  int? get totalItems => _totalItems;

  /// Getter for total pages
  int? get totalPages => _totalPages;

  /// svg.vec format expected (cf [EmptyScreenLayout])
  Widget get emptyListIcon;

  String emptyListTitle(AppLocalizations appLocalizations);

  String emptyListExplanation(AppLocalizations appLocalizations);

  @protected
  Future<void> fetchInit(final BuildContext context) async {}

  /// Fetches data for a specific page
  @protected
  Future<void> fetchData(int pageNumber);

  /// Displays an item.
  Widget buildItem({required BuildContext context, required T item});

  /// Update the list with new items and pagination info
  @protected
  void updateItems({
    required List<T>? newItems,
    required int? pageNumber,
    required int? totalItems,
    required int? totalPages,
  }) {
    if (newItems == null && pageNumber == null) {
      return;
    }
    if (newItems != null) {
      _items.addAll(newItems);
    }
    if (pageNumber != null) {
      _currentPage = pageNumber;
    }
    _totalItems = totalItems ?? _totalItems;
    _totalPages = totalPages ?? _totalPages;
  }

  /// Load initial data only if the list is empty
  Future<void> loadInitiallyIfNeeded(BuildContext context) async {
    await fetchInit(context);
    if (_items.isNotEmpty) {
      return;
    }
    if (context.mounted) {
      await _load(context: context, pageNumber: _initialPage);
    }
  }

  bool canLoadMore() {
    return !_isLoading && (totalPages == null || currentPage < totalPages!);
  }

  /// Load more items (next page)
  Future<void> loadMore(BuildContext context) async {
    if (_totalPages == null || _currentPage >= _totalPages!) {
      return;
    }
    await _load(context: context, pageNumber: _currentPage + 1);
  }

  /// Internal method to handle loading with error handling
  Future<void> _load({
    required BuildContext context,
    required int pageNumber,
  }) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    try {
      await fetchInit(context);
      await fetchData(pageNumber);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SmoothFloatingSnackbar(
            content: Text(
              AppLocalizations.of(context).prices_error_loading_more_items,
            ),
            duration: SnackBarDuration.medium,
          ),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  final NumberFormat _numberFormat = NumberFormat.decimalPattern(
    ProductQuery.getLocaleString(),
  );

  /// Returns a formatted item count (e.g., "25 of 100 items")
  String formattedItemCount(
    BuildContext context,
    int loadedItems,
    int? totalItems,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return totalItems != null
        ? appLocalizations.item_count_with_total_string(
            _numberFormat.format(loadedItems),
            _numberFormat.format(totalItems),
          )
        : appLocalizations.item_count_string(_numberFormat.format(loadedItems));
  }
}
