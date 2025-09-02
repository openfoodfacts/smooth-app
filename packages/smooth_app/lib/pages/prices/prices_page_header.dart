import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class PricesHeader extends StatelessWidget {
  const PricesHeader(this.model, {this.pricesResult});

  final GetPricesModel model;
  final GetPricesResult? pricesResult;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return PinnedHeaderSliver(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.lightTheme()
              ? extension.primaryMedium
              : extension.primarySemiDark,
          borderRadius: const BorderRadius.vertical(bottom: ROUNDED_RADIUS),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: context.extension<SmoothColorsThemeExtension>().greyLight,
              blurRadius: 4.0,
              offset: const Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: MEDIUM_SPACE + HEADER_ROUNDED_RADIUS.x,
            bottom: MEDIUM_SPACE,
            start: model.displayEachProduct ? 16.0 : 8.0,
            end: model.displayEachProduct ? 16.0 : 8.0,
          ),
          child: IntrinsicHeight(
            child: Row(
              spacing: SMALL_SPACE,
              children: <Widget>[
                if (pricesResult?.total != null)
                  Expanded(
                    child: _PricesPageCounter(count: pricesResult!.total!),
                  ),
                Expanded(
                  child: _PricesHeaderAddPriceButton(onTap: model.addButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PricesPageCounter extends StatelessWidget {
  const _PricesPageCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        color: lightTheme ? Colors.white : extension.primaryUltraBlack,
        border: Border.all(
          color: lightTheme
              ? extension.greyDark.withValues(alpha: 0.35)
              : extension.greyDark,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SMALL_SPACE,
          horizontal: MEDIUM_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: VERY_SMALL_SPACE,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.lightTheme()
                    ? extension.primaryDark
                    : extension.primaryMedium,
                borderRadius: ANGULAR_BORDER_RADIUS,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: 2.0,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25.0,
                    color: lightTheme ? Colors.white : extension.primaryBlack,
                  ),
                ),
              ),
            ),
            Text(
              appLocalizations.prices_list_count,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricesHeaderAddPriceButton extends StatelessWidget {
  const _PricesHeaderAddPriceButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: lightTheme ? Colors.white : extension.primaryUltraBlack,
        border: DashedBorder.all(
          dashLength: 3.0,
          spaceLength: 3.0,
          color: lightTheme ? extension.primarySemiDark : extension.greyMedium,
        ),
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: InkWell(
          onTap: onTap,
          borderRadius: ROUNDED_BORDER_RADIUS,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: SMALL_SPACE,
              horizontal: MEDIUM_SPACE,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                icons.Add(
                  color: lightTheme
                      ? extension.primaryDark
                      : extension.primaryMedium,
                  size: 35.0,
                ),
                Text(
                  appLocalizations.prices_list_add_new_price,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
