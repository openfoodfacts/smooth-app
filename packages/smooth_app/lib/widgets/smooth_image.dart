import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads an image from the assets
/// If launched from [smooth_app_dev], the [package] is automatically added
class SmoothImage extends StatelessWidget {
  const SmoothImage(
    this.assetName, {
    this.package,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.color,
    Key? key,
  })  : assert(assetName.length > 0),
        assert(package == null || package.length > 0),
        super(key: key);

  const SmoothImage.square(
    String assetName, {
    String? package,
    double? size,
    BoxFit? fit,
    Alignment? alignment,
    Color? color,
    Key? key,
  }) : this(
          assetName,
          package: package,
          width: size,
          height: size,
          fit: fit,
          alignment: alignment,
          color: color,
          key: key,
        );

  final String assetName;
  final String? package;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (_isSVG) {
      return SvgPicture.asset(
        assetName,
        package: _package,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        color: color,
      );
    } else {
      return Image.asset(
        assetName,
        package: _package,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        color: color,
      );
    }
  }

  bool get _isSVG => assetName.endsWith('svg');

  String? get _package {
    if (assetName.startsWith('package')) {
      return null;
    }

    return package ?? 'smooth_app';
  }
}
