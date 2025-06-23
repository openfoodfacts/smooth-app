import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// Model that computes the scores and sorts the barcodes accordingly.
class PersonalizedRankingModel with ChangeNotifier {
  PersonalizedRankingModel(this.initialBarcodes, this.localDatabase) {
    initialBarcodes.forEach(localDatabase.upToDate.showInterest);
  }

  final List<String> initialBarcodes;
  final LocalDatabase localDatabase;

  late LoadingStatus _loadingStatus;
  String? _loadingError;

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  final List<MatchedScoreV2> scores = <MatchedScoreV2>[];

  int? _timestamp;

  @override
  void dispose() {
    initialBarcodes.forEach(localDatabase.upToDate.loseInterest);
    super.dispose();
  }

  /// Refreshes the computations.
  Future<void> refresh(final ProductPreferences productPreferences) async {
    _clear();
    _asyncLoad(localDatabase, productPreferences);
  }

  /// Clears the computations.
  void _clear() {
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = null;
    scores.clear();
  }

  /// Returns the loading progress between 0 (min) and 1 (max).
  double? getLoadingProgress() {
    if (_loadingStatus != LoadingStatus.LOADING) {
      return null;
    }
    if (initialBarcodes.isEmpty) {
      return 1;
    }
    return scores.length / initialBarcodes.length;
  }

  /// Removes a barcode from the barcodes and from the scores.
  void dismiss(final String barcode) {
    localDatabase.upToDate.loseInterest(barcode);
    initialBarcodes.remove(barcode);
    int? index;
    int i = 0;
    for (final MatchedScoreV2 score in scores) {
      if (score.barcode == barcode) {
        index = i;
      }
      i++;
    }
    if (index == null) {
      return;
    }
    scores.removeAt(index);
  }

  /// Computes the scores from the [Product]s extracted one by one from the db.
  Future<bool> _asyncLoad(
    final LocalDatabase localDatabase,
    final ProductPreferences productPreferences,
  ) async {
    try {
      final DaoProduct daoProduct = DaoProduct(localDatabase);
      for (final String barcode in initialBarcodes) {
        final Product? product = await daoProduct.get(barcode);
        if (product == null) {
          // unlikely, but what shall we do?
          continue;
        }
        scores.add(MatchedScoreV2(product, productPreferences));
        notifyListeners(); // refreshes the progress
      }
      MatchedScoreV2.sort(scores);
      _loadingStatus = LoadingStatus.LOADED;
    } catch (e) {
      _loadingError = e.toString();
      _loadingStatus = LoadingStatus.ERROR;
    }
    _timestamp = LocalDatabase.nowInMillis();
    notifyListeners();
    return _loadingStatus == LoadingStatus.LOADED;
  }

  bool needsRefresh() =>
      localDatabase.upToDate.needsRefresh(_timestamp, initialBarcodes);
}
