import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/users_profile_data.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/prices_dashboard_widget.dart';
import 'package:smooth_app/pages/prices/prices_user_profile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PricesDashboard extends StatelessWidget {
  PricesDashboard({super.key});

  late final Future<MaybeError<UserProfile>> _userProfile = _fetchUserProfile();

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: const Text('My Dashboard'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Open Prices Dashboard in browser',
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
      body: FutureBuilder<MaybeError<UserProfile>>(
          future: _userProfile,
          builder: (BuildContext context,
              AsyncSnapshot<MaybeError<UserProfile>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text(snapshot.error!.toString());
            }
            final UserProfile userProfile = snapshot.data!.value;
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
  static Future<MaybeError<UserProfile>> _fetchUserProfile() async {
    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;
    final Uri uri = OpenPricesAPIClient.getUri(
      path: '/api/v1/users/$userId',
    );

    final http.Response response =
        await HttpHelper().doGetRequest(uri, uriHelper: uriHelperFoodProd);
    try {
      if (response.statusCode == 200) {
        final dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
        return MaybeError<UserProfile>.value(
          UserProfile.fromJson(decodedResponse),
        );
      }
    } catch (e) {
      //
    }
    return MaybeError<UserProfile>.responseError(response);
  }
}
