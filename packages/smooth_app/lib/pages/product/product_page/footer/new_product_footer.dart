import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_add_price.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_add_to_lists.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_compare.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_edit.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_settings.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer_share.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductFooter extends StatelessWidget {
  const ProductFooter({super.key});

  static const double kHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context)
                .shadowColor
                .withOpacity(context.lightTheme() ? 0.25 : 0.6),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: const _ProductFooterButtonsBar(),
    );
  }
}

enum ProductFooterActionBar {
  addPrice('add_price'),
  edit('edit'),
  compare('compare'),
  addToList('add_to_list'),
  share('share'),
  settings('settings');

  const ProductFooterActionBar(this.key);

  final String key;

  static ProductFooterActionBar fromKey(String key) {
    return switch (key) {
      'add_price' => ProductFooterActionBar.addPrice,
      'edit' => ProductFooterActionBar.edit,
      'compare' => ProductFooterActionBar.compare,
      'add_to_list' => ProductFooterActionBar.addToList,
      'share' => ProductFooterActionBar.share,
      'settings' => ProductFooterActionBar.settings,
      _ => throw Exception('Unknown key $key'),
    };
  }

  /// The "settings" value must not persisted
  static List<ProductFooterActionBar> defaultOrder() =>
      const <ProductFooterActionBar>[
        edit,
        addPrice,
        compare,
        addToList,
        share,
      ];
}

class _ProductFooterButtonsBar extends StatelessWidget {
  const _ProductFooterButtonsBar();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    // Add an extra padding (for Android)
    if (Platform.isAndroid) {
      bottomPadding += MEDIUM_SPACE;
    }

    return SizedBox(
      height: ProductFooter.kHeight + LARGE_SPACE + bottomPadding,
      child: OutlinedButtonTheme(
        data: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            side: BorderSide(color: themeExtension.greyLight),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 19.0,
            ),
          ),
        ),
        child: ConsumerFilter<UserPreferences>(
          buildWhen: (UserPreferences? previous, UserPreferences current) =>
              previous?.productPageActions != current.productPageActions,
          builder: (BuildContext context, UserPreferences userPreferences, _) {
            final List<ProductFooterActionBar> productPageActions =
                userPreferences.productPageActions;

            return ListView.separated(
              padding: EdgeInsetsDirectional.only(
                start: SMALL_SPACE,
                end: SMALL_SPACE,
                top: LARGE_SPACE,
                bottom: bottomPadding,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: productPageActions.length + 1,
              itemBuilder: (BuildContext context, int index) {
                final ProductFooterActionBar action =
                    index == productPageActions.length
                        ? ProductFooterActionBar.settings
                        : productPageActions[index];

                return Provider<_ProductFooterButtonType>.value(
                  value: index == 0
                      ? _ProductFooterButtonType.filled
                      : _ProductFooterButtonType.outlined,
                  child: switch (action) {
                    ProductFooterActionBar.addPrice =>
                      const ProductFooterAddPriceButton(),
                    ProductFooterActionBar.addToList =>
                      const ProductFooterAddToListButton(),
                    ProductFooterActionBar.compare =>
                      const ProductFooterCompareButton(),
                    ProductFooterActionBar.edit =>
                      const ProductFooterEditButton(),
                    ProductFooterActionBar.share =>
                      const ProductFooterShareButton(),
                    ProductFooterActionBar.settings =>
                      const ProductFooterSettingsButton(),
                  },
                );
              },
              separatorBuilder: (_, __) =>
                  const SizedBox(width: BALANCED_SPACE),
            );
          },
        ),
      ),
    );
  }
}

class ProductFooterButton extends StatelessWidget {
  const ProductFooterButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.tooltip,
    this.semanticsLabel,
    this.enabled = true,
    this.vibrate = false,
  });

  final String? label;
  final String? semanticsLabel;
  final String? tooltip;
  final icons.AppIcon icon;
  final VoidCallback onTap;
  final bool vibrate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final _ProductFooterButtonType buttonType =
        context.watch<_ProductFooterButtonType>();

    final Widget button = switch (buttonType) {
      _ProductFooterButtonType.filled => _ProductFooterFilledButton(
          label: label,
          icon: icon,
          onTap: _onTap,
          enabled: enabled,
          semanticsLabel: semanticsLabel,
        ),
      _ProductFooterButtonType.outlined => _ProductFooterOutlinedButton(
          label: label,
          icon: icon,
          onTap: _onTap,
          enabled: enabled,
          semanticsLabel: semanticsLabel,
        ),
    };

    if (tooltip?.isNotEmpty == true) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    } else {
      return button;
    }
  }

  void _onTap() {
    if (vibrate) {
      SmoothHapticFeedback.lightNotification();
    }
    onTap();
  }
}

enum _ProductFooterButtonType {
  filled,
  outlined,
}

class _ProductFooterFilledButton extends StatelessWidget {
  const _ProductFooterFilledButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.semanticsLabel,
    this.enabled = true,
  });

  final String? label;
  final String? semanticsLabel;
  final icons.AppIcon icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final ProductPageCompatibility compatibility =
        context.watch<ProductPageCompatibility>();
    final Color contentColor = compatibility.color != null
        ? compatibility.color!
        : context.lightTheme()
            ? themeExtension.primaryBlack
            : themeExtension.primarySemiDark;
    final Color mainColor =
        enabled ? contentColor : contentColor.withOpacity(0.5);

    final Widget child = IconTheme(
      data: const IconThemeData(
        color: Colors.white,
        size: 18.0,
      ),
      child: icon,
    );

    return Semantics(
      excludeSemantics: true,
      button: true,
      label: semanticsLabel,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: mainColor,
          side: BorderSide.none,
        ),
        child: label == null
            ? child
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  child,
                  const SizedBox(width: 8.0),
                  Text(
                    label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProductFooterOutlinedButton extends StatelessWidget {
  const _ProductFooterOutlinedButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String? label;
  final String? semanticsLabel;
  final icons.AppIcon icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final Color contentColor =
        context.lightTheme() ? themeExtension.primaryBlack : Colors.white;
    final Color mainColor =
        enabled ? contentColor : contentColor.withOpacity(0.5);

    final Widget child = IconTheme(
      data: IconThemeData(
        color: mainColor,
        size: 18.0,
      ),
      child: icon,
    );

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      button: true,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: mainColor,
          backgroundColor: Colors.transparent,
        ),
        child: label == null
            ? child
            : Row(
                children: <Widget>[
                  child,
                  const SizedBox(width: 8.0),
                  Text(
                    label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
