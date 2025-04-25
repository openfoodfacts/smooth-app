import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';

/// A generic stateful widget for infinite scrolling lists.
class InfiniteScrollList<T, P> extends StatefulWidget {
  const InfiniteScrollList({
    required this.controller,
    required this.itemBuilder,
    required this.parameters,
    this.headerBuilder,
  });

  /// Controller for managing the infinite scroll behavior
  final InfiniteScrollController<T, P> controller;

  /// Builder for individual list items
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Optional builder for header
  final Widget Function(BuildContext context)? headerBuilder;

  /// Parameters for fetching items
  final P parameters;

  @override
  State<InfiniteScrollList<T, P>> createState() =>
      _InfiniteScrollListState<T, P>();
}

class _InfiniteScrollListState<T, P> extends State<InfiniteScrollList<T, P>> {
  // Hardcoded constant
  static const double _loadMoreTriggerOffset = 200.0;

  late final ScrollController _scrollController;
  Object? _error;
  bool _isInitialLoading = false;

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
      unawaited(_resetAndReload());
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

      widget.controller.reset(newInitialItems: items);
      widget.controller.hasMoreItems = hasMore;
    } catch (e) {
      _error = e;
    } finally {
      if (mounted) {
        setState(() {
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

    if (currentScroll > maxScroll - _loadMoreTriggerOffset) {
      unawaited(_loadMoreItems());
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
    return _resetAndReload();
  }

  // Default widget builders
  Widget _buildLoadingState(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Text(error.toString());
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Text('No results');
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return const SizedBox(height: MINIMUM_TOUCH_SIZE * 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return _buildLoadingState(context);
    }

    if (_error != null) {
      return _buildErrorState(context, _error);
    }

    if (widget.controller.items.isEmpty) {
      return _buildEmptyState(context);
    }

    final List<Widget> children = <Widget>[];

    // Add header if provided
    if (widget.headerBuilder != null) {
      children.add(widget.headerBuilder!(context));
    }

    // Add list items
    for (int i = 0; i < widget.controller.items.length; i++) {
      children.add(widget.itemBuilder(context, widget.controller.items[i]));
    }

    // Add loading indicator at the bottom if loading more
    if (widget.controller.isLoading) {
      children.add(_buildLoadingMoreIndicator(context));
    }

    // Add footer
    children.add(_buildFooter(context));

    final ListView listView = ListView(
      controller: _scrollController,
      children: children,
    );

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: listView,
    );
  }
}
