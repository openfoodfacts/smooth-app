import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

/// Padding to be used while building the SmoothCard on any Product card.
const EdgeInsets SMOOTH_CARD_PADDING =
    EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);

/// A SmoothCard on Product cards using standardized margin.
Widget buildProductSmoothCard({
  Widget? header,
  required Widget body,
  EdgeInsets? padding = EdgeInsets.zero,
}) {
  return SmoothCard(
    margin: const EdgeInsets.only(
      right: SMALL_SPACE,
      left: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_LARGE_SPACE,
    ),
    padding: padding,
    header: header,
    child: body,
  );
}
