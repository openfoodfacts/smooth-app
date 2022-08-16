import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class PictureNotFound extends StatelessWidget {
  const PictureNotFound();

  static const String NOT_FOUND_ASSET = 'assets/product/product_not_found.svg';

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        NOT_FOUND_ASSET,
        fit: BoxFit.cover,
      );
}
