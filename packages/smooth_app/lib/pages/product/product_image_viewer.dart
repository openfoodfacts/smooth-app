import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays a full-screen image with an edit floating button
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.barcode,
    required this.imageData,
  });

  final String barcode;
  final ProductImageData imageData;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late final ProductImageData imageData;

  /// When the image is edited, this is the new image
  late ImageProvider imageProvider;
  bool _isEdited = false;

  @override
  void initState() {
    imageData = widget.imageData;
    imageProvider = NetworkImage(imageData.imageUrl!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => SmoothScaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton.extended(
          label: Text(AppLocalizations.of(context).edit_photo_button_label),
          icon: const Icon(Icons.edit),
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            final DaoInt daoInt = DaoInt(context.read<LocalDatabase>());
            _editImage(daoInt);
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: WHITE_COLOR,
          elevation: 0,
          title: Text(imageData.title),
          leading: SmoothBackButton(
            onPressed: () => Navigator.maybePop(context, _isEdited),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.tight(
                Size(double.infinity, MediaQuery.of(context).size.height / 2),
              ),
              child: PhotoView(
                minScale: 0.2,
                imageProvider: imageProvider,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: imageProvider,
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _editImage(final DaoInt daoInt) async {
    final String? imageUrl = imageData.getImageUrl(ImageSize.ORIGINAL);
    final String? fallbackImageUrl = imageData.imageUrl;
    if (imageUrl == null || fallbackImageUrl == null) {
      return;
    }

    final File? imageFile = await LoadingDialog.run<File?>(
      context: context,
      future:
          _downloadImageFileWithFallback(daoInt, imageUrl, fallbackImageUrl),
    );

    if (imageFile == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final File? photoUploaded = await Navigator.push<File?>(
      context,
      MaterialPageRoute<File?>(
        builder: (BuildContext context) => ConfirmAndUploadPicture(
          barcode: widget.barcode,
          imageType: imageData.imageField,
          initialPhoto: imageFile,
        ),
      ),
    );
    if (photoUploaded != null) {
      _isEdited = true;
      if (!mounted) {
        return;
      }

      setState(() {
        imageProvider = FileImage(photoUploaded);
      });
    }
  }

  Future<File?> _downloadImageFileWithFallback(
      DaoInt daoInt, String url, String fallbackUrl) async {
    return await _downloadImageFile(daoInt, url) ??
        await _downloadImageFile(daoInt, fallbackUrl);
  }

  static const String _CROP_IMAGE_SEQUENCE_KEY = 'crop_image_sequence';

  Future<File?> _downloadImageFile(DaoInt daoInt, String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode > 299) {
      // TODO: Properly handle errors
      return null;
    }

    final Directory tempDirectory = await getTemporaryDirectory();

    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_IMAGE_SEQUENCE_KEY);

    final File file =
        File('${tempDirectory.path}/editing_image_$sequenceNumber');

    return file.writeAsBytes(response.bodyBytes);
  }
}
