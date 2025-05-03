import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';

/// A generic stateful widget for infinite scrolling lists.
class InfiniteScrollList<T, P, R> extends StatefulWidget {
  const InfiniteScrollList({
    required this.controller,
    required this.itemBuilder,
    required this.parameters,
  });

  /// Controller for managing the infinite scroll behavior
  final InfiniteScrollController<T, P, R> controller;

  /// Builder for individual list items
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Parameters for fetching items
  final P parameters;

  @override
  State<InfiniteScrollList<T, P, R>> createState() =>
      _InfiniteScrollListState<T, P, R>();
}

class _InfiniteScrollListState<T, P, R>
    extends State<InfiniteScrollList<T, P, R>> {
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
      await widget.controller.loadInitiallyIfNeeded(widget.parameters, context);
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
    if (widget.controller.isLoading ||
        !(widget.controller.totalPages == null ||
            widget.controller.currentPage < widget.controller.totalPages!)) {
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
      setState(() {});
      await widget.controller.loadMore(widget.parameters, context);
      if (mounted) {
        setState(() {});
      }
    }
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

  Widget _buildFooter(BuildContext context) {
    return const SizedBox(height: MINIMUM_TOUCH_SIZE * 2);
  }

  Widget _buildHeader(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    String title;
    final int totalPages = widget.controller.totalPages ?? 1;
    final int currentPage = widget.controller.currentPage;
    final int itemsCount = widget.controller.items.length;
    final int totalItems = widget.controller.totalItems ?? itemsCount;

    if (totalPages > 1) {
      title = appLocalizations.prices_list_length_many_pages(
        itemsCount,
        totalItems,
      );
      title = '$title ($currentPage / $totalPages)';
    } else {
      title = appLocalizations.prices_list_length_one_page(
        itemsCount,
      );
    }

    return SmoothCard(child: ListTile(title: Text(title)));
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

    children.add(_buildHeader(context));

    for (final T item in widget.controller.items) {
      children.add(widget.itemBuilder(context, item));
    }

    if (widget.controller.isLoading) {
      children.add(_buildLoadingMoreIndicator(context));
    }

    children.add(_buildFooter(context));

    return ListView(
      controller: _scrollController,
      children: children,
    );
  }
}
