import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/matched_product_v2.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/add_category_button.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/question_page.dart';
import 'package:smooth_app/query/category_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/robotoff_questions_query.dart';

const List<String> _ATTRIBUTE_GROUP_ORDER = <String>[
  AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
  AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
  AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
  AttributeGroup.ATTRIBUTE_GROUP_LABELS,
  AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
];

// Each row in the summary card takes roughly 40px.
const int SUMMARY_CARD_ROW_HEIGHT = 40;

class SummaryCard extends StatefulWidget {
  const SummaryCard(
    this._product,
    this._productPreferences, {
    this.isFullVersion = false,
    this.showUnansweredQuestions = false,
    this.isRemovable = true,
    this.isSettingClickable = true,
  });

  final Product _product;
  final ProductPreferences _productPreferences;

  /// If false, the card will be clipped to a smaller version so it can fit on
  /// smaller screens.
  /// It should only be clickable in the full / in product page version
  /// Buttons should only be visible in full mode
  final bool isFullVersion;

  /// If true, the summary card will try to load unanswered questions about this
  /// product and give a prompt to answer those questions.
  final bool showUnansweredQuestions;

  /// If true, there will be a button to remove the product from the carousel.
  final bool isRemovable;

  /// If true, the icon setting will be clickable.
  final bool isSettingClickable;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  late Product _product;
  late final bool allowClicking;

