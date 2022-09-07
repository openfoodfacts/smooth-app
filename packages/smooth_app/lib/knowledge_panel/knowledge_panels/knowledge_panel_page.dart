import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
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
  String get traceName => 'Opened full knowledge panel page ${_getTitle()}';

  late Product _product;

  @override
  void initState() {
    _product = widget.product;
    super.initState();
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
  Widget build(BuildContext context) => Consumer<UpToDateProductProvider>(
        builder: (
          final BuildContext context,
          final UpToDateProductProvider provider,
          final Widget? child,
        ) {
          final Product? refreshedProduct = provider.get(_product);
          if (refreshedProduct != null) {
            _product = refreshedProduct;
          }
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
        },
      );

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
              duration: SnackBarDuration.short,
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

  String _getTitle() {
    final KnowledgePanelPanelGroupElement? groupElement =
        _groupElementOf(context);
    if (groupElement?.title.isNotEmpty == true) {
      return groupElement!.title;
    }
    final KnowledgePanel? panel =
        KnowledgePanelWidget.getKnowledgePanel(_product, widget.panelId);
    if (panel?.titleElement?.title.isNotEmpty == true) {
      return (panel?.titleElement?.title)!;
    }
    return '';
  }
}
