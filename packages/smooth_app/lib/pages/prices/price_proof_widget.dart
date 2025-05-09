import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Left: Image only
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmoothImage(
                width: imageSize,
                height: imageSize,
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
            const SizedBox(width: SMALL_SPACE),
            // Right: All information in a single column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Top row: Proof type and price count
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          proofType,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (priceCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priceCount == 1 ? '1 price' : '$priceCount prices',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: VERY_SMALL_SPACE),

                  // Price if available
                  if (proof.currency != null)
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          proof.currency.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  // Date and time
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$date, $time',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  // Location if available
                  if (proof.location != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              proof.location!.name ?? appLocalizations.unknown,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
