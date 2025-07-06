import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';

/// A generic stateful widget for infinite scrolling lists that works with InfiniteScrollManager.
class InfiniteScrollSliverList<T> extends StatefulWidget {
  const InfiniteScrollSliverList({required this.manager});

  /// Manager for handling the infinite scroll behavior
  final InfiniteScrollManager<T> manager;

  @override
  State<InfiniteScrollSliverList<T>> createState() =>
      _InfiniteScrollSliverListState<T>();
}

class _InfiniteScrollSliverListState<T>
    extends State<InfiniteScrollSliverList<T>> {
  static const double _loadMoreTriggerOffset = 200.0;

  late ScrollController _scrollController;
  Object? _error;
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialLoad());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scrollController = PrimaryScrollController.of(context)
      ..replaceListener(_scrollListener);
  }

  @override
  void didUpdateWidget(InfiniteScrollSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scrollController = PrimaryScrollController.of(context)
      ..replaceListener(_scrollListener);

    if (oldWidget.manager != widget.manager) {
      unawaited(_initialLoad());
    }
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(child: Center(child: Text(_error.toString())));
    }

    final List<T> items = widget.manager.items;
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(AppLocalizations.of(context).prices_no_result),
        ),
      );
    }

    return MultiSliver(
      children: <Widget>[
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final T item = items[index];
            return widget.manager.buildItem(context: context, item: item);
          },
        ),
      ],
    );
  }
}
