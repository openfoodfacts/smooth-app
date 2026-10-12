enum StoreLabel {
  GooglePlayStore,
  AppleAppStore,
  FDroid,
  AmazonAppStore,
  Test;

  String get name {
    return switch (this) {
      StoreLabel.GooglePlayStore => 'Google Play Store',
      StoreLabel.AppleAppStore => 'Apple App Store',
      StoreLabel.FDroid => 'F-Droid',
      StoreLabel.AmazonAppStore => 'Amazon App Store',
      StoreLabel.Test => 'Test Store',
    };
  }
}

enum ScannerLabel { ZXing, MLKit, Test }
