import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/proof_type_extensions.dart';

/// Crop Helper for proof images: brand new image.
class ProofCropHelper extends CropHelper {
  ProofCropHelper({
    required this.model,
  });

  final PriceModel model;

  @override
  bool isNewImage() => true;

  @override
  String getPageTitle(final AppLocalizations appLocalizations) =>
      model.proofType.getTitle(appLocalizations);

  @override
  IconData getProcessIcon() => Icons.check;

  @override
  String getProcessLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.okay;

  @override
  bool get enableEraser => true;

  @override
  Future<CropParameters?> process({
    required final BuildContext context,
    required final CropController controller,
    required final ui.Image image,
    required final File inputFile,
    required final File smallCroppedFile,
    required final Directory directory,
    required final int sequenceNumber,
    required final List<Offset> offsets,
  }) async {
    // It's a brand new picture, with crop parameters.
    // For performance reasons, we do not crop the image full-size here,
    // but in the background task.
    // For privacy reasons, we won't send the full image to the server and
    // let it crop it: we'll send the cropped image directly.
    final File fullFile = await copyFullImageFile(
      directory,
      sequenceNumber,
      inputFile,
    );
    if (!context.mounted) {
      return null;
    }
    return getCropParameters(
      controller: controller,
      fullFile: fullFile,
      smallCroppedFile: smallCroppedFile,
      offsets: offsets,
    );
  }
}
