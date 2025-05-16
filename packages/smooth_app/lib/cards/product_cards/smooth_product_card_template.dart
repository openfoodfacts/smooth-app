import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool isDarkMode = themeData.colorScheme.brightness == Brightness.dark;
    final Color itemColor = isDarkMode ? PRIMARY_GREY_COLOR : LIGHT_GREY_COLOR;

    final Widget textWidget = SizedBox(
      width: double.infinity,
      height: screenSize.width * .04,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: LARGE_SPACE,
        vertical: LARGE_SPACE,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: screenSize.width * 0.25,
              height: screenSize.width * 0.265,
              child: PictureNotFound.decoration(
                backgroundDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(
                    color: extension.greyNormal,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: BALANCED_SPACE),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            themeData.textTheme.headlineMedium!.fontSize! * 2.0,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: barcode == null
                            ? textWidget
                            : Text(
                                barcode!,
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: VERY_SMALL_SPACE),
                    if (message == null)
                      textWidget
                    else
                      Text(
                        message!,
                        maxLines: 3,
                      ),
                    const Spacer(),
                    if (actionButton == null)
                      Shimmer.fromColors(
                        baseColor: itemColor,
                        highlightColor: itemColor.withValues(alpha: 0.8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _fakeScoreWidget(itemColor),
                            const SizedBox(width: BALANCED_SPACE),
                            _fakeScoreWidget(itemColor),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: 240 * 39.0 / 130,
                        height: 39.0,
                        child: actionButton,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fakeScoreWidget(Color itemColor) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        color: itemColor,
      ),
      child: const SizedBox(
        height: 39.0,
        width: 240 * 39.0 / 130,
      ),
    );
  }
}
