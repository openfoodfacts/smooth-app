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
import 'package:smooth_app/pages/product/edit_image_button.dart';
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

  /// The initial input file we start with.
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

  /// The screen size, used as a maximum size for the transient image.
  ///
  /// We need this info:
  /// * we experienced performance issues when cropping the full size
  /// * it's much faster to create a smaller file
  /// * the size of the screen is a good approximation of "how big is enough?"
  late Size _screenSize;

  /// Are we currently processing data (for action buttons hiding).
  bool _processing = true;

  /// Latest picked picture (from Gallery or Camera).
  XFile? _pickedPicture;

  static const Rect _initialRect = Rect.fromLTRB(0, 0, 1, 1);

  Future<ui.Image> _loadUiImage(final Uint8List list) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  Future<void> _load(final Uint8List list) async {
    setState(() => _processing = true);
    _image = await _loadUiImage(list);
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
    _initLoad();
  }

  Future<void> _initLoad() async => _load(await widget.inputFile.readAsBytes());

  @override
  Widget build(final BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
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
                    child: Padding(
                      padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
                      child: RotatedCropImage(
                        controller: _controller,
                        image: _image,
                        minimumImageSize: 1,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: MEDIUM_SPACE,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      EditImageButton(
                        iconData: Icons.camera_alt,
                        label: appLocalizations.capture,
                        onPressed: () async => _capture(),
                      ),
                      EditImageButton(
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

  /// Returns a file with the full image (no cropping here).
  ///
  /// To be sent to the server, as well as the crop parameters and the rotation.
  /// It's faster for us to let the server do the actual cropping full size.
  Future<File> _getFullImageFile(
    final Directory directory,
    final int sequenceNumber,
  ) async {
    final File result;
    final String fullPath = '${directory.path}/full_image_$sequenceNumber.jpeg';
    if (_pickedPicture == null) {
      result = widget.inputFile.copySync(fullPath);
    } else {
      result = File(fullPath);
      final Uint8List list = await _pickedPicture!.readAsBytes();
      await result.writeAsBytes(list);
    }
    return result;
  }

  /// Returns a small file with the cropped image, for the transient image.
  Future<File?> _getCroppedImageFile(
    final Directory directory,
    final int sequenceNumber,
  ) async {
    final String croppedPath = '${directory.path}/cropped_$sequenceNumber.jpeg';
    final File result = File(croppedPath);
    final image2.Image? rawImage = await _controller.croppedBitmap(
      maxSize: _screenSize.longestSide,
    );
    if (rawImage == null) {
      return null;
    }
    final Uint8List data = Uint8List.fromList(image2.encodeJpg(rawImage));
    await result.writeAsBytes(data);
    return result;
  }

  Future<bool> _saveFileAndExit() async {
    // TODO(monsieurtanuki): hide the controls while computing?
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoInt daoInt = DaoInt(localDatabase);
    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_PAGE_SEQUENCE_KEY);
    final Directory directory = await getApplicationSupportDirectory();

    final File? croppedFile = await _getCroppedImageFile(
      directory,
      sequenceNumber,
    );
    if (croppedFile == null) {
      return true;
    }
    final File fullFile = await _getFullImageFile(
      directory,
      sequenceNumber,
    );

    final Rect cropRect = _getCropRect();
    await BackgroundTaskImage.addTask(
      widget.barcode,
      imageField: widget.imageField,
      fullFile: fullFile,
      croppedFile: croppedFile,
      rotation: _controller.degrees,
      x1: cropRect.left.ceil(),
      y1: cropRect.top.ceil(),
      x2: cropRect.right.floor(),
      y2: cropRect.bottom.floor(),
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
    Navigator.of(context).pop<File>(croppedFile);
    return true;
  }

  Rect _getCropRect() {
    final Offset center = _controller.getRotatedOffsetForOff(
      _controller.crop.center,
    );
    final Offset topLeft = _controller.getRotatedOffsetForOff(
      _controller.crop.topLeft,
    );
    double width = 2 * (center.dx - topLeft.dx);
    if (width < 0) {
      width = -width;
    }
    double height = 2 * (center.dy - topLeft.dy);
    if (height < 0) {
      height = -height;
    }
    final Rect rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    return rect;
  }

  static const String _CROP_PAGE_SEQUENCE_KEY = 'crop_page_sequence';

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (_controller.value.rotation == Rotation.noon &&
        _controller.value.crop == _initialRect &&
        _pickedPicture == null &&
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
    _pickedPicture = pickedXFile;
    await _load(await pickedXFile.readAsBytes());
    _processing = false;
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
