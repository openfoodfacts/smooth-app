import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/hideable_container.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_barcode_widget.dart';
import 'package:smooth_app/widgets/smooth_close_button.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// A common Widget for carrousel item cards.
/// It allows to have the correct width/height and also a scale down feature,
/// in the case where the content is too big.
///
/// An optional [backgroundColorOpacity] can be used (mainly for the "main" card).
class ScanProductBaseCard extends StatelessWidget {
  const ScanProductBaseCard({
    required this.headerLabel,
    required this.headerIndicatorColor,
    required this.child,
    this.backgroundChild,
    this.childPadding,
    this.headerBackgroundColor,
    this.onRemove,
    super.key,
  });

  static const double HEADER_MIN_HEIGHT_NORMAL = 50.0;
  static const double HEADER_MIN_HEIGHT_DENSE = 45.0;

  final String headerLabel;
  final Color headerIndicatorColor;
  final Color? headerBackgroundColor;
  final EdgeInsetsGeometry? childPadding;
  final Widget child;

  /// A Widget that will be displayed behind [childPadding].
  /// Note: It will embedded in a [Stack]
  final Widget? backgroundChild;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    Widget child = _buildChild();
    if (backgroundChild != null) {
      child = Stack(
        children: <Widget>[
          backgroundChild!,
          Positioned.fill(child: child),
        ],
      );
    }

    return HideableContainer(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: VERY_SMALL_SPACE,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: ROUNDED_BORDER_RADIUS,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(
                    alpha: context.lightTheme() ? 0.08 : 0.3,
                  ),
                  offset: const Offset(0.0, 2.0),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: SmoothCard(
              padding: EdgeInsetsDirectional.zero,
              margin: EdgeInsetsDirectional.zero,
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  _SmoothProductCardHeader(
                    backgroundColor: headerBackgroundColor,
                    label: headerLabel,
                    indicatorColor: headerIndicatorColor,
                    onClose: onRemove != null
                        ? () => onRemove?.call(context)
                        : null,
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final EdgeInsetsGeometry padding =
            childPadding ??
            const EdgeInsetsDirectional.only(
              start: VERY_LARGE_SPACE,
              end: VERY_LARGE_SPACE,
              top: LARGE_SPACE,
              bottom: SMALL_SPACE,
            );

        return Padding(
          padding: padding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth - padding.horizontal,
              height: constraints.maxHeight - padding.vertical,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

typedef OnRemoveCallback = void Function(BuildContext context);

class _SmoothProductCardHeader extends StatelessWidget {
  const _SmoothProductCardHeader({
    required this.label,
    required this.indicatorColor,
    this.onClose,
    this.backgroundColor,
  });

  final Color? backgroundColor;
  final String label;
  final Color indicatorColor;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ??
        context.extension<SmoothColorsThemeExtension>().primarySemiDark;
    final String closeTooltip = AppLocalizations.of(
      context,
    ).carousel_close_tooltip;
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: dense
            ? ScanProductBaseCard.HEADER_MIN_HEIGHT_DENSE
            : ScanProductBaseCard.HEADER_MIN_HEIGHT_NORMAL,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
          color: bgColor,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: VERY_LARGE_SPACE,
            end: onClose != null ? SMALL_SPACE : LARGE_SPACE,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                ),
              ),
              SizedBox(width: dense ? BALANCED_SPACE : MEDIUM_SPACE),
              Expanded(
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onClose != null) ...<Widget>[
                const SizedBox(width: MEDIUM_SPACE),
                SmoothCloseButton(
                  onClose: onClose!,
                  circleColor: bgColor,
                  crossSize: 11.5,
                  crossColor: Colors.white,
                  circleBorderColor: Colors.white,
                  tooltip: closeTooltip,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ScanProductBaseCardTitle extends StatelessWidget {
  const ScanProductBaseCardTitle({
    required this.title,
    this.padding,
    super.key,
  });

  final String title;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            EdgeInsetsDirectional.only(
              bottom: dense ? SMALL_SPACE : MEDIUM_SPACE,
            ).copyWith(
              top: padding?.top,
              bottom: padding?.bottom,
              start: padding?.start,
              end: padding?.end,
            ),
        child: TextWithUnderlinedParts(
          text: title,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
        ),
      ),
    );
  }
}

class ScanProductBaseCardText extends StatelessWidget {
  const ScanProductBaseCardText({required this.text, super.key});

  final Widget text;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14.5),
      child: text,
    );
  }
}

class ScanProductBaseCardBarcode extends StatelessWidget {
  const ScanProductBaseCardBarcode({
    required this.barcode,
    this.height,
    this.padding,
    super.key,
  }) : assert(height == null || height > 0);

  final String barcode;
  final double? height;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return Padding(
      padding:
          EdgeInsetsDirectional.only(
            top: dense ? SMALL_SPACE : MEDIUM_SPACE,
            bottom: dense ? BALANCED_SPACE : LARGE_SPACE * 2,
          ).copyWith(
            top: padding?.top,
            bottom: padding?.bottom,
            start: padding?.start,
            end: padding?.end,
          ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ANGULAR_BORDER_RADIUS,
          color: lightTheme ? theme.primaryMedium : theme.primaryLight,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: dense ? 75.0 : 100.0),
            child: SmoothBarcodeWidget(
              height: height ?? 100.0,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 30.0,
                vertical: dense ? SMALL_SPACE : MEDIUM_SPACE,
              ),
              color: Colors.black,
              backgroundColor: lightTheme ? Colors.white : Colors.transparent,
              barcode: barcode,
            ),
          ),
        ),
      ),
    );
  }
}

class ScanProductBaseCardButton extends StatelessWidget {
  const ScanProductBaseCardButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SmoothButtonWithArrow(text: text, onTap: onTap);
  }
}
