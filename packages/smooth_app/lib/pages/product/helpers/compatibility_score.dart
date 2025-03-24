import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/product_incomplete_card.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const List<String> _ATTRIBUTE_IDS = <String>[
  // Nutritional quality
  Attribute.ATTRIBUTE_NUTRISCORE,
  Attribute.ATTRIBUTE_LOW_SALT,
  Attribute.ATTRIBUTE_LOW_SUGARS,
  Attribute.ATTRIBUTE_LOW_FAT,
  Attribute.ATTRIBUTE_LOW_SATURATED_FAT,
  // Ingredients
  Attribute.ATTRIBUTE_VEGAN,
  Attribute.ATTRIBUTE_VEGETARIAN,
  Attribute.ATTRIBUTE_PALM_OIL_FREE,
  // Environment
  Attribute.ATTRIBUTE_ECOSCORE,
  Attribute.ATTRIBUTE_FOREST_FOOTPRINT,
  // Food processing
  Attribute.ATTRIBUTE_NOVA,
  Attribute.ATTRIBUTE_ADDITIVES,
  // Labels
  Attribute.ATTRIBUTE_LABELS_ORGANIC,
  Attribute.ATTRIBUTE_LABELS_FAIR_TRADE,
  // Allergens
  Attribute.ATTRIBUTE_ALLERGENS_NO_GLUTEN,
  Attribute.ATTRIBUTE_ALLERGENS_NO_MILK,
  Attribute.ATTRIBUTE_ALLERGENS_NO_EGGS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_NUTS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_PEANUTS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_SESAME_SEEDS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_SOYBEANS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_CELERY,
  Attribute.ATTRIBUTE_ALLERGENS_NO_MUSTARD,
  Attribute.ATTRIBUTE_ALLERGENS_NO_LUPIN,
  Attribute.ATTRIBUTE_ALLERGENS_NO_FISH,
  Attribute.ATTRIBUTE_ALLERGENS_NO_CRUSTACEANS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_MOLLUSCS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_MOLLUSCS,
  Attribute.ATTRIBUTE_ALLERGENS_NO_SULPHUR_DIOXIDE_AND_SULPHITES,
];

class CompatibilityScore extends StatefulWidget {
  const CompatibilityScore(
    this._product, {
    required this.compatibility,
    this.progress = 0.0,
    this.maxWidth = 100.0,
  });

  final ProductPageCompatibility compatibility;
  final double progress;
  final double maxWidth;
  final Product _product;

  @override
  State<CompatibilityScore> createState() => _CompatibilityScoreState();
}

