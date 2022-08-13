import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class PictureNotFound extends StatelessWidget {
  const PictureNotFound();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/product/product_not_found.svg',
      fit: BoxFit.cover,
    );
  }
}
