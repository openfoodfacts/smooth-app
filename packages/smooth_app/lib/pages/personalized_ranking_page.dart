import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/personalized_ranking_model.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
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
  String get actionName => 'Opened personalized ranking page';

  static const int _backgroundAlpha = 51;

  late final PersonalizedRankingModel _model;

  List<String>? _compactPreferences;

  @override
  void initState() {
    super.initState();
    _model = PersonalizedRankingModel(
      widget.barcodes,
      context.read<LocalDatabase>(),
    );
  }

  Future<void> _addToLists(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final bool? added = await ProductListUserDialogHelper(daoProductList)
        .showUserAddProductsDialog(
      context,
      widget.barcodes.toSet(),
    );
    if (!context.mounted) {
      return;
    }
    if (added != null && added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar(
          content: Text(
            appLocalizations.added_to_list_msg,
          ),
          duration: SnackBarDuration.medium,
        ),
      );
    }
  }

  Future<void> _handlePopUpClick(String value) async {
    switch (value) {
      case 'add_to_list':
        await _addToLists(context);
        break;
      default:
        throw Exception('Unknown case $value');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(widget.title, overflow: TextOverflow.fade),
        actions: <Widget>[
          SmoothPopupMenuButton<String>(
            onSelected: _handlePopUpClick,
            itemBuilder: (BuildContext context) {
              return <SmoothPopupMenuItem<String>>[
                SmoothPopupMenuItem<String>(
                  value: 'add_to_list',
                  label: appLocalizations.user_list_button_add_product,
                  icon: const AddToList.symbol().icon,
                ),
              ];
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider<PersonalizedRankingModel>(
        create: (final BuildContext context) => _model,
        builder: (final BuildContext context, final Widget? wtf) {
          context.watch<PersonalizedRankingModel>();
          final List<String> compactPreferences =
              productPreferences.getCompactView();
          if (_compactPreferences == null) {
            _compactPreferences = compactPreferences;
            _model.refresh(productPreferences);
          } else {
            bool refresh = !_compactPreferences!.equals(compactPreferences);
            if (!refresh) {
              refresh = _model.needsRefresh();
            }
            if (refresh) {
              // TODO(monsieurtanuki): could maybe be automatic with VisibilityDetector
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: SmoothLargeButtonWithIcon(
                    leadingIcon: const Icon(Icons.refresh),
                    text: appLocalizations.refresh_with_new_preferences,
                    onPressed: () {
                      _compactPreferences = compactPreferences;
                      _model.refresh(productPreferences);
                    },
                  ),
                ),
              );
            }
          }
          if (_model.loadingStatus == LoadingStatus.LOADING) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                value: _model.getLoadingProgress() ?? 1,
              ),
            );
          }
          if (_model.loadingStatus != LoadingStatus.LOADED) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          MatchedProductStatusV2? status;
          final List<_VirtualItem> list = <_VirtualItem>[];
          for (final MatchedScoreV2 score in _model.scores) {
            if (status == null || status != score.status) {
              status = score.status;
              list.add(_VirtualItem.status(status));
            }
            list.add(_VirtualItem.score(score));
          }
          final bool darkMode = Theme.of(context).brightness == Brightness.dark;
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
    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: helper.getColor(context),
        child: Padding(
          padding: const EdgeInsets.all(MEDIUM_SPACE),
          child: Text(
            helper.getHeaderText(appLocalizations),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                  color: Colors.white,
                ),
          ),
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
          alignment: AlignmentDirectional.centerEnd,
          color: RED_COLOR,
          padding: const EdgeInsetsDirectional.only(end: 30.0),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        key: Key(matchedProduct.barcode),
        onDismissed: (final DismissDirection direction) {
          _model.dismiss(matchedProduct.barcode);
          ScaffoldMessenger.of(context).showSnackBar(
            SmoothFloatingSnackbar(
              content: Text(appLocalizations.product_removed_comparison),
              duration: SnackBarDuration.medium,
            ),
          );
        },
        child: ProductListItemSimple(
          barcode: matchedProduct.barcode,
          backgroundColor:
              ProductCompatibilityHelper.status(matchedProduct.status)
                  .getColor(context)
                  .withAlpha(_backgroundAlpha),
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
