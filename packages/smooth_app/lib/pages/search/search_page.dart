import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/pages/search/search_history_view.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// The [SearchPage] screen.
/// It can opened directly with the [SearchPageExtra] constructor.
/// From GoRouter, the page is named [AppRoutes.SEARCH] and we need to pass a
/// [SearchPageExtra] object for extras.
class SearchPage extends StatefulWidget {
  const SearchPage(
    this.searchHelper, {
    this.preloadedList,
    this.autofocus = true,
    this.heroTag,
  });

  SearchPage.fromExtra(SearchPageExtra extra)
    : this(
        extra.searchHelper,
        preloadedList: extra.preloadedList,
        autofocus: extra.autofocus ?? true,
        heroTag: extra.heroTag,
      );

  final SearchHelper searchHelper;
  final List<SearchPreloadedItem>? preloadedList;
  final bool autofocus;
  final String? heroTag;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class SearchPageExtra {
  const SearchPageExtra({
    required this.searchHelper,
    this.preloadedList,
    this.autofocus,
    this.heroTag,
  });

  final SearchHelper searchHelper;
  final List<SearchPreloadedItem>? preloadedList;

  /// If not passed, will default to [false]
  final bool? autofocus;
  final String? heroTag;
}

class _SearchPageState extends State<SearchPage> {
  // https://github.com/openfoodfacts/smooth-app/pull/2219
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope2(
      onWillPop: () async {
        /// For the world view, we need to intercept the back button from here
        /// See below for the custom [Navigator]
        if (widget.searchHelper.value != null) {
          setState(() => widget.searchHelper.value = null);
          return (false, null);
        }
        return (true, null);
      },
      child: MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<TextEditingController>.value(
            value: _searchTextController,
          ),
          ChangeNotifierProvider<SearchHelper>.value(
            value: widget.searchHelper,
          ),
        ],
        child: SmoothScaffold(
          body: Column(
            children: <Widget>[
              ValueNotifierListener<SearchHelper, SearchQuery?>(
                listener: _onSearchChanged,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: SMALL_SPACE,
                      horizontal: BALANCED_SPACE,
                    ),
                    child: SearchField(
                      autofocus: widget.autofocus,
                      focusNode: _searchFocusNode,
                      searchHelper: widget.searchHelper,
                      heroTag: widget.heroTag,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<SearchHelper>(
                  builder: (BuildContext context, SearchHelper searchHelper, _) {
                    /// Show the history when there is no search
                    if (searchHelper.value == null) {
                      return SearchHistoryView(
                        focusNode: _searchFocusNode,
                        onTap: (String query) =>
                            widget.searchHelper.searchWithController(
                              context,
                              query,
                              _searchTextController,
                              _searchFocusNode,
                            ),
                        searchHelper: widget.searchHelper,
                        preloadedList:
                            widget.preloadedList ?? <SearchPreloadedItem>[],
                      );
                    } else {
                      /// A custom [Navigator] is used to intercept the World
                      /// results to be embedded in this part of the screen and
                      /// not on a new one.
                      return Navigator(
                        key: _navigatorKey,
                        pages: <MaterialPage<dynamic>>[
                          MaterialPage<void>(child: searchHelper.value!.widget),
                        ],
                        onDidRemovePage: (_) {
                          /// Mandatory to provide this method
                          /// The event is intercepted by the [WillPopScope2]
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(
    BuildContext context,
    SearchQuery? oldValue,
    SearchQuery? value,
  ) {
    if (value != null && _searchTextController.text != value.search) {
      /// Update the search field when an history item is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchTextController.text = value.search;
      });
    } else if (oldValue != null) {
      /// If we were on the world results, ensure to go back to
      /// the main list of results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.popUntil((Route<dynamic> route) {
          return route.isFirst;
        });
      });
    }
  }
}
