import 'dart:async';
import 'dart:ui';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/price_category_repository.dart';
import 'package:smooth_app/pages/prices/price_label_repository.dart';
import 'package:smooth_app/pages/prices/price_origin_repository.dart';

/// Localization helper for prices, managing static cache and downloads.
class PriceL10nHelper {
  PriceL10nHelper();

  final PriceCategoryRepository _categoryRepository = PriceCategoryRepository();
  late final String? _categoryTag;
  String? _categoryName;
  final PriceOriginRepository _originRepository = PriceOriginRepository();
  late final List<String>? _originsTags;
  List<String>? _originsNames;
  final PriceLabelRepository _labelRepository = PriceLabelRepository();
  late final List<String>? _labelsTags;
  List<String>? _labelsNames;

  String? getCategory() => _categoryName ?? _categoryTag;

  List<String>? getLabels() => _labelsNames ?? _labelsTags;

  List<String>? getOrigins() => _originsNames ?? _originsTags;

  void localizeTags(final Price price, final VoidCallback refresh) {
    _categoryTag = price.categoryTag;
    _originsTags = price.originsTags;
    _labelsTags = price.labelsTags;
    if (_categoryTag != null) {
      _categoryName = _categoryRepository.getCachedName(_categoryTag);
      if (_categoryName == null) {
        unawaited(_loadCategoryName(refresh));
      }
    }
    if (_originsTags?.isNotEmpty == true) {
      _originsNames = _originRepository.getCachedNames(_originsTags!);
      if (_originsNames == null) {
        unawaited(_loadOriginsNames(refresh));
      }
    }
    if (_labelsTags?.isNotEmpty == true) {
      _labelsNames = _labelRepository.getCachedNames(_labelsTags!);
      if (_labelsNames == null) {
        unawaited(_loadLabelsNames(refresh));
      }
    }
  }

  Future<void> _loadCategoryName(final VoidCallback refresh) async {
    _categoryName = await _categoryRepository.getDownloadedName(_categoryTag!);
    if (_categoryName != null) {
      refresh.call();
    }
  }

  Future<void> _loadOriginsNames(final VoidCallback refresh) async {
    _originsNames = await _originRepository.getDownloadedNames(_originsTags!);
    if (_originsNames != null) {
      refresh.call();
    }
  }

  Future<void> _loadLabelsNames(final VoidCallback refresh) async {
    _labelsNames = await _labelRepository.getDownloadedNames(_labelsTags!);
    if (_labelsNames != null) {
      refresh.call();
    }
  }
}
