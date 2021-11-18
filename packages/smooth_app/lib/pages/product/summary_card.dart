import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Main attributes, to be displayed on top
const List<String> _SCORE_ATTRIBUTE_IDS = <String>[
  Attribute.ATTRIBUTE_NUTRISCORE,
  Attribute.ATTRIBUTE_ECOSCORE,
];

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
  const SummaryCard(this._product, this._productPreferences,
      {this.isRenderedInProductPage = false});

  final Product _product;
  final ProductPreferences _productPreferences;
  final bool isRenderedInProductPage;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  // Number of Rows that will be printed in the SummaryCard, initialized to a
  // very high number for infinite rows.
  int totalPrintableRows = 10000;

  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (widget.isRenderedInProductPage) {
        return buildProductSmoothCard(
          header: _buildProductCompatibilityHeader(context),
          body: Padding(
            padding: SMOOTH_CARD_PADDING,
            child: _buildSummaryCardContent(context),
          ),
        );
      } else {
        return _buildLimitedSizeSummaryCard(constraints.maxHeight);
      }
    });
  }

  Widget _buildLimitedSizeSummaryCard(double parentHeight) {
    totalPrintableRows = parentHeight ~/ SUMMARY_CARD_ROW_HEIGHT;
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: SmoothCard.CIRCULAR_RADIUS),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: SmoothCard.CIRCULAR_RADIUS),
              ),
              child: Center(
                // TODO(jasmeet): Internationalize
                child: Text(
                  'Tap to see more info...',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .apply(color: Colors.lightBlue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCardContent(BuildContext context) {
    final List<Attribute> scoreAttributes =
        AttributeListExpandable.getPopulatedAttributes(
            widget._product, _SCORE_ATTRIBUTE_IDS);

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
      final Iterable<AttributeGroup> groupIterable = widget
          ._product.attributeGroups!
          .where((AttributeGroup group) => group.id == groupId);
      if (groupIterable.isEmpty) {
        continue;
      }
      final AttributeGroup group = groupIterable.single;
      final List<Widget> attributeChips = _buildAttributeChips(
        _getOrderedAndFilteredAttributes(
          group,
          <String>[
            PreferenceImportance.ID_VERY_IMPORTANT,
            PreferenceImportance.ID_IMPORTANT,
          ],
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
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(children: displayedGroups),
    );
    return Column(
      children: <Widget>[
        _buildProductTitleTile(context),
        for (final Attribute attribute in scoreAttributes)
          ScoreCard(
            iconUrl: attribute.iconUrl!,
            description:
                attribute.descriptionShort ?? attribute.description ?? '',
            cardEvaluation: getCardEvaluationFromAttribute(attribute),
          ),
        attributesContainer,
      ],
    );
  }

  Widget _buildProductCompatibilityHeader(BuildContext context) {
    final ProductCompatibility compatibility =
        getProductCompatibility(widget._productPreferences, widget._product);
    // NOTE: This is temporary and will be updated once the feature is supported
    // by the server.
    return Container(
      decoration: BoxDecoration(
        color: getProductCompatibilityHeaderBackgroundColor(compatibility),
        // Ensure that the header has the same circular radius as the SmoothCard.
        borderRadius: const BorderRadius.only(
          topLeft: SmoothCard.CIRCULAR_RADIUS,
          topRight: SmoothCard.CIRCULAR_RADIUS,
        ),
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: Center(
        child: Text(
          getProductCompatibilityHeaderTextWidget(compatibility),
          style:
              Theme.of(context).textTheme.subtitle1!.apply(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductTitleTile(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          getProductName(widget._product, appLocalizations),
          style: themeData.textTheme.headline4,
        ),
        subtitle: Text(widget._product.brands ?? appLocalizations.unknownBrand),
        trailing: Text(
          widget._product.quantity ?? '',
          style: themeData.textTheme.headline3,
        ),
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
        padding: const EdgeInsets.only(top: SMALL_SPACE, bottom: LARGE_SPACE),
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
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                attributeIcon,
                Expanded(child: Text(attributeDisplayTitle)),
              ]));
    });
  }

  /// Returns the mandatory attributes, ordered by attribute group order
  List<Attribute> _getMandatoryAttributes() {
    final List<Attribute> result = <Attribute>[];
    if (widget._product.attributeGroups == null) {
      return result;
    }
    const List<String> filter = <String>[PreferenceImportance.ID_MANDATORY];
    final Map<String, List<Attribute>> mandatoryAttributesByGroup =
        <String, List<Attribute>>{};
    // collecting all the mandatory attributes, by group
    for (final AttributeGroup attributeGroup
        in widget._product.attributeGroups!) {
      mandatoryAttributesByGroup[attributeGroup.id!] =
          _getOrderedAndFilteredAttributes(attributeGroup, filter);
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

  /// Returns the attributes that match the filter, ordered by filter order
  ///
  /// [_SCORE_ATTRIBUTE_IDS] attributes are not included, as they are already
  /// dealt with somewhere else.
  List<Attribute> _getOrderedAndFilteredAttributes(
    final AttributeGroup attributeGroup,
    final List<String> orderedImportanceFilter,
  ) {
    final List<Attribute> result = <Attribute>[];
    if (attributeGroup.attributes == null) {
      return result;
    }
    final Map<String, List<Attribute>> attributeByImportances =
        <String, List<Attribute>>{};
    for (final Attribute attribute in attributeGroup.attributes!) {
      final String attributeId = attribute.id!;
      if (_SCORE_ATTRIBUTE_IDS.contains(attributeId)) {
        continue;
      }
      if (attributeGroup.id == AttributeGroup.ATTRIBUTE_GROUP_LABELS) {
        _attributesToExcludeIfStatusIsUnknown.add(attributeId);
      }
      final String importanceId =
          widget._productPreferences.getImportanceIdForAttributeId(attributeId);
      if (orderedImportanceFilter.contains(importanceId)) {
        attributeByImportances[importanceId] ??= <Attribute>[];
        attributeByImportances[importanceId]!.add(attribute);
      }
    }
    for (final String importanceId in orderedImportanceFilter) {
      if (attributeByImportances[importanceId] != null) {
        result.addAll(attributeByImportances[importanceId]!);
      }
    }
    return result;
  }
}
