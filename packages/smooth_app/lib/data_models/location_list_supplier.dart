import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/query/product_query.dart';

/// Asynchronously loads locations.
class LocationListSupplier {
  LocationListSupplier(
    this.query,
    this.optimizedSearch,
  );

  /// Query text.
  final String query;

  /// True if we want to focus on shops.
  final bool optimizedSearch;

  /// Locations as result.
  final List<OsmLocation> locations = <OsmLocation>[];

  /// Returns additional query parameters.
  String _getAdditionalParameters() =>
      optimizedSearch ? '&osm_tag=shop&osm_tag=amenity' : '';

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad() async {
    // don't ask me why, but it looks like we need to explicitly set a language,
    // or else we get different (and not relevant) results
    // and only en,fr,de can be used.
    OpenFoodFactsLanguage getQueryLanguage() =>
        switch (ProductQuery.getLanguage()) {
          OpenFoodFactsLanguage.FRENCH => OpenFoodFactsLanguage.FRENCH,
          OpenFoodFactsLanguage.GERMAN => OpenFoodFactsLanguage.GERMAN,
          OpenFoodFactsLanguage.ENGLISH => OpenFoodFactsLanguage.ENGLISH,
          _ => OpenFoodFactsLanguage.ENGLISH,
        };

    try {
      locations.clear();
      final http.Response response = await http.get(
        Uri(
          scheme: 'https',
          host: 'photon.komoot.io',
          path: 'api',
          query: 'q=${Uri.encodeComponent(query)}'
              '&lang=${getQueryLanguage().offTag}'
              '${_getAdditionalParameters()}',
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
        final String? osmKey = properties['osm_key'];
        final String? osmValue = properties['osm_value'];
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
          osmKey: osmKey,
          osmValue: osmValue,
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
