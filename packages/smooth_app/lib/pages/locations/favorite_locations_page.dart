import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/favorite_location_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class FavoriteLocationsPage extends StatefulWidget {
  const FavoriteLocationsPage();

  @override
  State<FavoriteLocationsPage> createState() => _FavoriteLocationsPageState();
}

class _FavoriteLocationsPageState extends State<FavoriteLocationsPage> {
  late Future<Map<String, OsmLocation?>> _favorites;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favorites = FavoriteLocationHelper().getFavorites(
      context.watch<LocalDatabase>(),
    );
  }

  void _reload() {
    setState(() {
      _favorites = FavoriteLocationHelper().getFavorites(
        context.read<LocalDatabase>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.prices_favorite_stores),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_favorite_stores_add,
                leadingIcon: const icons.Add(),
                onPressed: _busy ? null : _addStore,
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, OsmLocation?>>(
                future: _favorites,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<Map<String, OsmLocation?>> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return SingleChildScrollView(
                          child: SmoothErrorCard(
                            errorMessage: snapshot.error.toString(),
                            tryAgainFunction: _reload,
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      final List<MapEntry<String, OsmLocation?>> favorites =
                          snapshot.data!.entries.toList();
                      if (favorites.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(LARGE_SPACE),
                            child: Text(
                              appLocalizations.prices_favorite_stores_empty,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MapEntry<String, OsmLocation?> favorite =
                              favorites[index];
                          final OsmLocation? location = favorite.value;
                          final String? subtitle = location?.getSubtitle();
                          return SmoothCard(
                            child: ListTile(
                              title: Text(
                                location?.getTitle() ??
                                    appLocalizations
                                        .prices_favorite_stores_unknown,
                              ),
                              subtitle: location == null
                                  ? Text(
                                      appLocalizations
                                          .prices_favorite_stores_unavailable,
                                    )
                                  : subtitle == null
                                  ? null
                                  : Text(subtitle),
                              trailing: IconButton(
                                tooltip: appLocalizations
                                    .prices_favorite_stores_remove,
                                icon: const icons.Heart.filled(),
                                style: IconButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                onPressed: _busy
                                    ? null
                                    : () => _update(
                                        () => FavoriteLocationHelper()
                                            .removeFavorite(
                                              context.read<LocalDatabase>(),
                                              favorite.key,
                                            ),
                                      ),
                              ),
                            ),
                          );
                        },
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStore() async {
    await _update(() async {
      final LocalDatabase localDatabase = context.read<LocalDatabase>();
      final List<OsmLocation> locations = await DaoOsmLocation(
        localDatabase,
      ).getAll();
      if (!mounted) {
        return;
      }
      final OsmLocation? location = await Navigator.of(context)
          .push<OsmLocation>(
            MaterialPageRoute<OsmLocation>(
              builder: (BuildContext context) => SearchPage(
                SearchLocationHelper(),
                preloadedList: <SearchLocationPreloadedItem>[
                  for (final OsmLocation location in locations)
                    SearchLocationPreloadedItem(location, popFirst: false),
                ],
                autofocus: false,
              ),
            ),
          );
      if (location != null) {
        await FavoriteLocationHelper().setFavorite(
          localDatabase,
          location,
          true,
        );
      }
    });
  }

  Future<void> _update(final Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).error)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
