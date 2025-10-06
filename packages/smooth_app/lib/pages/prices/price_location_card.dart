import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Card that displays the location for price adding.
class PriceLocationCard extends StatelessWidget {
  const PriceLocationCard({required this.onLocationChanged});

  final Function(OsmLocation location) onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OsmLocation? location = model.location;

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_location_subtitle,
      leading: const icons.Shopping.cart(),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: SmoothLargeButtonWithIcon(
        text: location == null
            ? appLocalizations.prices_location_find
            : location.getTitle() ??
                  location.getSubtitle() ??
                  location.getLatLng().toString(),
        leadingIcon: const icons.Location(),
        onPressed: model.proof != null
            ? null
            : () async {
                final LocalDatabase localDatabase = context
                    .read<LocalDatabase>();
                final List<SearchLocationPreloadedItem> preloadedList =
                    <SearchLocationPreloadedItem>[];
                final List<OsmLocation> locations = await DaoOsmLocation(
                  localDatabase,
                ).getAll();
                if (!context.mounted) {
                  return;
                }
                for (final OsmLocation osmLocation in locations) {
                  preloadedList.add(
                    SearchLocationPreloadedItem(osmLocation, popFirst: false),
                  );
                }
                final OsmLocation? osmLocation =
                    await Navigator.push<OsmLocation>(
                      context,
                      MaterialPageRoute<OsmLocation>(
                        builder: (BuildContext context) => SearchPage(
                          SearchLocationHelper(),
                          preloadedList: preloadedList,
                          autofocus: false,
                        ),
                      ),
                    );
                if (osmLocation == null) {
                  return;
                }
                final DaoOsmLocation daoOsmLocation = DaoOsmLocation(
                  localDatabase,
                );
                await daoOsmLocation.put(osmLocation);

                onLocationChanged.call(osmLocation);
              },
      ),
    );
  }
}
