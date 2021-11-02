import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:openfoodfacts/model/Product.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;