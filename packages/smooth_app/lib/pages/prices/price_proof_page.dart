import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        label: Text(appLocalizations.prices_add_a_price),
        icon: const Icon(Icons.add),
        onPressed: () async {
          if (!await ProductRefresher().checkIfLoggedIn(
            context,
            isLoggedInMandatory: true,
          )) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ProductPriceAddPage(
                PriceModel.proof(proof: proof),
              ),
            ),
          );
        },
      ),
      appBar: SmoothAppBar(
        title: Text(appLocalizations.user_search_proof_title),
        subTitle: Text(dateFormat.format(proof.created)),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(_getUrl(true)),
          ),
        ],
      ),
      body: Center(
        child: Image.network(
          _getUrl(false),
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: Image.network(
                _getUrl(true),
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getUrl(final bool isThumbnail) => proof
      .getFileUrl(
        uriProductHelper: ProductQuery.uriPricesHelper,
        isThumbnail: isThumbnail,
      )
      .toString();
}
