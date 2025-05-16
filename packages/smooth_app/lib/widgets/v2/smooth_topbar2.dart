import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';

class SmoothTopBar2 extends StatefulWidget implements PreferredSizeWidget {
  const SmoothTopBar2({
    required this.title,
    this.subTitle,
    this.topWidget,
    this.leadingAction,
    this.forceMultiLines = false,
    this.reducedHeightOnScroll = false,
    this.elevation = 4.0,
    this.elevationColor,
    this.elevationOnScroll = true,
    this.foregroundColor,
    this.backgroundColor,
    this.productType,
    super.key,
  })  : assert(title.length > 0),
        assert(forceMultiLines == false || subTitle == null);

  /// Height without the top view padding
  static double kTopBar2Height = 100;

  final String title;
  final String? subTitle;
  final double elevation;
  final Color? elevationColor;
  final bool elevationOnScroll;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool forceMultiLines;
  final bool reducedHeightOnScroll;
  final ProductType? productType;

  final PreferredSizeWidget? topWidget;
  final SmoothLeadingAction? leadingAction;

  @override
  State<SmoothTopBar2> createState() => _SmoothTopBar2State();

  @override
  Size get preferredSize => Size(double.infinity,
      kTopBar2Height + (topWidget?.preferredSize.height ?? 0.0));
}

class _SmoothTopBar2State extends State<SmoothTopBar2> {
  late double _progress = 0.0;
  late double _elevation = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.elevationOnScroll || widget.reducedHeightOnScroll) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => PrimaryScrollController.maybeOf(context)?.addListener(
          () => _onScroll(),
        ),
      );
    }

    if (!widget.elevationOnScroll) {
      _elevation = widget.elevation;
    }
  }

  void _onScroll() {
    final double offset = PrimaryScrollController.of(context).offset;
    final double newProgress = offset.progressAndClamp(
      0.0,
      HEADER_ROUNDED_RADIUS.x * 2.0,
      1.0,
    );

    if (newProgress != _progress) {
      setState(() {
        if (widget.elevationOnScroll) {
          _elevation = widget.elevation * newProgress;
        }
        if (widget.reducedHeightOnScroll) {
          _progress = newProgress;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        context.extension<SmoothColorsThemeExtension>();
    final TextDirection textDirection = Directionality.of(context);
    final bool darkTheme = context.darkTheme();

    final double imageWidth = MediaQuery.sizeOf(context).width * 0.22;
    final double imageHeight = imageWidth * 114 / 92;
    final BorderRadius borderRadius = BorderRadius.vertical(
        bottom:
            Radius.circular(HEADER_BORDER_RADIUS.topRight.x * (1 - _progress)));

    final Color backgroundColor = widget.backgroundColor ??
        (darkTheme ? colors.primaryDark : colors.primaryMedium);

    return PhysicalModel(
      color: Colors.transparent,
      elevation: _elevation,
      shadowColor: widget.elevationColor ??
          (darkTheme ? Colors.white10 : Colors.black12),
      borderRadius: borderRadius,
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: ColoredBox(
          color: backgroundColor,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: MediaQuery.viewPaddingOf(context).top,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.topWidget != null)
                  SizedBox.fromSize(
                    size: widget.topWidget!.preferredSize,
                    child: widget.topWidget,
                  ),
                SizedBox(
                  height: _computeHeight(),
                  child: Stack(
                    children: <Widget>[
                      _getImageAsset(
                        backgroundColor: backgroundColor,
                        textDirection: textDirection,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                      ),
                      Positioned.directional(
                        textDirection: textDirection,
                        top: 0.0,
                        bottom: VERY_LARGE_SPACE * (1 - _progress),
                        start: widget.leadingAction != null
                            ? BALANCED_SPACE
                            : VERY_LARGE_SPACE,
                        end: (imageWidth * 0.7) *
                            (1 - _progress.progressAndClamp(0.5, 0.9, 1.0)),
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Row(
                            crossAxisAlignment: widget.subTitle != null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: <Widget>[
                              if (widget.leadingAction != null) ...<Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 9.0,
                                  ),
                                  child: SmoothLeadingButton(
                                    action: widget.leadingAction!,
                                    foregroundColor: widget.foregroundColor,
                                  ),
                                ),
                                const SizedBox(width: BALANCED_SPACE)
                              ],
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    bottom: 1.56 * (1 - _progress),
                                    top: _computeTextTopPadding(),
                                  ),
                                  child: _getText(darkTheme, colors),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _computeHeight() =>
      kToolbarHeight +
      ((SmoothTopBar2.kTopBar2Height - kToolbarHeight) * (1 - _progress));

  Positioned _getImageAsset({
    required Color backgroundColor,
    required TextDirection textDirection,
    required double imageWidth,
    required double imageHeight,
  }) {
    final double progress = _progress.progressAndClamp(0.0, 0.7, 1.0);

    if (widget.productType == null) {
      return Positioned.directional(
        textDirection: textDirection,
        bottom: -(imageHeight / 2.1),
        end: -imageWidth * 0.15,
        child: Offstage(
          offstage: progress == 1.0,
          child: ExcludeSemantics(
            child: SvgPicture.asset(
              'assets/product/product_completed_graphic_light.svg',
              width: MediaQuery.sizeOf(context).width * 0.22,
              height: imageHeight,
            ),
          ),
        ),
      );
    }

    final double height = switch (widget.productType!) {
      ProductType.food => imageHeight / 2.1,
      ProductType.beauty => imageHeight / 2.0,
      ProductType.petFood => imageHeight / 2.7,
      ProductType.product => imageHeight / 2.65,
    };

    return Positioned.directional(
      textDirection: textDirection,
      bottom: 0.0,
      end: 0.0,
      child: Offstage(
        offstage: progress == 1.0,
        child: ExcludeSemantics(
          child: SvgPicture.asset(
            widget.productType!.getIllustration(),
            width: imageWidth,
            height: height,
            colorFilter: progress == 0.0
                ? null
                : ColorFilter.mode(
                    backgroundColor.withValues(alpha: progress),
                    BlendMode.srcATop,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getText(bool darkTheme, SmoothColorsThemeExtension colors) {
    final Widget text = Text(
      widget.title,
      maxLines: widget.subTitle != null ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: widget.foregroundColor ??
            (darkTheme ? colors.primaryMedium : colors.primaryBlack),
        fontSize: 20.0,
        height: widget.reducedHeightOnScroll ? 1.3 : 1.5,
        fontWeight: FontWeight.bold,
      ),
    );

    if (widget.forceMultiLines) {
      return SizedBox(
        height: (MediaQuery.textScalerOf(context).scale(20.0) * 2.0) * 1.5,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: text,
        ),
      );
    } else if (widget.subTitle == null) {
      return text;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text,
        Text(
          widget.subTitle!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.foregroundColor ??
                (darkTheme ? colors.primaryMedium : colors.primaryBlack),
            fontSize: 16.0,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _computeTextTopPadding() {
    double topPadding = widget.leadingAction != null && widget.subTitle != null
        ? (9.0 * (1 - _progress.progressAndClamp(0.2, 0.9, 0.50)))
        : MEDIUM_SPACE;

    if (widget.subTitle != null) {
      topPadding += 4.5 * (1 - _progress);
    }

    return topPadding;
  }
}
