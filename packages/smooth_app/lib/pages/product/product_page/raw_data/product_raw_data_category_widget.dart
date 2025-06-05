import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/category_label_ext.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_elements_list_widget.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductRawDataCategoryWidget extends StatelessWidget {
  //Rename ProductRawDataCategoryWidget
  const ProductRawDataCategoryWidget(this.category, this.onEditTap,
      {this.controller});

  final ProductRawDataCategory category;
  final ScrollController? controller;
  final GestureTapCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: _ProductRawDataCategoryTile(
            category.category.toIcon(),
            category.category.toL10nString(appLocalizations),
            onEditTap,
          ),
        ),
        ProductRawDataElementsListWidget(
          elements: category.rawDatas,
        )
      ],
    );
    ;
  }
}

class _ProductRawDataCategoryTile extends StatelessWidget {
  const _ProductRawDataCategoryTile(this.icon, this.label, this.onEditTap);

  final Widget icon;
  final String label;
  final GestureTapCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final bool lightTheme = context.lightTheme();
    final Color contentColor = lightTheme
        ? context.extension<SmoothColorsThemeExtension>().primaryBlack
        : Colors.white;

    final Color dividerColor =
        lightTheme ? const Color(0xFFF9F9F9) : Colors.white;

    final Color categoryColor = lightTheme
        ? context.extension<SmoothColorsThemeExtension>().primaryLight
        : context.extension<SmoothColorsThemeExtension>().primarySemiDark;

    return Container(
      color: categoryColor,
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
                Row(
                  children: <Widget>[
                    IconTheme(
                      data: const IconThemeData(
                        color: Colors.grey,
                        size: 18.0,
                      ),
                      child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onEditTap,
                          child: Tooltip(
                              message: AppLocalizations.of(context)
                                  .raw_data_edit_tooltip,
                              enableFeedback: true,
                              child: icons.Edit())),
                    ),
                    const SizedBox(width: 28.0),
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
