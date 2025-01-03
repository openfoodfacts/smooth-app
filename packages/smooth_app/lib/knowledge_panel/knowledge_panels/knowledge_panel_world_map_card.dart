import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/product/world_map_page.dart';

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

    final MapOptions mapOptions = _generateMapOptions(
      coordinates: coordinates,
      markerSize: markerSize,
      interactive: false,
    );

    final List<Widget> children = <Widget>[
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'org.openfoodfacts.app',
      ),
      MarkerLayer(markers: markers),
      RichAttributionWidget(
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
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
      child: SizedBox(
        height: 200,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<Widget>(
                builder: (_) => WorldMapPage(
                  title: _getTitle(context),
                  mapOptions: _generateMapOptions(
                    coordinates: coordinates,
                    markerSize: markerSize,
                    initialZoom: 12.0,
                    interactive: true,
                  ),
                  children: children,
                ),
              ),
            );
          },
          child: IgnorePointer(
            ignoring: true,
            child: FlutterMap(
              options: mapOptions,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  MapOptions _generateMapOptions({
    required List<LatLng> coordinates,
    required double markerSize,
    double initialZoom = 6.0,
    bool interactive = false,
  }) {
    final MapOptions mapOptions;
    if (coordinates.length == 1) {
      mapOptions = MapOptions(
        initialCenter: coordinates.first,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      );
    } else {
      mapOptions = MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: coordinates,
          maxZoom: 13.0,
          forceIntegerZoomLevel: true,
          padding: EdgeInsets.all(markerSize),
        ),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      );
    }
    return mapOptions;
  }

  String? _getTitle(BuildContext context) {
    try {
      return context.read<KnowledgePanel>().titleElement?.title;
    } catch (_) {
      return null;
    }
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
