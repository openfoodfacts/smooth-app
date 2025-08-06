import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/proof_type_extensions.dart';
import 'package:smooth_app/pages/proof_crop_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays the proof for price adding.
class PriceProofCard extends StatelessWidget {
  const PriceProofCard({this.forcedProofType, this.includeMyProofs = true});

  final ProofType? forcedProofType;
  final bool includeMyProofs;

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
                      File(model.cropParameters!.smallCroppedFile!.path),
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
                  : model.proofType.getTitle(appLocalizations),
              leadingIcon: !model.hasImage
                  ? const Icon(_iconTodo)
                  : const Icon(_iconDone),
              onPressed: model.proof != null
                  ? null
                  : () async {
                      final List<_ProofSource> sources =
                          _ProofSource.getPossibleProofSources(
                            includeMyProofs: includeMyProofs,
                          );
                      // not very likely
                      if (sources.isEmpty) {
                        return;
                      }
                      final _ProofSource? proofSource;
                      if (sources.length == 1) {
                        proofSource = sources.first;
                      } else {
                        proofSource = await _ProofSource.select(
                          context,
                          sources: sources,
                        );
                      }
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
              children:
                  (const <ProofType>[ProofType.receipt, ProofType.priceTag])
                      .map<Widget>(
                        (final ProofType item) => SizedBox(
                          width: constraints.maxWidth / 2,
                          child: RadioListTile<ProofType>(
                            title: Text(item.getTitle(appLocalizations)),
                            value: item,
                            groupValue: model.proofType,
                            onChanged:
                                model.proof != null || forcedProofType != null
                                ? null
                                : (final ProofType? proofType) =>
                                      model.proofType = proofType!,
                          ),
                        ),
                      )
                      .toList(),
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

  String getTitle(final AppLocalizations appLocalizations) => switch (this) {
    _ProofSource.camera => appLocalizations.settings_app_camera,
    _ProofSource.gallery => appLocalizations.gallery_source_label,
    _ProofSource.history => appLocalizations.user_search_proofs_title,
  };

  IconData getIconData() => switch (this) {
    _ProofSource.camera => Icons.camera_rounded,
    _ProofSource.gallery => Icons.perm_media_rounded,
    _ProofSource.history => Icons.document_scanner_rounded,
  };

  Future<void> process(
    final BuildContext context,
    final PriceModel model,
  ) async {
    switch (this) {
      case _ProofSource.history:
        final Proof? proof = await Navigator.of(context).push<Proof>(
          MaterialPageRoute<Proof>(
            builder: (BuildContext context) =>
                const PricesProofsPage(selectProof: true),
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

  static List<_ProofSource> getPossibleProofSources({
    required final bool includeMyProofs,
  }) {
    final List<_ProofSource> result = <_ProofSource>[];
    final bool hasCamera = CameraHelper.hasACamera;
    if (hasCamera) {
      result.add(_ProofSource.camera);
    }
    result.add(_ProofSource.gallery);
    if (includeMyProofs) {
      result.add(_ProofSource.history);
    }
    return result;
  }

  static Future<_ProofSource?> select(
    final BuildContext context, {
    required final List<_ProofSource> sources,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showSmoothListOfChoicesModalSheet<_ProofSource>(
      context: context,
      title: appLocalizations.prices_proof_find,
      labels: sources.map<String>(
        (_ProofSource source) => source.getTitle(appLocalizations),
      ),
      prefixIcons: sources
          .map<Widget>((_ProofSource source) => Icon(source.getIconData()))
          .toList(),
      addEndArrowToItems: true,
      values: sources,
    );
  }
}
