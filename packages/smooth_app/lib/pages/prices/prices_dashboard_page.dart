import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/prices_dashboard_widget.dart';
import 'package:smooth_app/pages/prices/prices_user_profile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PricesDashboardPage extends StatelessWidget {
  PricesDashboardPage();

  late final Future<MaybeError<PriceUser>> _userProfile = _fetchUserProfile();

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
          builder: (BuildContext context,
              AsyncSnapshot<MaybeError<PriceUser>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Text(snapshot.error!.toString());
            }
            final PriceUser userProfile = snapshot.data!.value;
            return Column(
              children: <Widget>[
                PricesUserProfile(profile: userProfile),
                Expanded(
                    child: PricesDashboardWidget(userProfile: userProfile)),
              ],
            );
          }),
    );
  }

  // TODO(chetanr25): To be implemented in OpenFoodFacts flutter package
  static Future<MaybeError<PriceUser>> _fetchUserProfile() async {
    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;
    final Uri uri = OpenPricesAPIClient.getUri(
      path: '/api/v1/users/$userId',
    );

    final http.Response response =
        await HttpHelper().doGetRequest(uri, uriHelper: uriHelperFoodProd);
    try {
      if (response.statusCode == 200) {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<PriceUser>.value(
          PriceUser.fromJson(decodedResponse),
        );
      }
    } catch (e) {
      //
    }
    return MaybeError<PriceUser>.responseError(response);
  }
}
