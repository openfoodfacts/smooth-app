import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A generic controller for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
/// [P] is the type of parameters used for pagination.
/// [R] is the type of result returned from the fetch operation.
class InfiniteScrollController<T, P, R> {
  InfiniteScrollController({
    required Future<R> Function(P parameters, int page,
            {void Function(int? totalItems, int? totalPages)?
                onPageInfoUpdated})
        fetchResult,
    required List<T> Function(R result) extractItems,
    Iterable<T>? initialItems,
  })  : _fetchResult = fetchResult,
        _extractItems = extractItems,
        _currentPage =
            initialItems != null && initialItems.isNotEmpty ? _initialPage : 0,
        _items = List<T>.from(initialItems ?? <T>[]);

  /// Future with the fetched items
  final Future<R> Function(P parameters, int page,
          {void Function(int? totalItems, int? totalPages)? onPageInfoUpdated})
      _fetchResult;

  /// Function to extract items from the result
  final List<T> Function(R result) _extractItems;

  /// Parameters for the fetch operation
  P? parameters;

  static const int _initialPage = 1;

  /// Current items in the list
  final List<T> _items;
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
  /// Private method to load items for a specific page
  Future<void> _load(P parameters, BuildContext context, int page) async {
    if (_isLoading) {
      return;
    }

    this.parameters = parameters;
    _isLoading = true;

    try {
      final R result = await _fetchResult(
        parameters,
        page,
        onPageInfoUpdated: (int? newTotalItems, int? newTotalPages) {
          _updatePaginationInfo(
              newTotalItems: newTotalItems, newTotalPages: newTotalPages);
        },
      );

      // Extract items from the result
      final List<T> newItems = _extractItems(result);

      if (page == _initialPage) {
        _items.clear();
      }

      _items.addAll(newItems);
      _currentPage = page;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .prices_error_loading_more_items)),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Load initial data only if the list is empty
  Future<void> loadInitiallyIfNeeded(P parameters, BuildContext context) async {
    if (_items.isNotEmpty) {
      return;
    }
    await _load(parameters, context, _initialPage);
  }

  /// Load more items (next page)
  Future<void> loadMore(P parameters, BuildContext context) async {
    if (totalPages != null && !(_currentPage < totalPages!)) {
      return;
    }
    await _load(parameters, context, _currentPage + 1);
  }

  /// Update pagination information
  void _updatePaginationInfo({int? newTotalItems, int? newTotalPages}) {
    totalItems = newTotalItems;
    totalPages = newTotalPages;
  }
}
