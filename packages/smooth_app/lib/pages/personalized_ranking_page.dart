import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/personalized_search/matched_product_v2.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/personalized_ranking_model.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/tmp_matched_product_v2.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PersonalizedRankingPage extends StatefulWidget {
  const PersonalizedRankingPage({
    required this.barcodes,
    required this.title,
  });

  final List<String> barcodes;
  final String title;

  @override
  State<PersonalizedRankingPage> createState() =>
      _PersonalizedRankingPageState();
}

class _PersonalizedRankingPageState extends State<PersonalizedRankingPage>
    with TraceableClientMixin {
  @override
  String get traceName => 'Opened personalized ranking page'; // optional

  @override
  String get traceTitle => 'personalized_ranking_page';

  static const int _backgroundAlpha = 51;

  late final PersonalizedRankingModel _model;

  List<String>? _compactPreferences;

  @override
  void initState() {
    super.initState();
    _model = PersonalizedRankingModel(widget.barcodes);
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Consumer<UpToDateProductProvider>(
      builder: (
        final BuildContext context,
        final UpToDateProductProvider upToDateProductProvider,
        final Widget? child,
      ) =>
          SmoothScaffold(
        appBar: AppBar(
          title: Text(widget.title, overflow: TextOverflow.fade),
        ),
        body: ChangeNotifierProvider<PersonalizedRankingModel>(
          create: (final BuildContext context) => _model,
          builder: (final BuildContext context, final Widget? wtf) {
            context.watch<PersonalizedRankingModel>();
            final List<String> compactPreferences =
                productPreferences.getCompactView();
            if (_compactPreferences == null) {
              _compactPreferences = compactPreferences;
              _model.refresh(context.read<LocalDatabase>(), productPreferences);
            } else {
              bool refresh = !_compactPreferences!.equals(compactPreferences);
              if (!refresh) {
                refresh = _model.needsRefresh(upToDateProductProvider);
              }
              if (refresh) {
                // TODO(monsieurtanuki): could maybe be automatic with VisibilityDetector
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SMALL_SPACE),
                    child: SmoothLargeButtonWithIcon(
                      icon: Icons.refresh,
                      text: appLocalizations.refresh_with_new_preferences,
                      onPressed: () {
                        _compactPreferences = compactPreferences;
                        _model.refresh(
                            context.read<LocalDatabase>(), productPreferences);
                      },
                    ),
                  ),
                );
              }
            }
            if (_model.loadingStatus == LoadingStatus.LOADING) {
              return Center(
                child: CircularProgressIndicator(
                  value: _model.getLoadingProgress() ?? 1,
                ),
              );
            }
            if (_model.loadingStatus != LoadingStatus.LOADED) {
              return const Center(child: CircularProgressIndicator());
            }
            AnalyticsHelper.trackPersonalizedRanking(widget.barcodes.length);
            MatchedProductStatusV2? status;
            final List<_VirtualItem> list = <_VirtualItem>[];
            for (final MatchedScoreV2 score in _model.scores) {
              if (status == null || status != score.status) {
                status = score.status;
                list.add(_VirtualItem.status(status));
              }
              list.add(_VirtualItem.score(score));
            }
            final bool darkMode =
                Theme.of(context).brightness == Brightness.dark;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) => _buildItem(
                list[index],
                appLocalizations,
                darkMode,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(
    final _VirtualItem item,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) =>
      item.status != null
          ? _buildHeader(
              item.status!,
              appLocalizations,
              darkMode,
            )
          : _buildSmoothProductCard(
              item.score!,
              appLocalizations,
              darkMode,
            );

  Widget _buildHeader(
    final MatchedProductStatusV2 status,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) {
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.status(status);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Text(
          helper.getHeaderText(appLocalizations),
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    );
  }

  Widget _buildSmoothProductCard(
    final MatchedScoreV2 matchedProduct,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) =>
      Dismissible(
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.symmetric(vertical: 14),
          color: RED_COLOR,
          padding: const EdgeInsetsDirectional.only(end: 30),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        key: Key(matchedProduct.barcode),
        onDismissed: (final DismissDirection direction) {
          _model.dismiss(matchedProduct.barcode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.product_removed_comparison),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MEDIUM_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: ProductListItemSimple(
            barcode: matchedProduct.barcode,
            backgroundColor:
                ProductCompatibilityHelper.status(matchedProduct.status)
                    .getHeaderBackgroundColor(darkMode)
                    .withAlpha(_backgroundAlpha),
          ),
        ),
      );
}

/// Virtual item in the list: either a product or a status header
class _VirtualItem {
  const _VirtualItem.score(this.score) : status = null;
  const _VirtualItem.status(this.status) : score = null;
  final MatchedScoreV2? score;
  final MatchedProductStatusV2? status;
}
