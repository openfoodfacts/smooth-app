import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';

/// Asynchronously loads locations.
class LocationListSupplier {
  LocationListSupplier(
    this.query,
  );

  final String query;

  final List<OsmLocation> locations = <OsmLocation>[];

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad() async {
    try {
      locations.clear();
      final http.Response response = await http.get(
        Uri(
          scheme: 'https',
          host: 'photon.komoot.io',
          path: 'api',
          queryParameters: <String, String>{
            'q': query,
          },
        ),
      );
      if (response.statusCode != 200) {
        return 'Could not retrieve locations';
      }
      final Map<String, dynamic> map = json.decode(response.body);
      if (map['type'] != 'FeatureCollection') {
        return 'Unexpected result type: ${map['type']}';
      }
      final List<dynamic> features = map['features'];
      for (final Map<String, dynamic> item in features) {
        final Map<String, dynamic> properties = item['properties'];
        final LocationOSMType? osmType = _convertType(properties['osm_type']);
        if (osmType == null) {
          continue;
        }
        final Map<String, dynamic> geometry = item['geometry'];
        final String type = geometry['type'];
        if (type != 'Point') {
          continue;
        }
        final List<dynamic> coordinates = geometry['coordinates'];
        final double longitude = coordinates[0] as double;
        final double latitude = coordinates[1] as double;
        final int osmId = properties['osm_id'];
        final String? name = properties['name'];
        final String? street = properties['street'];
        final String? city = properties['city'];
        final String? countryCode = properties['countrycode'];
        final String? country = properties['country'];
        final String? postCode = properties['postcode'];
        final OsmLocation osmLocation = OsmLocation(
          osmId: osmId,
          osmType: osmType,
          longitude: longitude,
          latitude: latitude,
          name: name,
          city: city,
          postcode: postCode,
          street: street,
          country: country,
          countryCode: countryCode,
        );
        locations.add(osmLocation);
      }
    } catch (e) {
      locations.clear();
      return e.toString();
    }
    return null;
  }

  static LocationOSMType? _convertType(final String type) => switch (type) {
        'W' => LocationOSMType.way,
        'N' => LocationOSMType.node,
        'R' => LocationOSMType.relation,
        _ => null,
      };
}
