import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/discount_type_extension.dart';
import 'package:smooth_app/widgets/smooth_dropdown.dart';

class PriceDiscountTypeDropdown extends StatelessWidget {
  const PriceDiscountTypeDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DiscountType? value;
  final ValueChanged<DiscountType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothDropdownButton<DiscountType?>(
        isExpanded: true,
        value: value,
        items: <SmoothDropdownItem<DiscountType?>>[
          SmoothDropdownItem<DiscountType?>(
            value: null,
            label: appLocalizations.prices_discount_type,
          ),
          ...DiscountType.values.map(
            (DiscountType discountType) => SmoothDropdownItem<DiscountType?>(
              value: discountType,
              label: discountType.getTitle(appLocalizations),
            ),
          ),
        ],
        onChanged: (DiscountType? value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
