import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
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
  late final ImageProvider? imageProvider;
  bool _isEdited = false;

  @override
  void initState() {
    imageData = widget.imageData;
    imageProvider =
        imageData.imageUrl != null ? NetworkImage(imageData.imageUrl!) : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SmoothScaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: WHITE_COLOR,
          elevation: 0,
          title: Text(imageData.title),
          leading: SmoothBackButton(
            onPressed: () => Navigator.maybePop(context, _isEdited),
          ),
        ),
        backgroundColor: Colors.black,
        floatingActionButton: _buildEditButton(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.tight(
                Size(double.infinity, MediaQuery.of(context).size.height / 2),
              ),
              child: PhotoView(
                imageProvider: imageProvider,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );

  FloatingActionButton _buildEditButton() => FloatingActionButton.extended(
        label: Text(AppLocalizations.of(context).edit_photo_button_label),
        icon: const Icon(Icons.edit),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _editImage,
      );

  Future<File> _downloadImageFile(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Directory tempDirectory = await getTemporaryDirectory();
    final File imageFile = await File('${tempDirectory.path}/editing_image')
        .writeAsBytes(response.bodyBytes);
    return imageFile;
  }

  Future<void> _editImage() async {
    final File? imageFile = await LoadingDialog.run<File>(
      context: context,
      future: _downloadImageFile(imageData.imageUrl!),
    );

    if (imageFile == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    // ignore: use_build_context_synchronously
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
}