class _CompatibilityScoreState extends State<CompatibilityScore>
    with UpToDateMixin {
  bool _sortByImportance = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initUpToDate(widget._product, context.read<LocalDatabase>());
    if (ProductIncompleteCard.isProductIncomplete(upToDateProduct)) {
      AnalyticsHelper.trackProductEvent(
        AnalyticsEvent.showFastTrackProductEditCard,
        product: widget._product,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    refreshUpToDate();
    return InkWell(
      child: ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: _getScoreWidget(context),
      ),
      onTap: () {
        _showCompatibilityScoreSheet(context);
      },
    );
  }

  void _showCompatibilityScoreSheet(BuildContext context) {
    showSmoothModalSheet(
        context: context,
        isScrollControlled: false,
        builder: (BuildContext lContext) => StatefulBuilder(
                builder: (BuildContext rContext, StateSetter setModalState) {
              final UserPreferences userPreferences =
                  context.read<UserPreferences>();

              final Map<String, List<Map<String, dynamic>>> importanceGrouped =
                  <String, List<Map<String, dynamic>>>{
                'mandatory': <Map<String, dynamic>>[],
                'very_important': <Map<String, dynamic>>[],
                'important': <Map<String, dynamic>>[],
                'not_important': <Map<String, dynamic>>[],
              };

              final Map<String, List<Map<String, dynamic>>> scoreGrouped =
                  <String, List<Map<String, dynamic>>>{
                'positive': <Map<String, dynamic>>[],
                'negative': <Map<String, dynamic>>[],
              };

              final Map<String, int> importanceOrder = <String, int>{
                'mandatory': 4,
                'very_important': 3,
                'important': 2,
                'not_important': 1,
              };

              for (final String attributeID in _ATTRIBUTE_IDS) {
                final Attribute attribute =
                    widget._product.getAttribute(attributeID) ?? Attribute();

                if (attribute.status == 'unknown') {
                  continue;
                }

                final String importance =
                    userPreferences.getImportance(attributeID);
                final double score = attribute.match ?? 0.0;

                final Map<String, dynamic> attributeData = <String, dynamic>{
                  'attribute': attribute,
                  'score': score
                };

                if (importanceGrouped.containsKey(importance)) {
                  importanceGrouped[importance]!.add(attributeData);
                }

                if (score >= 50) {
                  scoreGrouped['positive']!.add(attributeData);
                } else {
                  scoreGrouped['negative']!.add(attributeData);
                }
              }

              List<MapEntry<String, List<Map<String, dynamic>>>> sortedGroups;

              if (_sortByImportance) {
                sortedGroups = importanceGrouped.entries.toList();
                sortedGroups.sort((MapEntry<String, List<Map<String, dynamic>>>
                            a,
                        MapEntry<String, List<Map<String, dynamic>>> b) =>
                    importanceOrder[b.key]!.compareTo(importanceOrder[a.key]!));
              } else {
                sortedGroups = scoreGrouped.entries.toList();
              }

              for (final MapEntry<String, List<Map<String, dynamic>>> group
                  in sortedGroups) {
                group.value.sort(
                    (Map<String, dynamic> a, Map<String, dynamic> b) =>
                        (b['score'] as double).compareTo(a['score']));
              }
              return SmoothModalSheet(
                title: AppLocalizations.of(context)
                    .compatibility_score_modal_title,
                prefixIndicator: true,
                bodyPadding: EdgeInsets.zero,
                suffix: SmoothModalSheetHeaderButton(
                  backgroundColor: widget.compatibility.color ?? GREY_COLOR,
                  foregroundColor: WHITE_COLOR,
                  label:
                      '${widget.compatibility.score ?? AppLocalizations.of(context).not_applicable_short}%',
                ),
                body: SizedBox(
                  height: 500,
                  child: SmoothScaffold(
                    contentBehindStatusBar: true,
                    spaceBehindStatusBar: false,
                    changeStatusBarBrightness: false,
                    statusBarBackgroundColor: Colors.transparent,
                    body: SmoothModalSheetBodyContainer(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: <Widget>[
                            ...sortedGroups.map(
                              (MapEntry<String, List<Map<String, dynamic>>>
                                  entry) {
                                final String groupTitle =
                                    _getGroupTitle(entry.key);
                                return entry.value.isEmpty
                                    ? const SizedBox.shrink()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          _groupTitle(groupTitle),
                                          const SizedBox(height: SMALL_SPACE),
                                          ...entry.value.map(
                                            (Map<String, dynamic> item) =>
                                                _buildAttributeItem(
                                              context,
                                              item['attribute'] as Attribute,
                                              item['score'] as double,
                                            ),
                                          ),
                                          const SizedBox(height: MEDIUM_SPACE),
                                        ],
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar:
                        _getCompatibitlityFooter(setModalState),
                  ),
                ),
              );
            }));
  }

  String _getGroupTitle(String groupKey) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    switch (groupKey) {
      case 'mandatory':
        return appLocalizations.attribute_preference_mandatory;
      case 'very_important':
        return appLocalizations.attribute_preference_very_important;
      case 'important':
        return appLocalizations.attribute_preference_important;
      case 'not_important':
        return appLocalizations.attribute_preference_not_important;
      case 'positive':
        return appLocalizations.attribute_score_positive;
      case 'negative':
        return appLocalizations.attribute_score_negative;
      default:
        return appLocalizations.attribute_other;
    }
  }

  Widget _buildAttributeItem(
      BuildContext context, Attribute attribute, double score) {
    final Widget attributeIcon = getAttributeDisplayIcon(attribute);

    return Padding(
        padding: const EdgeInsets.only(bottom: SMALL_SPACE),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: InkWell(
                borderRadius: ANGULAR_BORDER_RADIUS,
                onTap: () {
                  _openFullKnowledgePanel(attribute: attribute);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
                    child: Row(
                      children: <Widget>[
                        if (attribute.name!.endsWith('Score'))
                          SvgIconChip(attribute.iconUrl ?? '', height: 30.0)
                        else
                          attributeIcon,
                        const SizedBox(width: SMALL_SPACE),
                        Expanded(
                          child: Text(attribute.descriptionShort ??
                              attribute.title ??
                              ''),
                        ),
                        if (attribute.panelId != null)
                          const icons.Chevron.right(
                            color: Colors.black,
                            size: 12.0,
                          )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _getCompatibitlityFooter(StateSetter setModalState) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Container(
      color: lightTheme
          ? themeExtension.primaryLight
          : themeExtension.primarySemiDark,
      child: SafeArea(
        child: IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: lightTheme
                  ? themeExtension.primaryLight
                  : themeExtension.primarySemiDark,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MEDIUM_SPACE),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: <Widget>[
                        _getCompatibilityFooterButton(
                          _sortByImportance
                              ? AppLocalizations.of(context).sort_by_score
                              : AppLocalizations.of(context).sort_by_importance,
                          const icons.Clear(),
                          () {
                            setModalState(() {
                              setState(() {
                                _sortByImportance = !_sortByImportance;
                                _scrollController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                            });
                          },
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  _getCompatibilityFooterButton(
                    null,
                    const icons.Personalization(),
                    () => AppNavigator.of(context).push(
                      AppRoutes.PREFERENCES(PreferencePageType.FOOD),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScoreWidget(
    BuildContext context,
  ) {
    final String compatibilityLabel =
        AppLocalizations.of(context).product_page_compatibility_score;

    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: widget.progress,
            child: Container(
              width: widget.maxWidth * widget.progress,
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsetsDirectional.only(start: 2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: Radius.circular(18.0),
                ),
              ),
              child: Transform.translate(
                offset: Offset((1 - widget.progress) * 10, 0.0),
                child: SizedBox(
                  child: icons.Info(
                    color: widget.compatibility.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 6.0,
                bottom: SMALL_SPACE,
                start: 6.0,
                end: 6.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${widget.compatibility.score}%',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 12.0,
                      height: 0.9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compatibilityLabel,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        height: 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCompatibilityFooterButton(
      String? label, Widget icon, VoidCallback? onTap) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();
    final Color contentColor =
        lightTheme ? themeExtension.primaryBlack : Colors.white;
    final Color foregroundColor = contentColor;

    final Widget child = IconTheme(
      data: IconThemeData(
        color: foregroundColor,
        size: 18.0,
      ),
      child: icon,
    );

    return Semantics(
      label: label,
      excludeSemantics: true,
      button: true,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            side: BorderSide(width: 0.5, color: foregroundColor),
            foregroundColor: foregroundColor,
            backgroundColor: Colors.white),
        child: label == null
            ? child
            : Row(
                children: <Widget>[
                  child,
                  const SizedBox(width: 8.0),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _groupTitle(String groupTitle) {
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
      child: Semantics(
        explicitChildNodes: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lightTheme
                ? themeExtension.primaryLight
                : themeExtension.primarySemiDark,
            borderRadius: ANGULAR_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: MEDIUM_SPACE,
              vertical: SMALL_SPACE,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  SmoothModalSheetHeaderPrefixIndicator(
                    color: lightTheme
                        ? themeExtension.primaryUltraBlack
                        : themeExtension.primaryLight,
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  Text(
                    groupTitle,
                    textAlign: TextAlign.start,
                    style: themeData.textTheme.titleSmall!.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: lightTheme
                          ? themeExtension.primaryUltraBlack
                          : themeExtension.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFullKnowledgePanel({
    required final Attribute attribute,
  }) async {
    final String? panelId = attribute.panelId;
    if (panelId == null) {
      return;
    }
    final KnowledgePanel? knowledgePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
      widget._product,
      panelId,
    );
    if (knowledgePanel == null) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => KnowledgePanelPage(
          panelId: panelId,
          product: widget._product,
        ),
      ),
    );
  }
}
