import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/locations/favorite_location_helper.dart';
import 'package:smooth_app/pages/locations/location_map_page.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';

/// Location search preloaded list item, for locations historically selected.
class SearchLocationPreloadedItem extends SearchPreloadedItem {
  SearchLocationPreloadedItem(this.osmLocation, {required this.popFirst});

  final OsmLocation osmLocation;
  final bool popFirst;

  @override
  Widget getWidget(
    final BuildContext context, {
    final VoidCallback? onDismissItem,
  }) {
    final String? title = osmLocation.getTitle();
    final String? subtitle = osmLocation.getSubtitle();
    final Widget child = SmoothCard(
      child: ListTile(
        leading: Consumer<LocalDatabase>(
          builder: (BuildContext context, LocalDatabase localDatabase, _) {
            final bool isFavorite = FavoriteLocationHelper().isFavorite(
              localDatabase,
              osmLocation,
            );

            return IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async => FavoriteLocationHelper().setFavorite(
                localDatabase,
                osmLocation,
                !isFavorite,
              ),
            );
          },
        ),
        onTap: () {
          if (popFirst) {
            // pops this result page
            Navigator.of(context).pop();
          }
          // returns the result from search page
          Navigator.of(context).pop(osmLocation);
        },
        title: title == null ? null : Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: IconButton(
          onPressed: () async => Navigator.push<OsmLocation>(
            context,
            MaterialPageRoute<OsmLocation>(
              builder: (BuildContext context) =>
                  LocationMapPage(osmLocation, popFirst: popFirst),
            ),
          ),
          icon: const Icon(Icons.map),
        ),
      ),
    );
    if (onDismissItem == null) {
      return child;
    }
    return Dismissible(
      key: Key('${osmLocation.osmType}${osmLocation.osmId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) async => onDismissItem(),
      background: Container(
        color: RED_COLOR,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: LARGE_SPACE * 2),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: child,
    );
  }

  @override
  Future<void> delete(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoOsmLocation(localDatabase).delete(osmLocation);
  }
}
