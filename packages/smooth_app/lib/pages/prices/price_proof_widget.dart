import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/query/product_query.dart';

/// Widget that displays a price proof with its image and metadata.
class PriceProofWidget extends StatelessWidget {
  const PriceProofWidget(this.proof);

  final Proof proof;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double imageSize = screenSize.width * 0.25;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString());
    final String date = dateFormat.format(proof.date ?? proof.created);
    final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(proof.created);
    final String time = timeOfDay.format(context);
    final int priceCount = proof.priceCount;
    final String proofType = _getProofTypeLabel(appLocalizations);

    return Semantics(
      label: _generateSemanticsLabel(
        appLocalizations,
        date,
        time,
        proof.location?.name,
        priceCount,
      ),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left: Image with fixed dimensions
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SmoothImage(
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    imageProvider: NetworkImage(
                      proof
                          .getFileUrl(
                            uriProductHelper: ProductQuery.uriPricesHelper,
                            isThumbnail: true,
                          )
                          .toString(),
                    ),
                    rounded: false,
                  ),
                ),
              ),
              const SizedBox(width: SMALL_SPACE),
              // Right: All information in a single column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Single Wrap widget for all buttons
                    Wrap(
                      spacing: VERY_SMALL_SPACE,
                      runSpacing: VERY_SMALL_SPACE,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        // Proof type button
                        PriceButton(
                          title: proofType,
                          onPressed: () {},
                          iconData: _getProofTypeIcon(),
                        ),

                        // Price count button
                        if (priceCount > 0)
                          PriceButton(
                            title: priceCount == 1
                                ? '1 price'
                                : '$priceCount prices',
                            onPressed: () {},
                            iconData: Icons.receipt_long,
                          ),

                        // Currency button if available
                        if (proof.currency != null)
                          PriceButton(
                            title: _formatCurrency(proof.currency.toString()),
                            onPressed: () {},
                            iconData: Icons.monetization_on,
                          ),

                        // Date and time button
                        PriceButton(
                          title: '$date, $time',
                          onPressed: () {},
                          iconData: Icons.calendar_today,
                        ),

                        // Location button if available
                        if (proof.location != null)
                          PriceButton(
                            title: proof.location!.name ??
                                appLocalizations.unknown,
                            onPressed: () {},
                            iconData: Icons.location_on,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(String currencyString) {
    // Extract only the currency code from formats like "Currency.inr"
    if (currencyString.contains('.')) {
      return currencyString.split('.').last.toUpperCase();
    }
    return currencyString.toUpperCase();
  }

  String _getProofTypeLabel(AppLocalizations appLocalizations) {
    if (proof.type == null) {
      return appLocalizations.prices_proof_type_generic;
    }

    switch (proof.type) {
      case ProofType.receipt:
        return appLocalizations.prices_proof_type_receipt;
      default:
        return appLocalizations.prices_proof_type_generic;
    }
  }

  IconData? _getProofTypeIcon() {
    if (proof.type == null) {
      return Icons.receipt_long;
    }

    switch (proof.type) {
      case ProofType.receipt:
        return Icons.receipt;
      default:
        return Icons.receipt_long;
    }
  }

  String _generateSemanticsLabel(
    AppLocalizations appLocalizations,
    String date,
    String time,
    String? location,
    int priceCount,
  ) {
    final StringBuffer info = StringBuffer(date);
    info.write(' $time');

    if (location?.isNotEmpty == true) {
      info.write(' - $location');
    }

    final String proofType = _getProofTypeLabel(appLocalizations);
    final String priceText = priceCount == 1 ? '1 price' : '$priceCount prices';
    return '$priceText - $proofType';
  }
}
