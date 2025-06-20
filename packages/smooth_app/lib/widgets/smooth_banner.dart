import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_close_button.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class SmoothBanner extends StatelessWidget {
  const SmoothBanner({
    required this.icon,
    required this.content,
    this.title,
    this.titleColor,
    this.titleStyle,
    this.contentColor,
    this.contentStyle,
    this.iconAlignment,
    this.iconColor,
    this.iconBackgroundColor,
    this.titleBackgroundColor,
    this.contentBackgroundColor,
    this.onDismissClicked,
    this.borderRadius,
    this.addSafeArea = false,
    this.topShadow = false,
    super.key,
  });

  final AlignmentGeometry? iconAlignment;
  final Widget icon;
  final String? title;
  final String content;

  /// If not null, a dismiss button is displayed
  final ValueChanged<SmoothBannerDismissEvent>? onDismissClicked;
  final bool topShadow;
  final bool addSafeArea;

  final BorderRadiusGeometry? borderRadius;

  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final Color? contentColor;
  final TextStyle? contentStyle;
  final Color? titleBackgroundColor;
  final Color? contentBackgroundColor;

  static const Color _titleColor = Color(0xFF373737);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding =
        addSafeArea ? MediaQuery.viewPaddingOf(context).bottom : 0.0;

    Widget child = IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 15,
            child: ExcludeSemantics(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: iconBackgroundColor ?? const Color(0xFFE4E4E4),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                alignment: iconAlignment ?? AlignmentDirectional.topCenter,
                child: IconTheme(
                  data: IconThemeData(
                    color: iconColor ?? const Color(0xFF373737),
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 85,
            child: Container(
              width: double.infinity,
              color: contentBackgroundColor ?? const Color(0xFFECECEC),
              padding: EdgeInsetsDirectional.only(
                bottom: onDismissClicked != null ? LARGE_SPACE : MEDIUM_SPACE,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ColoredBox(
                    color: titleBackgroundColor ?? Colors.transparent,
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: MEDIUM_SPACE,
                        vertical: onDismissClicked != null
                            ? VERY_SMALL_SPACE
                            : BALANCED_SPACE,
                      ),
                      child: Row(
                        children: <Widget>[
                          if (title != null)
                            Expanded(
                              child: Text(
                                title!,
                                style: (titleStyle ??
                                        const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ))
                                    .copyWith(color: titleColor ?? _titleColor),
                              ),
                            ),
                          if (onDismissClicked != null) ...<Widget>[
                            const SizedBox(width: SMALL_SPACE),
                            SmoothCloseButton(
                              onClose: () => onDismissClicked!.call(
                                SmoothBannerDismissEvent.fromButton,
                              ),
                              circleColor: titleColor ?? _titleColor,
                              crossColor: Colors.white,
                              circleSize: 26.0,
                              crossSize: 12.0,
                              tooltip: AppLocalizations.of(context)
                                  .owner_field_info_close_button,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (onDismissClicked == null)
                    const SizedBox(
                      height: VERY_SMALL_SPACE,
                      width: MEDIUM_SPACE,
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: MEDIUM_SPACE,
                    ),
                    child: TextWithBoldParts(
                      text: content,
                      textStyle: (contentStyle ??
                              const TextStyle(fontSize: 14.0, height: 1.6))
                          .copyWith(
                        color: contentColor ?? const Color(0xFF373737),
                      ),
                    ),
                  ),
                  if (bottomPadding > 0) SizedBox(height: bottomPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    if (topShadow) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
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
        child: child,
      );
    }

    if (onDismissClicked != null) {
      child = Dismissible(
        key: const Key('SmoothBanner'),
        direction: DismissDirection.down,
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.down) {
            onDismissClicked!.call(SmoothBannerDismissEvent.fromSwipe);
          }
        },
        child: child,
      );
    }

    return child;
  }
}

enum SmoothBannerDismissEvent {
  fromSwipe,
  fromButton,
}
