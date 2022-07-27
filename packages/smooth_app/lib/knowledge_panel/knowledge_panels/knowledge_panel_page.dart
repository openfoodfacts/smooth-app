import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class KnowledgePanelPage extends StatefulWidget {
  const KnowledgePanelPage({
    required this.panel,
    required this.allPanels,
    required this.product,
    this.groupElement,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;
  final Product product;
  final KnowledgePanelPanelGroupElement? groupElement;

  @override
  State<KnowledgePanelPage> createState() => _KnowledgePanelPageState();
}

class _KnowledgePanelPageState extends State<KnowledgePanelPage>
    with TraceableClientMixin {
  @override
  String get traceTitle => 'knowledge_panel_page';

  @override
  String get traceName => 'Opened full knowledge panel page $_title';

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(
          _title,
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
              panel: widget.panel,
              allPanels: widget.allPanels,
              product: widget.product,
              isInitiallyExpanded: true,
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    if (widget.groupElement?.title.isNotEmpty == true) {
      return widget.groupElement!.title;
    } else if (widget.panel.titleElement?.title.isNotEmpty == true) {
      return widget.panel.titleElement!.title;
    } else {
      return '';
    }
  }

  Future<bool> _refreshProduct(BuildContext context) async {
    try {
      if (InheritedDataManager.of(context).currentBarcode.isNotEmpty) {
        final LocalDatabase localDatabase = context.read<LocalDatabase>();
        final bool result = await ProductRefresher().fetchAndRefresh(
          context: context,
          localDatabase: localDatabase,
          barcode: InheritedDataManager.of(context).currentBarcode,
        );
        if (mounted && result) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.product_refreshed),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return result;
      } else {
        return false;
      }
    } catch (e) {
      //no refreshing during onboarding
      return false;
    }
  }
}
