import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page_loader.dart';
import 'package:smooth_app/pages/product/portion_calculator.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Detail page of knowledge panels (if you click on the forward/more button).
class KnowledgePanelPage extends StatefulWidget {
  const KnowledgePanelPage({
    required this.panelId,
    required this.product,
  });

  final String panelId;
  final Product product;

  @override
  State<KnowledgePanelPage> createState() => _KnowledgePanelPageState();
}

class _KnowledgePanelPageState extends State<KnowledgePanelPage>
    with TraceableClientMixin, UpToDateMixin {
  @override
  String get actionName => 'Opened full knowledge panel page';

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  static KnowledgePanelPanelGroupElement? _groupElementOf(
    BuildContext context,
  ) {
    try {
      return Provider.of<KnowledgePanelPanelGroupElement>(context);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String title = _getTitle();

    context.watch<LocalDatabase>();
    refreshUpToDate();
    return Provider<Product>.value(
      value: upToDateProduct,
      child: SmoothScaffold(
        backgroundColor: context.lightTheme()
            ? context.extension<SmoothColorsThemeExtension>().primaryLight
            : null,
        appBar: SmoothAppBar(
          title: Semantics(
            label: _getTitleForAccessibility(appLocalizations, title),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subTitle: Text(
            getProductNameAndBrands(upToDateProduct, appLocalizations),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: _actions(),
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshProduct(context),
          child: Scrollbar(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsetsDirectional.only(
                top: SMALL_SPACE,
                start: VERY_SMALL_SPACE,
                end: VERY_SMALL_SPACE,
                bottom: SMALL_SPACE + MediaQuery.viewPaddingOf(context).bottom,
              ),
              children: <Widget>[
                SmoothCard(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: LARGE_SPACE,
                  ),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 15.0, height: 1.5),
                    child: KnowledgePanelExpandedCard(
                      panelId: widget.panelId,
                      product: upToDateProduct,
                      isInitiallyExpanded: true,
                      isClickable: true,
                    ),
                  ),
                ),
                if (PortionCalculator.isVisible(widget.panelId))
                  SmoothCard(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: LARGE_SPACE,
                    ),
                    child: PortionCalculator(upToDateProduct),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    try {
      final String? barcode = upToDateProduct.barcode;

      if (barcode?.isEmpty == true) {
        return;
      }
      await ProductRefresher().fetchAndRefresh(
        barcode: barcode ?? '',
        context: context,
      );
    } catch (e) {
      //no refreshing during onboarding
    }
  }

  String _getTitle() {
    final KnowledgePanelPanelGroupElement? groupElement =
        _groupElementOf(context);
    if (groupElement?.title != null &&
        groupElement?.title!.isNotEmpty == true) {
      return groupElement!.title!;
    }
    final KnowledgePanel? panel = KnowledgePanelsBuilder.getKnowledgePanel(
      upToDateProduct,
      widget.panelId,
    );
    if (panel?.titleElement?.title.isNotEmpty == true) {
      return (panel?.titleElement?.title)!;
    }
    return '';
  }

  String _getTitleForAccessibility(
    AppLocalizations appLocalizations,
    String title,
  ) {
    final String productName = upToDateProduct.productName ??
        upToDateProduct.abbreviatedName ??
        upToDateProduct.genericName ??
        '';
    if (title.isEmpty) {
      return appLocalizations.knowledge_panel_page_title_no_title(productName);
    } else {
      return appLocalizations.knowledge_panel_page_title(
        title,
        productName,
      );
    }
  }

  List<Widget>? _actions() {
    if (<String>['ingredients', 'ingredients_analysis_details']
        .contains(widget.panelId)) {
      return <Widget>[
        _KnowledgePanelPageEditAction(
          tooltip: AppLocalizations.of(context).ingredients_editing_title,
          onPressed: () async => ProductFieldOcrIngredientEditor().edit(
            context: context,
            product: upToDateProduct,
          ),
        ),
      ];
    } else if (widget.panelId == 'nutrition_facts_table') {
      return <Widget>[
        _KnowledgePanelPageEditAction(
          tooltip: AppLocalizations.of(context).nutrition_facts_editing_title,
          onPressed: () async => NutritionPageLoader.showNutritionPage(
            product: upToDateProduct,
            isLoggedInMandatory: true,
            context: context,
          ),
        ),
      ];
    } else if (<String>[
      'origins_of_ingredients',
      'environmental_score_origins_of_ingredients'
    ].contains(widget.panelId)) {
      return <Widget>[
        _KnowledgePanelPageEditAction(
          tooltip: AppLocalizations.of(context).origins_editing_title,
          onPressed: () async =>
              ProductFieldSimpleEditor(SimpleInputPageOriginHelper()).edit(
            context: context,
            product: upToDateProduct,
          ),
        ),
      ];
    } else if (widget.panelId == 'environmental_score_packaging') {
      return <Widget>[
        _KnowledgePanelPageEditAction(
          tooltip: AppLocalizations.of(context).origins_editing_title,
          onPressed: () async => ProductFieldPackagingEditor().edit(
            context: context,
            product: upToDateProduct,
          ),
        ),
      ];
    }

    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('panelId', widget.panelId));
  }
}

class _KnowledgePanelPageEditAction extends StatelessWidget {
  const _KnowledgePanelPageEditAction({
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SmoothPopupMenuButton<void>(
        buttonIcon: const Icon(Icons.more_vert),
        onSelected: (_) => onPressed(),
        itemBuilder: (BuildContext context) {
          return <SmoothPopupMenuItem<void>>[
            SmoothPopupMenuItem<void>(
              label: tooltip,
              value: null,
              icon: Icons.edit,
            ),
          ];
        });
  }
}
