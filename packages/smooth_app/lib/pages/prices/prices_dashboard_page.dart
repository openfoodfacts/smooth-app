import 'package:flutter/material.dart';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/prices_dashboard_widget.dart';
import 'package:smooth_app/pages/prices/prices_user_profile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PricesDashboardPage extends StatelessWidget {
  PricesDashboardPage();

  late final Future<MaybeError<PriceUser>> _userProfile =
      OpenPricesAPIClient.getUser(
        OpenFoodAPIConfiguration.globalUser!.userId,
        uriHelper: ProductQuery.uriPricesHelper,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.prices_dashboard_title),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_dashboard_open_in_browser,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'dashboard',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<MaybeError<PriceUser>>(
        future: _userProfile,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<MaybeError<PriceUser>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error!.toString()));
              }
              final MaybeError<PriceUser> result = snapshot.data!;
              if (result.isError) {
                return Center(
                  child: Text(result.error ?? appLocalizations.error_occurred),
                );
              }
              final PriceUser userProfile = result.value;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    PricesUserProfile(profile: userProfile),
                    PricesDashboardWidget(userProfile: userProfile),
                    const SizedBox(height: VERY_LARGE_SPACE),
                  ],
                ),
              );
            },
      ),
    );
  }
}
