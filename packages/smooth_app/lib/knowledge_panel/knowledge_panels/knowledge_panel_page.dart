import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
    with TraceableClientMixin {
  @override
  String get traceTitle => 'knowledge_panel_page';

  @override
  String get traceName => 'Opened full knowledge panel page';

  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_initialProduct.barcode!);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_initialProduct.barcode!);
    super.dispose();
  }

  static KnowledgePanelPanelGroupElement? _groupElementOf(
      BuildContext context) {
    try {
      return Provider.of<KnowledgePanelPanelGroupElement>(context);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(),
          maxLines: 2,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProduct(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SmoothCard(
            padding: const EdgeInsets.all(
              SMALL_SPACE,
            ),
            child: KnowledgePanelExpandedCard(
              panelId: widget.panelId,
              product: _product,
              isInitiallyExpanded: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    try {
      final String barcode = InheritedDataManager.of(context).currentBarcode;
      if (barcode.isEmpty) {
        return;
      }
      await ProductRefresher().fetchAndRefresh(
        barcode: barcode,
        widget: this,
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
    final KnowledgePanel? panel =
        KnowledgePanelWidget.getKnowledgePanel(_product, widget.panelId);
    if (panel?.titleElement?.title.isNotEmpty == true) {
      return (panel?.titleElement?.title)!;
    }
    return '';
  }
}
