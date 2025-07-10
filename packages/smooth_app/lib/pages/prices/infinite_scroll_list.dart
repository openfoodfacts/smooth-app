import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';

/// A generic stateful widget for infinite scrolling lists that works with InfiniteScrollManager.
class InfiniteScrollList<T> extends StatefulWidget {
  const InfiniteScrollList({required this.manager});

  /// Manager for handling the infinite scroll behavior
  final InfiniteScrollManager<T> manager;

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  static const double _loadMoreTriggerOffset = 200.0;

  late final ScrollController _scrollController;
  Object? _error;
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    unawaited(_initialLoad());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });

    try {
      await widget.manager.loadInitiallyIfNeeded(context);
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
    if (!widget.manager.canLoadMore()) {
      return;
    }

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (currentScroll > maxScroll - _loadMoreTriggerOffset) {
      unawaited(_loadMoreItems());
    }
  }

  Future<void> _loadMoreItems() async {
    if (!mounted) {
      return;
    }
    setState(() {});
    await widget.manager.loadMore(context);
    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SmoothFloatingSnackbar(content: Text(_getItemCount(context))),
    );
  }

  String _getItemCount(BuildContext context) =>
      widget.manager.formattedItemCount(context);

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return Center(child: Text(_error.toString()));
    }

    if (widget.manager.items.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).prices_no_result));
    }

    // Calculate total item count: header + items + optional loading indicator + footer spacer
    final int itemCount = 1 + // header
        widget.manager.items.length + // items
        (widget.manager.isLoading ? 1 : 0) + // loading indicator
        1; // footer spacer

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        // Header with item count
        if (index == 0) {
          return SmoothCard(child: ListTile(title: Text(_getItemCount(context))));
        }
        
        // Items
        final int itemIndex = index - 1;
        if (itemIndex < widget.manager.items.length) {
          return widget.manager.buildItem(
            context: context,
            item: widget.manager.items[itemIndex],
          );
        }
        
        // Loading indicator
        if (widget.manager.isLoading && itemIndex == widget.manager.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        
        // Footer spacer
        return const SizedBox(height: MINIMUM_TOUCH_SIZE * 2);
      },
    );
  }
}
