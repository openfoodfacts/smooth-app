import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A generic abstract class for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
abstract class InfiniteScrollManager<T> {
  /// Creates an instance of [InfiniteScrollManager] with optional initial items.
  InfiniteScrollManager({
    List<T>? initialItems,
  })  : _items = List<T>.from(initialItems ?? <T>[]),
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

  /// Abstract method to implement the data fetching logic for a specific page
  /// This method must be implemented by subclasses to handle API calls or data fetching
  @protected
  Future<void> fetchData(int pageNumber);

  /// Optional method to implement custom item rendering
  /// Subclasses can override this to provide custom item display logic
  @protected
  Widget buildItem({
    required BuildContext context,
    required T item,
    required int index,
  }) {
    // Default implementation returns a simple ListTile
    // Subclasses should override this with their specific UI
    return ListTile(
      title: Text(item.toString()),
    );
  }

  /// Protected method for subclasses to update the list with new items and pagination info
  @protected
  void updateItems({
    required List<T> newItems,
    required int pageNumber,
    int? totalItems,
    int? totalPages,
  }) {
    if (pageNumber == _initialPage) {
      _items.clear();
    }

    _items.addAll(newItems);
    _currentPage = pageNumber;
    _totalItems = totalItems ?? _totalItems;
    _totalPages = totalPages ?? _totalPages;
  }

  /// Load initial data only if the list is empty
  Future<void> loadInitiallyIfNeeded(BuildContext context) async {
    if (_items.isNotEmpty) {
      return;
    }
    await _load(context: context, pageNumber: _initialPage);
  }

  /// Load more items (next page)
  Future<void> loadMore(BuildContext context) async {
    if (_totalPages != null && _currentPage >= _totalPages!) {
      return;
    }
    await _load(context: context, pageNumber: _currentPage + 1);
  }

  /// Reload data from the first page
  Future<void> refresh(BuildContext context) async {
    await _load(context: context, pageNumber: _initialPage);
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

  /// Returns a formatted page indicator (e.g., "Page 1 / 5")
  String formattedPageIndicator(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _totalPages != null
        ? appLocalizations.page_indicator_with_total(_currentPage, _totalPages!)
        : appLocalizations.page_indicator(_currentPage);
  }

  /// Returns a formatted item count (e.g., "25 of 100 items")
  String formattedItemCount(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _totalItems != null
        ? appLocalizations.item_count_with_total(_items.length, _totalItems!)
        : appLocalizations.item_count(_items.length);
  }
}
