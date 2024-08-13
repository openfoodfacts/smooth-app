import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class KnowledgePanelWorldMapCard extends StatelessWidget {
  const KnowledgePanelWorldMapCard(this.mapElement);

  final KnowledgePanelWorldMapElement mapElement;

  @override
  Widget build(BuildContext context) {
    if (mapElement.pointers.isEmpty || mapElement.pointers.first.geo == null) {
      return EMPTY_WIDGET;
    }

    const double markerSize = 30;
    final List<Marker> markers = <Marker>[];
    final List<LatLng> coordinates = <LatLng>[];
    void addCoordinate(final LatLng latLng) {
      coordinates.add(latLng);
      markers.add(
        Marker(
          point: latLng,
          child: const Icon(Icons.pin_drop, color: Colors.lightBlue),
          alignment: Alignment.topCenter,
          width: markerSize,
          height: markerSize,
        ),
      );
    }

    for (final KnowledgePanelGeoPointer pointer in mapElement.pointers) {
      final KnowledgePanelLatLng? geo = pointer.geo;
      if (geo != null) {
        addCoordinate(LatLng(geo.lat, geo.lng));
      }
    }

    final MapOptions mapOptions;
    if (coordinates.length == 1) {
      mapOptions = MapOptions(
        initialCenter: coordinates.first,
        initialZoom: 6.0,
      );
    } else {
      mapOptions = MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: coordinates,
          maxZoom: 13.0,
          forceIntegerZoomLevel: true,
          padding: const EdgeInsets.all(markerSize),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: mapOptions,
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.openfoodfacts.app',
            ),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              popupInitialDisplayDuration: const Duration(seconds: 5),
              animationConfig: const ScaleRAWA(),
              showFlutterMapAttribution: false,
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
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      IterableProperty<String?>(
        'pointers',
        mapElement.pointers.map(
          (KnowledgePanelGeoPointer pointer) =>
              pointer.geo?.toJson().toString(),
        ),
      ),
    );
  }
}
