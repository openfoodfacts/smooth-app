import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/loading_dialog.dart';

Future<File?> pickImageAndCrop(BuildContext context) async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedXFile = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedXFile == null) {
    // User didn't pick any image.
    return null;
  }

  Uint8List? bytes = await pickedXFile.readAsBytes();
  final CropController _controller = CropController();

  await Navigator.push<Widget>(
    context,
    MaterialPageRoute<Widget>(
      builder: (BuildContext context) {
        context.watch<ThemeProvider>();
        final ThemeData theme = Theme.of(context);
        return Scaffold(
          body: Crop(
            image: bytes!,
            controller: _controller,
            onCropped: (Uint8List image) {
              bytes = image;
              Navigator.pop(context);
            },
            initialSize: 0.5,
            baseColor: theme.colorScheme.primary,
            maskColor: Colors.white.withAlpha(100),
            cornerDotBuilder: (double size, EdgeAlignment edgeAlignment) =>
                DotControl(color: theme.colorScheme.primary),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () {
                    bytes = null;
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () {
                    _controller.crop();
                  },
                )
              ],
            ),
          ),
        );
      },
    ),
  );

  if (bytes == null) {
    return null;
  }

  final Directory tempDir = await getTemporaryDirectory();
  final String tempPath = tempDir.path;
  final String filePath = '$tempPath/upload_img_file_01.tmp';
  return File(filePath).writeAsBytes(bytes!);
}

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
