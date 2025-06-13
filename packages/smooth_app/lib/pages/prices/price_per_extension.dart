import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Extension for PricePer.
extension PricePerExtension on PricePer {
  String getTitle(final AppLocalizations appLocalizations) => switch (this) {
        PricePer.kilogram => appLocalizations.prices_per_kilogram,
        PricePer.unit => appLocalizations.prices_per_unit,
      };

  String getShortTitle(final AppLocalizations appLocalizations) =>
      switch (this) {
        PricePer.kilogram => appLocalizations.prices_per_kilogram_short,
        PricePer.unit => appLocalizations.prices_per_unit_short,
      };
}
