import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// A generic abstract class for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
abstract class InfiniteScrollManager<T> {
  /// Creates an instance of [InfiniteScrollManager] with optional initial items.
  InfiniteScrollManager({
    List<T>? initialItems,
  })  : _items = initialItems ?? <T>[],
        _currentPage =
            initialItems != null && initialItems.isNotEmpty ? _initialPage : 0;

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

  @protected
  Future<void> fetchInit() async {}

  /// Fetches data for a specific page
  @protected
  Future<void> fetchData(int pageNumber);

  /// Displays an item.
  @protected
  Widget buildItem({
    required BuildContext context,
    required T item,
  });

  Widget getItemWidget({required BuildContext context, required T item}) {
    return buildItem(context: context, item: item);
  }

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
    await fetchInit();
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
      await fetchData(pageNumber);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).prices_error_loading_more_items,
            ),
          ),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Returns a formatted item count (e.g., "25 of 100 items")
  String formattedItemCount(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _totalItems != null
        ? appLocalizations.item_count_with_total(_items.length, _totalItems!)
        : appLocalizations.item_count(_items.length);
  }
}
