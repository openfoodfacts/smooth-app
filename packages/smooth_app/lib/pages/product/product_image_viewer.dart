import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
  });

  final Product product;
  final ImageField imageField;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late ProductImageData _imageData;

  String get _barcode => _initialProduct.barcode!;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_barcode);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_barcode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    _imageData = getProductImageData(_product, widget.imageField);
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      _imageData,
      _barcode,
    );
    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
              child: imageProvider == null
                  ? const SizedBox.expand(child: PictureNotFound())
                  : PhotoView(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: (imageProvider == null)
                      ? Container()
                      : EditImageButton(
                          iconData: Icons.do_disturb_on,
                          label:
                              appLocalizations.edit_photo_unselect_button_label,
                          onPressed: () async {
                            final NavigatorState navigatorState =
                                Navigator.of(context);
                            await BackgroundTaskUnselect.addTask(
                              _barcode,
                              imageField: widget.imageField,
                              widget: this,
                            );
                            _localDatabase.notifyListeners();
                            navigatorState.pop();
                          },
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: EditImageButton(
                    iconData: imageProvider == null ? Icons.add : Icons.edit,
                    label: imageProvider == null
                        ? appLocalizations.add
                        : appLocalizations.edit_photo_button_label,
                    onPressed: () async => _editImage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editImage() async {
    // we have no image at all here: we need to create one.
    if (!TransientFile.isImageAvailable(_imageData, _barcode)) {
      await confirmAndUploadNewPicture(
        this,
        imageField: _imageData.imageField,
        barcode: _barcode,
      );
      return;
    }

    // best option: use the transient file.
    File? imageFile = TransientFile.getImage(
      _imageData.imageField,
      _barcode,
    );

    // but if not possible, get the best picture from the server.
    if (imageFile == null) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final String? imageUrl = _imageData.getImageUrl(ImageSize.ORIGINAL);
      if (imageUrl == null) {
        await LoadingDialog.error(
          context: context,
          title: appLocalizations.image_edit_url_error,
        );
        return;
      }

      final DaoInt daoInt = DaoInt(_localDatabase);
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

    await Navigator.push<File>(
      context,
      MaterialPageRoute<File>(
        builder: (BuildContext context) => CropPage(
          barcode: _barcode,
          imageField: _imageData.imageField,
          inputFile: imageFile!,
          brandNewPicture: false,
        ),
        fullscreenDialog: true,
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
