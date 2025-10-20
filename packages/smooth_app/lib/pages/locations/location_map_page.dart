import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_app/data_models/location_osm_type_extension.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays a map centered on a location.
class LocationMapPage extends StatelessWidget {
  const LocationMapPage(this.osmLocation, {required this.popFirst});

  final OsmLocation osmLocation;
  final bool popFirst;

  @override
  Widget build(BuildContext context) {
    const double markerSize = 50;
    final LatLng latLng = osmLocation.getLatLng();
    final String? title = osmLocation.getTitle();
    final String? subtitle = osmLocation.getSubtitle();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: title == null ? null : Text(title),
        subTitle: subtitle == null
            ? null
            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            icon: const icons.Info(),
            onPressed: () => _showLocationDetails(context),
          ),
          IconButton(
            icon: const icons.Check.circled(),
            onPressed: () {
              // pops that map page
              Navigator.of(context).pop();
              if (popFirst) {
                // pops the result page
                Navigator.of(context).pop();
              }
              // returns the result
              Navigator.of(context).pop(osmLocation);
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: latLng, initialZoom: 17),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'org.openfoodfacts.app',
          ),
          MarkerLayer(
            markers: <Marker>[
              Marker(
                point: latLng,
                child: const icons.Location(
                  color: Colors.black,
                  size: markerSize,
                  shadow: Shadow(color: Colors.black26, blurRadius: 4.0),
                ),
                alignment: const Alignment(0.0, -0.9),
                width: markerSize,
                height: markerSize,
              ),
            ],
          ),
          RichAttributionWidget(
            popupInitialDisplayDuration: const Duration(seconds: 5),
            animationConfig: const ScaleRAWA(),
            attributions: <SourceAttribution>[
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => LaunchUrlHelper.launchURL(
                  'https://www.openstreetmap.org/copyright',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationDetails(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showSmoothListOfItemsModalSheet<void>(
      context: context,
      title: appLocalizations.location_map_details_title,
      items: <ModalSheetItem>[
        if (osmLocation.name != null)
          ModalSheetItem(
            title: appLocalizations.location_map_details_name,
            subTitle: osmLocation.name,
            leading: const icons.Shop(),
          ),
        if (osmLocation.street != null)
          ModalSheetItem(
            title: appLocalizations.location_map_details_street,
            subTitle: osmLocation.street,
            leading: const icons.Street(),
          ),
        if (osmLocation.city != null)
          ModalSheetItem(
            title: appLocalizations.location_map_details_city,
            subTitle: osmLocation.city,
            leading: const icons.City(),
          ),
        if (osmLocation.postcode != null)
          ModalSheetItem(
            title: appLocalizations.location_map_details_postcode,
            subTitle: osmLocation.postcode,
            leading: const icons.PostalCode(),
          ),
        if (osmLocation.country != null)
          ModalSheetItem(
            title: appLocalizations.location_map_details_country,
            subTitle: osmLocation.country,
            leading: const icons.World.location(),
          ),
        ModalSheetItem(
          title: appLocalizations.location_map_details_coordinates,
          subTitle: '${osmLocation.latitude}, ${osmLocation.longitude}',
          leading: const icons.Location(),
        ),
        ModalSheetItem(
          title: appLocalizations.location_map_details_osm_id,
          subTitle: '${osmLocation.osmType.short}${osmLocation.osmId}',
          leading: const icons.OSMLogo(),
          trailing: const icons.ExternalLink(),
          onTap: () => LaunchUrlHelper.launchURL(
            'https://www.openstreetmap.org/node/${osmLocation.osmId}',
          ),
        ),
      ],
    );
  }
}
