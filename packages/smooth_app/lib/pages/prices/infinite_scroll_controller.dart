import 'dart:async';

/// A generic controller for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
/// [P] is the type of parameters used for pagination.
class InfiniteScrollController<T, P> {
  InfiniteScrollController({
    required this.fetchItems,
    Iterable<T> initialItems = const <Never>[],
    this.initialPage = 1,
    this.onError,
  })  : _currentPage = initialPage,
        _items = List<T>.from(initialItems),
        initialItems = List<T>.from(initialItems);

  /// Returns a Future with the fetched items and a boolean indicating if more items can be loaded
  final Future<(List<T>, bool)> Function(P parameters, int page) fetchItems;

  /// Parameters for the fetch operation
  P? parameters;

  /// Initial page number
  final int initialPage;

  /// Initial items to populate the list
  final List<T> initialItems;

  /// Called when an error occurs during fetching
  final Function(dynamic error)? onError;

  /// Current items in the list
  List<T> _items;
  List<T> get items => _items;

  /// Current page being fetched
  int _currentPage;
  int get currentPage => _currentPage;

  /// Whether currently loading more items
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Whether more items can be loaded
  bool _hasMoreItems = true;

  /// Set whether more items can be loaded
  set hasMoreItems(bool value) {
    _hasMoreItems = value;
  }

  /// Computed property for hasMoreItems that considers both the explicit flag and page information
  bool get hasMoreItems {
    if (!_hasMoreItems) {
      return false;
    }
    if (totalPages == null) {
      return _hasMoreItems;
    }
    return _currentPage < totalPages!;
  }

  /// Additional pagination information
  int? totalItems;
  int? totalPages;

  /// Load more items
  Future<void> loadMore(P parameters) async {
    if (_isLoading || !hasMoreItems) {
      return;
    }

    this.parameters = parameters;
    _isLoading = true;

    try {
      final (List<T> newItems, bool hasMore) =
          await fetchItems(parameters, _currentPage + 1);

      _items.addAll(newItems);
      _currentPage++;
      _hasMoreItems = hasMore;
    } catch (e) {
      onError?.call(e);
    } finally {
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
    _hasMoreItems = true;
  }

  /// Update pagination metadata
  void updatePaginationInfo({int? newTotalItems, int? newTotalPages}) {
    totalItems = newTotalItems;
    totalPages = newTotalPages;
  }
}
