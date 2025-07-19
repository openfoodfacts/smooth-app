import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_data_value.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Price Data display (no product data here).
class PriceDataWidget extends StatelessWidget {
  const PriceDataWidget(
    this.price, {
    required this.model,
    required this.showOptionsMenu,
    super.key,
  });

  final Price price;
  final GetPricesModel model;
  final VoidCallback showOptionsMenu;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final DateFormat timeFormat = DateFormat('HH:mm');

    final DateTime created = price.created.toLocal();
    final String date = MaterialLocalizations.of(
      context,
    ).formatCompactDate(created);
    final String time = timeFormat.format(created);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return DefaultTextStyle.merge(
      style: TextStyle(color: extension.primaryBlack, fontSize: 15.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: BALANCED_SPACE,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: lightTheme
                ? extension.primaryNormal
                : extension.primaryMedium,
          ),
          child: Column(
            spacing: SMALL_SPACE,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PriceDataEntry(
                      icon: const icons.Clock.alt(size: 19.0),
                      label: '$date $time',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      labelPadding: const EdgeInsetsDirectional.only(
                        bottom: 2.5,
                      ),
                    ),
                  ),
                  PriceDataValue(price: price),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PriceDataEntry(
                      icon: const icons.Shop(size: 20.0),
                      label:
                          price.location?.name ??
                          appLocalizations.prices_entry_shop_not_found,
                      labelPadding: const EdgeInsetsDirectional.only(
                        bottom: 2.5,
                      ),
                    ),
                  ),
                  PriceDataDiscountedValue(price: price),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PriceDataEntry(
                      icon: const icons.Location(size: 19.44),
                      label:
                          '${price.location?.city}, ${price.location?.country ?? ''}',
                      labelPadding: const EdgeInsetsDirectional.only(
                        bottom: 2.5,
                      ),
                    ),
                  ),
                  _PriceMenuButton(onPressed: showOptionsMenu),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceDataEntry extends StatelessWidget {
  const _PriceDataEntry({
    required this.icon,
    required this.label,
    this.labelPadding,
    this.labelStyle,
  });

  final Widget icon;
  final String label;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Row(
      children: <Widget>[
        icon,
        const SizedBox(width: SMALL_SPACE),
        Padding(
          padding: labelPadding ?? EdgeInsetsDirectional.zero,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: lightTheme
                  ? extension.primaryBlack
                  : extension.primaryLight,
            ).merge(labelStyle),
          ),
        ),
      ],
    );
  }
}

class _PriceMenuButton extends StatelessWidget {
  const _PriceMenuButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return Tooltip(
      message: MaterialLocalizations.of(context).showMenuTooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Ink(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: extension.primaryMedium,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: icons.ThreeDots.vertical(
              size: 12.0,
              color: extension.primarySemiDark,
            ),
          ),
        ),
      ),
    );
  }
}
