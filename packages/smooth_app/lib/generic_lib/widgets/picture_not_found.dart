import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/helpers/app_helper.dart';

/// Displays a default asset as a _picture not found_ image.
class PictureNotFound extends StatelessWidget {
  const PictureNotFound();

  static const String NOT_FOUND_ASSET = 'assets/product/product_not_found.svg';

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        NOT_FOUND_ASSET,
        fit: BoxFit.cover,
        package: AppHelper.APP_PACKAGE,
      );
}
