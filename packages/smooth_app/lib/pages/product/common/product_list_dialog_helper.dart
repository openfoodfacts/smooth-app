import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

class ProductListDialogHelper {
  @visibleForTesting
  const ProductListDialogHelper();

  static ProductListDialogHelper get instance =>
      _instance ??= const ProductListDialogHelper();
  static ProductListDialogHelper? _instance;

  /// Setter that allows tests to override the singleton instance.
  @visibleForTesting
  static set instance(ProductListDialogHelper testInstance) =>
      _instance = testInstance;

  Future<bool> openClear(
    final BuildContext context,
    final DaoProductList daoProductList,
    final ProductList productList,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          close: false,
          body: Text(AppLocalizations.of(context)!.really_clear),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              text: AppLocalizations.of(context)!.no,
              onPressed: () => Navigator.pop(context, false),
            ),
            SmoothActionButton(
              text: AppLocalizations.of(context)!.yes,
              onPressed: () async {
                await daoProductList.clear(productList);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ) ??
      false;
}
