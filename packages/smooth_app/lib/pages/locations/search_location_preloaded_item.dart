import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/favorite_location_helper.dart';
import 'package:smooth_app/pages/locations/location_map_page.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/osm_location_kind.dart';
import 'package:smooth_app/pages/prices/price_data_entry.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';

/// Location search preloaded list item, for locations historically selected.
class SearchLocationPreloadedItem extends SearchPreloadedItem {
  SearchLocationPreloadedItem(this.osmLocation, {required this.popFirst});

  final OsmLocation osmLocation;
  final bool popFirst;

  @override
  Widget getWidget(
    BuildContext context, {
    VoidCallback? onDeleteItem,
    VoidCallback? onFavoriteChanged,
  }) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final String? name = osmLocation.name;
    final String? street = osmLocation.street;
    final String? address = _address;
    final String title = name ?? street ?? address ?? osmLocation.primaryKey;

    final _SearchLocationMenu menu = _SearchLocationMenu(
      osmLocation: osmLocation,
      title: title,
      popFirst: popFirst,
      onSelect: () => _select(context),
      onDeleteItem: onDeleteItem,
      onFavoriteChanged: onFavoriteChanged,
    );

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      padding: EdgeInsets.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: () => _select(context),
        onLongPress: () => menu.show(context),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: extension.primaryBlack, fontSize: 15.0),
          child: IconTheme.merge(
            data: IconThemeData(
              color: lightTheme
                  ? extension.primaryNormal
                  : extension.primaryMedium,
              size: 20.0,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: _horizontalPadding,
                    vertical: _verticalPadding,
                  ),
                  child: Column(
                    spacing: SMALL_SPACE,
                    children: <Widget>[
                      Row(
                        spacing: VERY_SMALL_SPACE,
                        children: <Widget>[
                          Expanded(
                            child: PriceDataEntry(
                              icon: OsmLocationKind.of(osmLocation).icon,
                              label: title,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              labelPadding: const EdgeInsetsDirectional.only(
                                bottom: 2.5,
                              ),
                            ),
                          ),
                          // The heart is drawn above, with a larger tap area
                          const SizedBox.square(
                            dimension: _SearchLocationFavoriteItem.size,
                          ),
                        ],
                      ),
                      if (name != null && street != null)
                        PriceDataEntry(
                          icon: const icons.Street.road(),
                          label: street,
                          labelPadding: const EdgeInsetsDirectional.only(
                            bottom: 2.5,
                          ),
                        ),
                      Row(
                        spacing: VERY_SMALL_SPACE,
                        children: <Widget>[
                          Expanded(
                            child: address == null || address == title
                                ? EMPTY_WIDGET
                                : PriceDataEntry(
                                    icon: const icons.Location(),
                                    label: address,
                                    labelPadding:
                                        const EdgeInsetsDirectional.only(
                                          bottom: 2.5,
                                        ),
                                  ),
                          ),
                          menu,
                        ],
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  top:
                      _verticalPadding +
                      _SearchLocationFavoriteItem.iconPadding -
                      _SearchLocationFavoriteItem.tapPadding,
                  end:
                      _horizontalPadding +
                      _SearchLocationFavoriteItem.iconPadding -
                      _SearchLocationFavoriteItem.tapPadding,
                  child: _SearchLocationFavoriteItem(
                    osmLocation: osmLocation,
                    onTap: onFavoriteChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _horizontalPadding = SMALL_SPACE + MEDIUM_SPACE;
  static const double _verticalPadding = SMALL_SPACE + BALANCED_SPACE;

  void _select(BuildContext context) {
    if (popFirst) {
      // pops this result page
      Navigator.of(context).pop();
    }
    // returns the result from search page
    Navigator.of(context).pop(osmLocation);
  }

  /// e.g. "75019 Paris (France)".
  ///
  /// Unlike [OsmLocation.getSubtitle], without the OSM tag: the icon shows it.
  String? get _address {
    final String place = <String>[
      ?osmLocation.postcode,
      ?osmLocation.city,
    ].join(' ');
    final String? country = osmLocation.country;
    if (country == null) {
      return place.isEmpty ? null : place;
    }
    return place.isEmpty ? country : '$place ($country)';
  }

  @override
  bool isPinned(BuildContext context) => FavoriteLocationHelper().isFavorite(
    context.read<LocalDatabase>(),
    osmLocation,
  );

  @override
  Future<void> delete(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoOsmLocation(localDatabase).delete(osmLocation);
  }
}

enum _SearchLocationAction { select, favorite, openMap, delete }

class _SearchLocationMenu extends StatelessWidget {
  const _SearchLocationMenu({
    required this.osmLocation,
    required this.title,
    required this.popFirst,
    required this.onSelect,
    this.onDeleteItem,
    this.onFavoriteChanged,
  });

  final OsmLocation osmLocation;
  final String title;
  final bool popFirst;
  final VoidCallback onSelect;
  final VoidCallback? onDeleteItem;
  final VoidCallback? onFavoriteChanged;

  @override
  Widget build(BuildContext context) =>
      SmoothRoundMenuButton(onPressed: () async => show(context));

  Future<void> show(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool canDelete = onDeleteItem != null;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool isFavorite = FavoriteLocationHelper().isFavorite(
      localDatabase,
      osmLocation,
    );

    final _SearchLocationAction? action =
        await showSmoothListOfChoicesModalSheet<_SearchLocationAction>(
          context: context,
          title: appLocalizations.search_location_menu_title(title),
          labels: <String>[
            appLocalizations.search_location_select,
            if (isFavorite)
              appLocalizations.search_location_favorite_remove
            else
              appLocalizations.search_location_favorite_add,
            appLocalizations.prices_location_open_map,
            if (canDelete) appLocalizations.search_location_remove,
          ],
          prefixIcons: <Widget>[
            const icons.Favorite.check(),
            if (isFavorite)
              const icons.Heart.filled()
            else
              const icons.Heart.outline(),
            const icons.Map.marker(),
            if (canDelete) const icons.Trash(),
          ],
          values: <_SearchLocationAction>[
            _SearchLocationAction.select,
            _SearchLocationAction.favorite,
            _SearchLocationAction.openMap,
            if (canDelete) _SearchLocationAction.delete,
          ],
        );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _SearchLocationAction.select:
        onSelect();
      case _SearchLocationAction.favorite:
        await FavoriteLocationHelper().setFavorite(
          localDatabase,
          osmLocation,
          !isFavorite,
        );
        onFavoriteChanged?.call();
      case _SearchLocationAction.openMap:
        await Navigator.push<OsmLocation>(
          context,
          MaterialPageRoute<OsmLocation>(
            builder: (BuildContext context) =>
                LocationMapPage(osmLocation, popFirst: popFirst),
          ),
        );
      case _SearchLocationAction.delete:
        onDeleteItem?.call();
    }
  }
}

class _SearchLocationFavoriteItem extends StatelessWidget {
  const _SearchLocationFavoriteItem({required this.osmLocation, this.onTap});

  static const double iconSize = 24.0;

  /// In the layout of the card.
  static const double iconPadding = VERY_SMALL_SPACE;
  static const double size = iconSize + 2 * iconPadding;

  /// Around the icon, for the tap area: more than [iconPadding].
  static const double tapPadding = (kMinInteractiveDimension - iconSize) / 2;

  final OsmLocation osmLocation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalDatabase>(
      builder: (BuildContext context, LocalDatabase localDatabase, _) {
        final SmoothColorsThemeExtension theme = context
            .extension<SmoothColorsThemeExtension>();

        final bool isFavorite = FavoriteLocationHelper().isFavorite(
          localDatabase,
          osmLocation,
        );

        return IconButton(
          tooltip: isFavorite
              ? AppLocalizations.of(context).search_location_favorite_remove
              : AppLocalizations.of(context).search_location_favorite_add,
          iconSize: iconSize,
          icon: isFavorite
              ? const icons.Heart.filled()
              : const icons.Heart.outline(),
          style: IconButton.styleFrom(
            foregroundColor: isFavorite ? theme.secondaryVibrant : null,
            overlayColor: theme.secondaryVibrant,
            padding: const EdgeInsets.all(tapPadding),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () async {
            // Read at tap time: the build snapshot may be stale after a
            // quick double tap.
            final bool target = !FavoriteLocationHelper().isFavorite(
              localDatabase,
              osmLocation,
            );

            await FavoriteLocationHelper().setFavorite(
              localDatabase,
              osmLocation,
              target,
            );

            onTap?.call();
          },
        );
      },
    );
  }
}
