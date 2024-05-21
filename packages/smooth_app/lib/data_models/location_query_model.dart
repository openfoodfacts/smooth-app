import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// Location query model.
class LocationQueryModel with ChangeNotifier {
  LocationQueryModel(this.query) {
    _asyncLoad(notify: true);
  }

  final String query;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  List<OsmLocation> displayedResults = <OsmLocation>[];

  bool isEmpty() => displayedResults.isEmpty;

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  late final LocationListSupplier supplier = LocationListSupplier(query);

  Future<bool> _asyncLoad({
    final bool notify = false,
    final bool fromScratch = false,
  }) async {
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      await _process(supplier.locations, fromScratch);
      _loadingStatus = LoadingStatus.LOADED;
    }
    if (notify) {
      notifyListeners();
    }
    return _loadingStatus == LoadingStatus.LOADED;
  }

  Future<void> _process(
    final List<OsmLocation> locations,
    final bool fromScratch,
  ) async {
    if (fromScratch) {
      displayedResults.clear();
    }
    displayedResults.addAll(locations);
    _loadingStatus = LoadingStatus.LOADED;
  }
}
