import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_radio.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/proof_type_extensions.dart';
import 'package:smooth_app/pages/proof_crop_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Card that displays the proof for price adding.
class PriceProofCard extends StatelessWidget {
  const PriceProofCard({this.forcedProofType, this.includeMyProofs = true});

  final ProofType? forcedProofType;
  final bool includeMyProofs;

  static const IconData _iconTodo = Icons.find_in_page_rounded;
  static const IconData _iconDone = Icons.swap_horizontal_circle_rounded;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_proof_subtitle,
      leading: const icons.PriceReceipt(),
      contentPadding: const EdgeInsetsDirectional.only(
        top: BALANCED_SPACE,
        bottom: MEDIUM_SPACE,
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
      ),
      child: Column(
        children: <Widget>[
          SmoothRadioGroup<ProofType>(
            groupValue: model.proofType,
            onChanged: (final ProofType? proofType) =>
                model.proofType = proofType!,
            items:
                (forcedProofType != null
                        ? <ProofType>[forcedProofType!]
                        : <ProofType>[ProofType.receipt, ProofType.priceTag])
                    .map<SmoothRadioItem<ProofType>>(
                      (final ProofType item) => SmoothRadioItem<ProofType>(
                        value: item,
                        label: item.getTitle(appLocalizations),
                        icon: item.getIcon(context),
                      ),
                    )
                    .toList(growable: false),
          ),
          const SizedBox(height: VERY_SMALL_SPACE),
          _ProofImagePreview(model: model),
          const SizedBox(height: VERY_SMALL_SPACE),
          SmoothLargeButtonWithIcon(
            text: !model.hasImage
                ? appLocalizations.prices_proof_find
                : appLocalizations.prices_proof_change,
            leadingIcon: !model.hasImage
                ? const Icon(_iconTodo)
                : const Icon(_iconDone),
            trailingIcon: !model.hasImage
                ? const icons.Chevron.right(size: 10.0)
                : const icons.Edit(size: 10.0),
            onPressed: () async {
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
    _ProofSource.history => const icons.PriceReceipt().icon,
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
          .toList(growable: false),
      addEndArrowToItems: true,
      values: sources,
    );
  }
}

class _ProofImagePreview extends StatelessWidget {
  const _ProofImagePreview({required this.model});

  final PriceModel model;

  @override
  Widget build(BuildContext context) {
    if (model.proof == null && model.cropParameters == null) {
      return EMPTY_WIDGET;
    }

    final Widget child;
    if (model.proof != null) {
      child = Padding(
        padding: const EdgeInsetsDirectional.only(top: 2.0),
        child: Image(
          image: NetworkImage(
            model.proof!
                .getFileUrl(
                  uriProductHelper: ProductQuery.uriPricesHelper,
                  isThumbnail: true,
                )!
                .toString(),
          ),
        ),
      );
    } else {
      final double screenHeight = MediaQuery.heightOf(context);

      child = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double imageSize = math.max(
            screenHeight * 0.4,
            constraints.maxWidth,
          );

          return Image.file(
            File(model.cropParameters!.smallCroppedFile!.path),
            width: imageSize,
            height: imageSize,
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 2.0),
        borderRadius: ANGULAR_BORDER_RADIUS,
      ),
      position: DecorationPosition.foreground,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: ClipRRect(borderRadius: ANGULAR_BORDER_RADIUS, child: child),
      ),
    );
  }
}
