import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/query/product_query.dart';

/// Widget that displays a price proof with its image and metadata.
class PriceProofWidget extends StatelessWidget {
  const PriceProofWidget(this.proof, {super.key});

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
    final String timeAgo = _getTimeAgo(proof.created);

    // Format as "date (time ago)" when recent
    final String dateDisplay = timeAgo.isNotEmpty ? '$date ($timeAgo)' : date;

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
      child: SmoothCard(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        borderRadius: ROUNDED_BORDER_RADIUS,
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left: Image with fixed dimensions
              ClipRRect(
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
              const SizedBox(width: SMALL_SPACE),
              // Right: All information in a single column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildProofTypeRow(context),
                    Text(
                      dateDisplay,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (proof.location != null)
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.public,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              proof.location!.name ?? appLocalizations.unknown,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: SMALL_SPACE),
                    if (priceCount > 0)
                      _buildInfoChip(
                        context,
                        priceCount == 1 ? '1 price' : '$priceCount prices',
                        Icons.receipt_long,
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

  /// Builds the proof type row with currency symbol when available
  Widget _buildProofTypeRow(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String proofTypeLabel = _getProofTypeLabel(appLocalizations);

    return Row(
      children: <Widget>[
        Text(
          proofTypeLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (proof.currency != null) ...<Widget>[
          const SizedBox(width: 4),
          const Text(
            '(',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            proof.currency!.symbol,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            ')',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a styled information chip with icon
  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getProofTypeLabel(AppLocalizations appLocalizations) {
    if (proof.type == null) {
      return appLocalizations.prices_proof_type_price_tag;
    }

    switch (proof.type) {
      case ProofType.receipt:
        return appLocalizations.prices_proof_type_receipt;
      default:
        return appLocalizations.prices_proof_type_price_tag;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    if (difference.inDays < 7) {
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min ago';
      } else {
        return 'just now';
      }
    }
    return '';
  }

  String _generateSemanticsLabel(
    AppLocalizations appLocalizations,
    String date,
    String time,
    String? location,
    int priceCount,
  ) {
    final StringBuffer info = StringBuffer();
    final String timeAgo = _getTimeAgo(proof.created);

    final String proofType = _getProofTypeLabel(appLocalizations);
    info.write(proofType);

    if (priceCount > 0) {
      final String priceText =
          priceCount == 1 ? '1 price' : '$priceCount prices';
      info.write(', $priceText');
    }

    if (timeAgo.isNotEmpty) {
      info.write(', $date ($timeAgo)');
    } else {
      info.write(', $date');
    }

    if (location?.isNotEmpty == true) {
      info.write(', at $location');
    }

    if (proof.currency != null) {
      info.write(
          ', ${proof.currency!.symbol} (${proof.currency!.name}) currency');
    }

    return info.toString();
  }
}
