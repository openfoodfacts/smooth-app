import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/pages/product/summary_card.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this._localDatabase, this.backgroundColor) : super();

  final LocalDatabase _localDatabase;
  final Color backgroundColor;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

// Just here to load the product and pass it to the next Widget
class _PreferencesPageState extends State<PreferencesPage> {
  late Future<void> _initFuture;
  late Product _product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFuture = _init();
  }

  Future<void> _init() async =>
      _product = await OnboardingDataProduct.forProduct(widget._localDatabase)
          .getData(rootBundle);

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);
            return Text(
              appLocalizations.preferences_page_loading_error(snapshot.error),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          return _Helper(_product, widget.backgroundColor);
        },
      );
}

// In order to avoid to reload the product when refreshing the preferences.
class _Helper extends StatefulWidget {
  const _Helper(this.product, this.backgroundColor);

  final Product product;
  final Color backgroundColor;

  @override
  State<_Helper> createState() => _HelperState();
}

class _HelperState extends State<_Helper> {
  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> pageData = <Widget>[
      SvgPicture.asset(
        'assets/onboarding/preferences.svg',
        height: MediaQuery.sizeOf(context).height * .25,
        package: AppHelper.APP_PACKAGE,
      ),
      Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: LARGE_SPACE,
          start: LARGE_SPACE,
          end: LARGE_SPACE,
        ),
        child: Text(
          appLocalizations.productDataUtility,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: LARGE_SPACE,
          start: LARGE_SPACE,
          end: LARGE_SPACE,
        ),
        child: SummaryCard(
          widget.product,
          productPreferences,
          isFullVersion: true,
          isRemovable: false,
          isSettingVisible: false,
          isProductEditable: false,
          isPictureVisible: false,
        ),
      ),
    ];
    pageData.addAll(
      UserPreferencesFood(
        productPreferences: productPreferences,
        context: context,
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: Theme.of(context),
      ).getOnboardingContent(),
    );
    return ColoredBox(
      color: widget.backgroundColor,
      child: SafeArea(
        bottom: Platform.isAndroid,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
                  itemCount: pageData.length,
                  itemBuilder: (BuildContext context, int position) =>
                      pageData[position],
                ),
              ),
            ),
            NextButton(
              OnboardingPage.PREFERENCES_PAGE,
              backgroundColor: widget.backgroundColor,
              nextKey: const Key('nextAfterPreferences'),
            ),
          ],
        ),
      ),
    );
  }
}
