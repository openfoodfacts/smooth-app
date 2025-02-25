import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/location_list_nominatim_supplier.dart';
import 'package:smooth_app/data_models/location_list_photon_supplier.dart';
import 'package:smooth_app/data_models/location_osm_type_extension.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';

/// Asynchronously loads locations.
abstract class LocationListSupplier {
  static LocationListSupplier getBestInitialSupplier(final String query) {
    int? osmId = int.tryParse(query);
    if (osmId != null) {
      final List<String> queries = <String>[];
      for (final LocationOSMType type in LocationOSMType.values) {
        queries.add('${type.short}$osmId');
      }
      return LocationListNominatimSupplier(queries);
    }
    if (query.length > 1) {
      final String firstChar = query.substring(0, 1).toUpperCase();
      for (final LocationOSMType type in LocationOSMType.values) {
        if (firstChar == type.short) {
          osmId = int.tryParse(query.substring(1));
          if (osmId != null) {
            return LocationListNominatimSupplier(<String>[query]);
          }
        }
      }
    }
    return LocationListPhotonSupplier(query, true);
  }

  /// Locations as result.
  final List<OsmLocation> locations = <OsmLocation>[];

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad();

  /// Returns a possible alternate supplier, probably less restrictive.
  LocationListSupplier? get alternateSupplier;
}
