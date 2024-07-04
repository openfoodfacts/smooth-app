import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays the date for price adding.
class PriceDateCard extends StatelessWidget {
  const PriceDateCard();

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String locale = ProductQuery.getLocaleString();
    final DateFormat dateFormat = DateFormat.yMd(locale);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_date_subtitle),
          SmoothLargeButtonWithIcon(
            text: dateFormat.format(model.date),
            icon: Icons.calendar_month,
            onPressed: () async {
              final DateTime? newDate = await showDatePicker(
                context: context,
                locale: Locale(ProductQuery.getLanguage().offTag),
                firstDate: model.firstDate,
                lastDate: model.today,
                builder: (final BuildContext context, final Widget? child) {
                  // for some reason we don't have a fine display without that theme.
                  // cf. https://stackoverflow.com/questions/50321182/how-to-customize-a-date-picker
                  final ThemeData themeData =
                      Theme.of(context).brightness == Brightness.light
                          ? ThemeData.light()
                          : ThemeData.dark();
                  return Theme(
                    data: themeData.copyWith(),
                    child: child!,
                  );
                },
              );
              if (newDate == null) {
                return;
              }
              model.date = newDate;
            },
          ),
        ],
      ),
    );
  }
}
