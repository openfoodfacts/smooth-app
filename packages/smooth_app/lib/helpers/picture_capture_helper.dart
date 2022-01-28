import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:openfoodfacts/model/SendImage.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/widgets/loading_dialog.dart';

Future<File?> pickImageAndCrop() async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedXFile = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedXFile == null) {
    // User didn't pick any image.
    return null;
  }

  return ImageCropper.cropImage(
    sourcePath: pickedXFile.path,
    androidUiSettings: const AndroidUiSettings(
      lockAspectRatio: false,
      hideBottomControls: true,
    ),
  );
}

Future<bool> uploadPicture(
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
  final Status result = await OpenFoodAPIClient.addProductImage(
    ProductQuery.getUser(),
    image,
  );
  if (result.error != null || result.status != 'status ok') {
    // Image upload failed :( Show an error and go back to [AddNewProductPage].
    await LoadingDialog.error(
        context: context, title: appLocalizations.error_occurred);
    return false;
  }
  return true;
}
