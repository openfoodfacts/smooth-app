import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/data_models/onboarding_data_knowledge_panels.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelPageTemplate extends StatefulWidget {
  const KnowledgePanelPageTemplate({
    required this.headerTitle,
    required this.page,
    required this.panelId,
    required this.localDatabase,
  });

  final String headerTitle;
  final OnboardingPage page;

  /// We will only display this panel
  final String panelId;

  final LocalDatabase localDatabase;

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

  Future<dynamic> _init() async => _knowledgePanels =
      await OnboardingDataKnowledgePanels(widget.localDatabase)
          .getData(rootBundle);

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
            return const Center(child: CircularProgressIndicator());
          }
          final Widget knowledgePanelWidget =
              const KnowledgePanelsBuilder().buildSingle(
            _knowledgePanels,
            widget.panelId,
          )!;
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
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    KnowledgePanelProductCards(<Widget>[knowledgePanelWidget]),
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
