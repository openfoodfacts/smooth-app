import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';
import 'package:smooth_app/widgets/widget_height.dart';

class EditProductFooter extends StatefulWidget {
  const EditProductFooter({required this.uploadIndicator, super.key});

  final bool uploadIndicator;

  @override
  State<EditProductFooter> createState() => _EditProductFooterState();
}

class _EditProductFooterState extends State<EditProductFooter>
    with TickerProviderStateMixin {
  static const double BUTTON_WIDTH = 45.0;

  final ScrollController _scrollController = ScrollController();

  late AnimationController _menuController;
  late AnimationController _loadingController;
  late Animation<double> _menuAnimation;
  late Animation<double> _loadingAnimation;
  late double _menuOffsetX = -1.0;
  late double _loadingOffsetY;
  late double _height = 0.0;
  late DragStartDetails _dragStartDetails;

  @override
  void initState() {
    super.initState();
    _menuController =
        AnimationController(
            vsync: this,
            duration: SmoothAnimationsDuration.medium,
          )
          ..addListener(() {
            setState(() {
              _menuOffsetX = _menuAnimation.value;

              /// Also move the upload indicator
              if (widget.uploadIndicator) {
                _loadingOffsetY =
                    _height *
                    (1 - _menuOffsetX.progressAndClamp(0.0, _maxOffsetX, 1.0));
              }
            });
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed && _menuOffsetX > 0.0) {
              _scrollController.jumpTo(0.0);
            }
          });

    _loadingController =
        AnimationController(
          vsync: this,
          duration: SmoothAnimationsDuration.long,
        )..addListener(() {
          setState(() => _loadingOffsetY = _loadingAnimation.value);
        });

    if (widget.uploadIndicator) {
      _loadingOffsetY = 0.0;
    } else {
      /// Temp value
      _loadingOffsetY = double.infinity;
    }

    onNextFrame(() => setState(() => _menuOffsetX = _maxOffsetX));
  }

  @override
  void didUpdateWidget(covariant EditProductFooter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.uploadIndicator != widget.uploadIndicator) {
      if (widget.uploadIndicator) {
        _startLoadingAnimation(from: _height, to: 0.0);
      } else {
        _startLoadingAnimation(from: 0.0, to: _height);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_menuOffsetX < 0.0) {
      /// Wait for the first frame to be displayed
      return EMPTY_WIDGET;
    }

    final double width = MediaQuery.sizeOf(context).width;

    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          start: 0.0,
          end: BUTTON_WIDTH - 20.0,
          bottom: 0.0,
          child: Offstage(
            offstage: _loadingOffsetY == _height,
            child: Opacity(
              opacity: 1 - _loadingOffsetY.progressAndClamp(0.0, _height, 1.0),
              child: Transform.translate(
                offset: Offset(0.0, _loadingOffsetY),
                child: const _EditPageLoadingIndicator(),
              ),
            ),
          ),
        ),
        MeasureSize(
          onChange: _onSizeAvailable,
          child: Transform.translate(
            offset: Offset(_menuOffsetX, 0),
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _onTapMenu(width),
                    onTapDown: (TapDownDetails details) =>
                        SmoothHapticFeedback.click(),
                    onHorizontalDragStart: (DragStartDetails details) {
                      SmoothHapticFeedback.click();
                      _dragStartDetails = details;
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails details) =>
                        _onHorizontalDragUpdate(details, width),
                    onHorizontalDragEnd: (DragEndDetails details) =>
                        _onHorizontalDragEnd(details, width),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(
                            _menuOffsetX.progressAndClamp(0.0, width / 4, 1.0) *
                                20.0,
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
                        height: _height,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: LARGE_SPACE,
                            bottom: MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          child: Transform.rotate(
                            angle:
                                math.pi *
                                (1 -
                                    _menuOffsetX.progressAndClamp(
                                      0.0,
                                      width - BUTTON_WIDTH,
                                      1.0,
                                    )),
                            child: const Drag.start(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - BUTTON_WIDTH,
                    child: ProductFooter(
                      actions: const <ProductFooterActionBar>[
                        ProductFooterActionBar.barcode,
                        ProductFooterActionBar.contributionGuide,
                        ProductFooterActionBar.openWebsite,
                      ],
                      scrollController: _scrollController,
                      highlightFirstItem: false,
                      showSettings: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSizeAvailable(Size size) {
    if (_height != size.height) {
      _height = size.height;
      if (!widget.uploadIndicator) {
        _loadingOffsetY = _height;
      }

      _loadingAnimation = Tween<double>(begin: 0.0, end: _height).animate(
        CurvedAnimation(parent: _loadingController, curve: Curves.easeOutQuint),
      );

      setState(() {});
    }
  }

  void _onTapMenu(double width) {
    if (_menuOffsetX == 0.0) {
      _startMenuAnimation(from: 0.0, to: width - BUTTON_WIDTH);
    } else {
      _startMenuAnimation(from: width - BUTTON_WIDTH, to: 0.0);
    }
  }

  /// Move the menu and the upload indicator
  void _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    setState(() {
      _menuOffsetX += details.delta.dx;
      if (_menuOffsetX < 0) {
        _menuOffsetX = 0;
      } else if (_menuOffsetX > width - BUTTON_WIDTH) {
        _menuOffsetX = width - BUTTON_WIDTH;
      }

      if (widget.uploadIndicator) {
        _loadingOffsetY =
            _height *
            (1 - _menuOffsetX.progressAndClamp(0.0, _maxOffsetX, 1.0));
      }
    });
  }

  /// Snap to the closest edge
  void _onHorizontalDragEnd(DragEndDetails details, double width) {
    if (_dragStartDetails.localPosition.dx - details.localPosition.dx > 0) {
      _startMenuAnimation(from: _menuOffsetX, to: 0.0);
    } else {
      _startMenuAnimation(from: _menuOffsetX, to: width - BUTTON_WIDTH);
    }
  }

  double get _maxOffsetX => MediaQuery.sizeOf(context).width - BUTTON_WIDTH;

  void _startMenuAnimation({required double from, required double to}) {
    _menuAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeOutQuint),
    );
    _menuController.forward(from: 0.0);
  }

  void _startLoadingAnimation({required double from, required double to}) {
    /// The controller is already set up
    if (from == 0.0) {
      _loadingController.forward(from: 0.0);
    } else {
      _loadingController.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    _loadingController.dispose();
    super.dispose();
  }
}

class _EditPageLoadingIndicator extends StatelessWidget {
  const _EditPageLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.lightTheme()
                ? Colors.black12
                : const Color(0x10FFFFFF),
            blurRadius: 6.0,
            offset: const Offset(0.0, -4.0),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 15,
              child: ExcludeSemantics(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF824116),
                  padding: EdgeInsetsDirectional.only(
                    top: SMALL_SPACE,
                    start: LARGE_SPACE,
                    end: LARGE_SPACE,
                    bottom: MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  alignment: AlignmentDirectional.center,
                  child: CloudUploadAnimation(
                    size: MediaQuery.sizeOf(context).width * 0.10,
                    color: lightTheme ? Colors.white : null,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 85,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: lightTheme ? Colors.white : extension.primaryUltraBlack,
                alignment: AlignmentDirectional.center,
                padding: EdgeInsetsDirectional.only(
                  start: MEDIUM_SPACE,
                  end: LARGE_SPACE * 2,
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: TextWithBoldParts(
                  text: appLocalizations
                      .edit_product_pending_operations_banner_short_message,
                  textStyle: const TextStyle(fontSize: 14.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
