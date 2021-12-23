import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Example explanation on how to scan a product.
class ScanExample extends StatelessWidget {
  const ScanExample();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SvgPicture.asset(
      'assets/onboarding/scan_example.svg',
    );
  }
}
