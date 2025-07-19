import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/prices/price_add_helper.dart';
import 'package:smooth_app/pages/prices/price_model.dart';

/// Card that displays the bulk proof button for price adding.
class PriceBulkProofCard extends StatefulWidget {
  const PriceBulkProofCard(this.formKey);

  final GlobalKey<FormState> formKey;

  @override
  State<PriceBulkProofCard> createState() => _PriceBulkProofCardState();
}

class _PriceBulkProofCardState extends State<PriceBulkProofCard> {
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_bulk_proof_upload_subtitle,
      leading: const Icon(Icons.document_scanner_rounded),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: _text.isNotEmpty
          ? ListTile(
              leading: const CircularProgressIndicator.adaptive(),
              title: Text(_text),
            )
          : Column(
              children: <Widget>[
                ListTile(
                  trailing: const Icon(Icons.warning),
                  title: Text(
                    appLocalizations.prices_bulk_proof_upload_warning,
                  ),
                ),
                SmoothLargeButtonWithIcon(
                  text: appLocalizations.prices_bulk_proof_upload_select,
                  leadingIcon: const Icon(Icons.add),
                  onPressed: model.location == null
                      ? null
                      : () async => _selectAndUpload(model: model),
                ),
              ],
            ),
    );
  }

  void _setText(final String message) {
    if (mounted) {
      setState(() => _text = message);
    }
  }

  Future<void> _selectAndUpload({required PriceModel model}) async {
    final String? error = await _selectAndUploadWithError(model: model);
    _setText(error ?? '');
  }

  // Returns the error message, or null if OK.
  Future<String?> _selectAndUploadWithError({required PriceModel model}) async {
    final PriceAddHelper priceAddHelper = PriceAddHelper(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    const int imageQuality = 80;
    final Directory directory = await BackgroundTaskUpload.getDirectory();
    const String BULK_PROOF_IMAGE_SEQUENCE_KEY = 'bulk_proof_image_sequence';
    final Rect cropRect = CropHelper.getLocalCropRectFromRect(
      CropHelper.fullImageCropRect,
    );

    _setText('Selecting files');
    final List<XFile> xFiles = await ImagePicker().pickMultiImage(
      imageQuality: imageQuality,
      requestFullMetadata: false,
    );
    if (xFiles.isEmpty) {
      return null;
    }

    if (!await priceAddHelper.acceptsWarning()) {
      return null;
    }
    if (!mounted) {
      return null;
    }
    _setText('Starting the upload');
    late int index;
    final int count = xFiles.length;
    final DaoInt daoInt = DaoInt(localDatabase);
    try {
      index = 0;
      for (final XFile xFile in xFiles) {
        index++;
        final int sequenceNumber = await getNextSequenceNumber(
          daoInt,
          BULK_PROOF_IMAGE_SEQUENCE_KEY,
        );
        final String path = xFile.path;
        final File temporaryFile = File(path);
        final int pos = path.lastIndexOf(Platform.pathSeparator);
        final String filename = path.substring(pos + 1);
        final File toBeUploadedFile = File(
          '${directory.path}/bulk_proof_${sequenceNumber}_$filename',
        );
        _setText('Locally copying file #$index/$count');
        await temporaryFile.copy(toBeUploadedFile.path);
        await temporaryFile.delete();

        _setText('Preparing upload #$index/$count');
        model.cropParameters = CropParameters(
          fullFile: toBeUploadedFile,
          smallCroppedFile: null,
          rotation: CropRotation.up.degrees,
          cropRect: cropRect,
          eraserCoordinates: null,
        );
        if (!mounted) {
          return null;
        }
        if (!await priceAddHelper.check(model, widget.formKey)) {
          return null;
        }
        if (!mounted) {
          return null;
        }
        await model.addTask(context, displaySnackbar: false);
        model.clearProof();
      }
    } catch (e) {
      return 'Failed at image #$index/$count';
    }
    return null;
  }
}
