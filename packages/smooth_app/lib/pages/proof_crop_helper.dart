import 'dart:async';
import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/proof_type_extensions.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Crop Helper for proof images: brand new image.
class ProofCropHelper extends CropHelper {
  ProofCropHelper({required this.model});

  final PriceModel model;

  @override
  bool isNewImage() => true;

  @override
  String getPageTitle(AppLocalizations appLocalizations) =>
      model.proofType.getTitle(appLocalizations);

  @override
  Widget getProcessIcon() => const icons.Check();

  @override
  String getProcessLabel(AppLocalizations appLocalizations) =>
      appLocalizations.okay;

  @override
  bool get enableEraser => true;

  @override
  Future<CropParameters> process({
    required BuildContext context,
    required CropController controller,
    required File inputFile,
    required int inputFullWidth,
    required int inputFullHeight,
    required File preCroppedFile,
    required Directory directory,
    required int sequenceNumber,
    required List<Offset> offsets,
  }) async {
    // It's a brand new picture, with crop parameters.
    // For privacy reasons, we won't send the full image to the server and
    // let it crop it: we'll send the cropped image directly.

    // here we already have a full size cropped image, in smallCroppedFile
    return CropParameters.asIs(preCroppedFile);
  }
}
