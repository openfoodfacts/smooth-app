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
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
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
  late final AppLocalizations _appLocalizations = AppLocalizations.of(context);

  /// When the image is edited, this is the new image
  ImageProvider? _imageProvider;
  late bool _isImageUrlAvailable;

  @override
  void initState() {
    super.initState();
    _isImageUrlAvailable = widget.imageData.imageUrl != null;
    if (_isImageUrlAvailable) {
      _imageProvider = NetworkImage(
        widget.imageData.imageUrl!,
      );
    }
  }

  @override
  Widget build(BuildContext context) => SmoothScaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton.extended(
          label: Text(
            _isImageUrlAvailable
                ? _appLocalizations.edit_photo_button_label
                : _appLocalizations.add,
          ),
          icon: Icon(
            _isImageUrlAvailable ? Icons.edit : Icons.add,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            final DaoInt daoInt = DaoInt(context.read<LocalDatabase>());
            if (_isImageUrlAvailable) {
              _editImage(daoInt);
            } else {
              _newImage(widget.imageData);
            }
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.tight(
                Size(double.infinity, MediaQuery.of(context).size.height / 2),
              ),
              child: _isImageUrlAvailable
                  ? PhotoView(
                      minScale: 0.2,
                      imageProvider: _imageProvider,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: _imageProvider!,
                      ),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    )
                  : const PictureNotFound(),
            ),
          ],
        ),
      );
  Future<void> _newImage(ProductImageData data) async {
    final File? croppedImageFile = await startImageCropping(this);
    if (croppedImageFile == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final File? photoUploaded = await Navigator.push<File>(
      context,
      MaterialPageRoute<File>(
        builder: (BuildContext context) => ConfirmAndUploadPicture(
          barcode: widget.barcode,
          imageField: data.imageField,
          initialPhoto: croppedImageFile,
        ),
      ),
    );
    if (photoUploaded != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _imageProvider = FileImage(photoUploaded);
      });
    }
  }

  Future<void> _editImage(final DaoInt daoInt) async {
    final String? imageUrl = widget.imageData.getImageUrl(ImageSize.ORIGINAL);
    if (imageUrl == null) {
      await _showDownloadFailedDialog(_appLocalizations.image_edit_url_error);
      return;
    }

    final File? imageFile = await LoadingDialog.run<File?>(
        context: context, future: _downloadImageFile(daoInt, imageUrl));

    if (imageFile == null) {
      await _showDownloadFailedDialog(_appLocalizations.image_download_error);
      return;
    }

    if (!mounted) {
      return;
    }

    final File? photoUploaded = await Navigator.push<File>(
      context,
      MaterialPageRoute<File>(
        builder: (BuildContext context) => ConfirmAndUploadPicture(
          barcode: widget.barcode,
          imageField: widget.imageData.imageField,
          initialPhoto: imageFile,
        ),
      ),
    );
    if (photoUploaded != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _imageProvider = FileImage(photoUploaded);
      });
    }
  }

  Future<void> _showDownloadFailedDialog(String? title) =>
      LoadingDialog.error(context: context, title: title);

  static const String _CROP_IMAGE_SEQUENCE_KEY = 'crop_image_sequence';

  Future<File?> _downloadImageFile(DaoInt daoInt, String url) async {
    final Uri uri = Uri.parse(url);
    final http.Response response = await http.get(uri);
    final int code = response.statusCode;
    if (code != 200) {
      throw NetworkImageLoadException(statusCode: code, uri: uri);
    }

    final Directory tempDirectory = await getTemporaryDirectory();

    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_IMAGE_SEQUENCE_KEY);

    final File file =
        File('${tempDirectory.path}/editing_image_$sequenceNumber');

    return file.writeAsBytes(response.bodyBytes);
  }
}
