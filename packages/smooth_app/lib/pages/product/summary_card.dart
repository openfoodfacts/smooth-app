import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/cards/product_cards/question_card.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/category_product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/robotoff_questions_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/helpers/smooth_matched_product.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

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
    this.refreshProductCallback,
  });

  final Product _product;
  final ProductPreferences _productPreferences;

  /// If false, the card will be clipped to a smaller version so it can fit on
  /// smaller screens.
  final bool isFullVersion;

  /// If true, the summary card will try to load unanswered questions about this
  /// product and give a prompt to answer those questions.
  final bool showUnansweredQuestions;

  /// Callback to refresh the product when necessary.
  final Function(BuildContext)? refreshProductCallback;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  // Number of Rows that will be printed in the SummaryCard, initialized to a
  // very high number for infinite rows.
  int totalPrintableRows = 10000;

  // For some reason, special case for "label" attributes
  final Set<String> _attributesToExcludeIfStatusIsUnknown = <String>{};
  Future<List<RobotoffQuestion>>? _productQuestions;

  @override
  void initState() {
    super.initState();
    if (widget.showUnansweredQuestions) {
      loadProductQuestions();
    }
  }

  Future<void> loadProductQuestions() async {
    _productQuestions = RobotoffQuestionsQuery(widget._product.barcode!)
        .getRobotoffQuestionsForProduct();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
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
    });
  }

  Widget _buildLimitedSizeSummaryCard(double parentHeight) {
    totalPrintableRows = parentHeight ~/ SUMMARY_CARD_ROW_HEIGHT;
    return Stack(
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
                  AppLocalizations.of(context)!.tab_for_more,
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
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<Attribute> scoreAttributes =
        getPopulatedAttributes(widget._product, SCORE_ATTRIBUTE_IDS);

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
      if (widget._product.attributeGroups == null) {
        continue;
      }
      final Iterable<AttributeGroup> groupIterable = widget
          ._product.attributeGroups!
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
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(children: displayedGroups),
    );
    String? categoryTag;
    String? categoryLabel;
    if (widget._product.categoriesTags?.isNotEmpty ?? false) {
      categoryTag = widget._product.categoriesTags!.last;
      if (widget
              ._product
              .categoriesTagsInLanguages?[ProductQuery.getLanguage()!]
              ?.isNotEmpty ??
          false) {
        categoryLabel = widget._product
            .categoriesTagsInLanguages![ProductQuery.getLanguage()!]!.last;
      }
    }
    return Column(
      children: <Widget>[
        ProductTitleCard(widget._product),
        for (final Attribute attribute in scoreAttributes)
          ScoreCard(
            iconUrl: attribute.iconUrl,
            description:
                attribute.descriptionShort ?? attribute.description ?? '',
            cardEvaluation: getCardEvaluationFromAttribute(attribute),
          ),
        _buildProductQuestionsWidget(),
        attributesContainer,
        if (widget._product.statesTags
                ?.contains('en:categories-to-be-completed') ??
            false)
          addPanelButton(appLocalizations.score_add_missing_product_category,
              onPressed: () {}),
        if (categoryTag != null && categoryLabel != null)
          addPanelButton(
            appLocalizations.product_search_same_category,
            iconData: Icons.leaderboard,
            onPressed: () async => ProductQueryPageHelper().openBestChoice(
              color: Colors.deepPurple,
              heroTag: 'search_bar',
              name: categoryLabel!,
              localDatabase: localDatabase,
              productQuery: CategoryProductQuery(
                categoryTag: widget._product.categoriesTags!.last,
                size: 500,
              ),
              context: context,
            ),
          ),
        if ((widget._product.statesTags
                    ?.contains('en:product-name-to-be-completed') ??
                false) ||
            (widget._product.statesTags
                    ?.contains('en:quantity-to-be-completed') ??
                false))
          addPanelButton(
              'Complete basic details', // TODO(vik4114): localization
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not implemented yet'),
                duration: Duration(seconds: 2),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProductCompatibilityHeader(BuildContext context) {
    final MatchedProduct matchedProduct = MatchedProduct.getMatchedProduct(
      widget._product,
      widget._productPreferences,
      context.watch<UserPreferences>(),
    );
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper(matchedProduct);
    return Container(
      decoration: BoxDecoration(
        color: helper.getBackgroundColor(),
        // Ensure that the header has the same circular radius as the SmoothCard.
        borderRadius: const BorderRadius.only(
          topLeft: ROUNDED_RADIUS,
          topRight: ROUNDED_RADIUS,
        ),
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: Center(
        child: Text(
          helper.getHeaderText(AppLocalizations.of(context)!),
          style:
              Theme.of(context).textTheme.subtitle1!.apply(color: Colors.white),
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
                Expanded(child: Text(attributeDisplayTitle).selectable()),
              ]));
    });
  }

  /// Returns the mandatory attributes, ordered by attribute group order
  List<Attribute> _getMandatoryAttributes() {
    final List<Attribute> result = <Attribute>[];
    if (widget._product.attributeGroups == null) {
      return result;
    }
    final Map<String, List<Attribute>> mandatoryAttributesByGroup =
        <String, List<Attribute>>{};
    // collecting all the mandatory attributes, by group
    for (final AttributeGroup attributeGroup
        in widget._product.attributeGroups!) {
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    if (_productQuestions == null) {
      return EMPTY_WIDGET;
    }
    return FutureBuilder<List<RobotoffQuestion>>(
        future: _productQuestions,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<RobotoffQuestion>> snapshot,
        ) {
          final List<RobotoffQuestion> questions =
              snapshot.data ?? <RobotoffQuestion>[];
          if (questions.isNotEmpty) {
            return InkWell(
              onTap: () async {
                await Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => QuestionCard(
                      product: widget._product,
                      questions: questions,
                      updateProductUponAnswers: updateProductUponAnswers,
                    ),
                  ),
                );
              },
              child: SmoothCard(
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
                        style: Theme.of(context).primaryTextTheme.bodyLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: SMALL_SPACE),
                        child: Text(
                          appLocalizations.contribute_to_get_rewards,
                          style: Theme.of(context).primaryTextTheme.bodyText2,
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

  Future<void> updateProductUponAnswers() async {
    // Reload the product questions, they might have been answered.
    // Or the backend may have new ones.
    await loadProductQuestions();
    // Reload the product as it may have been updated because of the
    // new answers.
    if (widget.refreshProductCallback != null) {
      widget.refreshProductCallback!(context);
    }
  }
}
