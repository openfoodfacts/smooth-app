import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Extensions on ProofType.
extension ProofTypeExtension on ProofType {
  String getTitle(AppLocalizations appLocalizations) => switch (this) {
        ProofType.receipt => appLocalizations.prices_proof_receipt,
        ProofType.priceTag => appLocalizations.prices_proof_price_tag,
        // not used for the moment
        ProofType.gdprRequest => 'GDPR Request',
        // not used for the moment
        ProofType.shopImport => 'Shop import',
      };
}
