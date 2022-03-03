import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  final SendImage image = SendImage(
    lang: ProductQuery.getLanguage(),
    barcode: barcode,
    imageField: imageField,
    imageUri: imageUri,
  );
  final Status? result = await LoadingDialog.run<Status>(
    context: context,
    future: OpenFoodAPIClient.addProductImage(
      ProductQuery.getUser(),
      image,
    ),
    title: appLocalizations.uploading_image,
  );
  if (result == null || result.error != null || result.status != 'status ok') {
    await LoadingDialog.error(
      context: context,
      title: appLocalizations.error_occurred,
    );
    return false;
  }
  return true;
}
