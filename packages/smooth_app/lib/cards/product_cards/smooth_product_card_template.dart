import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image_container.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

/// Empty template for a product card display.
///
/// Based on the "real" [SmoothProductCardFound].
class SmoothProductCardTemplate extends StatelessWidget {
  const SmoothProductCardTemplate({
    this.error,
    this.barcode,
  });

  final String? error;
  final String? barcode;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final bool isDarkMode = themeData.colorScheme.brightness == Brightness.dark;
    final Color itemColor = isDarkMode ? PRIMARY_GREY_COLOR : LIGHT_GREY_COLOR;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final Widget textWidget = Container(
      width: screenSize.width * .4,
      height: screenSize.width * .05,
      color: itemColor,
    );
    // In the actual display, it's a 240x130 svg resized with iconSize
    final Widget svgWidget = error == null
        ? Container(
            height: iconSize * .9,
            width: 240 * iconSize / 130,
            color: itemColor,
          )
        : SizedBox(
            height: iconSize * .9,
            width: 240 * iconSize / 130,
            child: SvgPicture.asset(
              'assets/misc/error.svg',
              height: iconSize * .9,
            ),
          );
    return Container(
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        color: backgroundColor,
      ),
      child: SmoothCard(
        elevation: SmoothProductCardFound.elevation,
        color: Colors.transparent,
        padding: const EdgeInsets.all(VERY_SMALL_SPACE),
        child: Row(
          children: <Widget>[
            SmoothProductImageContainer(
              width: screenSize.width * 0.20,
              height: screenSize.width * 0.20,
              child: Container(color: itemColor),
            ),
            const Padding(padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
            Expanded(
              child: SizedBox(
                height: screenSize.width * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (barcode == null) textWidget else Text(barcode!),
                    if (error == null) textWidget,
                    if (error == null) textWidget,
                    if (error != null) AutoSizeText(error!, maxLines: 3),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
            Padding(
              padding: const EdgeInsets.all(VERY_SMALL_SPACE),
              child: error == null
                  ? Column(
                      children: <Widget>[
                        svgWidget,
                        Container(height: iconSize * .2),
                        svgWidget,
                      ],
                    )
                  : Center(child: svgWidget),
            ),
          ],
        ),
      ),
    );
  }
}
