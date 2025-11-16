import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/empty_screen_layout.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/product/query_results_banner.dart';

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
      widget.manager.formattedItemCount(
        context,
        widget.manager.items.length,
        widget.manager.totalItems,
      );

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return Center(child: Text(_error.toString()));
    }

    if (widget.manager.items.isEmpty) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return EmptyScreenLayout(
        icon: widget.manager.emptyListIcon,
        title: widget.manager.emptyListTitle(appLocalizations),
        explanation: widget.manager.emptyListExplanation(appLocalizations),
      );
    }

    final List<Widget> children = <Widget>[];

    children.add(
      QueryResultsBanner(
        mainText: _getItemCount(context),
        margin: const EdgeInsetsDirectional.only(top: BALANCED_SPACE),
      ),
    );

    for (final T item in widget.manager.items) {
      children.add(widget.manager.buildItem(context: context, item: item));
    }

    if (widget.manager.isLoading) {
      children.add(
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: LARGE_SPACE),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    children.add(const SizedBox(height: MINIMUM_TOUCH_SIZE * 2));

    return ListView.builder(
      controller: _scrollController,
      itemCount: children.length,
      itemBuilder: (BuildContext context, int index) => children[index],
    );
  }
}
