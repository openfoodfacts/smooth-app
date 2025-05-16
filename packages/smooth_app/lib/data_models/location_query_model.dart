import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// Location query model, from location suppliers.
class LocationQueryModel with ChangeNotifier {
  LocationQueryModel(this.query) {
    _currentSupplier = LocationListSupplier.getBestInitialSupplier(query);
    unawaited(_asyncLoad());
  }

  late LocationListSupplier _currentSupplier;

  final String query;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  List<OsmLocation> displayedResults = <OsmLocation>[];

  bool isEmpty() => displayedResults.isEmpty;

  String? get loadingError => _loadingError;

  LoadingStatus get loadingStatus => _loadingStatus;

  Future<bool> _asyncLoad() async {
    _loadingStatus = LoadingStatus.LOADING;
    notifyListeners();
    _loadingError = await _currentSupplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      await _process(_currentSupplier.locations);
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

  LocationListSupplier? get alternateSupplier =>
      _currentSupplier.alternateSupplier;

  Future<void> loadMore(final LocationListSupplier supplier) async {
    _currentSupplier = supplier;
    await _asyncLoad();
  }
}
