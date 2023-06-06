import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/add_simple_input_button.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/hideable_container.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_questions_widget.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/category_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

const List<String> _ATTRIBUTE_GROUP_ORDER = <String>[
  AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
  AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
  AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
  AttributeGroup.ATTRIBUTE_GROUP_LABELS,
  AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
];

// Each row in the summary card takes roughly 40px.
const int _SUMMARY_CARD_ROW_HEIGHT = 40;

class SummaryCard extends StatefulWidget {
  const SummaryCard(
    this._product,
    this._productPreferences, {
    this.isFullVersion = false,
    this.showUnansweredQuestions = false,
    this.isRemovable = true,
    this.isSettingClickable = true,
    this.isProductEditable = true,
    this.attributeGroupsClickable = true,
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

  /// If true, the product will be editable
  final bool isProductEditable;

  /// If true, all chips / groups are clickable
  final bool attributeGroupsClickable;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;

  // Number of Rows that will be printed in the SummaryCard, initialized to a
  // very high number for infinite rows.
  int _totalPrintableRows = 10000;

  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};

  @override
  void initState() {
    super.initState();
    _initialProduct = widget._product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_initialProduct.barcode!);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_initialProduct.barcode!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    if (widget.isFullVersion) {
      return buildProductSmoothCard(
        header: _buildProductCompatibilityHeader(context),
        body: Padding(
          padding: SMOOTH_CARD_PADDING,
          child: _buildSummaryCardContent(context),
        ),
        margin: EdgeInsets.zero,
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          _buildLimitedSizeSummaryCard(constraints.maxHeight),
    );
  }

  Widget _buildLimitedSizeSummaryCard(double parentHeight) {
    _totalPrintableRows = parentHeight ~/ _SUMMARY_CARD_ROW_HEIGHT;
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
                        Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
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
    _totalPrintableRows -= 4;
    // Each Score card takes about 1.5 rows to render.
    _totalPrintableRows -= (1.5 * scoreAttributes.length).ceil();

    final List<Widget> displayedGroups = <Widget>[];

    // First, a virtual group with mandatory attributes of all groups
    final List<Widget> attributeChips = _buildAttributeChips(
      getMandatoryAttributes(
        _product,
        _ATTRIBUTE_GROUP_ORDER,
        _attributesToExcludeIfStatusIsUnknown,
        widget._productPreferences,
      ),
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
        getFilteredAttributes(
          group,
          PreferenceImportance.ID_IMPORTANT,
          _attributesToExcludeIfStatusIsUnknown,
          widget._productPreferences,
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
        _product.categoriesTagsInLanguages?[ProductQuery.getLanguage()];
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
      if (statesTags
          .contains(ProductState.CATEGORIES_COMPLETED.toBeCompletedTag)) {
        summaryCardButtons.add(
          AddSimpleInputButton(
            product: _product,
            helper: SimpleInputPageCategoryHelper(),
          ),
        );
      }

      // Compare to category
      if (categoryTag != null && categoryLabel != null) {
        summaryCardButtons.add(
          addPanelButton(
            localizations.product_search_same_category,
            iconData: Icons.leaderboard,
            onPressed: () async => ProductQueryPageHelper().openBestChoice(
              name: categoryLabel!,
              localDatabase: _localDatabase,
              productQuery: CategoryProductQuery(categoryTag!),
              context: context,
            ),
          ),
        );
      }

      // Complete basic details
      if (statesTags
              .contains(ProductState.PRODUCT_NAME_COMPLETED.toBeCompletedTag) ||
          statesTags
              .contains(ProductState.QUANTITY_COMPLETED.toBeCompletedTag)) {
        final ProductFieldEditor editor = ProductFieldDetailsEditor();
        summaryCardButtons.add(
          addPanelButton(
            editor.getLabel(localizations),
            onPressed: () async => widget.isProductEditable
                ? editor.edit(
                    context: context,
                    product: _product,
                  )
                : null,
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
          onRemove: (BuildContext context) async {
            HideableContainerState.of(context).hide(() async {
              final ContinuousScanModel model =
                  context.read<ContinuousScanModel>();
              await model.removeBarcode(_product.barcode!);

              // Vibrate twice
              SmoothHapticFeedback.confirm();
            });
          },
        ),
        ..._getAttributes(scoreAttributes),
        if (widget.isFullVersion) ProductQuestionsWidget(_product),
        attributesContainer,
        ...summaryCardButtons,
      ],
    );
  }

  List<Widget> _getAttributes(List<Attribute> scoreAttributes) {
    final List<Widget> attributes = <Widget>[];

    for (final Attribute attribute in scoreAttributes) {
      if (widget.isFullVersion) {
        attributes.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
            child: InkWell(
              borderRadius: ANGULAR_BORDER_RADIUS,
              onTap: () async => _openFullKnowledgePanel(
                attribute: attribute,
              ),
              child: ScoreCard.attribute(
                attribute: attribute,
                isClickable: true,
                margin: EdgeInsets.zero,
              ),
            ),
          ),
        );
      } else {
        attributes.add(
          ScoreCard.attribute(
            attribute: attribute,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: helper.getHeaderForegroundColor(isDarkMode),
                      ),
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.only(topRight: ROUNDED_RADIUS),
            onTap: widget.isSettingClickable
                ? () => AppNavigator.of(context).push(
                      AppRoutes.PREFERENCES(PreferencePageType.FOOD),
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
    _totalPrintableRows -= (attributeChips.length / 2).ceil();
    return AbsorbPointer(
      absorbing: !widget.attributeGroupsClickable,
      child: Column(
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
      ),
    );
  }

  List<Widget> _buildAttributeChips(final List<Attribute> attributes) {
    final List<Widget> result = <Widget>[];
    for (final Attribute attribute in attributes) {
      final Widget? attributeChip =
          _buildAttributeChipForValidAttributes(attribute);
      if (attributeChip != null && result.length / 2 < _totalPrintableRows) {
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
              Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.grey),
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
            enableFeedback: _isAttributeOpeningAllowed(attribute),
            onTap: () async => _openFullKnowledgePanel(
              attribute: attribute,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
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

  bool _isAttributeOpeningAllowed(Attribute attribute) =>
      widget.isFullVersion &&
      _product.knowledgePanels != null &&
      attribute.panelId != null;

  Future<void> _openFullKnowledgePanel({
    required final Attribute attribute,
  }) async {
    if (!_isAttributeOpeningAllowed(attribute)) {
      return;
    }

    final String? panelId = attribute.panelId;
    if (panelId == null) {
      return;
    }
    final KnowledgePanel? knowledgePanel =
        KnowledgePanelWidget.getKnowledgePanel(
      _product,
      panelId,
    );
    if (knowledgePanel == null) {
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => KnowledgePanelPage(
          panelId: panelId,
          product: _product,
        ),
      ),
    );
  }
}
