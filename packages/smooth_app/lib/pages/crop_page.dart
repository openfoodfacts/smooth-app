import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_crop.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/helpers/image_compute_container.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage({
    required this.inputFile,
    required this.barcode,
    required this.imageField,
    required this.language,
    required this.initiallyDifferent,
    required this.isLoggedInMandatory,
    this.imageId,
    this.initialCropRect,
    this.initialRotation,
  });

  /// The initial input file we start with.
  final File inputFile;

  final ImageField imageField;
  final String barcode;
  final OpenFoodFactsLanguage language;

  /// Is the full picture initially different from the current selection?
  final bool initiallyDifferent;

  /// Only makes sense when we deal with an "already existing" image.
  final int? imageId;

  final Rect? initialCropRect;

  final CropRotation? initialRotation;

  final bool isLoggedInMandatory;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  late CropController _controller;
  late ui.Image _image;

  /// The screen size, used as a maximum size for the transient image.
  ///
  /// We need this info:
  /// * we experienced performance issues when cropping the full size
  /// * it's much faster to create a smaller file
  /// * the size of the screen is a good approximation of "how big is enough?"
  late Size _screenSize;

  /// Progress text, if we are processing data. `null` means we're done.
  String? _progress = '';

  late Rect _initialCrop;
  late CropRotation _initialRotation;

  Future<void> _load(final Uint8List list) async {
    _image = await BackgroundTaskImage.loadUiImage(list);
    _initialCrop = _getInitialRect();
    _initialRotation = widget.initialRotation ?? CropRotation.up;
    _controller = CropController(
      defaultCrop: _initialCrop,
      rotation: _initialRotation,
    );
    _progress = null;
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
    final CropRotation rotation = widget.initialRotation ?? CropRotation.up;
    switch (rotation) {
      case CropRotation.up:
      case CropRotation.down:
        result = Rect.fromLTRB(
          widget.initialCropRect!.left / _image.width,
          widget.initialCropRect!.top / _image.height,
          widget.initialCropRect!.right / _image.width,
          widget.initialCropRect!.bottom / _image.height,
        );
        break;
      case CropRotation.right:
      case CropRotation.left:
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

  Future<void> _initLoad() async => _load(await widget.inputFile.readAsBytes());

  @override
  Widget build(final BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
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
        body: _progress != null
            ? Center(
                child: Text(
                  _progress!,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : SafeArea(
                child: Column(
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
                      child: CropImage(
                        controller: _controller,
                        image: Image.file(widget.inputFile),
                        minimumImageSize: MINIMUM_TOUCH_SIZE,
                        gridCornerSize: MINIMUM_TOUCH_SIZE * .75,
                        touchSize: MINIMUM_TOUCH_SIZE,
                        paddingSize: MINIMUM_TOUCH_SIZE * .5,
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
  Future<File> _getCroppedImageFile(
    final Directory directory,
    final int sequenceNumber,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String croppedPath = '${directory.path}/cropped_$sequenceNumber.bmp';
    final File result = File(croppedPath);
    setState(() => _progress = appLocalizations.crop_page_action_cropping);
    final ui.Image cropped = await _controller.croppedBitmap(
      maxSize: _screenSize.longestSide,
    );
    setState(() => _progress = appLocalizations.crop_page_action_local);

    try {
      await saveBmp(file: result, source: cropped)
          .timeout(const Duration(seconds: 10));
    } catch (e, trace) {
      AnalyticsHelper.sendException(e, stackTrace: trace);
      rethrow;
    }

    return result;
  }

  Future<File?> _saveFileAndExitTry() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // only for new image upload we have to check the minimum size.
    if (widget.imageId == null) {
      // Returns the size of the resulting cropped image.
      Size getCroppedSize() {
        switch (_controller.rotation) {
          case CropRotation.up:
          case CropRotation.down:
            return Size(
              _controller.crop.width * _image.width,
              _controller.crop.height * _image.height,
            );
          case CropRotation.left:
          case CropRotation.right:
            return Size(
              _controller.crop.width * _image.height,
              _controller.crop.height * _image.width,
            );
        }
      }

      final Size croppedSize = getCroppedSize();
      if (!BackgroundTaskImage.isPictureBigEnough(
        croppedSize.width,
        croppedSize.height,
      )) {
        final int width = croppedSize.width.floor();
        final int height = croppedSize.height.floor();
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => SmoothAlertDialog(
            title: appLocalizations.crop_page_too_small_image_title,
            body: Text(
              appLocalizations.crop_page_too_small_image_message(
                ImageHelper.minimumWidth,
                ImageHelper.minimumHeight,
                width,
                height,
              ),
            ),
            actionsAxis: Axis.vertical,
            positiveAction: SmoothActionButton(
              text: appLocalizations.okay,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        return null;
      }
    }

    if (!mounted) {
      return null;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoInt daoInt = DaoInt(localDatabase);
    final int sequenceNumber =
        await getNextSequenceNumber(daoInt, _CROP_PAGE_SEQUENCE_KEY);
    final Directory directory = await BackgroundTaskUpload.getDirectory();

    final File croppedFile = await _getCroppedImageFile(
      directory,
      sequenceNumber,
    );

    setState(
      () => _progress = appLocalizations.crop_page_action_server,
    );
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
      if (mounted) {
        await BackgroundTaskImage.addTask(
          widget.barcode,
          language: widget.language,
          imageField: widget.imageField,
          fullFile: fullFile,
          croppedFile: croppedFile,
          rotation: _controller.rotation.degrees,
          x1: cropRect.left.ceil(),
          y1: cropRect.top.ceil(),
          x2: cropRect.right.floor(),
          y2: cropRect.bottom.floor(),
          context: context,
        );
      }
    } else {
      // in this case, it's an existing picture, with crop parameters.
      // we let the server do everything: better performance, and no privacy
      // issue here (we're cropping from an allegedly already privacy compliant
      // picture).
      final Rect cropRect = _getServerCropRect();
      if (mounted) {
        await BackgroundTaskCrop.addTask(
          widget.barcode,
          language: widget.language,
          imageField: widget.imageField,
          imageId: widget.imageId!,
          croppedFile: croppedFile,
          rotation: _controller.rotation.degrees,
          x1: cropRect.left.ceil(),
          y1: cropRect.top.ceil(),
          x2: cropRect.right.floor(),
          y2: cropRect.bottom.floor(),
          context: context,
        );
      }
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

  Future<bool> _saveFileAndExit() async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return false;
    }

    setState(
      () => _progress = AppLocalizations.of(context).crop_page_action_saving,
    );
    try {
      final File? file = await _saveFileAndExitTry();
      _progress = null;
      if (file == null) {
        if (mounted) {
          setState(() {});
        }
        return false;
      } else {
        if (mounted) {
          Navigator.of(context).pop<File>(file);
        }
        return true;
      }
    } catch (e) {
      _showErrorDialog();
      return false;
    } finally {
      _progress = null;
    }
  }

  /// Returns the crop rect according to local cropping method * factor.
  Rect _getLocalCropRect() => BackgroundTaskImage.getResizedRect(
      _controller.crop, BackgroundTaskImage.cropConversionFactor);

  Offset _getRotatedOffsetForOff(final Offset offset) =>
      _getRotatedOffsetForOffHelper(
        _controller.rotation,
        offset,
        _image.width.toDouble(),
        _image.height.toDouble(),
      );

  /// Returns the offset as rotated, for the OFF-dart rotation/crop tool.
  Offset _getRotatedOffsetForOffHelper(
    final CropRotation rotation,
    final Offset offset01,
    final double noonWidth,
    final double noonHeight,
  ) {
    switch (rotation) {
      case CropRotation.up:
      case CropRotation.down:
        return Offset(
          noonWidth * offset01.dx,
          noonHeight * offset01.dy,
        );
      case CropRotation.right:
      case CropRotation.left:
        return Offset(
          noonHeight * offset01.dx,
          noonWidth * offset01.dy,
        );
    }
  }

  /// Returns the crop rect according to server cropping method.
  Rect _getServerCropRect() {
    final Offset center = _getRotatedOffsetForOff(_controller.crop.center);
    final Offset topLeft = _getRotatedOffsetForOff(_controller.crop.topLeft);
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

  Future<void> _showErrorDialog() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothSimpleErrorAlertDialog(
          title: appLocalizations.crop_page_action_local_failed_title,
          message: appLocalizations.crop_page_action_local_failed_message,
        );
      },
    );
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
