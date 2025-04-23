// generic_infinite_scroll.dart

import 'package:flutter/material.dart';

/// A generic class for handling infinite scrolling in lists.
/// [T] is the type of items being displayed.
/// [P] is the type of parameters used for pagination.
class InfiniteScrollController<T, P> {
  InfiniteScrollController({
    required this.fetchItems,
    Iterable<T> initialItems = _kEmptyIterable,
    this.initialPage = 1,
    this.onError,
  })  : _currentPage = initialPage,
        _items = List<T>.from(initialItems),
        initialItems = List<T>.from(initialItems);

  static const Iterable<Never> _kEmptyIterable = <Never>[];

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
  bool get hasMoreItems => _hasMoreItems;

  /// Additional pagination information
  int? totalItems;
  int? totalPages;

  /// Load more items
  Future<void> loadMore(P parameters) async {
    if (_isLoading || !_hasMoreItems) {
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

/// A generic stateful widget for infinite scrolling lists.
class InfiniteScrollList<T, P> extends StatefulWidget {
  const InfiniteScrollList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
    required this.parameters,
    this.loadMoreTriggerOffset = 200.0,
    this.loadingMoreBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.onRefresh,
  });

  /// Controller for managing the infinite scroll behavior
  final InfiniteScrollController<T, P> controller;

  /// Builder for individual list items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Builder for showing loading state
  final Widget Function(BuildContext context) loadingBuilder;

  /// Builder for showing error state
  final Widget Function(BuildContext context, dynamic error) errorBuilder;

  /// Builder for showing empty state
  final Widget Function(BuildContext context) emptyBuilder;

  /// Optional builder for showing loading more state at the bottom of the list
  final Widget Function(BuildContext context)? loadingMoreBuilder;

  /// Optional builder for header
  final Widget Function(BuildContext context)? headerBuilder;

  /// Optional builder for footer
  final Widget Function(BuildContext context)? footerBuilder;

  /// Parameters for fetching items
  final P parameters;

  /// Scroll offset from the bottom that triggers loading more items
  final double loadMoreTriggerOffset;

  /// ScrollPhysics for the ListView
  final ScrollPhysics? physics;

  /// Padding for the ListView
  final EdgeInsets? padding;

  /// Whether the ListView should shrink-wrap its contents
  final bool shrinkWrap;

  /// Callback for pull-to-refresh functionality
  final Future<void> Function()? onRefresh;

  @override
  State<InfiniteScrollList<T, P>> createState() =>
      _InfiniteScrollListState<T, P>();
}

class _InfiniteScrollListState<T, P> extends State<InfiniteScrollList<T, P>> {
  late ScrollController _scrollController;
  Object? _error;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _initialLoad();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InfiniteScrollList<T, P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parameters change, reset and reload
    if (widget.parameters != oldWidget.parameters) {
      _resetAndReload();
    }
  }

  Future<void> _initialLoad() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });

    try {
      final (List<T> items, bool hasMore) = await widget.controller
          .fetchItems(widget.parameters, widget.controller.initialPage);

      if (mounted) {
        setState(() {
          widget.controller.reset(newInitialItems: items);
          widget.controller._hasMoreItems = hasMore;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isInitialLoading = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (widget.controller.isLoading || !widget.controller.hasMoreItems) {
      return;
    }

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (currentScroll > maxScroll - widget.loadMoreTriggerOffset) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (mounted) {
      setState(() {}); // Trigger rebuild to show loading indicator
      await widget.controller.loadMore(widget.parameters);
      if (mounted) {
        setState(() {}); // Update UI with new items
      }
    }
  }

  Future<void> _resetAndReload() async {
    if (mounted) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });

      widget.controller.reset();
      await _initialLoad();
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await _resetAndReload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return widget.loadingBuilder(context);
    }

    if (_error != null) {
      return widget.errorBuilder(context, _error);
    }

    if (widget.controller.items.isEmpty) {
      return widget.emptyBuilder(context);
    }

    final List<Widget> children = <Widget>[];

    // Add header if provided
    if (widget.headerBuilder != null) {
      children.add(widget.headerBuilder!(context));
    }

    // Add list items
    for (int i = 0; i < widget.controller.items.length; i++) {
      children.add(widget.itemBuilder(context, widget.controller.items[i], i));
    }

    // Add loading indicator at the bottom if loading more
    if (widget.controller.isLoading && widget.loadingMoreBuilder != null) {
      children.add(widget.loadingMoreBuilder!(context));
    }

    // Add footer if provided
    if (widget.footerBuilder != null) {
      children.add(widget.footerBuilder!(context));
    }

    final ListView listView = ListView(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      children: children,
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: listView,
      );
    } else {
      return listView;
    }
  }
}
