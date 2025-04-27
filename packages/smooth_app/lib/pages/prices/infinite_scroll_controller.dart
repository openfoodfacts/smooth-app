import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A generic controller for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
/// [P] is the type of parameters used for pagination.
class InfiniteScrollController<T, P> {
  InfiniteScrollController({
    required this.fetchItems,
    required Iterable<T> initialItems,
  })  : _currentPage = _initialPage,
        _items = List<T>.from(initialItems),
        initialItems = List<T>.from(initialItems);

  /// Returns a Future with the fetched items
  final Future<List<T>> Function(P parameters, int page) fetchItems;

  /// Parameters for the fetch operation
  P? parameters;

  static const int _initialPage = 1;

  /// Initial items to populate the list
  final List<T> initialItems;

  /// Current items in the list
  List<T> _items;
  List<T> get items => _items;

  /// Current page being fetched
  int _currentPage;
  int get currentPage => _currentPage;

  /// Whether currently loading more items
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Additional pagination information
  int? totalItems;
  int? totalPages;

  /// Returns a formatted page indicator (e.g., "Page 1 / 5")
  String formattedPageIndicator(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return totalPages != null
        ? appLocalizations.page_indicator_with_total(currentPage, totalPages!)
        : appLocalizations.page_indicator(currentPage);
  }

  /// Returns a formatted item count (e.g., "25 of 100 items")
  String formattedItemCount(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return totalItems != null
        ? appLocalizations.item_count_with_total(items.length, totalItems!)
        : appLocalizations.item_count(items.length);
  }

  /// Load more items
  Future<void> loadMore(P parameters, [BuildContext? context]) async {
    if (_isLoading || (totalPages != null && !(_currentPage < totalPages!))) {
      return;
    }

    this.parameters = parameters;
    _isLoading = true;

    try {
      final List<T> newItems = await fetchItems(parameters, _currentPage + 1);
      _items.addAll(newItems);
      _currentPage++;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more items: $e')),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Reset the controller to its initial state with optional new initial items
  void reset({List<T>? newInitialItems}) {
    _currentPage = _initialPage;
    _items = newInitialItems != null
        ? List<T>.from(newInitialItems)
        : List<T>.from(initialItems);
    _isLoading = false;
    totalItems = null;
    totalPages = null;
  }

  /// Update pagination information
  void updatePaginationInfo({int? newTotalItems, int? newTotalPages}) {
    totalItems = newTotalItems;
    totalPages = newTotalPages;
  }
}
