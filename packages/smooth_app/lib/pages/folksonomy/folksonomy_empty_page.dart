import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:vector_graphics/vector_graphics.dart';

class FolksonomyEmptyPage extends StatelessWidget {
  const FolksonomyEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: MEDIUM_SPACE,
            children: <Widget>[
              SizedBox.square(
                dimension: 150.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: extension.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: extension.primaryMedium,
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: SvgPicture(
                      AssetBytesLoader('assets/icons/property_empty.svg.vec'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
              Text(
                appLocalizations.product_tags_empty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2.0),
              Text(
                appLocalizations.product_tags_explanation,
                style: const TextStyle(fontSize: 15.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
