import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

/// Empty template for a product card display.
///
/// Based on the "real" [SmoothProductCardItemFound].
class SmoothProductCardTemplate extends StatelessWidget {
  const SmoothProductCardTemplate({
    this.message,
    this.barcode,
    this.actionButton,
  });

  final String? message;
  final String? barcode;
  final Widget? actionButton;

  // TODO(m123): Animate

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final ThemeData themeData = Theme.of(context);
    final bool isDarkMode = themeData.colorScheme.brightness == Brightness.dark;
    final Color itemColor = isDarkMode ? PRIMARY_GREY_COLOR : LIGHT_GREY_COLOR;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final Widget textWidget = Container(
      width: double.infinity,
      height: screenSize.width * .04,
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
    );
    // In the actual display, it's a 240x130 svg resized with iconSize
    final double svgWidth = 240 * iconSize / 130;
    final Widget svgWidget = Container(
      height: iconSize * .9,
      width: svgWidth,
      color: itemColor,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MEDIUM_SPACE,
        vertical: SMALL_SPACE,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: ROUNDED_BORDER_RADIUS,
          color: backgroundColor,
        ),
        child: SmoothCard(
          elevation: SmoothProductCardItemFound.elevation,
          color: Colors.transparent,
          padding: const EdgeInsets.all(VERY_SMALL_SPACE),
          child: Row(
            children: <Widget>[
              SmoothImage(
                width: screenSize.width * 0.20,
                height: screenSize.width * 0.20,
                color: itemColor,
              ),
              const Padding(
                  padding: EdgeInsetsDirectional.only(start: VERY_SMALL_SPACE)),
              Expanded(
                child: SizedBox(
                  height: screenSize.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (barcode == null)
                        textWidget
                      else
                        Text(
                          barcode!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (message == null)
                        textWidget
                      else
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: SMALL_SPACE),
                          child: AutoSizeText(
                            message!,
                            maxLines: 3,
                            minFontSize: 5,
                          ),
                        ),
                      Opacity(opacity: 0, child: textWidget)
                    ],
                  ),
                ),
              ),
              const Padding(
                  padding: EdgeInsetsDirectional.only(start: VERY_SMALL_SPACE)),
              Padding(
                padding: const EdgeInsets.all(VERY_SMALL_SPACE),
                child: actionButton == null
                    ? Column(
                        children: <Widget>[
                          svgWidget,
                          Container(height: iconSize * .2),
                          svgWidget,
                        ],
                      )
                    : SizedBox(
                        width: svgWidth,
                        height: iconSize * (.9 * 2 + .2),
                        child: actionButton,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
