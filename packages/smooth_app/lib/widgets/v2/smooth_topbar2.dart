import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothTopBar2 extends StatefulWidget implements PreferredSizeWidget {
  const SmoothTopBar2({
    required this.title,
    this.topWidget,
    this.leadingAction,
    this.forceMultiLines = false,
    this.elevation = 4.0,
    super.key,
  }) : assert(title.length > 0);

  /// Height without the top view padding
  static double kTopBar2Height = 100;

  final String title;
  final double elevation;
  final bool forceMultiLines;
  final PreferredSizeWidget? topWidget;
  final SmoothTopBarLeadingAction? leadingAction;

  @override
  State<SmoothTopBar2> createState() => _SmoothTopBar2State();

  @override
  Size get preferredSize => Size(double.infinity,
      kTopBar2Height + (topWidget?.preferredSize.height ?? 0.0));
}

class _SmoothTopBar2State extends State<SmoothTopBar2> {
  double _elevation = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => PrimaryScrollController.maybeOf(context)?.addListener(
        () => _onScroll(),
      ),
    );
  }

  void _onScroll() {
    final double offset = PrimaryScrollController.of(context).offset;
    final double newElevation = offset.progressAndClamp(
          0.0,
          HEADER_ROUNDED_RADIUS.x * 2.0,
          1.0,
        ) *
        widget.elevation;

    if (newElevation != _elevation) {
      setState(() {
        _elevation = newElevation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final TextDirection textDirection = Directionality.of(context);
    final bool darkTheme = context.darkTheme();

    final double imageWidth = MediaQuery.sizeOf(context).width * 0.22;
    final double imageHeight = imageWidth * 114 / 92;

    return PhysicalModel(
      color: Colors.transparent,
      elevation: _elevation,
      shadowColor: context.darkTheme() ? Colors.white10 : Colors.black12,
      borderRadius: const BorderRadius.vertical(
        bottom: HEADER_ROUNDED_RADIUS,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: HEADER_ROUNDED_RADIUS,
        ),
        child: ColoredBox(
          color: darkTheme ? colors.primaryDark : colors.primaryMedium,
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
                  height: SmoothTopBar2.kTopBar2Height,
                  child: Stack(
                    children: <Widget>[
                      Positioned.directional(
                        textDirection: textDirection,
                        bottom: -(imageHeight / 2.1),
                        end: -imageWidth * 0.15,
                        child: ExcludeSemantics(
                          child: SvgPicture.asset(
                            'assets/product/product_completed_graphic_light.svg',
                            width: MediaQuery.sizeOf(context).width * 0.22,
                            height: imageHeight,
                          ),
                        ),
                      ),
                      Positioned.directional(
                        textDirection: textDirection,
                        top: MEDIUM_SPACE,
                        bottom: VERY_LARGE_SPACE,
                        start: widget.leadingAction != null
                            ? BALANCED_SPACE
                            : VERY_LARGE_SPACE,
                        end: imageWidth * 0.7,
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              if (widget.leadingAction != null) ...<Widget>[
                                _SmoothTopBarLeadingButton(
                                  action: widget.leadingAction!,
                                ),
                                const SizedBox(width: BALANCED_SPACE)
                              ],
                              Expanded(
                                child: Padding(
                                  padding: widget.leadingAction != null
                                      ? const EdgeInsetsDirectional.only(
                                          bottom: 1.56,
                                        )
                                      : EdgeInsets.zero,
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

  Widget _getText(bool darkTheme, SmoothColorsThemeExtension colors) {
    final Widget text = Text(
      widget.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: darkTheme ? colors.primaryMedium : colors.primaryBlack,
        fontSize: 20.0,
        height: 1.5,
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
    }

    return text;
  }
}

enum SmoothTopBarLeadingAction {
  close,
  back,
  minimize,
}

class _SmoothTopBarLeadingButton extends StatelessWidget {
  const _SmoothTopBarLeadingButton({
    required this.action,
  });

  final SmoothTopBarLeadingAction action;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final String message = getMessage(localizations);
    final Color color =
        context.darkTheme() ? colors.primaryMedium : colors.primaryBlack;

    return Semantics(
      button: true,
      value: message,
      excludeSemantics: true,
      child: Tooltip(
        message: message,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            splashColor: Colors.white70,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: 1.0,
                ),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 36.0,
                child: appIcon(
                  size: 16.0,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon({
    required double size,
    required Color color,
  }) {
    assert(size >= 0.0);

    return switch (action) {
      SmoothTopBarLeadingAction.close => icons.Close(size: size, color: color),
      SmoothTopBarLeadingAction.back =>
        icons.Arrow.left(size: size, color: color),
      SmoothTopBarLeadingAction.minimize => Padding(
          padding: const EdgeInsetsDirectional.only(top: 1.0),
          child: icons.Chevron.down(size: size, color: color),
        ),
    };
  }

  String getMessage(MaterialLocalizations localizations) {
    return switch (action) {
      SmoothTopBarLeadingAction.close => localizations.closeButtonTooltip,
      SmoothTopBarLeadingAction.back => localizations.backButtonTooltip,
      SmoothTopBarLeadingAction.minimize => localizations.closeButtonTooltip,
    };
  }
}
