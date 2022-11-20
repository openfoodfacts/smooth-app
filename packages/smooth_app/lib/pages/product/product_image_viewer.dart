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
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays a full-screen image with an "edit" floating button.
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
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      widget.imageData,
      widget.barcode,
    );
    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(appLocalizations.edit_photo_button_label),
        icon: const Icon(Icons.edit),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async => _editImage(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        title: Text(widget.imageData.title),
        leading: SmoothBackButton(
          iconColor: Colors.white,
          onPressed: () => Navigator.maybePop(context),
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
              imageProvider:
                  imageProvider, // TODO(monsieurtanuki): what if null?
              heroAttributes: PhotoViewHeroAttributes(
                tag: imageProvider ??
                    Object(), // TODO(monsieurtanuki): what if null?
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editImage() async {
    // we have no image at all here: we need to create one.
    if (!TransientFile.isImageAvailable(widget.imageData, widget.barcode)) {
      await confirmAndUploadNewPicture(
        this,
        imageField: widget.imageData.imageField,
        barcode: widget.barcode,
      );
      return;
    }

    // best option: use the transient file.
    File? imageFile = TransientFile.getImage(
      widget.imageData.imageField,
      widget.barcode,
    );

    // but if not possible, get the best picture from the server.
    if (imageFile == null) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final String? imageUrl = widget.imageData.getImageUrl(ImageSize.ORIGINAL);
      if (imageUrl == null) {
        await LoadingDialog.error(
          context: context,
          title: appLocalizations.image_edit_url_error,
        );
        return;
      }

      final DaoInt daoInt = DaoInt(context.read<LocalDatabase>());
      imageFile = await LoadingDialog.run<File?>(
        context: context,
        future: _downloadImageFile(daoInt, imageUrl),
      );

      if (imageFile == null) {
        await LoadingDialog.error(
          context: context,
          title: appLocalizations.image_download_error,
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ConfirmAndUploadPicture(
          barcode: widget.barcode,
          imageField: widget.imageData.imageField,
          initialPhoto: imageFile!,
        ),
      ),
    );
  }

  static const String _CROP_IMAGE_SEQUENCE_KEY = 'crop_image_sequence';

  /// Downloads an image from the server and stores it locally in temp folder.
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
