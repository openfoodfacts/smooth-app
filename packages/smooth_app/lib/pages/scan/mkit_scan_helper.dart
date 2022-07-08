import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/scan/abstract_camera_image_getter.dart';
import 'package:smooth_app/pages/scan/camera_image_cropper.dart';
import 'package:smooth_app/pages/scan/camera_image_full_getter.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// ML Kit bar code decoder (within an Isolate)
class MLKitScanDecoder {
  MLKitScanDecoder({
    required CameraDescription camera,
    required this.scanMode,
  }) : _mainIsolate = _MLKitScanDecoderMainIsolate(
          camera: camera,
          scanMode: scanMode,
        );

  final DevModeScanMode scanMode;
  final _MLKitScanDecoderMainIsolate _mainIsolate;

  /// Extract barcodes from an image
  ///
  /// A null result is sent when the [scanMode] is unsupported or if a current
  /// decoding is already in progress
  /// Otherwise a list of decoded barcoded is returned
  /// Note: This list may be empty if no barcode is detected
  Future<List<String>?> processImage(CameraImage image) async {
    switch (scanMode) {
      case DevModeScanMode.CAMERA_ONLY:
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return null;
      case DevModeScanMode.SCAN_FULL_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
      // OK -> continue
    }

    return _mainIsolate.decode(image);
  }

  Future<void> dispose() async {
    _mainIsolate.dispose();
    Logs.d(tag: 'MLKitScanDecoder', 'Disposed');
  }
}

/// Main class allowing to communicate with [_MLKitScanDecoderIsolate]
/// The communication is bi-directional:
/// -> From the main Isolate to the "decoder" Isolate
///   -> Send the configuration (camera description + scan mode)
///   -> Send a camera image to decode
/// <- From the "decoder" Isolate
///   -> When the Isolate is started (a [SendPort] is provided to communicate)
///   -> When the Isolate is ready (camera description & scan mode are provided)
///   -> When an image is decoded
class _MLKitScanDecoderMainIsolate {
  _MLKitScanDecoderMainIsolate({
    required this.camera,
    required this.scanMode,
  }) : _port = ReceivePort() {
    _port.listen((dynamic message) {
      if (message is SendPort) {
        _sendPort = message;

        _sendPort!.send(
          _MLKitScanDecoderIsolate._createConfig(
            camera,
            scanMode,
          ),
        );
      } else if (message is bool) {
        _isIsolateInitialized = true;

        if (_queuedImage != null && _completer != null) {
          _sendPort!.send(_queuedImage!.export());
          _queuedImage = null;
        }
      } else if (message is List) {
        _completer?.complete(message as List<String>);
        _completer = null;
      }
    });
  }

  final CameraDescription camera;
  final DevModeScanMode scanMode;

  /// Port used by the Isolate to send us events:
  /// - when a [SendPort] is available
  /// - when the Isolate is ready to receive images
  /// - when the Isolate has finished a detection
  final ReceivePort _port;

  /// Port provided by the Isolate to send instructions
  /// - send the configuration (camera & scan mode)
  /// - send a camera image
  SendPort? _sendPort;

  FlutterIsolate? _isolate;

  /// Flag used when the Isolate is both started and ready to receive images
  bool _isIsolateInitialized = false;

  /// When an image is provided, this [Completer] allows to notify the response
  Completer<List<String>?>? _completer;

  /// When the Isolate is started, we have to wait until [_isIsolateInitialized]
  /// is [true]. This variable temporary contains the image waiting to be
  /// decoded.
  CameraImage? _queuedImage;

  /// Decodes barcodes from a [CameraImage]
  /// A null result will be sent until the Isolate isn't ready
  Future<List<String>?> decode(CameraImage image) async {
    // If a decoding process is running -> ignore new requests
    if (_completer != null) {
      return null;
    }

    _completer = Completer<List<String>?>();

    if (_isolate == null) {
      _isolate = await FlutterIsolate.spawn(
        _MLKitScanDecoderIsolate.startIsolate,
        _port.sendPort,
      );
      _queuedImage = image;
      return _completer!.future;
    } else if (_isIsolateInitialized) {
      _sendPort?.send(image.export());
      return _completer!.future;
    }

    return null;
  }

