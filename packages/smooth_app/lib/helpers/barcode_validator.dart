import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

bool _canShowInvalidBarcodeSnackbar = true;

void disallowShowInvalidBarcodeSnackbar() {
  _canShowInvalidBarcodeSnackbar = false;
}

void allowShowInvalidBarcodeSnackbar() {
  _canShowInvalidBarcodeSnackbar = true;
}

void showInvalidBarcodeSnackbar(BuildContext context) {
  if (!_canShowInvalidBarcodeSnackbar) {
    return;
  }

  disallowShowInvalidBarcodeSnackbar();

  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text(appLocalizations.not_valid_barcode),
        ),
      )
      .closed
      .then((_) => allowShowInvalidBarcodeSnackbar());
}
