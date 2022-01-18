import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelPageTemplate extends StatefulWidget {
  const KnowledgePanelPageTemplate({
    required this.assetFile,
    required this.headerTitle,
    required this.page,
  });

  final String assetFile;
  final String headerTitle;
  final OnboardingPage page;

  @override
  State<KnowledgePanelPageTemplate> createState() =>
      _KnowledgePanelPageTemplateState();
}

class _KnowledgePanelPageTemplateState
    extends State<KnowledgePanelPageTemplate> {
  late Future<void> _initFuture;
  late KnowledgePanels _knowledgePanels;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<dynamic> _init() async {
    // Load KnowledgePanels
    final String kpResponse = await rootBundle.loadString(widget.assetFile);
    final Map<String, dynamic> kpData =
        jsonDecode(kpResponse) as Map<String, dynamic>;
    final Map<String, dynamic> kpDataProduct =
        kpData['product'] as Map<String, dynamic>;
    _knowledgePanels = KnowledgePanels.fromJson(
        kpDataProduct['knowledge_panels'] as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
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
                  // bottom padding is very large because [NextButton] is stacked on top of the page.
                  padding: const EdgeInsets.only(
                    top: LARGE_SPACE,
                    right: LARGE_SPACE,
                    left: LARGE_SPACE,
                    bottom: VERY_LARGE_SPACE * 5,
                  ),
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LARGE_SPACE,
                      ),
                      child: Text(
                        widget.headerTitle,
                        style: Theme.of(context).textTheme.headline2!.apply(
                              color: Colors.black,
                            ),
                      ),
                    ),
                    KnowledgePanelProductCards(knowledgePanelWidgets),
                  ],
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NextButton(widget.page),
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