  void dispose() {
    _isIsolateInitialized = false;

    _completer?.completeError(Exception('Isolate stopped'));
    _completer = null;

    _sendPort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

// ignore: avoid_classes_with_only_static_members
class _MLKitScanDecoderIsolate {
  // Only 1D barcodes. More info on:
  // [https://www.scandit.com/blog/types-barcodes-choosing-right-barcode/]
  static final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: <BarcodeFormat>[
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.code128,
      BarcodeFormat.itf,
      BarcodeFormat.codabar,
    ],
  );

  static const String _cameraKey = 'camera';
  static const String _scanModeKey = 'scanMode';

  /// Port to communicate with the main Isolate
  static late ReceivePort? _port;
  static CameraDescription? _camera;
  static DevModeScanMode? _scanMode;

  static void startIsolate(SendPort port) {
    _port = ReceivePort();

    _port!.listen(
      (dynamic message) async {
        if (message is Map<String, dynamic>) {
          if (message.containsKey(_cameraKey)) {
            _initIsolate(message);
            port.send(true);
          } else {
            await onNewBarcode(message, port);
          }
        }
      },
    );

    port.send(_port!.sendPort);
  }

  /// Content required for this Isolate to be "ready"
  static Map<String, dynamic> _createConfig(
    CameraDescription camera,
    DevModeScanMode scanMode,
  ) {
    return <String, dynamic>{
      _cameraKey: camera.export(),
      _scanModeKey: scanMode.index,
    };
  }

  /// Parse content containing the configuration of this Isolate
  // ignore: avoid_dynamic_calls
  static void _initIsolate(Map<String, dynamic> message) {
    _camera = _CameraDescriptionUtils.import(
      message[_cameraKey] as Map<String, dynamic>,
    );
    _scanMode = DevModeScanMode.values[message[_scanModeKey] as int];
  }

  static bool get isReady => _camera != null && _scanMode != null;

  static Future<void> onNewBarcode(
    Map<dynamic, dynamic> message,
    SendPort port,
  ) async {
    if (!isReady) {
      return;
    }

    final CameraImage image = CameraImage.fromPlatformData(message);
    final InputImage cropImage = _cropImage(image);
    final double imageHeight =
        cropImage.inputImageData?.size.longestSide ?? double.infinity;

    final List<Barcode> barcodes =
        await _barcodeScanner.processImage(cropImage);

    port.send(
      barcodes
          // Only accepts barcodes on half-top of the image
          .where((Barcode barcode) =>
              (barcode.boundingBox?.top ?? 0.0) <= imageHeight * 0.5)
          .map((Barcode barcode) => _changeBarcodeType(barcode))
          .where((String? barcode) => barcode?.isNotEmpty == true)
          .cast<String>()
          .toList(growable: false),
    );
  }

  static String? _changeBarcodeType(Barcode barcode) {
    //EAN13 begins with 0 is detected as UPC-A by google_mlkit_barcode_scanning v0.3.0
    if (barcode.rawValue != null && barcode.format == BarcodeFormat.upca) {
      return '0${barcode.rawValue}';
    }
    return barcode.rawValue;
  }

  static InputImage _cropImage(CameraImage image) {
    final AbstractCameraImageGetter getter;

    switch (_scanMode!) {
      case DevModeScanMode.CAMERA_ONLY:
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        throw Exception('Unsupported mode $_scanMode!');
      case DevModeScanMode.SCAN_FULL_IMAGE:
        getter = CameraImageFullGetter(image, _camera!);
        break;
      case DevModeScanMode.SCAN_HALF_IMAGE:
        getter = CameraImageCropper(
          image,
          _camera!,
          left01: 0,
          top01: 0,
          width01: 1,
          height01: .5,
        );
        break;
    }

    return getter.getInputImage();
  }
}

/// [Isolate]s don't support custom classes.
/// This extension exports raw data from a [CameraImage], to be able to call
/// [CameraImage.fromPlatformData]
extension _CameraImageExtension on CameraImage {
  Map<String, dynamic> export() => <String, dynamic>{
        'format': format.raw,
        'width': width,
        'height': height,
        'lensAperture': lensAperture,
        'sensorExposureTime': sensorExposureTime,
        'sensorSensitivity': sensorSensitivity,
        'planes': planes
            .map((Plane p) => <dynamic, dynamic>{
                  'bytes': p.bytes,
                  'bytesPerPixel': p.bytesPerPixel,
                  'bytesPerRow': p.bytesPerRow,
                  'height': p.height,
                  'width': p.width,
                })
            .toList(
              growable: false,
            )
      };
}

/// [Isolate]s don't support custom classes.
/// This extension exports raw data from a [CameraDescription], to be able to
/// call the [CameraDescription] constructor via [_CameraDescriptionUtils.import].
extension _CameraDescriptionExtension on CameraDescription {
  Map<String, dynamic> export() => <String, dynamic>{
        _CameraDescriptionUtils._nameKey: name,
        _CameraDescriptionUtils._lensDirectionKey: lensDirection.index,
        _CameraDescriptionUtils._sensorOrientationKey: sensorOrientation,
      };
}

/// Recreate a [CameraDescription] from [_CameraDescriptionExtension.export]
class _CameraDescriptionUtils {
  const _CameraDescriptionUtils._();

  static const String _nameKey = 'name';
  static const String _lensDirectionKey = 'lensDirection';
  static const String _sensorOrientationKey = 'sensorOrientation';

  static CameraDescription import(Map<String, dynamic> map) {
    return CameraDescription(
      name: map[_nameKey] as String,
      lensDirection: CameraLensDirection.values[map[_lensDirectionKey] as int],
      sensorOrientation: map[_sensorOrientationKey] as int,
    );
  }
}
