import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as image2;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_controller.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_image.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage(
    this.inputFile, {
    this.title,
  });

  final File inputFile;
  final String? title;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  late RotatedCropController _controller;
  late ui.Image _image;

  /// Are we currently processing data (for action buttons hiding).
  bool _processing = true;

  /// Is that the same picture as the initial input file?
  bool _samePicture = true;

  static const Rect _initialRect = Rect.fromLTRB(0, 0, 1, 1);

  Future<ui.Image> _loadUiImage(final File file) async {
    final Uint8List list = await file.readAsBytes();
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  Future<void> _load(final File file) async {
    setState(() => _processing = true);
    _image = await _loadUiImage(file);
    _controller = RotatedCropController(defaultCrop: _initialRect);
    _processing = false;
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load(widget.inputFile);
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? appLocalizations.product_edit_photo_title,
            maxLines: 2,
          ),
          actions: _processing
              ? null
              : <Widget>[
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      setState(() => _processing = true);
                      final XFile? pickedXFile = await pickImageFile(this);
                      if (pickedXFile == null) {
                        return;
                      }
                      await _load(File(pickedXFile.path));
                      _processing = false;
                      _samePicture = false;
                      if (!mounted) {
                        return;
                      }
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () => setState(() => _controller.rotateRight()),
                  ),
                ],
        ),
        floatingActionButton: _processing
            ? null
            : FloatingActionButton.extended(
                onPressed: () async => _mayExitPage(saving: true),
                label: Text(appLocalizations.okay),
              ),
        backgroundColor: Colors.black,
        body: _processing
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(MEDIUM_SPACE),
                  child: RotatedCropImage(
                    controller: _controller,
                    image: _image,
                    minimumImageSize: 1,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _saveFileAndExit() async {
    final DaoInt daoInt = DaoInt(context.read<LocalDatabase>());
    final image2.Image? rawImage = await _controller.croppedBitmap();
    if (rawImage == null) {
      return;
    }
    final Uint8List data = Uint8List.fromList(image2.encodeJpg(rawImage));
    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_PAGE_SEQUENCE_KEY);

    final Directory tempDirectory = await getTemporaryDirectory();
    final String path = '${tempDirectory.path}/crop_$sequenceNumber.jpeg';
    await File(path).writeAsBytes(data);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop<String>(path);
  }

  static const String _CROP_PAGE_SEQUENCE_KEY = 'crop_page_sequence';

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (_controller.value.rotation == Rotation.noon &&
        _controller.value.crop == _initialRect &&
        _samePicture) {
      // nothing has changed, let's leave
      if (saving) {
        Navigator.of(context).pop();
      }
      return true;
    }

    // the cropped image has changed, but the user went back without saving
    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
    }

    await _saveFileAndExit();
    return true;
  }
}
