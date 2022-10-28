enum DevModeScanMode {
  CAMERA_ONLY,
  PREPROCESS_FULL_IMAGE,
  PREPROCESS_HALF_IMAGE,
  SCAN_FULL_IMAGE,
  SCAN_HALF_IMAGE;

  static DevModeScanMode get defaultScanMode => DevModeScanMode.SCAN_FULL_IMAGE;

  String get label {
    switch (this) {
      case DevModeScanMode.CAMERA_ONLY:
        return 'Only camera stream, no scanning';
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
        return 'Camera stream and full image preprocessing, no scanning';
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return 'Camera stream and half image preprocessing, no scanning';
      case DevModeScanMode.SCAN_FULL_IMAGE:
        return 'Full image scanning';
      case DevModeScanMode.SCAN_HALF_IMAGE:
        return 'Half image scanning';
    }
  }

  int get idx {
    switch (this) {
      case DevModeScanMode.CAMERA_ONLY:
        return 4;
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
        return 3;
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return 2;
      case DevModeScanMode.SCAN_FULL_IMAGE:
        return 0;
      case DevModeScanMode.SCAN_HALF_IMAGE:
        return 1;
    }
  }

  static DevModeScanMode fromIndex(final int? index) {
    if (index == null) {
      return defaultScanMode;
    }
    for (final DevModeScanMode scanMode in DevModeScanMode.values) {
      if (scanMode.index == index) {
        return scanMode;
      }
    }
    throw Exception('Unknown index $index');
  }
}
