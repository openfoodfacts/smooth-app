import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class PriceHeaderContainer extends StatelessWidget {
  const PriceHeaderContainer({
    required this.line1,
    required this.semanticsLabel,
    this.imageProvider,
    this.line2,
    this.line3,
    this.count,
    this.warningIndicator = false,
    super.key,
  });

  final ImageProvider? imageProvider;
  final String line1;
  final String? line2;
  final String? line3;
  final int? count;
  final String semanticsLabel;
  final bool warningIndicator;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: VERY_SMALL_SPACE,
          end: VERY_SMALL_SPACE,
          top: VERY_SMALL_SPACE,
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox.square(
                dimension: 80.0,
                child: Stack(
                  children: <Widget>[
                    if (imageProvider != null)
                      ProductPicture.fromImageProvider(
                        imageProvider: imageProvider!,
                        size: const Size.square(80.0),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      )
                    else
                      const PictureNotFound.ink(
                        backgroundDecoration: BoxDecoration(
                          borderRadius: ANGULAR_BORDER_RADIUS,
                        ),
                      ),
                    if (count != null)
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: _PriceCountBadge(count: count!),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: SMALL_SPACE),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: SMALL_SPACE,
                  children: <Widget>[
                    Row(
                      spacing: SMALL_SPACE,
                      children: <Widget>[
                        if (warningIndicator)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 3.0),
                            child: icons.Warning(
                              color: context
                                  .extension<SmoothColorsThemeExtension>()
                                  .error,
                              size: 20.0,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            line1,
                            maxLines: _line1MaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    if (line2 != null)
                      Text(
                        line2!,
                        maxLines: _line2MaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (line3 != null) Text(line3!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _line1MaxLines {
    if (line2 == null || line3 == null) {
      return 2;
    } else {
      return 1;
    }
  }

  int get _line2MaxLines {
    if (line3 == null) {
      return 2;
    } else {
      return 1;
    }
  }
}

class _PriceCountBadge extends StatelessWidget {
  const _PriceCountBadge({required this.count}) : assert(count >= 0);

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PriceCountWidget.getForegroundColor(
          count,
        ).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: VERY_SMALL_SPACE,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SMALL_SPACE,
          children: <Widget>[
            const icons.PriceTag(color: Colors.white, size: 16.0),
            Text(
              count.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
