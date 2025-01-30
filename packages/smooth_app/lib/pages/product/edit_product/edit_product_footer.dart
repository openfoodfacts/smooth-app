import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class EditProductFooter extends StatefulWidget {
  const EditProductFooter({super.key});

  @override
  State<EditProductFooter> createState() => _EditProductFooterState();
}

class _EditProductFooterState extends State<EditProductFooter>
    with SingleTickerProviderStateMixin {
  static const double BUTTON_WIDTH = 45.0;

  late AnimationController _controller;
  late Animation<double> _animation;
  late double _offsetX = -1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
    )..addListener(() => setState(() {
          _offsetX = _animation.value;
        }));

    onNextFrame(() => setState(
          () => _offsetX = MediaQuery.sizeOf(context).width - BUTTON_WIDTH,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_offsetX < 0.0) {
      /// Wait for the first frame to be displayed
      return EMPTY_WIDGET;
    }

    final double width = MediaQuery.sizeOf(context).width;

    return Transform.translate(
      offset: Offset(_offsetX, 0),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (_offsetX == 0.0) {
                  _startAnimation(
                    from: 0.0,
                    to: width - BUTTON_WIDTH,
                  );
                } else {
                  _startAnimation(
                    from: width - BUTTON_WIDTH,
                    to: 0.0,
                  );
                }
              },
              onTapDown: (TapDownDetails details) {
                SmoothHapticFeedback.click();
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  _offsetX += details.delta.dx;
                  if (_offsetX < 0) {
                    _offsetX = 0;
                  } else if (_offsetX > width - BUTTON_WIDTH) {
                    _offsetX = width - BUTTON_WIDTH;
                  }
                });
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.globalPosition.dx < width / 2) {
                  _startAnimation(
                    from: _offsetX,
                    to: 0.0,
                  );
                } else {
                  _startAnimation(
                    from: _offsetX,
                    to: width - BUTTON_WIDTH,
                  );
                }
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(
                      _offsetX.progressAndClamp(0.0, width / 4, 1.0) * 20.0,
                    ),
                  ),
                  color: context.lightTheme()
                      ? context
                          .extension<SmoothColorsThemeExtension>()
                          .primaryBlack
                      : context
                          .extension<SmoothColorsThemeExtension>()
                          .primarySemiDark,
                ),
                child: SizedBox(
                  width: BUTTON_WIDTH,
                  height: ProductFooter.kHeight +
                      LARGE_SPACE +
                      MediaQuery.viewPaddingOf(context).bottom,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: LARGE_SPACE,
                      bottom: MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: Transform.rotate(
                      angle: math.pi *
                          (1 -
                              _offsetX.progressAndClamp(
                                  0.0, width - BUTTON_WIDTH, 1.0)),
                      child: const Drag.start(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width - BUTTON_WIDTH,
              child: const ProductFooter(
                actions: <ProductFooterActionBar>[
                  ProductFooterActionBar.barcode,
                  ProductFooterActionBar.contributionGuide,
                  ProductFooterActionBar.openWebsite,
                ],
                highlightFirstItem: false,
                showSettings: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startAnimation({required double from, required double to}) {
    _animation = Tween<double>(
      begin: from,
      end: to,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint),
    );
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
