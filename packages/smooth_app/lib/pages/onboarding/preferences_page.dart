import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/user_preferences_food.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this._localDatabase) : super();

  final LocalDatabase _localDatabase;

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

  Future<dynamic> _init() async => _product =
      await OnboardingDataProduct(widget._localDatabase).getData(rootBundle);

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Helper(_product);
        },
      );
}

// In order to avoid to reload the product when refreshing the preferences.
class _Helper extends StatefulWidget {
  const _Helper(this.product);

  final Product product;

  @override
  State<_Helper> createState() => _HelperState();
}

class _HelperState extends State<_Helper> {
  bool _isProductExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<Widget> pageData = <Widget>[
      Padding(
        padding: const EdgeInsets.only(
          right: LARGE_SPACE,
          left: LARGE_SPACE,
          bottom: LARGE_SPACE,
        ),
        child: Text(
          appLocalizations.productDataUtility,
          style: Theme.of(context).textTheme.displayMedium,
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
            widget.product,
            productPreferences,
            isFullVersion: _isProductExpanded,
          ),
        ),
      ),
    ];
    pageData.addAll(
      UserPreferencesFood(
        productPreferences: productPreferences,
        setState: setState,
        context: context,
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: Theme.of(context),
      ).getContent(),
    );
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
          const Align(
            alignment: Alignment.bottomCenter,
            child: NextButton(OnboardingPage.PREFERENCES_PAGE),
          ),
        ],
      ),
    );
  }

  void _expandProductCard() {
    if (!_isProductExpanded) {
      setState(() => _isProductExpanded = true);
    }
  }
}
