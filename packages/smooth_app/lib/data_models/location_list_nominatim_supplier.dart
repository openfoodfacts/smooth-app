import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/query/product_query.dart';

/// Asynchronously loads locations from Nominatim and OSM ids.
class LocationListNominatimSupplier extends LocationListSupplier {
  LocationListNominatimSupplier(this.queries);

  final List<String> queries;

  @override
  LocationListSupplier? get alternateSupplier => null;

  @override
  Future<String?> asyncLoad() async {
    try {
      locations.clear();
      final http.Response response = await http.get(
        Uri(
          scheme: 'https',
          host: 'nominatim.openstreetmap.org',
          path: 'lookup',
          query:
              'osm_ids=${queries.join(',')}'
              '&format=json'
              '&accept-language=${ProductQuery.getLanguage().offTag}',
        ),
      );
      if (response.statusCode != 200) {
        return 'Could not retrieve locations';
      }
      final List<dynamic> list = json.decode(response.body);
      for (final Map<String, dynamic> item in list) {
        final LocationOSMType? osmType = LocationOSMType.fromOffTag(
          (item['osm_type'] as String).toUpperCase(),
        );
        if (osmType == null) {
          continue;
        }
        final double longitude = double.parse(item['lon']);
        final double latitude = double.parse(item['lat']);
        final int osmId = item['osm_id'] as int;
        final Map<String, dynamic>? address =
            item['address'] as Map<String, dynamic>?;
        final String? name = item['name'] as String?;
        final String? osmKey = item['class'] as String?;
        final String? osmValue = item['type'] as String?;
        String? street;
        String? city;
        String? countryCode;
        String? country;
        String? postCode;
        if (address != null) {
          street = address['road'];
          city = address['city'];
          countryCode = address['country_code'];
          country = address['country'];
          postCode = address['postcode'];
        }
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
