import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as image2;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_controller.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_image.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage(this.inputFile);

  final File inputFile;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final RotatedCropController controller = RotatedCropController(
    // TODO(monsieurtanuki): could be improved (was the default in crop_image)
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  ui.Image? _image;

  Future<ui.Image> loadUiImage() async {
    final Uint8List list = await widget.inputFile.readAsBytes();
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  Future<void> _load() async {
    _image = await loadUiImage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).product_edit_photo_title),
        ),
        backgroundColor: Colors.black,
        body: _image == null
            ? const CircularProgressIndicator.adaptive()
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(MEDIUM_SPACE),
                  child: RotatedCropImage(
                    controller: controller,
                    image: _image!,
                    minimumImageSize: 1,
                  ),
                ),
              ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.rotate_right),
              onPressed: () => setState(() => controller.rotateRight()),
            ),
            TextButton(
              onPressed: _finished,
              child: Text(
                AppLocalizations.of(context).okay,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

  Future<void> _finished() async {
    final DaoInt daoInt = DaoInt(context.read<LocalDatabase>());
    final image2.Image? rawImage = await controller.croppedBitmap();
    if (rawImage == null) {
      return;
    }
    final Uint8List data = Uint8List.fromList(image2.encodeJpg(rawImage));
    final int sequenceNumber = await _getNextSequenceNumber(daoInt);

    final Directory tempDirectory = await getTemporaryDirectory();
    final String path = '${tempDirectory.path}/crop_$sequenceNumber.jpeg';
    await File(path).writeAsBytes(data);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop<String>(path);
  }

  static const String _CROP_PAGE_SEQUENCE_KEY = 'crop_page_sequence';

  Future<int> _getNextSequenceNumber(final DaoInt daoInt) async {
    int? result = daoInt.get(_CROP_PAGE_SEQUENCE_KEY);
    if (result == null) {
      result = 1;
    } else {
      result++;
    }
    await daoInt.put(_CROP_PAGE_SEQUENCE_KEY, result);
    return result;
  }
}
