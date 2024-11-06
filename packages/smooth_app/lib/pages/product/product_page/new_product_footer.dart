import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/product_list_helper.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/query/category_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
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
        child: ListView(
          padding: EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
            end: SMALL_SPACE,
            top: LARGE_SPACE,
            bottom: bottomPadding,
          ),
          scrollDirection: Axis.horizontal,
          children: const <Widget>[
            SizedBox(width: 10.0),
            _ProductAddPriceButton(),
            SizedBox(width: 10.0),
            _ProductEditButton(),
            SizedBox(width: 10.0),
            _ProductCompareButton(),
            SizedBox(width: 10.0),
            _ProductAddToListButton(),
            SizedBox(width: 10.0),
            _ProductShareButton(),
          ],
        ),
      ),
    );
  }
}

class _ProductAddToListButton extends StatelessWidget {
  const _ProductAddToListButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ProductFooterOutlinedButton(
      label: appLocalizations.user_list_button_add_product,
      icon: const icons.AddToList(),
      onTap: () => _editList(context, context.read<Product>()),
    );
  }

  Future<bool?> _editList(BuildContext context, Product product) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    showSmoothDraggableModalSheet(
      context: context,
      header: SmoothModalSheetHeader(
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
        title: appLocalizations.user_list_title,
        suffix: const SmoothModalSheetHeaderCloseButton(),
      ),
      bodyBuilder: (BuildContext context) => AddProductToListContainer(
        barcode: product.barcode!,
      ),
    );

    return true;
  }
}

class _ProductAddPriceButton extends StatelessWidget {
  const _ProductAddPriceButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConsumerFilter<UserPreferences>(
      buildWhen: (UserPreferences? previous, UserPreferences current) =>
          previous?.userCurrencyCode != current.userCurrencyCode,
      builder: (BuildContext context, UserPreferences userPreferences, _) {
        final Currency currency = Currency.values.firstWhere(
          (Currency currency) =>
              currency.name == userPreferences.userCurrencyCode,
          orElse: () => Currency.USD,
        );

        return _ProductFooterFilledButton(
          label: appLocalizations.prices_add_a_price,
          icon: switch (currency) {
            Currency.GBP => const icons.AddPrice.britishPound(),
            Currency.USD => const icons.AddPrice.dollar(),
            Currency.EUR => const icons.AddPrice.euro(),
            Currency.RUB => const icons.AddPrice.ruble(),
            Currency.INR => const icons.AddPrice.rupee(),
            Currency.CHF => const icons.AddPrice.swissFranc(),
            Currency.TRY => const icons.AddPrice.turkishLira(),
            Currency.UAH => const icons.AddPrice.ukrainianHryvnia(),
            Currency.KRW => const icons.AddPrice.won(),
            Currency.JPY => const icons.AddPrice.yen(),
            _ => const icons.AddPrice.dollar(),
          },
          onTap: () => _addAPrice(context, context.read<Product>()),
        );
      },
    );
  }

  Future<void> _addAPrice(BuildContext context, Product product) {
    return ProductPriceAddPage.showProductPage(
      context: context,
      product: PriceMetaProduct.product(context.read<Product>()),
      proofType: ProofType.priceTag,
    );
  }
}

class _ProductEditButton extends StatelessWidget {
  const _ProductEditButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ProductFooterOutlinedButton(
      label: appLocalizations.edit_product_label_short,
      semanticsLabel: appLocalizations.edit_product_label,
      icon: const icons.Edit(),
      onTap: () => _editProduct(context, context.read<Product>()),
    );
  }

  Future<void> _editProduct(BuildContext context, Product product) async {
    ProductPageState.of(context).stopRobotoffQuestion();

    AnalyticsHelper.trackEvent(
      AnalyticsEvent.openProductEditPage,
      barcode: product.barcode,
    );

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditProductPage(product),
      ),
    );

    if (context.mounted) {
      ProductPageState.of(context).startRobotoffQuestion();
    }
  }
}

