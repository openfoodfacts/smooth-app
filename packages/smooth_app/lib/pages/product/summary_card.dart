import 'package:flutter/material.dart';
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
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/hideable_container.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_incomplete_card.dart';
import 'package:smooth_app/pages/product/summary_attribute_group.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
    this.isRemovable = true,
    this.isSettingVisible = true,
    this.isPictureVisible = true,
    this.attributeGroupsVisible = true,
    this.scrollableContent = false,
    this.isTextSelectable,
    this.margin,
    this.contentPadding,
    this.buttonPadding,
    this.heroTag,
    this.borderRadius,
  });

  final Product _product;
  final ProductPreferences _productPreferences;

  /// If false, the card will be clipped to a smaller version so it can fit on
  /// smaller screens.
  /// It should only be clickable in the full / in product page version
  /// Buttons should only be visible in full mode
  final bool isFullVersion;

  /// If true, there will be a button to remove the product from the carousel.
  final bool isRemovable;

  /// If true, the icon setting will be clickable.
  final bool isSettingVisible;

  /// If true, a picture will be display next to the product name…
  final bool isPictureVisible;

  /// If true, all chips / groups are visible
  final bool attributeGroupsVisible;

  /// If true, the text will be selectable
  final bool? isTextSelectable;

  /// Margin for the card
  final EdgeInsetsGeometry? margin;

  /// Padding for the content (name of the product, attributes…)
  final EdgeInsetsGeometry? contentPadding;

  /// Padding for the "Tap for more" button
  final EdgeInsetsGeometry? buttonPadding;

  /// An optional Hero animation for [ProductPicture]
  final String? heroTag;

  final bool scrollableContent;

  final BorderRadius? borderRadius;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> with UpToDateMixin {
  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};

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
    if (widget.isFullVersion) {
      return buildProductSmoothCard(
        body: _buildSummaryCardContent(
          context,
          padding: widget.margin ?? SMOOTH_CARD_PADDING,
        ),
        margin: EdgeInsets.zero,
        borderRadius: widget.borderRadius,
      );
    } else {
      return _buildLimitedSizeSummaryCard();
    }
  }

  Widget _buildLimitedSizeSummaryCard() {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return Padding(
      padding:
          widget.margin ??
          const EdgeInsets.symmetric(
            horizontal: SMALL_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Column(
          children: <Widget>[
            Expanded(
              child: buildProductSmoothCard(
                body: Padding(
                  padding: widget.contentPadding ?? SMOOTH_CARD_PADDING,
                  child: _buildSummaryCardContent(context),
                ),
                borderRadius: widget.borderRadius,
                margin: EdgeInsets.zero,
              ),
            ),
            Container(
              width: double.infinity,
              padding:
                  widget.buttonPadding ??
                  const EdgeInsets.symmetric(vertical: SMALL_SPACE),
              decoration: BoxDecoration(
                color: context.lightTheme()
                    ? themeExtension.primaryDark
                    : themeExtension.primarySemiDark,
                borderRadius:
                    widget.borderRadius ??
                    const BorderRadius.vertical(bottom: ROUNDED_RADIUS),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SMALL_SPACE,
                  end: SMALL_SPACE,
                  bottom: 2.0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tap_for_more,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: BALANCED_SPACE),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeExtension.secondaryVibrant,
                        ),
                        padding: const EdgeInsets.all(VERY_SMALL_SPACE),
                        child: const icons.Arrow.right(
                          color: Colors.white,
                          size: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardContent(
    BuildContext context, {
    EdgeInsetsGeometry padding = EdgeInsetsDirectional.zero,
  }) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final List<String> excludedAttributeIds = userPreferences
        .getExcludedAttributeIds();
    final List<Attribute> scoreAttributes = getPopulatedAttributes(
      upToDateProduct,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );

    final List<Widget> summaryCardButtons = <Widget>[];

    if (widget.isFullVersion) {
      final List<String> statesTags =
          upToDateProduct.statesTags ?? List<String>.empty();

      // Complete basic details
      if (statesTags.contains(
            ProductState.PRODUCT_NAME_COMPLETED.toBeCompletedTag,
          ) ||
          statesTags.contains(
            ProductState.QUANTITY_COMPLETED.toBeCompletedTag,
          )) {
        final ProductFieldEditor editor = ProductFieldDetailsEditor();
        summaryCardButtons.add(
          addPanelButton(
            editor.getLabel(localizations),
            onPressed: () async =>
                editor.edit(context: context, product: upToDateProduct),
          ),
        );
      }
    }

    final Widget child = Column(
      children: <Widget>[
        Padding(
          padding: padding,
          child: ProductTitleCard(
            upToDateProduct,
            widget.isTextSelectable ?? widget.isFullVersion,
            heroTag: widget.heroTag,
            dense: !widget.isFullVersion,
            isPictureVisible: widget.isPictureVisible,
            expandableBrands: widget.isTextSelectable ?? true,
            onRemove: (BuildContext context) async {
              HideableContainerState.of(context).hide(() async {
                final ContinuousScanModel model = context
                    .read<ContinuousScanModel>();
                await model.removeBarcode(barcode);

                // Vibrate twice
                SmoothHapticFeedback.confirm();
              });
            },
          ),
        ),
        if (ProductIncompleteCard.isProductIncomplete(upToDateProduct))
          Padding(
            padding: padding,
            child: ProductIncompleteCard(product: upToDateProduct),
          ),
        ..._getAttributes(scoreAttributes),
        if (widget.attributeGroupsVisible) _attributesContainer(padding),
        Padding(
          padding: padding,
          child: Column(children: summaryCardButtons),
        ),
      ],
    );

    if (widget.scrollableContent) {
      return SingleChildScrollView(child: child);
    } else {
      return child;
    }
  }

  Widget _attributesContainer(EdgeInsetsGeometry padding) {
    final List<Widget> displayedGroups = <Widget>[];

    // First, a virtual group with mandatory attributes of all groups
    final List<Widget> attributeChips = _buildAttributeChips(
      getMandatoryAttributes(
        upToDateProduct,
        _ATTRIBUTE_GROUP_ORDER,
        _attributesToExcludeIfStatusIsUnknown,
        widget._productPreferences,
      ),
      padding,
    );
    if (attributeChips.isNotEmpty) {
      displayedGroups.add(
        SummaryAttributeGroup(
          attributeChips: attributeChips,
          isClickable: false,
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
          PreferenceImportance.ID_VERY_IMPORTANT,
          _attributesToExcludeIfStatusIsUnknown,
          widget._productPreferences,
        ),
        padding,
      );
      attributeChips.addAll(
        _buildAttributeChips(
          getFilteredAttributes(
            group,
            PreferenceImportance.ID_IMPORTANT,
            _attributesToExcludeIfStatusIsUnknown,
            widget._productPreferences,
          ),
          padding,
        ),
      );
      if (attributeChips.isNotEmpty) {
        displayedGroups.add(
          SummaryAttributeGroup(
            attributeChips: attributeChips,
            isClickable: false,
            isFirstGroup: displayedGroups.isEmpty,
            groupName: group.id == AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS
                ? group.name!
                : null,
          ),
        );
      }
    }

    final Widget attributesContainer = displayedGroups.isNotEmpty
        ? Container(
            alignment: AlignmentDirectional.topStart,
            margin: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: LARGE_SPACE,
            ),
            child: Column(children: displayedGroups),
          )
        : const SizedBox(height: SMALL_SPACE);
    // cf. https://github.com/openfoodfacts/smooth-app/issues/2147
    return attributesContainer;
  }

  List<Widget> _getAttributes(List<Attribute> scoreAttributes) {
    final List<Widget> attributes = <Widget>[];

    for (final Attribute attribute in scoreAttributes) {
      if (widget.isFullVersion) {
        attributes.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
            child: InkWell(
              onTap: () async => _isAttributeClickable(attribute)
                  ? _openFullKnowledgePanel(attribute: attribute)
                  : null,
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
          ScoreCard.attribute(attribute: attribute, isClickable: false),
        );
      }
    }
    return attributes;
  }

  List<Widget> _buildAttributeChips(
    final List<Attribute> attributes,
    EdgeInsetsGeometry padding,
  ) {
    final List<Widget> result = <Widget>[];
    for (final Attribute attribute in attributes) {
      final Widget? attributeChip = _buildAttributeChipForValidAttributes(
        attribute,
        padding,
      );
      if (attributeChip != null) {
        result.add(attributeChip);
      }
    }
    return result;
  }

  Widget? _buildAttributeChipForValidAttributes(
    final Attribute attribute,
    EdgeInsetsGeometry padding,
  ) {
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
        final SmoothColorsThemeExtension theme = context
            .extension<SmoothColorsThemeExtension>();
        final VoidCallback? onTap = _isAttributeClickable(attribute)
            ? () => _openFullKnowledgePanel(attribute: attribute)
            : null;

        return SizedBox(
          width: constraints.maxWidth / 2,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding.add(
                const EdgeInsets.symmetric(vertical: VERY_SMALL_SPACE),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: SMALL_SPACE,
                children: <Widget>[
                  attributeIcon,
                  Expanded(
                    child: Text(
                      attributeDisplayTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (onTap != null)
                    icons.AppIconTheme(
                      size: 15.0,
                      color: context.lightTheme()
                          ? theme.greyDark
                          : theme.greyLight,
                      child: icons.Chevron.horizontalDirectional(context),
                    ),
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

  /// Ensures [_isAttributeClickable] is called before this method
  Future<void> _openFullKnowledgePanel({
    required final Attribute attribute,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => KnowledgePanelPage(
          panelId: attribute.panelId!,
          product: upToDateProduct,
        ),
      ),
    );
  }

  bool _isAttributeClickable(Attribute attribute) {
    if (!_isAttributeOpeningAllowed(attribute)) {
      return false;
    }

    final String? panelId = attribute.panelId;
    if (panelId == null) {
      return false;
    }
    final KnowledgePanel? knowledgePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(upToDateProduct, panelId);
    if (knowledgePanel == null) {
      return false;
    }
    return true;
  }
}
