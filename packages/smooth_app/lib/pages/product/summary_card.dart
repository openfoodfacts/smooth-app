import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';
import 'package:smooth_app/pages/product/hideable_container.dart';
import 'package:smooth_app/pages/product/product_compatibility_header.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_incomplete_card.dart';
import 'package:smooth_app/pages/product/product_questions_widget.dart';
import 'package:smooth_app/pages/product/summary_attribute_group.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

const List<String> _ATTRIBUTE_GROUP_ORDER = <String>[
  AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
  AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
  AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
  AttributeGroup.ATTRIBUTE_GROUP_LABELS,
  AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
];

class SummaryCard extends StatefulWidget {
  const SummaryCard(
    this._product,
    this._productPreferences, {
    this.isFullVersion = false,
    this.showQuestionsBanner = false,
    this.isRemovable = true,
    this.isSettingVisible = true,
    this.isProductEditable = true,
    this.attributeGroupsClickable = true,
    this.padding,
    this.shadow,
  });

  final Product _product;
  final ProductPreferences _productPreferences;

  /// If false, the card will be clipped to a smaller version so it can fit on
  /// smaller screens.
  /// It should only be clickable in the full / in product page version
  /// Buttons should only be visible in full mode
  final bool isFullVersion;

  /// If true, show the [QuestionCard] if there are questions for the product.
  final bool showQuestionsBanner;

  /// If true, there will be a button to remove the product from the carousel.
  final bool isRemovable;

  /// If true, the icon setting will be clickable.
  final bool isSettingVisible;

  /// If true, the product will be editable
  final bool isProductEditable;

  /// If true, all chips / groups are clickable
  final bool attributeGroupsClickable;

  final EdgeInsetsGeometry? padding;

  /// An optional shadow to apply to the card
  final BoxShadow? shadow;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> with UpToDateMixin {
  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};
  late ProductQuestionsLayout _questionsLayout;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget._product, context.read<LocalDatabase>());
    _questionsLayout = getUserQuestionsLayout(context.read<UserPreferences>());
    if (ProductIncompleteCard.isProductIncomplete(upToDateProduct)) {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.showFastTrackProductEditCard,
        barcode: barcode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    refreshUpToDate();
    if (widget.isFullVersion) {
      return buildProductSmoothCard(
        header: ProductCompatibilityHeader(
          product: upToDateProduct,
          productPreferences: widget._productPreferences,
          isSettingVisible: widget.isSettingVisible,
        ),
        body: Padding(
          padding: widget.padding ?? SMOOTH_CARD_PADDING,
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
    final SmoothColorsThemeExtension? themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>();

    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: SMALL_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow:
                  widget.shadow != null ? <BoxShadow>[widget.shadow!] : null,
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            child: ClipRRect(
              borderRadius: ROUNDED_BORDER_RADIUS,
              child: OverflowBox(
                alignment: AlignmentDirectional.topStart,
                minHeight: parentHeight,
                maxHeight: double.infinity,
                child: buildProductSmoothCard(
                  header: ProductCompatibilityHeader(
                    product: upToDateProduct,
                    productPreferences: widget._productPreferences,
                    isSettingVisible: widget.isSettingVisible,
                  ),
                  body: Padding(
                    padding: SMOOTH_CARD_PADDING,
                    child: _buildSummaryCardContent(context),
                  ),
                  margin: EdgeInsets.zero,
                ),
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
                  color: themeExtension!.primaryNormal,
                  borderRadius:
                      const BorderRadius.vertical(bottom: ROUNDED_RADIUS),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 2.0),
                      child: Text(
                        AppLocalizations.of(context).tap_for_more,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: BALANCED_SPACE,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(VERY_SMALL_SPACE),
                      child: icons.Arrow.right(
                        color: themeExtension.primaryNormal,
                        size: 12.0,
                      ),
                    )
                  ],
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
      upToDateProduct,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );

    final List<Widget> displayedGroups = <Widget>[];

    // First, a virtual group with mandatory attributes of all groups
    final List<Widget> attributeChips = _buildAttributeChips(
      getMandatoryAttributes(
        upToDateProduct,
        _ATTRIBUTE_GROUP_ORDER,
        _attributesToExcludeIfStatusIsUnknown,
        widget._productPreferences,
      ),
    );
    if (attributeChips.isNotEmpty) {
      displayedGroups.add(
        SummaryAttributeGroup(
          attributeChips: attributeChips,
          isClickable: widget.attributeGroupsClickable,
          isFirstGroup: displayedGroups.isEmpty,
          groupName: null,
        ),
      );
    }
    // Then, all groups, each with very important and important attributes
    for (final String groupId in _ATTRIBUTE_GROUP_ORDER) {
      if (upToDateProduct.attributeGroups == null) {
        continue;
      }
      final Iterable<AttributeGroup> groupIterable = upToDateProduct
          .attributeGroups!
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
          SummaryAttributeGroup(
            attributeChips: attributeChips,
            isClickable: widget.attributeGroupsClickable,
            isFirstGroup: displayedGroups.isEmpty,
            groupName: group.id == AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS
                ? group.name!
                : null,
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

    final List<Widget> summaryCardButtons = <Widget>[];

    if (widget.isFullVersion) {
      final List<String> statesTags =
          upToDateProduct.statesTags ?? List<String>.empty();

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
                ? editor.edit(context: context, product: upToDateProduct)
                : null,
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
        ProductTitleCard(
          upToDateProduct,
          widget.isFullVersion,
          isRemovable: widget.isRemovable,
          onRemove: (BuildContext context) async {
            HideableContainerState.of(context).hide(() async {
              final ContinuousScanModel model =
                  context.read<ContinuousScanModel>();
              await model.removeBarcode(barcode);

              // Vibrate twice
              SmoothHapticFeedback.confirm();
            });
          },
        ),
        if (ProductIncompleteCard.isProductIncomplete(upToDateProduct))
          ProductIncompleteCard(product: upToDateProduct),
        ..._getAttributes(scoreAttributes),
        if (widget.isFullVersion &&
            widget.showQuestionsBanner &&
            _questionsLayout == ProductQuestionsLayout.button)
          ProductQuestionsWidget(
            upToDateProduct,
            layout: ProductQuestionsLayout.button,
          ),
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

  List<Widget> _buildAttributeChips(final List<Attribute> attributes) {
    final List<Widget> result = <Widget>[];
    for (final Attribute attribute in attributes) {
      final Widget? attributeChip =
          _buildAttributeChipForValidAttributes(attribute);
      if (attributeChip != null) {
        result.add(attributeChip);
      }
    }
    return result;
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
            borderRadius: ANGULAR_BORDER_RADIUS,
            enableFeedback: _isAttributeOpeningAllowed(attribute),
            onTap: () async => _openFullKnowledgePanel(
              attribute: attribute,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  attributeIcon,
                  Expanded(child: Text(attributeDisplayTitle)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isAttributeOpeningAllowed(Attribute attribute) =>
      widget.isFullVersion &&
      upToDateProduct.knowledgePanels != null &&
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
        KnowledgePanelsBuilder.getKnowledgePanel(
      upToDateProduct,
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
          product: upToDateProduct,
        ),
      ),
    );
  }
}
