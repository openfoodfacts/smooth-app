import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PreferencesRootSearchController extends SearchHelper {
  PreferencesRootSearchController();

  String? query;

  @override
  void search(
    BuildContext context,
    String? keywords, {
    required Function(String) searchQueryCallback,
  }) {
    query = keywords;
    notifyListeners();
  }

  void clear() {
    query = null;
    notifyListeners();
  }

  @override
  String getHintText(AppLocalizations appLocalizations) {
    return appLocalizations.preferences_app_bar_search_hint;
  }

  @override
  String get historyKey => 'preferences_root_search_history';
}

/// Base class for all preference roots.
/// [PreferencesRoot] corresponds to a page where each root can have its own
/// app bar and cards.
/// The [getCards] method should be overridden to provide the cards for the root.
/// The [getExternalSearchTiles] method can be overridden to provide external
/// search tiles for the root which will be displayed in the search results only.
/// The [buildAppBar] method can be overridden to provide a custom app bar for
/// the root.
/// The [PreferencesRoot] also handles the search logic. When the user searches
/// for a tile, the cards are replaced by individual tiles that match the search
/// query.
/// The search query is performed deep in the widget tree.
abstract class PreferencesRoot extends StatefulWidget {
  const PreferencesRoot({super.key, this.title, this.customAppBar})
    : assert(
        title != null || customAppBar != null,
        'Either title or customAppBar must be provided',
      );

  final String? title;
  final Widget? customAppBar;

  List<PreferenceCard> getCards(BuildContext context);

  WidgetBuilder? getHeader() => null;

  WidgetBuilder? getFooter() => null;

  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
    BuildContext context,
  ) => <ExternalSearchPreferenceTile>[];

  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];
    final List<PreferenceCard> cards = getCards(context);

    for (final PreferenceCard card in cards) {
      if (card.grid) {
        continue;
      }

      for (final PreferenceTile tile in card.tiles) {
        if (tile.keywords.toLowerCase().contains(query.toLowerCase())) {
          matchingTiles.add(tile);
        }

        if (tile is NavigationPreferenceTile && tile.root != null) {
          matchingTiles.addAll(tile.root!.searchTiles(context, query));
        }
      }
    }

    return matchingTiles;
  }

  Widget buildAppBar(BuildContext context) {
    if (customAppBar != null) {
      return customAppBar!;
    }

    final SmoothPopupMenuButton<dynamic>? menu = actions(context);

    return SliverPinnedHeader(
      child: SmoothAppBar(
        title: Text(title!),
        leading: const SmoothBackButton(),
        actions: menu != null ? <Widget>[menu] : null,
      ),
    );
  }

  List<PreferenceTile> searchFoodTiles(BuildContext context, String query) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesFood food = UserPreferencesFoodPage.getUserPreferences(
      userPreferences: userPreferences,
      context: context,
    );
    return food.searchTiles(context, query);
  }

  Widget buildSearchResults(BuildContext context, List<PreferenceTile> tiles) {
    final ThemeData theme = Theme.of(context);

    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => tiles[index],
      separatorBuilder: (BuildContext context, _) =>
          Divider(color: theme.dividerColor),
      itemCount: tiles.length,
    );
  }

  Widget buildCardsList(BuildContext context, List<PreferenceCard> cards) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => cards[index],
      separatorBuilder: (BuildContext context, _) =>
          const SizedBox(height: LARGE_SPACE),
      itemCount: cards.length,
    );
  }

  void prepareForBuild(BuildContext context) {}

  Widget buildScaffold(BuildContext context, Widget content) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return SmoothScaffold(
      backgroundColor: !context.darkTheme()
          ? themeExtension.primaryLight
          : null,
      body: content,
    );
  }

  SmoothPopupMenuButton<dynamic>? actions(BuildContext context) => null;

  @override
  State<PreferencesRoot> createState() => _PreferencesRootState();
}

class _PreferencesRootState extends State<PreferencesRoot> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.prepareForBuild(context);

    final PreferencesRootSearchController searchController = context
        .watch<PreferencesRootSearchController>();

    final bool displayTiles =
        searchController.query != null && searchController.query!.isNotEmpty;

    List<PreferenceTile> tiles = <PreferenceTile>[];
    if (displayTiles) {
      tiles = <PreferenceTile>[
        ...widget.searchTiles(context, searchController.query!),
        ...widget.searchFoodTiles(context, searchController.query!),
        ...widget.getExternalSearchTiles(context),
      ];
    }

    final WidgetBuilder? header = widget.getHeader();
    final WidgetBuilder? footer = widget.getFooter();

    Widget sliver;
    if (displayTiles) {
      sliver = widget.buildSearchResults(context, tiles);
    } else if (_focusNode.hasFocus) {
      sliver = const SliverFillRemaining();
    } else {
      sliver = widget.buildCardsList(context, widget.getCards(context));
    }

    final Widget content = MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ScrollController>.value(
          value: _scrollController,
        ),
        ChangeNotifierProvider<FocusNode>.value(value: _focusNode),
      ],
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          widget.buildAppBar(context),
          if (header != null) SliverToBoxAdapter(child: header.call(context)),
          SliverPadding(
            padding: EdgeInsetsDirectional.only(
              top: displayTiles ? 0.0 : LARGE_SPACE,
              start: displayTiles ? 0.0 : MEDIUM_SPACE,
              end: displayTiles ? 0.0 : MEDIUM_SPACE,
              bottom: VERY_LARGE_SPACE,
            ),
            sliver: sliver,
          ),
          if (footer != null) ...<Widget>[
            SliverFillRemaining(
              fillOverscroll: false,
              hasScrollBody: false,
              child: Column(
                children: <Widget>[const Spacer(), footer.call(context)],
              ),
            ),
          ],
        ],
      ),
    );

    return widget.buildScaffold(context, content);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
