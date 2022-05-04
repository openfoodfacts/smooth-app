import 'package:flutter/material.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart'
    as MlKit;
import 'package:qr_code_scanner/qr_code_scanner.dart' as QrCodeScanner;

List<MlKit.BarcodeFormat> invalidBarcodesMlKit = <MlKit.BarcodeFormat>[
  MlKit.BarcodeFormat.qrCode,
  MlKit.BarcodeFormat.unknown,
];

List<QrCodeScanner.BarcodeFormat> invalidBarcodesQrCodeScanner =
    <QrCodeScanner.BarcodeFormat>[
  QrCodeScanner.BarcodeFormat.qrcode,
  QrCodeScanner.BarcodeFormat.unknown,
];

bool isValidBarcodeMlKit(MlKit.Barcode barcode) {
  return !invalidBarcodesMlKit.contains(barcode.value.format);
}

bool isValidBarcodeQrcodeScanner(QrCodeScanner.Barcode barcode) {
  return !invalidBarcodesQrCodeScanner.contains(barcode.format);
}

bool _canShowInvalidebarcodeSnackbar = true;

void showInvalidBarcodeSnackbar(BuildContext context) {
  if (!_canShowInvalidebarcodeSnackbar) {
    return;
  }
  _canShowInvalidebarcodeSnackbar = false;

  ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(
          content: Text('Yay! A SnackBar!'),
        ),
      )
      .closed
      .then((_) {
    _canShowInvalidebarcodeSnackbar = true;
  });
}
