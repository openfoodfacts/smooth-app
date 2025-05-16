import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

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
