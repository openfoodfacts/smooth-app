enum StoreLabel {
  GooglePlayStore,
  AppleAppStore,
  FDroid,
  AmazonAppStore,
  Test;

  String get name {
    switch (this) {
      case StoreLabel.GooglePlayStore:
        return 'Google Play Store';
      case StoreLabel.AppleAppStore:
        return 'Apple App Store';
      case StoreLabel.FDroid:
        return 'F-Droid';
      case StoreLabel.AmazonAppStore:
        return 'Amazon App Store';
      case StoreLabel.Test:
        return 'Test Store';
    }
  }
}

enum ScannerLabel { ZXing, MLKit, Test }
