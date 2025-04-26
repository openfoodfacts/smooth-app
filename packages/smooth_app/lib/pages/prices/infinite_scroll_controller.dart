import 'dart:async';

/// A generic controller for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
/// [P] is the type of parameters used for pagination.
class InfiniteScrollController<T, P> {
  InfiniteScrollController({
    required this.fetchItems,
    Iterable<T> initialItems = const <Never>[],
    this.initialPage = 1,
  })  : _currentPage = initialPage,
        _items = List<T>.from(initialItems),
        initialItems = List<T>.from(initialItems);

  /// Returns a Future with the fetched items
  final Future<List<T>> Function(P parameters, int page) fetchItems;

  /// Parameters for the fetch operation
  P? parameters;

  /// Initial page number
  final int initialPage;

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
  String get formattedPageIndicator {
    return totalPages != null
        ? 'Page $currentPage / $totalPages'
        : 'Page $currentPage';
  }

  /// Returns a formatted item count (e.g., "25 of 100 items")
  String get formattedItemCount {
    return totalItems != null
        ? '${items.length} of $totalItems items'
        : '${items.length} items';
  }

  /// Load more items
  Future<void> loadMore(P parameters) async {
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
      _isLoading = false;
    }
  }

  /// Reset the controller to its initial state with optional new initial items
  void reset({List<T>? newInitialItems}) {
    _currentPage = initialPage;
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
