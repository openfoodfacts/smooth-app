import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as image2;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_crop.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/tmp_crop_image/image_compute_helper.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_controller.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_image.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage({
    required this.inputFile,
    required this.barcode,
    required this.imageField,
    required this.initiallyDifferent,
    this.imageId,
    this.initialCropRect,
    this.initialRotation,
  });

  /// The initial input file we start with.
  final File inputFile;

  final ImageField imageField;
  final String barcode;

  /// Is the full picture initially different from the current selection?
  final bool initiallyDifferent;

  /// Only makes sense when we deal with an "already existing" image.
  final int? imageId;

  final Rect? initialCropRect;

  final Rotation? initialRotation;

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

  late Rect _initialCrop;
  late Rotation _initialRotation;

  Future<void> _load(final Uint8List list) async {
    setState(() => _processing = true);
    _image = await BackgroundTaskImage.loadUiImage(list);
    _initialCrop = _getInitialRect();
    _initialRotation = widget.initialRotation ?? Rotation.noon;
    _controller = RotatedCropController(
      defaultCrop: _initialCrop,
      rotation: _initialRotation,
    );
    _processing = false;
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Rect _getInitialRect() {
    if (widget.initialCropRect == null) {
      return const Rect.fromLTRB(0, 0, 1, 1);
    }
    // sometimes the server returns those crop values, meaning full photo.
    if (widget.initialCropRect!.left == -1 ||
        widget.initialCropRect!.top == -1 ||
        widget.initialCropRect!.right == -1 ||
        widget.initialCropRect!.bottom == -1) {
      return const Rect.fromLTRB(0, 0, 1, 1);
    }
    final Rect result;
    final Rotation rotation = widget.initialRotation ?? Rotation.noon;
    switch (rotation) {
      case Rotation.noon:
      case Rotation.sixOClock:
        result = Rect.fromLTRB(
          widget.initialCropRect!.left / _image.width,
          widget.initialCropRect!.top / _image.height,
          widget.initialCropRect!.right / _image.width,
          widget.initialCropRect!.bottom / _image.height,
        );
        break;
      case Rotation.threeOClock:
      case Rotation.nineOClock:
        result = Rect.fromLTRB(
          widget.initialCropRect!.left / _image.height,
          widget.initialCropRect!.top / _image.width,
          widget.initialCropRect!.right / _image.height,
          widget.initialCropRect!.bottom / _image.width,
        );
        break;
    }
    // we clamp in order to avoid controller crash.
    return Rect.fromLTRB(
      result.left.clamp(0, 1),
      result.top.clamp(0, 1),
      result.right.clamp(0, 1),
      result.bottom.clamp(0, 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async => _load(await widget.inputFile.readAsBytes());

  @override
  Widget build(final BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          title: Text(
            widget.imageField.getImagePageTitle(appLocalizations),
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
                      minimumImageSize:
                          MINIMUM_TOUCH_SIZE, // decent visual minimum size
                      gridCornerSize: MINIMUM_TOUCH_SIZE *
                          .75, // touch size will be this x 2
                      alwaysMove: true,
                    ),
                  ),
                  Center(
                    child: EditImageButton(
                      iconData: Icons.send,
                      label: appLocalizations.send_image_button_label,
                      onPressed: () async => _mayExitPage(saving: true),
                    ),
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
    result = widget.inputFile.copySync(fullPath);
    return result;
  }

  /// Returns a small file with the cropped image, for the transient image.
  ///
  /// Here we use BMP format as it's faster to encode.
  Future<File?> _getCroppedImageFile(
    final Directory directory,
    final int sequenceNumber,
  ) async {
    final String croppedPath = '${directory.path}/cropped_$sequenceNumber.bmp';
    final File result = File(croppedPath);
    final image2.Image? rawImage = await _controller.croppedBitmap(
      maxSize: _screenSize.longestSide,
    );
    if (rawImage == null) {
      return null;
    }
    await saveBmp(ImageComputeContainer(file: result, rawImage: rawImage));
    return result;
  }

  Future<File?> _saveFileAndExitTry() async {
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
      return null;
    }

    if (widget.imageId == null) {
      // in this case, it's a brand new picture, with crop parameters.
      // for performance reasons, we do not crop the image full-size here,
      // but in the background task.
      // for privacy reasons, we won't send the full image to the server and
      // let it crop it: we'll send the cropped image directly.
      final File fullFile = await _getFullImageFile(
        directory,
        sequenceNumber,
      );
      final Rect cropRect = _getLocalCropRect();
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
    } else {
      // in this case, it's an existing picture, with crop parameters.
      // we let the server do everything: better performance, and no privacy
      // issue here (we're cropping from an allegedly already privacy compliant
      // picture).
      final Rect cropRect = _getServerCropRect();
      await BackgroundTaskCrop.addTask(
        widget.barcode,
        imageField: widget.imageField,
        imageId: widget.imageId!,
        croppedFile: croppedFile,
        rotation: _controller.degrees,
        x1: cropRect.left.ceil(),
        y1: cropRect.top.ceil(),
        x2: cropRect.right.floor(),
        y2: cropRect.bottom.floor(),
        widget: this,
      );
    }
    localDatabase.notifyListeners();
    if (!mounted) {
      return croppedFile;
    }
    final ContinuousScanModel model = context.read<ContinuousScanModel>();
    await model
        .onCreateProduct(widget.barcode); // TODO(monsieurtanuki): a bit fishy

    return croppedFile;
  }

  Future<void> _saveFileAndExit() async {
    setState(() => _processing = true);
    try {
      final File? file = await _saveFileAndExitTry();
      _processing = false;
      if (!mounted) {
        return;
      }
      if (file == null) {
        setState(() {});
      } else {
        Navigator.of(context).pop<File>(file);
      }
    } finally {
      _processing = false;
    }
  }

  /// Returns the crop rect according to local cropping method * factor.
  Rect _getLocalCropRect() => BackgroundTaskImage.getResizedRect(
      _controller.crop, BackgroundTaskImage.cropConversionFactor);

  /// Returns the crop rect according to server cropping method.
  Rect _getServerCropRect() {
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
    if (_controller.value.rotation == _initialRotation &&
        _controller.value.crop == _initialCrop &&
        !widget.initiallyDifferent) {
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
      await _saveFileAndExit();
      return true;
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
