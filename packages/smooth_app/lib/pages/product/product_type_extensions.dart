import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

extension ProductTypeExtension on ProductType {
  String getTitle(AppLocalizations appLocalizations) {
    return switch (this) {
      ProductType.food => appLocalizations.product_type_label_food,
      ProductType.beauty => appLocalizations.product_type_label_beauty,
      ProductType.petFood => appLocalizations.product_type_label_pet_food,
      ProductType.product => appLocalizations.product_type_label_product,
    };
  }

  String getSubtitle(AppLocalizations appLocalizations) {
    return switch (this) {
      ProductType.food => appLocalizations.product_type_subtitle_food,
      ProductType.beauty => appLocalizations.product_type_subtitle_beauty,
      ProductType.petFood => appLocalizations.product_type_subtitle_pet_food,
      ProductType.product => appLocalizations.product_type_subtitle_product,
    };
  }

  String getIllustration() {
    return switch (this) {
      ProductType.food => 'assets/misc/logo_off_half.svg.vec',
      ProductType.beauty => 'assets/misc/logo_obf_half.svg.vec',
      ProductType.petFood => 'assets/misc/logo_opff_half.svg.vec',
      ProductType.product => 'assets/misc/logo_opf_half.svg.vec',
    };
  }

  Widget getIcon() {
    return switch (this) {
      ProductType.food => const icons.Logo.openFoodFacts(),
      ProductType.beauty => const icons.Logo.openBeautyFacts(),
      ProductType.petFood => const icons.Logo.openPetFoodFacts(),
      ProductType.product => const icons.Logo.openProductsFacts(),
    };
  }

  String getDomain() => switch (this) {
    ProductType.food => 'openfoodfacts',
    ProductType.beauty => 'openbeautyfacts',
    ProductType.petFood => 'openpetfoodfacts',
    ProductType.product => 'openproductsfacts',
  };

  String getLabel(final AppLocalizations appLocalizations) => switch (this) {
    ProductType.food => appLocalizations.product_type_label_food,
    ProductType.beauty => appLocalizations.product_type_label_beauty,
    ProductType.petFood => appLocalizations.product_type_label_pet_food,
    ProductType.product => appLocalizations.product_type_label_product,
  };

  String getRoadToScoreLabel(final AppLocalizations appLocalizations) =>
      switch (this) {
        ProductType.food => appLocalizations.hey_incomplete_product_message,
        ProductType.beauty =>
          appLocalizations.hey_incomplete_product_message_beauty,
        ProductType.petFood =>
          appLocalizations.hey_incomplete_product_message_pet_food,
        ProductType.product =>
          appLocalizations.hey_incomplete_product_message_product,
      };

  String getShareProductLabel(
    final AppLocalizations appLocalizations,
    final String url,
  ) => switch (this) {
    ProductType.food => appLocalizations.share_product_text(url),
    ProductType.beauty => appLocalizations.share_product_text_beauty(url),
    ProductType.petFood => appLocalizations.share_product_text_pet_food(url),
    ProductType.product => appLocalizations.share_product_text_product(url),
  };
}
