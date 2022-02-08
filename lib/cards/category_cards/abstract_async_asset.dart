import 'package:flutter/material.dart';

/// Widget with async load of asset file.
abstract class AbstractAsyncAsset extends StatelessWidget {
  const AbstractAsyncAsset(
    this.fullFilename,
    this.url, {
    this.width,
    this.height,
  });

  /// Full asset name, e.g. 'assets/cache/ab-agriculture-biologique.74x90.svg'
  final String fullFilename;

  /// URL (for debug purpose), e.g. https://static.openfoodfacts.org/images/lang/fr/labels/ab-agriculture-biologique.74x90.svg
  final String url;

  final double? width;
  final double? height;

  @protected
  Widget getEmptySpace() =>
      SizedBox(width: width ?? height, height: height ?? width);

  @protected
  void notFound() =>
      debugPrint('unexpected case: asset not found $fullFilename ($url)');
}
