import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/proof_crop_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays the proof for price adding.
class PriceProofCard extends StatelessWidget {
  const PriceProofCard();

  static const IconData _iconTodo = CupertinoIcons.exclamationmark;
  static const IconData _iconDone = Icons.receipt;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_proof_subtitle,
      leading: const Icon(Icons.document_scanner_rounded),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: Column(
        children: <Widget>[
          if (model.proof != null)
            Image(
              image: NetworkImage(
                model.proof!
                    .getFileUrl(
                      uriProductHelper: ProductQuery.uriPricesHelper,
                      isThumbnail: true,
                    )!
                    .toString(),
              ),
            )
          else if (model.cropParameters != null)
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  Image(
                image: FileImage(
                  File(model.cropParameters!.smallCroppedFile.path),
                ),
                width: constraints.maxWidth,
                height: constraints.maxWidth,
              ),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
            ),
            child: SmoothLargeButtonWithIcon(
              text: !model.hasImage
                  ? appLocalizations.prices_proof_find
                  : model.proofType == ProofType.receipt
                      ? appLocalizations.prices_proof_receipt
                      : appLocalizations.prices_proof_price_tag,
              leadingIcon: !model.hasImage
                  ? const Icon(_iconTodo)
                  : const Icon(_iconDone),
              onPressed: model.proof != null
                  ? null
                  : () async {
                      final _ProofSource? proofSource =
                          await _ProofSource.select(context);
                      if (proofSource == null) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
                      return proofSource.process(context, model);
                    },
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Row(
              children: <Widget>[
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: RadioListTile<ProofType>(
                    title: Text(appLocalizations.prices_proof_receipt),
                    value: ProofType.receipt,
                    groupValue: model.proofType,
                    onChanged: model.proof != null
                        ? null
                        : (final ProofType? proofType) =>
                            model.proofType = proofType!,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: RadioListTile<ProofType>(
                    title: Text(appLocalizations.prices_proof_price_tag),
                    value: ProofType.priceTag,
                    groupValue: model.proofType,
                    onChanged: model.proof != null
                        ? null
                        : (final ProofType? proofType) =>
                            model.proofType = proofType!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProofSource {
  camera,
  gallery,
  history;

  Future<void> process(
    final BuildContext context,
    final PriceModel model,
  ) async {
    switch (this) {
      case _ProofSource.history:
        final Proof? proof = await Navigator.of(context).push<Proof>(
          MaterialPageRoute<Proof>(
            builder: (BuildContext context) => const PricesProofsPage(
              selectProof: true,
            ),
          ),
        );
        if (proof != null) {
          model.setProof(proof);
        }
        return;
      case _ProofSource.camera:
      case _ProofSource.gallery:
        final UserPictureSource source = this == _ProofSource.gallery
            ? UserPictureSource.GALLERY
            : UserPictureSource.CAMERA;
        final CropParameters? cropParameters = await confirmAndUploadNewImage(
          context,
          cropHelper: ProofCropHelper(model: model),
          isLoggedInMandatory: true,
          forcedSource: source,
        );
        if (cropParameters != null) {
          model.cropParameters = cropParameters;
        }
    }
  }

  static Future<_ProofSource?> select(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool hasCamera = CameraHelper.hasACamera;

    return showSmoothListOfChoicesModalSheet<_ProofSource>(
      context: context,
      title: appLocalizations.prices_proof_find,
      labels: <String>[
        if (hasCamera) appLocalizations.settings_app_camera,
        appLocalizations.gallery_source_label,
        appLocalizations.user_search_proofs_title,
      ],
      prefixIcons: <Widget>[
        if (hasCamera) const Icon(Icons.camera_rounded),
        const Icon(Icons.perm_media_rounded),
        const Icon(Icons.document_scanner_rounded),
      ],
      addEndArrowToItems: true,
      values: <_ProofSource>[
        _ProofSource.camera,
        _ProofSource.gallery,
        _ProofSource.history,
      ],
    );
  }
}
