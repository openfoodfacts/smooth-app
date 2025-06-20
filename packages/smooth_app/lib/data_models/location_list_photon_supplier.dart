import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/data_models/location_osm_type_extension.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/query/product_query.dart';

/// Asynchronously loads locations from Photon and query searches.
///
/// We use 2 location suppliers:
/// * the first one optimized on shops, as it's what we want.
/// * an optional one with no restrictions, in case OSM data is a bit clumsy.
class LocationListPhotonSupplier extends LocationListSupplier {
  LocationListPhotonSupplier(
    this.query,
    this.optimizedSearch,
  );

  /// Query text.
  final String query;

  /// True if we want to focus on shops.
  final bool optimizedSearch;

  /// Returns additional query parameters.
  String _getAdditionalParameters() =>
      optimizedSearch ? '&osm_tag=shop&osm_tag=amenity' : '';

  @override
  LocationListSupplier? get alternateSupplier =>
      !optimizedSearch ? null : LocationListPhotonSupplier(query, false);

  @override
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
      final Map<String, dynamic> map = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      if (map['type'] != 'FeatureCollection') {
        return 'Unexpected result type: ${map['type']}';
      }
      final List<dynamic> features = map['features'];
      for (final Map<String, dynamic> item in features) {
        final Map<String, dynamic> properties = item['properties'];
        final String? short = properties['osm_type'];
        if (short == null) {
          continue;
        }
        LocationOSMType? osmType;
        for (final LocationOSMType item in LocationOSMType.values) {
          if (short == item.short) {
            osmType = item;
            break;
          }
        }
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
}
