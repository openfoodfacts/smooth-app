import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/common/product_list_popup_items.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Page that lists all product lists.
class AllProductsListModal extends StatelessWidget {
  AllProductsListModal({required this.currentList});

  final ProductList currentList;

  final List<ProductList> _hardcodedProductLists = <ProductList>[
    ProductList.scanSession(),
    ProductList.scanHistory(),
    ProductList.history(),
  ];

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);

    return FutureBuilder<List<ProductList>>(
      future: _loadLists(daoProductList),
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductList>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            final List<ProductList> productLists =
                snapshot.data ?? <ProductList>[];
            return _buildList(
              context,
              productLists,
              productLists.fold(0, (int previousValue, ProductList element) {
                return math.max(previousValue, element.barcodes.length);
              }),
            );
          },
    );
  }

  Future<List<ProductList>> _loadLists(DaoProductList dao) async {
    final List<ProductList> list = <ProductList>[];
    final List<String> userLists = dao.getUserLists();

    /// User lists first
    for (final String userList in userLists) {
      list.add(ProductList.user(userList));
    }

    list.addAll(_hardcodedProductLists);

    /// Update lists information from database
    for (final ProductList productList in list) {
      await dao.get(productList);
    }

    return list;
  }

  Widget _buildList(
    BuildContext context,
    List<ProductList> productLists,
    int maxItemCount,
  ) {
    return SliverList.separated(
      itemCount: productLists.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1.0),
      itemBuilder: (BuildContext context, int index) {
        final ProductList productList = productLists[index];
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.textScalerOf(context).scale(65.0),
          ),
          child: _ModalProductListItem(
            productList: productList,
            selected:
                productList.listType == currentList.listType &&
                productList.parameters == currentList.parameters,
            counterDigits: maxItemCount.toString().length,
          ),
        );
      },
    );
  }
}

class _ModalProductListItem extends StatelessWidget {
  const _ModalProductListItem({
    required this.productList,
    required this.selected,
    required this.counterDigits,
  });

  final ProductList productList;
  final bool selected;
  final int counterDigits;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final LocalDatabase localDatabase = context.watch<LocalDatabase>();

    final int productsLength = productList.barcodes.length;
    final bool enableRename = productList.listType == ProductListType.USER;
    final bool hasProducts = productsLength > 0;

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final bool showImport =
        userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagProductListImport,
        ) ??
        false;

    return RadioGroup<bool>(
      groupValue: true,
      onChanged: (_) {},
      child: Material(
        color: selected
            ? (lightTheme ? extension.primaryMedium : extension.primarySemiDark)
            : Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(productList),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 2.0,
              top: VERY_SMALL_SPACE,
              bottom: VERY_SMALL_SPACE,
            ),
            child: Row(
              children: <Widget>[
                IgnorePointer(child: Radio<bool>(value: selected)),
                Expanded(
                  child: Text(
                    ProductQueryPageHelper.getProductListLabel(
                      productList,
                      appLocalizations,
                    ),
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: SMALL_SPACE),
                _ModalProductListItemCounter(
                  count: productsLength,
                  digits: counterDigits,
                ),
                if (enableRename || hasProducts || productList.isEditable)
                  PopupMenuButton<ProductListPopupMenuEntry>(
                    itemBuilder: (BuildContext context) {
                      final List<ProductListPopupItem> list =
                          <ProductListPopupItem>[
                            if (enableRename) ProductListPopupRename(),
                            if (hasProducts) ProductListPopupShare(),
                            if (hasProducts) ProductListPopupOpenInWeb(),
                            if (hasProducts) ProductListPopupClear(),
                            if (hasProducts) ProductListPopupExport(),
                            if (productList.isEditable && showImport)
                              ProductListPopupImport(),
                            if (productList.isEditable)
                              ProductListPopupDelete(),
                          ];
                      final List<PopupMenuEntry<ProductListPopupMenuEntry>>
                      result = <PopupMenuEntry<ProductListPopupMenuEntry>>[];
                      for (final ProductListPopupItem item in list) {
                        result.add(
                          PopupMenuItem<ProductListPopupMenuEntry>(
                            value: item.getEntry(),
                            child: ListTile(
                              leading: IconTheme.merge(
                                data: const IconThemeData(size: 18.0),
                                child: item.getIcon(),
                              ),
                              title: Text(item.getTitle(appLocalizations)),
                              contentPadding: EdgeInsetsDirectional.zero,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await item.doSomething(
                                  productList: productList,
                                  localDatabase: localDatabase,
                                  context: context,
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return result;
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalProductListItemCounter extends StatelessWidget {
  const _ModalProductListItemCounter({
    required this.count,
    required this.digits,
  });

  final int count;
  final int digits;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: ANGULAR_BORDER_RADIUS,
        color: lightTheme ? extension.primaryLight : extension.primaryDark,
        border: Border.all(color: extension.primaryNormal),
      ),

      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: MEDIUM_SPACE,
          end: MEDIUM_SPACE,
          top: 5.0,
          bottom: 6.0,
        ),
        child: SizedBox(
          width: MediaQuery.textScalerOf(
            context,
          ).scale(DefaultTextStyle.of(context).style.fontSize! * digits * 0.75),
          child: Text(
            NumberFormat.decimalPattern(
              ProductQuery.getLanguage().offTag,
            ).format(count),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
