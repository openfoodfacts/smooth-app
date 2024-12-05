import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// Location query model.
///
/// We use 2 location suppliers:
/// * the first one optimized on shops, as it's what we want
/// * an optional one with no restrictions, in case OSM data is a bit clumsy
class LocationQueryModel with ChangeNotifier {
  LocationQueryModel(this.query) {
    _asyncLoad(_supplierOptimized);
  }

  final String query;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  List<OsmLocation> displayedResults = <OsmLocation>[];

  bool _isOptimized = true;
  bool get isOptimized => _isOptimized;

  bool isEmpty() => displayedResults.isEmpty;

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  /// A location supplier focused on shops.
  late final LocationListSupplier _supplierOptimized =
      LocationListSupplier(query, true);

  /// A location supplier without restrictions.
  late final LocationListSupplier _supplierBroader =
      LocationListSupplier(query, false);

  Future<bool> _asyncLoad(final LocationListSupplier supplier) async {
    _loadingStatus = LoadingStatus.LOADING;
    notifyListeners();
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      await _process(supplier.locations);
      _loadingStatus = LoadingStatus.LOADED;
    }
    notifyListeners();
    return _loadingStatus == LoadingStatus.LOADED;
  }

  final Set<String> _locationKeys = <String>{};

  Future<void> _process(
    final List<OsmLocation> locations,
  ) async {
    for (final OsmLocation location in locations) {
      final String primaryKey = location.primaryKey;
      if (_locationKeys.contains(primaryKey)) {
        continue;
      }
      displayedResults.add(location);
      _locationKeys.add(primaryKey);
    }
    _loadingStatus = LoadingStatus.LOADED;
  }

  Future<void> loadMore() async {
    _isOptimized = false;
    _asyncLoad(_supplierBroader);
  }
}
