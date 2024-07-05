import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/scan/search_page.dart';

/// Card that displays the location for price adding.
class PriceLocationCard extends StatelessWidget {
  const PriceLocationCard();

  static const IconData _iconTodo = CupertinoIcons.exclamationmark;
  static const IconData _iconDone = Icons.place;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OsmLocation? location = model.location;
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_location_subtitle),
          SmoothLargeButtonWithIcon(
            text: location == null
                ? appLocalizations.prices_location_find
                : location.getTitle() ??
                    location.getSubtitle() ??
                    location.getLatLng().toString(),
            icon: location == null ? _iconTodo : _iconDone,
            onPressed: () async {
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              final List<SearchLocationPreloadedItem> preloadedList =
                  <SearchLocationPreloadedItem>[];
              for (final OsmLocation osmLocation in model.locations) {
                preloadedList.add(
                  SearchLocationPreloadedItem(
                    osmLocation,
                    popFirst: false,
                  ),
                );
              }
              final OsmLocation? osmLocation =
                  await Navigator.push<OsmLocation>(
                context,
                MaterialPageRoute<OsmLocation>(
                  builder: (BuildContext context) => SearchPage(
                    const SearchLocationHelper(),
                    preloadedList: preloadedList,
                    autofocus: false,
                  ),
                ),
              );
              if (osmLocation == null) {
                return;
              }
              final DaoOsmLocation daoOsmLocation =
                  DaoOsmLocation(localDatabase);
              await daoOsmLocation.put(osmLocation);
              final List<OsmLocation> newOsmLocations =
                  await daoOsmLocation.getAll();
              model.locations = newOsmLocations;
            },
          ),
        ],
      ),
    );
  }
}
