import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';

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
          SmoothLargeButtonWithIcon(
            text: model.xFile == null
                ? appLocalizations.prices_proof_find
                : model.proofType == ProofType.receipt
                    ? appLocalizations.prices_proof_receipt
                    : appLocalizations.prices_proof_price_tag,
            icon: model.xFile == null ? _iconTodo : _iconDone,
            onPressed: () async {
              // TODO(monsieurtanuki): add the crop feature
              final XFile? xFile = await pickImageFile(context);
              if (xFile != null) {
                model.xFile = xFile;
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
