import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class SampleProductPage extends StatefulWidget {
  @override
  State<SampleProductPage> createState() => _SampleProductPageState();
}

class _SampleProductPageState extends State<SampleProductPage> {
  late Future<void> _initFuture;
  late ProductPreferences _productPreferences;
  late Product _product;
  late KnowledgePanels _knowledgePanels;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<dynamic> _init() async {
    _productPreferences = context.read<ProductPreferences>();

    // Load Product
    final String productResponse = await rootBundle
        .loadString('assets/onboarding/sample_product_data.json');
    final Map<String, dynamic> productData =
        jsonDecode(productResponse) as Map<String, dynamic>;
    _product = Product.fromJson(productData['product'] as Map<String, dynamic>);

    // Load KnowledgePanels
    final String kpResponse = await rootBundle
        .loadString('assets/onboarding/sample_product_knowledge_panels.json');
    final Map<String, dynamic> kpData =
        jsonDecode(kpResponse) as Map<String, dynamic>;
    final Map<String, dynamic> kpDataProduct =
        kpData['product'] as Map<String, dynamic>;
    _knowledgePanels = KnowledgePanels.fromJson(
        kpDataProduct['knowledge_panels'] as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(context.read<ThemeProvider>());
    return FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          final List<Widget> knowledgePanelWidgets =
              const KnowledgePanelsBuilder().build(_knowledgePanels);
          return Scaffold(
            body: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.all(LARGE_SPACE),
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: LARGE_SPACE,
                        right: LARGE_SPACE,
                        bottom: LARGE_SPACE,
                      ),
                      child: Text(
                        appLocalizations.productDataUtility,
                        style: Theme.of(context).textTheme.headline2!.apply(
                              color: Colors.black,
                            ),
                      ),
                    ),
                    SummaryCard(_product, _productPreferences,
                        isFullVersion: true),
                    KnowledgePanelProductCards(knowledgePanelWidgets),
                  ],
                ),
                const Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NextButton(OnboardingPage.PRODUCT_EXAMPLE),
                  ),
                ),
              ],
            ),
            backgroundColor: SmoothTheme.getColor(
              Theme.of(context).colorScheme,
              materialColor,
              ColorDestination.SURFACE_BACKGROUND,
            ),
          );
        });
  }
}
