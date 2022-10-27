import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanner_mlkit/src/utils/abstract_camera_image_getter.dart';
import 'package:scanner_mlkit/src/utils/camera_image_cropper.dart';
import 'package:scanner_mlkit/src/utils/camera_image_full_getter.dart';
import 'package:scanner_shared/scanner_shared.dart';

class MLKitCameraScanner extends CameraScanner {
  bool _initialized = false;
  late DevModeScanMode _scanMode;
  late _MLKitScanDecoderMainIsolate _mainIsolate;

  /// Ensures the dispose() method is called if this class is GC'ed.
  static final Finalizer<_MLKitScanDecoderMainIsolate> _finalizer =
      Finalizer<_MLKitScanDecoderMainIsolate>(
    (_MLKitScanDecoderMainIsolate isolate) => isolate.dispose(),
  );

  @override
  Future<void> onInit({
    required CameraDescription camera,
    required DevModeScanMode mode,
  }) async {
    _scanMode = mode;
    _mainIsolate = _MLKitScanDecoderMainIsolate(
      camera: camera,
      scanMode: mode,
    );

    _initialized = true;
  }

  @override
  Future<List<String?>?> onNewCameraImage(CameraImage image) async =>
      _onNewImage(image);

  @override
  Future<List<String?>?> onNewCameraFile(String path) async =>
      _onNewImage(path);

  Future<List<String?>?> _onNewImage(dynamic image) async {
    // TODO(g123k): Not implemented
    switch (_scanMode) {
      case DevModeScanMode.CAMERA_ONLY:
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return null;
      case DevModeScanMode.SCAN_FULL_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
      // OK -> continue
    }

    /// The next call with recreate the isolate if necessary.
    /// Re-attaching it to the finalizer is mandatory.
    if (_mainIsolate.isDisposed) {
      _finalizer.attach(this, _mainIsolate, detach: this);
    }

    return _mainIsolate.decode(image);
  }

  @override
  bool get supportCameraFile => !Platform.isIOS;

  @override
  bool get supportCameraImage => true;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> onDispose() async {
    _initialized = false;
    _mainIsolate.dispose();
    _finalizer.detach(this);
    addLog(message: 'Disposed');

    return super.onDispose();
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
          if (_queuedImage is CameraImage) {
            _sendPort!.send((_queuedImage as CameraImage).export());
          } else if (_queuedImage is String) {
            _sendPort!.send(_CameraFileUtils.export(_queuedImage as String));
          }

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
  dynamic _queuedImage;

  /// Decodes barcodes from an image
  /// A null result will be sent until the Isolate isn't ready
  Future<List<String>?> decode(dynamic image) async {
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
      if (image is CameraImage) {
        _sendPort?.send(image.export());
      } else if (image is String) {
        _sendPort?.send(_CameraFileUtils.export(image));
      }

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

  bool get isDisposed =>
      _isIsolateInitialized == false &&
      _completer == null &&
      _sendPort == null &&
      _isolate == null;
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

    Iterable<Barcode>? barcodes;
    if (_CameraFileUtils.containsKey(message)) {
      final String path = _CameraFileUtils.import(message);
      final File file = File(path);

      if (file.existsSync() && file.lengthSync() > 0) {
        try {
          barcodes = await _barcodeScanner.processImage(
            InputImage.fromFilePath(path),
          );
        } catch (ignored) {
          // The native code may fail if the file is invalid
        }

        // Not mandatory as the native part also removes the file
        File(path).delete();
      }
    } else {
      final CameraImage image = CameraImage.fromPlatformData(message);
      final InputImage cropImage = _cropImage(image);
      final double imageHeight =
          cropImage.inputImageData?.size.longestSide ?? double.infinity;

      final List<Barcode> list = await _barcodeScanner.processImage(cropImage);

      // With files, we don't know the imageHeight
      barcodes = list.where((Barcode barcode) =>
          (barcode.boundingBox?.top ?? 0.0) <= imageHeight * 0.5);
    }

    if (barcodes == null || barcodes.isEmpty) {
      port.send(<String>['']);
    } else {
      port.send(
        barcodes
            .map((Barcode barcode) => _changeBarcodeType(barcode))
            .where((String? barcode) => barcode?.isNotEmpty == true)
            .cast<String>()
            .toList(growable: false),
      );
    }
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

class _CameraFileUtils {
  const _CameraFileUtils._();

  static Map<String, dynamic> export(String file) =>
      <String, dynamic>{'file': file};

  static String import(Map<dynamic, dynamic> map) => map['file'] as String;

  static bool containsKey(Map<dynamic, dynamic> map) => map.containsKey('file');
}