class _ProductCompareButton extends StatelessWidget {
  const _ProductCompareButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    const Set<String> blackListedCategories = <String>{
      'fr:vegan',
    };
    String? categoryTag;
    String? categoryLabel;
    final List<String>? labels =
        product.categoriesTagsInLanguages?[ProductQuery.getLanguage()];
    final List<String>? tags = product.categoriesTags;
    if (tags != null &&
        labels != null &&
        tags.isNotEmpty &&
        tags.length == labels.length) {
      categoryTag = product.comparedToCategory;
      if (categoryTag == null || blackListedCategories.contains(categoryTag)) {
        // fallback algorithm
        int index = tags.length - 1;
        // cf. https://github.com/openfoodfacts/openfoodfacts-dart/pull/474
        // looking for the most detailed non blacklisted category
        categoryTag = tags[index];
        while (blackListedCategories.contains(categoryTag) && index > 0) {
          index--;
          categoryTag = tags[index];
        }
      }
      if (categoryTag != null) {
        for (int i = 0; i < tags.length; i++) {
          if (categoryTag == tags[i]) {
            categoryLabel = labels[i];
          }
        }
      }
    }

    final bool enabled = categoryTag != null && categoryLabel != null;

    return _ProductFooterOutlinedButton(
      label: appLocalizations.product_search_same_category_short,
      semanticsLabel: appLocalizations.product_search_same_category,
      icon: const icons.Compare(),
      enabled: enabled,
      onTap: () => enabled
          ? _compareProduct(
              context: context,
              product: product,
              categoryLabel: categoryLabel!,
              categoryTag: categoryTag!,
            )
          : _showFeatureDisabledDialog(context),
    );
  }

  Future<void> _compareProduct({
    required BuildContext context,
    required Product product,
    required String categoryLabel,
    required String categoryTag,
  }) {
    return ProductQueryPageHelper.openBestChoice(
      name: categoryLabel,
      localDatabase: context.read<LocalDatabase>(),
      productQuery: CategoryProductQuery(
        categoryTag,
        productType: product.productType ?? ProductType.food,
      ),
      context: context,
      searchResult: false,
    );
  }

  void _showFeatureDisabledDialog(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SmoothFloatingSnackbar(
        content: Row(
          children: <Widget>[
            const ExcludeSemantics(
              child: icons.Warning(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: LARGE_SPACE),
            Expanded(
                child:
                    Text(appLocalizations.product_search_same_category_error)),
          ],
        ),
        backgroundColor: themeData.extension<SmoothColorsThemeExtension>()!.red,
        action: SnackBarAction(
          label: appLocalizations.okay,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class _ProductShareButton extends StatelessWidget {
  const _ProductShareButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ProductFooterOutlinedButton(
      label: appLocalizations.share,
      icon: icons.Share(),
      onTap: () => _shareProduct(context, context.read<Product>()),
    );
  }

  Future<void> _shareProduct(BuildContext context, Product product) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.shareProduct,
      barcode: product.barcode,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // We need to provide a sharePositionOrigin to make the plugin work on ipad
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String url = 'https://'
        '${ProductQuery.getCountry().offTag}.openfoodfacts.org'
        '/product/${product.barcode}';
    Share.share(
      appLocalizations.share_product_text(url),
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }
}

class _ProductFooterFilledButton extends StatelessWidget {
  const _ProductFooterFilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
    // ignore: unused_element
    this.semanticsLabel,
  });

  final String label;
  final String? semanticsLabel;
  final icons.AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Semantics(
      excludeSemantics: true,
      button: true,
      label: semanticsLabel,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: context.lightTheme()
              ? themeExtension.primaryBlack
              : themeExtension.primarySemiDark,
          side: BorderSide.none,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconTheme(
              data: const IconThemeData(
                color: Colors.white,
                size: 18.0,
              ),
              child: icon,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
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
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String label;
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
        child: Row(
          children: <Widget>[
            IconTheme(
              data: IconThemeData(
                color: mainColor,
                size: 18.0,
              ),
              child: icon,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
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
