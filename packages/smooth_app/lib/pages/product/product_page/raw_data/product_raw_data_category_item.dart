import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/category_label_ext.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_category_elements_item.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductRawDataCategoryItem extends StatelessWidget {
  const ProductRawDataCategoryItem(this.category, {this.controller});

  final ProductRawDataCategory category;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ProductRawDataCategoryTile(
            category.category.toIcon(),
            category.category.toL10nString(appLocalizations),
          ),
          CategoryElementsListView(
            elements: category.rawDatas,
            controller: controller,
          ),
        ]);
  }
}

class _ProductRawDataCategoryTile extends StatelessWidget {
  const _ProductRawDataCategoryTile(this.icon, this.label);

  final Widget icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final bool lightTheme = context.lightTheme();
    final Color contentColor = lightTheme
        ? context.extension<SmoothColorsThemeExtension>().primaryBlack
        : Colors.white;

    final Color dividerColor =
        lightTheme ? const Color(0xFFF9F9F9) : Colors.white;

    return Container(
      color: const Color(0xFFFEFEFE),
      child: Column(
        children: <Widget>[
          Container(
            margin:
                const EdgeInsetsDirectional.symmetric(vertical: MEDIUM_SPACE),
            //This rows of rows is here to have this Layout Spaced through the lign
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //Element icon + label
                Row(
                  children: <Widget>[
                    const SizedBox(width: 31.0),
                    IconTheme(
                      data: IconThemeData(
                        color: contentColor,
                        size: 18.0,
                      ),
                      child: icon,
                    ),
                    const SizedBox(width: MEDIUM_SPACE),
                    Text(label),
                  ],
                ),
                //Edit button
                const Row(
                  children: <Widget>[
                    IconTheme(
                      data: IconThemeData(
                        color: Colors.grey,
                        size: 18.0,
                      ),
                      child: icons.Edit(),
                    ),
                    SizedBox(width: 28.0),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: dividerColor,
            height: 0,
          )
        ],
      ),
    );
  }
}
