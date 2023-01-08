import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as image2;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_controller.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_image.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage({
    required this.inputFile,
    required this.barcode,
    required this.imageField,
    required this.brandNewPicture,
  });

  final File inputFile;
  final ImageField imageField;
  final String barcode;

  /// Is that a new picture we crop, or an existing picture?
  final bool brandNewPicture;

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
        appBar: SmoothAppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          title: Text(
            getImagePageTitle(appLocalizations, widget.imageField),
            maxLines: 2,
          ),
        ),
        backgroundColor: Colors.black,
        body: _processing
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _IconButton(
                        iconData: Icons.rotate_90_degrees_ccw_outlined,
                        onPressed: () => setState(
                          () => _controller.rotateLeft(),
                        ),
                      ),
                      _IconButton(
                        iconData: Icons.rotate_90_degrees_cw_outlined,
                        onPressed: () => setState(
                          () => _controller.rotateRight(),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: RotatedCropImage(
                      controller: _controller,
                      image: _image,
                      minimumImageSize: 1,
                    ),
                  ),
                  Wrap(
                    spacing: MEDIUM_SPACE,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      _OutlinedButton(
                        iconData: Icons.camera_alt,
                        label: appLocalizations.capture,
                        onPressed: () async => _capture(),
                      ),
                      _OutlinedButton(
                        iconData: Icons.check,
                        label: appLocalizations.confirm_button_label,
                        onPressed: () async => _mayExitPage(saving: true),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<bool> _saveFileAndExit() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoInt daoInt = DaoInt(localDatabase);
    final image2.Image? rawImage = await _controller.croppedBitmap();
    if (rawImage == null) {
      return true;
    }
    final Uint8List data = Uint8List.fromList(image2.encodeJpg(rawImage));
    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_PAGE_SEQUENCE_KEY);

    final Directory tempDirectory = await getApplicationSupportDirectory();
    final String path = '${tempDirectory.path}/crop_$sequenceNumber.jpeg';
    final File file = File(path);
    await file.writeAsBytes(data);

    if (!mounted) {
      return true;
    }

    await BackgroundTaskImage.addTask(
      widget.barcode,
      imageField: widget.imageField,
      imageFile: file,
      widget: this,
    );
    localDatabase.notifyListeners();
    if (!mounted) {
      return true;
    }
    final ContinuousScanModel model = context.read<ContinuousScanModel>();
    await model
        .onCreateProduct(widget.barcode); // TODO(monsieurtanuki): a bit fishy

    if (!mounted) {
      return true;
    }
    Navigator.of(context).pop<File>(file);
    return true;
  }

  static const String _CROP_PAGE_SEQUENCE_KEY = 'crop_page_sequence';

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (_controller.value.rotation == Rotation.noon &&
        _controller.value.crop == _initialRect &&
        _samePicture &&
        !widget.brandNewPicture) {
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
      if (!mounted) {
        return false;
      }
    }

    try {
      return _saveFileAndExit();
    } catch (e) {
      if (mounted) {
        // not likely to happen, but you never know...
        await LoadingDialog.error(
          context: context,
          title: 'Could not prepare picture with exception $e',
        );
      }
      return false;
    }
  }

  Future<void> _capture() async {
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
  }
}

/// Standard icon button for this page.
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.iconData,
    required this.onPressed,
  });

  final IconData iconData;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        child: Icon(iconData),
      );
}

/// Standard text button for this page.
class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
  });

  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: Icon(iconData),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.background,
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
          ),
        ),
        onPressed: onPressed,
        label: Text(label),
      );
}
