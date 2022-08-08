import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
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
    // TODO(monsieurtanuki): Zoom the map to show all [mapElement.pointers]
    // TODO(monsieurtanuki): Add a OSM copyright.
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            // The first pointer is used as the center of the map.
            center: LatLng(
              mapElement.pointers.first.geo!.lat,
              mapElement.pointers.first.geo!.lng,
            ),
            zoom: 6.0,
          ),
          layers: <LayerOptions>[
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: <String>['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: getMarkers(mapElement.pointers),
            ),
          ],
          nonRotatedChildren: <Widget>[
            AttributionWidget(
              attributionBuilder: (BuildContext context) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: ColoredBox(
                    color: const Color(0xCCFFFFFF),
                    child: GestureDetector(
                      onTap: () => LaunchUrlHelper.launchURL(
                        'https://www.openstreetmap.org/copyright',
                        false,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '© OpenStreetMap contributors',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: Colors.blue,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  List<Marker> getMarkers(List<KnowledgePanelGeoPointer> pointers) {
    final List<Marker> markers = <Marker>[];
    for (final KnowledgePanelGeoPointer pointer in pointers) {
      if (pointer.geo == null) {
        continue;
      }
      markers.add(
        Marker(
          point: LatLng(pointer.geo!.lat, pointer.geo!.lng),
          builder: (BuildContext ctx) => const Icon(
            Icons.pin_drop,
            color: Colors.lightBlue,
          ),
        ),
      );
    }
    return markers;
  }
}
