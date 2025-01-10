import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/smooth_close_button.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class SmoothBanner extends StatelessWidget {
  const SmoothBanner({
    required this.icon,
    required this.title,
    required this.content,
    this.titleColor,
    this.contentColor,
    this.iconAlignment,
    this.iconColor,
    this.iconBackgroundColor,
    this.contentBackgroundColor,
    this.onDismissClicked,
    this.addSafeArea = false,
    this.topShadow = false,
    super.key,
  });

  final AlignmentGeometry? iconAlignment;
  final Widget icon;
  final String title;
  final String content;

  /// If not null, a dismiss button is displayed
  final ValueChanged<SmoothBannerDismissEvent>? onDismissClicked;
  final bool topShadow;
  final bool addSafeArea;

  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? titleColor;
  final Color? contentColor;
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
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
                top: onDismissClicked != null
                    ? VERY_SMALL_SPACE
                    : BALANCED_SPACE,
                bottom: onDismissClicked != null ? LARGE_SPACE : MEDIUM_SPACE,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: titleColor ?? _titleColor,
                          ),
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
                  if (onDismissClicked == null)
                    const SizedBox(height: VERY_SMALL_SPACE),
                  TextWithBoldParts(
                    text: content,
                    textStyle: TextStyle(
                      fontSize: 14.0,
                      color: contentColor ?? const Color(0xFF373737),
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

    if (topShadow) {
      child = DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0.0, -4.0),
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
