import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_product_cards.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/onboarding/common/tooltip_shape_border.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class KnowledgePanelPageTemplate extends StatefulWidget {
  const KnowledgePanelPageTemplate({
    required this.headerTitle,
    required this.page,
    required this.panelId,
    required this.localDatabase,
    required this.backgroundColor,
    required this.svgAsset,
    required this.nextKey,
    this.selectableText = false,
  });

  final String headerTitle;
  final OnboardingPage page;

  /// We will only display this panel
  final String panelId;

  final LocalDatabase localDatabase;
  final Color backgroundColor;
  final String svgAsset;
  final Key nextKey;

  final bool selectableText;

  @override
  State<KnowledgePanelPageTemplate> createState() =>
      _KnowledgePanelPageTemplateState();
}

class _KnowledgePanelPageTemplateState
    extends State<KnowledgePanelPageTemplate> {
  late Future<void> _initFuture;
  bool _isHintDismissed = false;
  late final AppLocalizations appLocalizations = AppLocalizations.of(context);
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    _product = await OnboardingDataProduct.forProduct(widget.localDatabase)
        .getData(rootBundle);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);
            return Text(
              appLocalizations
                  .knowledge_panel_page_loading_error(snapshot.error),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final List<Widget> children = KnowledgePanelsBuilder.getChildren(
            context,
            panelElement: KnowledgePanelsBuilder.getRootPanelElement(
              _product,
              widget.panelId,
            )!,
            product: _product,
            onboardingMode: true,
          );
          return ColoredBox(
            color: widget.backgroundColor,
            child: SafeArea(
              bottom: Platform.isAndroid,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SvgPicture.asset(
                                widget.svgAsset,
                                height: MediaQuery.sizeOf(context).height * .25,
                                package: AppHelper.APP_PACKAGE,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: LARGE_SPACE,
                                ),
                                child: Text(
                                  widget.headerTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.wellSpaced,
                                ),
                              ),
                              if (children.isNotEmpty)
                                KnowledgePanelProductCards(
                                  <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: children,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      NextButton(
                        widget.page,
                        backgroundColor: widget.backgroundColor,
                        nextKey: widget.nextKey,
                      ),
                    ],
                  ),
                  ..._buildHintPopup(),
                ],
              ),
            ),
          );
        },
      );

  List<Widget> _buildHintPopup() {
    final Widget hintPopup = InkWell(
      key: const Key('toolTipPopUp'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).hintColor.withValues(alpha: 0.9),
        shape: const TooltipShapeBorder(arrowArc: 0.5),
        child: Container(
          margin: const EdgeInsetsDirectional.only(
            start: VERY_LARGE_SPACE,
            top: 10,
            end: 10,
            bottom: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  appLocalizations.hint_knowledge_panel_message,
                  style: TextStyle(color: Theme.of(context).cardColor),
                ),
              ),
              const SizedBox(width: VERY_LARGE_SPACE),
              Icon(
                Icons.close,
                color: Theme.of(context).cardColor,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _isHintDismissed = true;
        });
      },
    );
    final List<Widget> hitPopup = <Widget>[];
    if (!_isHintDismissed &&
        !OnboardingFlowNavigator.isOnboardingPagedInHistory(
            OnboardingPage.HEALTH_CARD_EXAMPLE) &&
        !OnboardingFlowNavigator.isOnboardingPagedInHistory(
            OnboardingPage.ECO_CARD_EXAMPLE)) {
      hitPopup.add(
        Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                // slightly lower than bottom bar top
                bottom: 2 * VERY_LARGE_SPACE +
                    MINIMUM_TOUCH_SIZE -
                    .5 * VERY_LARGE_SPACE,
              ),
              child: hintPopup,
            ),
          ),
        ),
      );
    }
    return hitPopup;
  }
}
