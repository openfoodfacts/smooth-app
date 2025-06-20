import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';

/// A generic stateful widget for infinite scrolling lists that works with InfiniteScrollManager.
class InfiniteScrollList<T> extends StatefulWidget {
  const InfiniteScrollList({
    required this.manager,
  });

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
      SmoothFloatingSnackbar(
        content: Text(_getItemCount(context)),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Text(error.toString());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(AppLocalizations.of(context).prices_no_result);
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  String _getItemCount(BuildContext context) =>
      widget.manager.formattedItemCount(context);

  Widget _buildFooter(BuildContext context) {
    return const SizedBox(height: MINIMUM_TOUCH_SIZE * 2);
  }

  Widget _buildHeader(BuildContext context) => SmoothCard(
        child: ListTile(
          title: Text(
            _getItemCount(context),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return _buildLoadingState(context);
    }

    if (_error != null) {
      return _buildErrorState(context, _error);
    }

    if (widget.manager.items.isEmpty) {
      return _buildEmptyState(context);
    }

    final List<Widget> children = <Widget>[];

    children.add(_buildHeader(context));

    for (final T item in widget.manager.items) {
      children.add(widget.manager.getItemWidget(
        context: context,
        item: item,
      ));
    }

    if (widget.manager.isLoading) {
      children.add(_buildLoadingMoreIndicator(context));
    }

    children.add(_buildFooter(context));

    return ListView(
      controller: _scrollController,
      children: children,
    );
  }
}
