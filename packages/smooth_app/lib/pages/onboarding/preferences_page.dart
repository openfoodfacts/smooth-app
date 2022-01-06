import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/user_preferences_food.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class PreferencesPage extends StatefulWidget {
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late Future<void> _initFuture;
  late Product _product;
  bool _isProductExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFuture = _init();
  }

  Future<dynamic> _init() async {
    // Load Product
    final String productResponse = await rootBundle
        .loadString('assets/onboarding/sample_product_data.json');
    final Map<String, dynamic> productData =
        jsonDecode(productResponse) as Map<String, dynamic>;
    _product = Product.fromJson(productData['product'] as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          final List<Widget> pageData = <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: LARGE_SPACE,
                left: LARGE_SPACE,
                bottom: LARGE_SPACE,
              ),
              child: Text(
                appLocalizations.productDataUtility,
                style: Theme.of(context).textTheme.headline2!.apply(
                      color: Colors.black,
                    ),
              ),
            ),
            Container(
              height: _isProductExpanded ? null : 150,
              padding: const EdgeInsets.only(
                bottom: LARGE_SPACE,
                right: LARGE_SPACE,
                left: LARGE_SPACE,
              ),
              child: GestureDetector(
                onTap: () => _expandProductCard(),
                child: SummaryCard(
                  _product,
                  productPreferences,
                  isFullVersion: _isProductExpanded,
                ),
              ),
            ),
          ];
          pageData.addAll(UserPreferencesFood(
            productPreferences: productPreferences,
            setState: setState,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
            themeData: Theme.of(context),
          ).getContent());
          return Scaffold(
            body: Stack(
              children: <Widget>[
                ListView(
                  // bottom padding is very large because [NextButton] is stacked on top of the page.
                  padding: const EdgeInsets.only(
                    top: LARGE_SPACE,
                    bottom: VERY_LARGE_SPACE * 5,
                  ),
                  shrinkWrap: true,
                  children: pageData,
                ),
                const Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NextButton(OnboardingPage.PREFERENCES_PAGE),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _expandProductCard() {
    if (!_isProductExpanded) {
      setState(() {
        _isProductExpanded = true;
      });
    }
  }
}
