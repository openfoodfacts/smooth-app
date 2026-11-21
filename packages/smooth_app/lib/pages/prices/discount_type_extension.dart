import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Extensions on DiscountType.
extension DiscountTypeExtension on DiscountType {
  String getTitle(AppLocalizations appLocalizations) => switch (this) {
    .quantity => appLocalizations.prices_discount_type_quantity,
    .sale => appLocalizations.prices_discount_type_sale,
    .seasonal => appLocalizations.prices_discount_type_seasonal,
    .loyaltyProgram => appLocalizations.prices_discount_type_loyalty_program,
    .expiresSoon => appLocalizations.prices_discount_type_expires_soon,
    .pickItYourself => appLocalizations.prices_discount_type_pick_it_yourself,
    .secondHand => appLocalizations.prices_discount_type_second_hand,
    .other => appLocalizations.prices_discount_type_other,
  };

  String getSubtitle(AppLocalizations appLocalizations) => switch (this) {
    .quantity => appLocalizations.prices_discount_type_quantity_subtitle,
    .sale => appLocalizations.prices_discount_type_sale_subtitle,
    .seasonal => appLocalizations.prices_discount_type_seasonal_subtitle,
    .loyaltyProgram =>
      appLocalizations.prices_discount_type_loyalty_program_subtitle,
    .expiresSoon => appLocalizations.prices_discount_type_expires_soon_subtitle,
    .pickItYourself =>
      appLocalizations.prices_discount_type_pick_it_yourself_subtitle,
    .secondHand => appLocalizations.prices_discount_type_second_hand_subtitle,
    .other => appLocalizations.prices_discount_type_other_subtitle,
  };

  IconData get iconData => switch (this) {
    .quantity => const icons.Discount.quantity().icon,
    .sale => const icons.Discount.sale().icon,
    .seasonal => const icons.Discount.seasonal().icon,
    .loyaltyProgram => const icons.Discount.loyalty().icon,
    .expiresSoon => const icons.Discount.soon().icon,
    .pickItYourself => const icons.Discount.pickIt().icon,
    .secondHand => const icons.Discount.secondHand().icon,
    .other => const icons.Discount.other().icon,
  };
}
