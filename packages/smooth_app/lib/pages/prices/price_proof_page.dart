import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Full page display of a proof.
class PriceProofPage extends StatelessWidget {
  const PriceProofPage(
    this.proof,
  );

  final Proof proof;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString()).add_Hms();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.user_search_proof_title),
        subTitle: Text(dateFormat.format(proof.created)),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(_getUrl()),
          ),
        ],
      ),
      body: Image(
        image: NetworkImage(_getUrl()),
        fit: BoxFit.cover,
      ),
    );
  }

  String _getUrl() => proof
      .getFileUrl(uriProductHelper: ProductQuery.uriPricesHelper)
      .toString();
}
