import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/proof_crop_helper.dart';

/// Card that displays the proof for price adding.
class PriceProofCard extends StatelessWidget {
  const PriceProofCard();

  static const IconData _iconTodo = CupertinoIcons.exclamationmark;
  static const IconData _iconDone = Icons.receipt;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_proof_subtitle),
          if (model.cropParameters != null)
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
          //Text(model.cropParameters!.smallCroppedFile.path),
          SmoothLargeButtonWithIcon(
            text: model.cropParameters == null
                ? appLocalizations.prices_proof_find
                : model.proofType == ProofType.receipt
                    ? appLocalizations.prices_proof_receipt
                    : appLocalizations.prices_proof_price_tag,
            icon: model.cropParameters == null ? _iconTodo : _iconDone,
            onPressed: () async {
              final CropParameters? cropParameters =
                  await confirmAndUploadNewImage(
                context,
                cropHelper: ProofCropHelper(model: model),
                isLoggedInMandatory: true,
              );
              if (cropParameters != null) {
                model.cropParameters = cropParameters;
              }
            },
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
                    onChanged: (final ProofType? proofType) =>
                        model.proofType = proofType!,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: RadioListTile<ProofType>(
                    title: Text(appLocalizations.prices_proof_price_tag),
                    value: ProofType.priceTag,
                    groupValue: model.proofType,
                    onChanged: (final ProofType? proofType) =>
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