  // Number of Rows that will be printed in the SummaryCard, initialized to a
  // very high number for infinite rows.
  int totalPrintableRows = 10000;

  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};
  bool _annotationVoted = false;

  @override
  void initState() {
    super.initState();
    allowClicking = !widget.isFullVersion;
    _product = widget._product;
  }

  @override
  Widget build(BuildContext context) => Consumer<UpToDateProductProvider>(
        builder: (
          final BuildContext context,
          final UpToDateProductProvider provider,
          final Widget? child,
        ) =>
            LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Product? refreshedProduct = provider.get(_product);
            if (refreshedProduct != null) {
              _product = refreshedProduct;
            }
            if (widget.isFullVersion) {
              return buildProductSmoothCard(
                header: _buildProductCompatibilityHeader(context),
                body: Padding(
                  padding: SMOOTH_CARD_PADDING,
                  child: _buildSummaryCardContent(context),
                ),
                margin: EdgeInsets.zero,
              );
            } else {
              return _buildLimitedSizeSummaryCard(constraints.maxHeight);
            }
          },
        ),
      );

  Widget _buildLimitedSizeSummaryCard(double parentHeight) {
    totalPrintableRows = parentHeight ~/ SUMMARY_CARD_ROW_HEIGHT;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SMALL_SPACE,
        vertical: VERY_SMALL_SPACE,
      ),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: ROUNDED_BORDER_RADIUS,
            child: OverflowBox(
              alignment: AlignmentDirectional.topStart,
              minHeight: parentHeight,
              maxHeight: double.infinity,
              child: buildProductSmoothCard(
                header: _buildProductCompatibilityHeader(context),
                body: Padding(
                  padding: SMOOTH_CARD_PADDING,
                  child: _buildSummaryCardContent(context),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: SMALL_SPACE,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: ROUNDED_RADIUS),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).tab_for_more,
                    style:
                        Theme.of(context).primaryTextTheme.bodyText1?.copyWith(
                              color: PRIMARY_BLUE_COLOR,
                            ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardContent(BuildContext context) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final AppLocalizations localizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    final List<Attribute> scoreAttributes = getPopulatedAttributes(
      _product,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );

    // Header takes 1 row.
    // Product Title Tile takes 2 rows to render.
    // Footer takes 1 row.
    totalPrintableRows -= 4;
    // Each Score card takes about 1.5 rows to render.
    totalPrintableRows -= (1.5 * scoreAttributes.length).ceil();

    final List<Widget> displayedGroups = <Widget>[];

    // First, a virtual group with mandatory attributes of all groups
    final List<Widget> attributeChips = _buildAttributeChips(
      _getMandatoryAttributes(),
    );
    if (attributeChips.isNotEmpty) {
      displayedGroups.add(
        _buildAttributeGroup(
          _buildAttributeGroupHeader(
            isFirstGroup: displayedGroups.isEmpty,
            groupName: null,
          ),
          attributeChips,
        ),
      );
    }
    // Then, all groups, each with very important and important attributes
    for (final String groupId in _ATTRIBUTE_GROUP_ORDER) {
      if (_product.attributeGroups == null) {
        continue;
      }
      final Iterable<AttributeGroup> groupIterable = _product.attributeGroups!
          .where((AttributeGroup group) => group.id == groupId);

      if (groupIterable.isEmpty) {
        continue;
      }
      final AttributeGroup group = groupIterable.single;
      final List<Widget> attributeChips = _buildAttributeChips(
        _getFilteredAttributes(
          group,
          PreferenceImportance.ID_IMPORTANT,
        ),
      );
      if (attributeChips.isNotEmpty) {
        displayedGroups.add(
          _buildAttributeGroup(
            _buildAttributeGroupHeader(
                isFirstGroup: displayedGroups.isEmpty,
                groupName: group.id == AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS
                    ? group.name!
                    : null),
            attributeChips,
          ),
        );
      }
    }
    final Widget attributesContainer = Container(
      alignment: AlignmentDirectional.topStart,
      margin: const EdgeInsetsDirectional.only(bottom: LARGE_SPACE),
      child: Column(children: displayedGroups),
    );
    // cf. https://github.com/openfoodfacts/smooth-app/issues/2147
    const Set<String> blackListedCategories = <String>{
      'fr:vegan',
    };
    String? categoryTag;
    String? categoryLabel;
    final List<String>? labels =
        _product.categoriesTagsInLanguages?[ProductQuery.getLanguage()!];
    final List<String>? tags = _product.categoriesTags;
    if (tags != null &&
        labels != null &&
        tags.isNotEmpty &&
        tags.length == labels.length) {
      categoryTag = _product.comparedToCategory;
      if (categoryTag == null || blackListedCategories.contains(categoryTag)) {
        // fallback algorithm
        int index = tags.length - 1;
        // cf. https://github.com/openfoodfacts/openfoodfacts-dart/pull/474
        // looking for the most detailed non blacklisted category
        categoryTag = tags[index];
        while (blackListedCategories.contains(categoryTag) && index > 0) {
          index--;
          categoryTag = tags[index];
        }
      }
      if (categoryTag != null) {
        for (int i = 0; i < tags.length; i++) {
          if (categoryTag == tags[i]) {
            categoryLabel = labels[i];
          }
        }
      }
    }
    final List<String> statesTags = _product.statesTags ?? List<String>.empty();

    final List<Widget> summaryCardButtons = <Widget>[];

    if (widget.isFullVersion) {
      // Complete category
      if (statesTags.contains('en:categories-to-be-completed')) {
        summaryCardButtons.add(AddCategoryButton(_product));
      }

      // Compare to category
      if (categoryTag != null && categoryLabel != null) {
        summaryCardButtons.add(
          addPanelButton(
            localizations.product_search_same_category,
            iconData: Icons.leaderboard,
            onPressed: () async => ProductQueryPageHelper().openBestChoice(
              name: categoryLabel!,
              localDatabase: localDatabase,
              productQuery: CategoryProductQuery(categoryTag!),
              context: context,
            ),
          ),
        );
      }

      // Complete basic details
      if (statesTags.contains('en:product-name-to-be-completed') ||
          statesTags.contains('en:quantity-to-be-completed')) {
        summaryCardButtons.add(
          addPanelButton(
            localizations.completed_basic_details_btn_text,
            onPressed: () async {
              await Navigator.push<Product?>(
                context,
                MaterialPageRoute<Product>(
                  builder: (BuildContext context) =>
                      AddBasicDetailsPage(_product),
                ),
              );
            },
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
        ProductTitleCard(
          _product,
          widget.isFullVersion,
          isRemovable: widget.isRemovable,
        ),
        ...getAttributes(scoreAttributes),
        if (widget.isFullVersion) _buildProductQuestionsWidget(),
        attributesContainer,
        ...summaryCardButtons,
      ],
    );
  }

  List<Widget> getAttributes(List<Attribute> scoreAttributes) {
    final List<Widget> attributes = <Widget>[];

    for (final Attribute attribute in scoreAttributes) {
      if (widget.isFullVersion) {
        attributes.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
            child: InkWell(
              borderRadius: ANGULAR_BORDER_RADIUS,
              onTap: () async => openFullKnowledgePanel(
                attribute: attribute,
              ),
              child: ScoreCard(
                iconUrl: attribute.iconUrl,
                description:
                    attribute.descriptionShort ?? attribute.description ?? '',
                cardEvaluation: getCardEvaluationFromAttribute(attribute),
                isClickable: true,
                margin: EdgeInsets.zero,
              ),
            ),
          ),
        );
      } else {
        attributes.add(
          ScoreCard(
            iconUrl: attribute.iconUrl,
            description:
                attribute.descriptionShort ?? attribute.description ?? '',
            cardEvaluation: getCardEvaluationFromAttribute(attribute),
            isClickable: false,
          ),
        );
      }
    }
    return attributes;
  }

  Widget _buildProductCompatibilityHeader(BuildContext context) {
    final MatchedProductV2 matchedProduct = MatchedProductV2(
      _product,
      widget._productPreferences,
    );
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.product(matchedProduct);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Ink(
      decoration: BoxDecoration(
        color: helper.getHeaderBackgroundColor(isDarkMode),
        // Ensure that the header has the same circular radius as the SmoothCard.
        borderRadius: const BorderRadius.only(
          topLeft: ROUNDED_RADIUS,
          topRight: ROUNDED_RADIUS,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Fake icon
          const SizedBox(
            width: kMinInteractiveDimension,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SMALL_SPACE,
                  horizontal: SMALL_SPACE,
                ),
                child: Text(
                  helper.getHeaderText(appLocalizations),
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: helper.getHeaderForegroundColor(isDarkMode),
                      ),
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.only(topRight: ROUNDED_RADIUS),
            onTap: widget.isSettingClickable
                ? () async => Navigator.push<Widget>(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) =>
                            const UserPreferencesPage(
                          type: PreferencePageType.FOOD,
                        ),
                      ),
                    )
                : null,
            child: Tooltip(
              message: appLocalizations.open_food_preferences_tooltip,
              triggerMode: widget.isSettingClickable
                  ? TooltipTriggerMode.longPress
                  : TooltipTriggerMode.tap,
              child: const SizedBox.square(
                dimension: kMinInteractiveDimension,
                child: Icon(
                  Icons.settings,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeGroup(
    final Widget header,
    final List<Widget> attributeChips,
  ) {
    totalPrintableRows -= (attributeChips.length / 2).ceil();
    return Column(
      children: <Widget>[
        header,
        Container(
          alignment: Alignment.topLeft,
          child: Wrap(
            runSpacing: 16,
            children: attributeChips,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAttributeChips(final List<Attribute> attributes) {
    final List<Widget> result = <Widget>[];
    for (final Attribute attribute in attributes) {
      final Widget? attributeChip =
          _buildAttributeChipForValidAttributes(attribute);
      if (attributeChip != null && result.length / 2 < totalPrintableRows) {
        result.add(attributeChip);
      }
    }
    return result;
  }

  Widget _buildAttributeGroupHeader({
    required bool isFirstGroup,
    String? groupName,
  }) {
    if (groupName != null) {
      return Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE, bottom: LARGE_SPACE),
        child: Text(
          groupName,
          style:
              Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: isFirstGroup
          ? EMPTY_WIDGET
          : const Divider(
              color: Colors.black12,
            ),
    );
  }

  Widget? _buildAttributeChipForValidAttributes(final Attribute attribute) {
    if (attribute.status == Attribute.STATUS_UNKNOWN &&
        _attributesToExcludeIfStatusIsUnknown.contains(attribute.id)) {
      return null;
    }
    final String? attributeDisplayTitle = getDisplayTitle(attribute);
    final Widget attributeIcon = getAttributeDisplayIcon(attribute);
    if (attributeDisplayTitle == null) {
      return null;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth / 2,
          child: InkWell(
            enableFeedback: allowAttributeOpening(attribute),
            onTap: () async => openFullKnowledgePanel(
              attribute: attribute,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                attributeIcon,
                Expanded(child: Text(attributeDisplayTitle)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Returns the mandatory attributes, ordered by attribute group order
  List<Attribute> _getMandatoryAttributes() {
    final List<Attribute> result = <Attribute>[];
    if (_product.attributeGroups == null) {
      return result;
    }
    final Map<String, List<Attribute>> mandatoryAttributesByGroup =
        <String, List<Attribute>>{};
    // collecting all the mandatory attributes, by group
    for (final AttributeGroup attributeGroup in _product.attributeGroups!) {
      mandatoryAttributesByGroup[attributeGroup.id!] = _getFilteredAttributes(
        attributeGroup,
        PreferenceImportance.ID_MANDATORY,
      );
    }

    // now ordering by attribute group order
    for (final String attributeGroupId in _ATTRIBUTE_GROUP_ORDER) {
      final List<Attribute>? attributes =
          mandatoryAttributesByGroup[attributeGroupId];
      if (attributes != null) {
        result.addAll(attributes);
      }
    }
    return result;
  }

  /// Returns the attributes that match the filter
  ///
  /// [SCORE_ATTRIBUTE_IDS] attributes are not included, as they are already
  /// dealt with somewhere else.
  List<Attribute> _getFilteredAttributes(
    final AttributeGroup attributeGroup,
    final String importance,
  ) {
    final List<Attribute> result = <Attribute>[];
    if (attributeGroup.attributes == null) {
      return result;
    }
    for (final Attribute attribute in attributeGroup.attributes!) {
      final String attributeId = attribute.id!;
      if (SCORE_ATTRIBUTE_IDS.contains(attributeId)) {
        continue;
      }
      if (attributeGroup.id == AttributeGroup.ATTRIBUTE_GROUP_LABELS) {
        _attributesToExcludeIfStatusIsUnknown.add(attributeId);
      }
      final String importanceId =
          widget._productPreferences.getImportanceIdForAttributeId(attributeId);
      if (importance == importanceId) {
        result.add(attribute);
      }
    }
    return result;
  }

  Widget _buildProductQuestionsWidget() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<RobotoffQuestion>>(
        future: _loadProductQuestions(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<RobotoffQuestion>> snapshot,
        ) {
          final List<RobotoffQuestion> questions =
              snapshot.data ?? <RobotoffQuestion>[];
          if (questions.isNotEmpty && !_annotationVoted) {
            return InkWell(
              onTap: () async {
                await Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => QuestionPage(
                      product: _product,
                      questions: questions,
                      updateProductUponAnswers: _updateProductUponAnswers,
                    ),
                  ),
                );
              },
              child: SmoothCard.angular(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.primary,
                elevation: 0,
                padding: const EdgeInsets.all(
                  SMALL_SPACE,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      // TODO(jasmeet): Use Material icon or SVG (after consulting UX).
                      Text(
                        '🏅 ${appLocalizations.tap_to_answer}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyLarge!
                            .copyWith(
                              color: isDarkMode ? Colors.black : WHITE_COLOR,
                            ),
                      ),
                      Container(
                        padding:
                            const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                        child: Text(
                          appLocalizations.contribute_to_get_rewards,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2!
                              .copyWith(
                                color: isDarkMode ? Colors.black : WHITE_COLOR,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return EMPTY_WIDGET;
        });
  }

  Future<void> _updateProductUponAnswers() async {
    // Reload the product questions, they might have been answered.
    // Or the backend may have new ones.
    final List<RobotoffQuestion> questions =
        await _loadProductQuestions() ?? <RobotoffQuestion>[];
    if (!mounted) {
      return;
    }
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(context.read<LocalDatabase>());
    if (questions.isEmpty) {
      await robotoffInsightHelper
          .removeInsightAnnotationsSavedForProdcut(_product.barcode!);
    }
    _annotationVoted =
        await robotoffInsightHelper.haveInsightAnnotationsVoted(questions);
    // Reload the product as it may have been updated because of the
    // new answers.
    if (!mounted) {
      return;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await ProductRefresher().fetchAndRefresh(
      context: context,
      localDatabase: localDatabase,
      barcode: _product.barcode!,
    );
  }

  Future<List<RobotoffQuestion>>? _loadProductQuestions() async {
    final List<RobotoffQuestion> questions =
        await RobotoffQuestionsQuery(_product.barcode!)
            .getRobotoffQuestionsForProduct();

    final RobotoffInsightHelper robotoffInsightHelper =
        //ignore: use_build_context_synchronously
        RobotoffInsightHelper(context.read<LocalDatabase>());
    _annotationVoted =
        await robotoffInsightHelper.haveInsightAnnotationsVoted(questions);
    return questions;
  }

  bool allowAttributeOpening(Attribute attribute) =>
      widget.isFullVersion &&
      _product.knowledgePanels != null &&
      attribute.panelId != null;

  Future<void> openFullKnowledgePanel({
    required final Attribute attribute,
  }) async {
    if (!allowAttributeOpening(attribute)) {
      return;
    }

    final KnowledgePanel? knowledgePanel =
        _product.knowledgePanels?.panelIdToPanelMap[attribute.panelId];

    if (knowledgePanel == null) {
      return;
    }

    final KnowledgePanelPanelGroupElement? group =
        KnowledgePanelGroupCard.groupElementOf(context);

    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => KnowledgePanelPage(
          groupElement: group,
          panel: knowledgePanel,
          allPanels: _product.knowledgePanels!,
          product: _product,
        ),
      ),
    );
  }
}
