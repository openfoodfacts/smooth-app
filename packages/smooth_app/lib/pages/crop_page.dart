import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' as size_getter;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_compute_container.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/prices/eraser_model.dart';
import 'package:smooth_app/pages/prices/eraser_painter.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Page dedicated to image cropping. Pops the resulting file path if relevant.
class CropPage extends StatefulWidget {
  const CropPage({
    required this.inputFile,
    required this.initiallyDifferent,
    required this.cropHelper,
    required this.isLoggedInMandatory,
    this.initialCropRect,
    this.initialRotation,
    this.onRetakePhoto,
  });

  /// The initial input file we start with.
  final File inputFile;

  /// Is the full picture initially different from the current selection?
  final bool initiallyDifferent;

  final Rect? initialCropRect;

  final CropRotation? initialRotation;

  final bool isLoggedInMandatory;

  final CropHelper cropHelper;

  final Future<File?> Function()? onRetakePhoto;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  late CropController _controller;
  late final int _fullImageWidth;
  late final int _fullImageHeight;
  int? _cacheImageWidth;
  int? _cacheImageHeight;

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

  /// True if we switched to the "erase" mode, and not the "crop grid" mode.
  bool _isErasing = false;

  final EraserModel _eraserModel = EraserModel();

  Future<void> _load() async {
    await _retrieveSize();
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

  Future<ui.Image> _loadFullImage() async =>
      BackgroundTaskImage.loadUiImage(await widget.inputFile.readAsBytes());

  Future<void> _retrieveSize() async {
    try {
      // may fail, cf. https://github.com/fluttercandies/dart_image_size_getter/pull/56
      final size_getter.Size imageSize =
          size_getter.ImageSizeGetter.getSizeResult(
            FileInput(widget.inputFile),
          ).size;
      if (imageSize.needRotate) {
        _fullImageWidth = imageSize.height;
        _fullImageHeight = imageSize.width;
      } else {
        _fullImageWidth = imageSize.width;
        _fullImageHeight = imageSize.height;
      }
    } catch (e) {
      // as a fallback; should take more memory and a bit longer (syllepsis)
      final ui.Image image = await _loadFullImage();
      _fullImageWidth = image.width;
      _fullImageHeight = image.height;
    }
  }

  Rect _getInitialRect() {
    if (widget.initialCropRect == null) {
      return CropHelper.fullImageCropRect;
    }
    // sometimes the server returns those crop values, meaning full photo.
    if (widget.initialCropRect!.left == -1 ||
        widget.initialCropRect!.top == -1 ||
        widget.initialCropRect!.right == -1 ||
        widget.initialCropRect!.bottom == -1) {
      return CropHelper.fullImageCropRect;
    }
    final Rect result;
    final CropRotation rotation = widget.initialRotation ?? CropRotation.up;
    switch (rotation) {
      case CropRotation.up:
      case CropRotation.down:
        result = Rect.fromLTRB(
          widget.initialCropRect!.left / _fullImageWidth,
          widget.initialCropRect!.top / _fullImageHeight,
          widget.initialCropRect!.right / _fullImageWidth,
          widget.initialCropRect!.bottom / _fullImageHeight,
        );
        break;
      case CropRotation.right:
      case CropRotation.left:
        result = Rect.fromLTRB(
          widget.initialCropRect!.left / _fullImageHeight,
          widget.initialCropRect!.top / _fullImageWidth,
          widget.initialCropRect!.right / _fullImageHeight,
          widget.initialCropRect!.bottom / _fullImageWidth,
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
    unawaited(_load());
  }

  @override
  Widget build(final BuildContext context) {
    _screenSize = MediaQuery.sizeOf(context);
    if (_progress == null && _cacheImageWidth == null) {
      final int longestSide = _screenSize.longestSide.floor();
      if (_fullImageWidth > _fullImageHeight) {
        _cacheImageWidth = min(_fullImageWidth, longestSide);
        _cacheImageHeight =
            (_cacheImageWidth! * _fullImageHeight) ~/ _fullImageWidth;
      } else {
        _cacheImageHeight = min(_fullImageHeight, longestSide);
        _cacheImageWidth =
            (_cacheImageHeight! * _fullImageWidth) ~/ _fullImageHeight;
      }
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope2(
      onWillPop: _onWillPop,
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          title: Text(
            widget.cropHelper.getPageTitle(appLocalizations),
            maxLines: 2,
          ),
          leading: const SmoothBackButton(backButtonType: BackButtonType.close),
          actions: <Widget>[
            if (widget.onRetakePhoto != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.5),
                child: IconButton(
                  icon: const icons.Camera.restart(),
                  tooltip: appLocalizations.crop_page_action_retake,
                  onPressed: () async {
                    final File? file = await widget.onRetakePhoto?.call();
                    if (file != null && context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<CropParameters>(
                          builder: (BuildContext context) => CropPage(
                            inputFile: file,
                            initiallyDifferent: widget.initiallyDifferent,
                            cropHelper: widget.cropHelper,
                            isLoggedInMandatory: widget.isLoggedInMandatory,
                            onRetakePhoto: widget.onRetakePhoto,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
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
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: SMALL_SPACE,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (!_isErasing)
                            _IconButton(
                              icon: const icons.Rotate.antiClockwise(),
                              tooltip: appLocalizations.photo_rotate_left,
                              onPressed: () => setState(() {
                                _controller.rotateLeft();
                                _eraserModel.rotation = _controller.rotation;
                              }),
                            ),
                          if (widget.cropHelper.enableEraser)
                            _IconButton(
                              icon: _isErasing
                                  ? const icons.Crop()
                                  : const icons.Brush(),
                              onPressed: () =>
                                  setState(() => _isErasing = !_isErasing),
                            ),
                          if (_isErasing)
                            _IconButton(
                              icon: const icons.Undo(),
                              tooltip: appLocalizations.photo_undo_action,
                              onPressed: _eraserModel.isEmpty
                                  ? null
                                  : () => setState(() => _eraserModel.undo()),
                            ),
                          if (!_isErasing)
                            _IconButton(
                              icon: const icons.Rotate.clockwise(),
                              tooltip: appLocalizations.photo_rotate_right,
                              onPressed: () => setState(() {
                                _controller.rotateRight();
                                _eraserModel.rotation = _controller.rotation;
                              }),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          IgnorePointer(
                            ignoring: _isErasing,
                            child: CropImage(
                              controller: _controller,
                              image: Image.file(
                                widget.inputFile,
                                cacheWidth: _cacheImageWidth,
                                cacheHeight: _cacheImageHeight,
                              ),
                              minimumImageSize: MINIMUM_TOUCH_SIZE,
                              gridCornerSize: MINIMUM_TOUCH_SIZE * .75,
                              touchSize: MINIMUM_TOUCH_SIZE,
                              paddingSize: MINIMUM_TOUCH_SIZE * .5,
                              alwaysMove: true,
                              overlayPainter: !widget.cropHelper.enableEraser
                                  ? null
                                  : EraserPainter(eraserModel: _eraserModel),
                            ),
                          ),
                          if (_isErasing)
                            LayoutBuilder(
                              builder:
                                  (
                                    final BuildContext context,
                                    final BoxConstraints constraints,
                                  ) => Center(
                                    child: GestureDetector(
                                      onPanStart:
                                          (final DragStartDetails details) =>
                                              setState(
                                                () => _eraserModel.panStart(
                                                  details.localPosition,
                                                  constraints,
                                                ),
                                              ),
                                      onPanUpdate:
                                          (final DragUpdateDetails details) =>
                                              setState(
                                                () => _eraserModel.panUpdate(
                                                  details.localPosition,
                                                  constraints,
                                                ),
                                              ),
                                      onPanEnd:
                                          (final DragEndDetails details) =>
                                              setState(
                                                () => _eraserModel.panEnd(),
                                              ),
                                    ),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VERY_SMALL_SPACE,
                        vertical: SMALL_SPACE,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: EditImageButton.center(
                          icon: widget.cropHelper.getProcessIcon(),
                          label: widget.cropHelper.getProcessLabel(
                            appLocalizations,
                          ),
                          onPressed: () async => _saveImageAndPop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Returns a small file with the cropped image, for the transient image.
  ///
  /// Here we use BMP format as it's faster to encode.
  Future<File> _getSmallCroppedImageFile(
    final Directory directory,
    final int sequenceNumber,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String croppedPath = '${directory.path}/cropped_$sequenceNumber.bmp';
    final File result = File(croppedPath);
    setState(() => _progress = appLocalizations.crop_page_action_cropping);
    final ui.Image image = await _loadFullImage();
    final ui.Image cropped = await CropController.getCroppedBitmap(
      image: image,
      maxSize: _screenSize.longestSide,
      crop: _controller.crop,
      rotation: _controller.rotation,
      overlayPainter: !widget.cropHelper.enableEraser
          ? null
          : EraserPainter(
              eraserModel: EraserModel(
                rotation: _controller.rotation,
                offsets: _eraserModel.offsets,
              ),
              cropRect: _controller.crop,
            ),
    );
    setState(() => _progress = appLocalizations.crop_page_action_local);

    try {
      await saveBmp(
        file: result,
        source: cropped,
      ).timeout(const Duration(seconds: 10));
    } catch (e, trace) {
      AnalyticsHelper.sendException(e, stackTrace: trace);
      rethrow;
    }

    return result;
  }

  Future<CropParameters?> _saveImageAndExitTry() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // only for new image upload we have to check the minimum size.
    if (widget.cropHelper.isNewImage()) {
      // Returns the size of the resulting cropped image.
      Size getCroppedSize() {
        switch (_controller.rotation) {
          case CropRotation.up:
          case CropRotation.down:
            return Size(
              _controller.crop.width * _fullImageWidth,
              _controller.crop.height * _fullImageHeight,
            );
          case CropRotation.left:
          case CropRotation.right:
            return Size(
              _controller.crop.width * _fullImageHeight,
              _controller.crop.height * _fullImageWidth,
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
    final int sequenceNumber = await daoInt.getNextSequenceNumber(
      _CROP_PAGE_SEQUENCE_KEY,
    );
    final Directory directory = await BackgroundTaskUpload.getDirectory();

    final File smallCroppedFile = await _getSmallCroppedImageFile(
      directory,
      sequenceNumber,
    );

    setState(() => _progress = appLocalizations.crop_page_action_server);
    if (!mounted) {
      return null;
    }
    return widget.cropHelper.process(
      context: context,
      controller: _controller,
      inputFullWidth: _fullImageWidth,
      inputFullHeight: _fullImageHeight,
      smallCroppedFile: smallCroppedFile,
      directory: directory,
      inputFile: widget.inputFile,
      sequenceNumber: sequenceNumber,
      offsets: _eraserModel.offsets,
    );
  }

  Future<CropParameters?> _saveImage() async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return null;
    }

    setState(
      () => _progress = AppLocalizations.of(context).crop_page_action_saving,
    );
    try {
      final CropParameters? cropParameters = await _saveImageAndExitTry();
      _progress = null;
      if (mounted) {
        setState(() {});
      }
      return cropParameters;
    } catch (e) {
      await _showErrorDialog();
      return null;
    } finally {
      _progress = null;
    }
  }

  static const String _CROP_PAGE_SEQUENCE_KEY = 'crop_page_sequence';

  /// Saves the image if relevant after a user click, and pops the result.
  Future<void> _saveImageAndPop() async {
    if (_nothingHasChanged()) {
      // nothing has changed, let's leave
      Navigator.of(context).pop();
      return;
    }

    try {
      final CropParameters? cropParameters = await _saveImage();
      if (cropParameters != null) {
        /// Checking if the context is still mounted is not enough here
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop<CropParameters>(cropParameters);
        });
      }
    } catch (e) {
      await _showExceptionDialog(e);
    }
  }

  bool _nothingHasChanged() =>
      _controller.value.rotation == _initialRotation &&
      _controller.value.crop == _initialCrop &&
      !widget.initiallyDifferent;

  Future<(bool, CropParameters?)> _onWillPop() async {
    if (_nothingHasChanged()) {
      // nothing has changed, let's leave
      return (true, null);
    }

    // the cropped image has changed, but the user went back without saving
    final bool? pleaseSave = await MayExitPageHelper()
        .openSaveBeforeLeavingDialog(
          context,
          title: widget.cropHelper.getPageTitle(AppLocalizations.of(context)),
        );
    if (pleaseSave == null) {
      return (false, null);
    }
    if (pleaseSave == false) {
      return (true, null);
    }
    if (!mounted) {
      return (false, null);
    }

    try {
      final CropParameters? cropParameters = await _saveImage();
      if (cropParameters != null) {
        if (mounted) {
          return (true, cropParameters);
        }
      }
    } catch (e) {
      await _showExceptionDialog(e);
    }

    return (false, null);
  }

  Future<void> _showErrorDialog() async {
    if (!mounted) {
      return;
    }
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

  Future<void> _showExceptionDialog(final Object e) async {
    if (mounted) {
      // not likely to happen, but you never know...
      return LoadingDialog.error(
        context: context,
        title: 'Could not prepare picture with exception $e',
      );
    }
  }
}

/// Standard icon button for this page.
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(shape: const CircleBorder()),
      child: icons.AppIconTheme(semanticLabel: tooltip, child: icon),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: iconWidget);
    } else {
      return iconWidget;
    }
  }
}
