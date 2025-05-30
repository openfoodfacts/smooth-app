import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_dropdown.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

class NutrientRow extends StatefulWidget {
  const NutrientRow({
    required this.nutritionContainer,
    required this.decimalNumberFormat,
    required this.orderedNutrient,
    required this.position,
    required this.isLast,
    required this.highlighted,
  });

  final NutritionContainerHelper nutritionContainer;
  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final bool isLast;
  final bool highlighted;

  @override
  State<NutrientRow> createState() => _NutrientRowState();
}

class _NutrientRowState extends State<NutrientRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SmoothAnimationsDuration.medium,
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _colorAnimation = null;
        }
      });
  }

  @override
  void didUpdateWidget(covariant NutrientRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.highlighted != widget.highlighted && widget.highlighted) {
      _colorAnimation = ColorTween(
        begin: _getColor(context.extension<SmoothColorsThemeExtension>()),
        end: context.extension<SmoothColorsThemeExtension>().secondaryLight,
      ).animate(_controller);
      _controller.repeat(count: 4, reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final String key = widget.orderedNutrient.id;

    Color color;
    if (_colorAnimation != null) {
      color = _colorAnimation!.value!;
    } else {
      color = _getColor(extension);
    }

    final TextEditingControllerWithHistory controller =
        context.watch<TextEditingControllerWithHistory>();

    final RobotoffNutrientEntity? robotoffNutrientEntity =
        widget.nutritionContainer.robotoffNutrientExtraction?.getNutrientEntity(
      widget.orderedNutrient.nutrient!,
      PerSize.oneHundredGrams,
    );

    String? extractionValue = robotoffNutrientEntity?.value;

    // We need to make sure the value is formatted properly
    if (extractionValue != null) {
      if (extractionValue != 'traces') {
        final num? extractionValueNum =
            NumberFormat().tryParse(extractionValue);
        if (extractionValueNum == null) {
          extractionValue = null;
        } else {
          try {
            // get a decent displayable numeric value if possible
            extractionValue =
                widget.decimalNumberFormat.format(extractionValueNum);
          } catch (e) {
            // at least we tried
          }
        }
      }
    }

    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: MEDIUM_SPACE,
          end: MEDIUM_SPACE,
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: KeyedSubtree(
                    key: Key('$key-value'),
                    child: _NutrientValueCell(
                      controller,
                      widget.decimalNumberFormat,
                      widget.orderedNutrient,
                      widget.position,
                      widget.isLast,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: KeyedSubtree(
                    key: Key('$key-unit'),
                    child: IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _NutrientUnitCell(
                              nutritionContainer: widget.nutritionContainer,
                              orderedNutrient: widget.orderedNutrient,
                            ),
                          ),
                          const _NutrientUnitVisibility()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (extractionValue != null && extractionValue != controller.text)
              Container(
                margin: const EdgeInsetsDirectional.only(
                  bottom: SMALL_SPACE,
                ),
                padding: const EdgeInsetsDirectional.only(
                  start: MEDIUM_SPACE,
                ),
                decoration: BoxDecoration(
                  color: extension.successBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: icons.Sparkles(
                        color: extension.success,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      extractionValue,
                      style: TextStyle(
                        color: extension.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Tooltip(
                      message: AppLocalizations.of(context)
                          .edit_product_form_item_add_suggestion,
                      child: IconButton(
                        onPressed: () {
                          controller.text = extractionValue!;
                          final Unit? unit = robotoffNutrientEntity?.unit;
                          if (unit != null) {
                            widget.nutritionContainer.setNutrientUnit(
                              widget.orderedNutrient.nutrient!,
                              unit,
                            );
                            AnalyticsHelper.trackRobotoffExtraction(
                              AnalyticsRobotoffEvents
                                  .robotoffNutritionInsightAccepted,
                              widget.orderedNutrient.nutrient!,
                              context.read<Product>(),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.add_circle_rounded,
                          color: extension.success,
                        ),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Color _getColor(SmoothColorsThemeExtension extension) =>
      widget.position.isEven ? extension.cellEven : extension.cellOdd;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _NutrientValueCell extends StatelessWidget {
  const _NutrientValueCell(
    this.controller,
    this.decimalNumberFormat,
    this.orderedNutrient,
    this.position,
    this.isLast,
  );

  final TextEditingControllerWithHistory controller;
  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Map<OrderedNutrient, FocusNode> focusNodes =
        context.watch<Map<OrderedNutrient, FocusNode>>();

    final Product product = context.watch<Product>();
    final bool isLast = position == focusNodes.length - 1;
    final Nutrient? nutrient = orderedNutrient.nutrient;

    final bool ownerFieldVisible = nutrient != null &&
        product.getOwnerFieldTimestamp(OwnerField.nutrient(nutrient)) != null;

    return Semantics(
      label: orderedNutrient.name,
      value: controller.text,
      textField: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => focusNodes[orderedNutrient]?.requestFocus(),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: VERY_SMALL_SPACE,
                          bottom: VERY_SMALL_SPACE,
                        ),
                        child: Text(
                          orderedNutrient.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: controller.isSet
                          ? Theme.of(context).inputDecorationTheme.fillColor
                          : Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: MEDIUM_SPACE,
                      ),
                      child: TextFormField(
                        controller: controller,
                        enabled: controller.isSet,
                        focusNode: focusNodes[orderedNutrient],
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        textInputAction: isLast ? null : TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            SimpleInputNumberField.getNumberRegExp(
                              decimal: true,
                            ),
                          ),
                          DecimalSeparatorRewriter(decimalNumberFormat),
                        ],
                        onFieldSubmitted: (final String value) {
                          focusNodes[orderedNutrient]?.unfocus();

                          if (isLast) {
                            return;
                          }

                          final int position =
                              focusNodes.keys.indexOf(orderedNutrient);

                          focusNodes[focusNodes.keys.elementAt(position + 1)]
                              ?.requestFocus();
                        },
                        validator: (String? value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value == 'traces') {
                            return null;
                          }
                          try {
                            decimalNumberFormat.parse(value);
                            return null;
                          } catch (e) {
                            return appLocalizations
                                .nutrition_page_invalid_number;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (ownerFieldVisible)
              IconButton(
                onPressed: () => showOwnerFieldInfoInModalSheet(context),
                icon: const OwnerFieldIcon(),
              )
            else
              const SizedBox(width: MEDIUM_SPACE),
          ],
        ),
      ),
    );
  }
}

class _NutrientUnitCell extends StatefulWidget {
  const _NutrientUnitCell({
    required this.nutritionContainer,
    required this.orderedNutrient,
  });

  final NutritionContainerHelper nutritionContainer;
  final OrderedNutrient orderedNutrient;

  @override
  State<_NutrientUnitCell> createState() => _NutrientUnitCellState();
}

class _NutrientUnitCellState extends State<_NutrientUnitCell> {
  @override
  Widget build(BuildContext context) {
    final Nutrient nutrient = getNutrient(widget.orderedNutrient);
    final Unit unit = widget.nutritionContainer.getUnit(nutrient);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: VERY_SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      child: _NutritionCellTextWatcher(
        builder: (_, TextEditingControllerWithHistory controller) {
          final List<Unit> units = widget.nutritionContainer.getUnits(nutrient);

          if (units.isEmpty) {
            units.add(unit);
          }

          return SmoothDropdownButton<Unit>(
            value: unit,
            textAlignment: AlignmentDirectional.center,
            items: units
                .map(
                  (final Unit unit) => SmoothDropdownItem<Unit>(
                    value: unit,
                    label: _getUnitLabel(unit),
                  ),
                )
                .toList(growable: false),
            onChanged: controller.isSet
                ? (final Unit? value) {
                    if (value == null) {
                      return;
                    }
                    setState(
                      () => widget.nutritionContainer
                          .setNextWeightUnit(widget.orderedNutrient),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }

  static const Map<Unit, String> _unitLabels = <Unit, String>{
    Unit.G: 'g',
    Unit.MILLI_G: 'mg',
    Unit.MICRO_G: 'mcg/µg',
    Unit.KJ: 'kJ',
    Unit.KCAL: 'kcal',
    Unit.PERCENT: '%',
  };

  static String _getUnitLabel(final Unit unit) =>
      _unitLabels[unit] ?? UnitHelper.unitToString(unit)!;
}

class _NutrientUnitVisibility extends StatelessWidget {
  const _NutrientUnitVisibility();

  @override
  Widget build(BuildContext context) {
    return _NutritionCellTextWatcher(
      builder: (
        BuildContext context,
        TextEditingControllerWithHistory controller,
      ) {
        final bool isValueSet = controller.isSet;

        return AspectRatio(
          aspectRatio: 1.0,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: isValueSet
                  ? context
                      .extension<SmoothColorsThemeExtension>()
                      .primarySemiDark
                  : Theme.of(context).disabledColor,
              shape: const CircleBorder(),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (isValueSet) {
                    controller.text = '-';
                  } else {
                    if (controller.previousValue != '-') {
                      controller.text = controller.previousValue ?? '-';
                    } else {
                      controller.text = '';
                    }
                  }
                },
                child: Icon(
                  isValueSet
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension NutritionTextEditionController on TextEditingController {
  bool get isSet => text.trim() != '-';

  bool get isNotSet => text.trim() == '-';
}

/// Use this Widget to be notified when the value is set or not
class _NutritionCellTextWatcher extends StatelessWidget {
  const _NutritionCellTextWatcher({
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    TextEditingControllerWithHistory value,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return Selector<TextEditingControllerWithHistory,
        TextEditingControllerWithHistory>(
      selector: (_, TextEditingControllerWithHistory controller) {
        return controller;
      },
      shouldRebuild: (_, TextEditingControllerWithHistory controller) {
        return controller.isDifferentFromPreviousValue;
      },
      builder: (BuildContext context,
          TextEditingControllerWithHistory controller, _) {
        return builder(context, controller);
      },
    );
  }
}

class NutritionFactsEditorExplanation extends StatelessWidget {
  const NutritionFactsEditorExplanation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExplanationTitleIcon(
      title: appLocalizations
          .edit_product_form_item_nutrition_facts_explanation_title,
      child: Column(
        children: <Widget>[
          ExplanationTextContainer(
            title: appLocalizations
                .edit_product_form_item_nutrition_facts_explanation_info1_title,
            items: <ExplanationTextContainerContent>[
              ExplanationTextContainerContentText(
                text: appLocalizations
                    .edit_product_form_item_nutrition_facts_explanation_info1_content,
              ),
              ExplanationTextContainerContentItem(
                text: appLocalizations.nutrition_page_per_100g,
                padding: EdgeInsets.zero,
              ),
              ExplanationTextContainerContentItem(
                text: appLocalizations.nutrition_page_per_100g_100ml,
                padding: const EdgeInsetsDirectional.only(
                  bottom: VERY_SMALL_SPACE,
                ),
              ),
            ],
          ),
          ExplanationTextContainer(
            title: appLocalizations
                .edit_product_form_item_nutrition_facts_explanation_info2_title,
            items: <ExplanationTextContainerContent>[
              ExplanationTextContainerContentText(
                text: appLocalizations
                    .edit_product_form_item_nutrition_facts_explanation_info2_content,
              ),
            ],
          ),
          ExplanationTextContainer(
            title: appLocalizations
                .edit_product_form_item_nutrition_facts_explanation_info3_title,
            items: <ExplanationTextContainerContent>[
              ExplanationTextContainerContentText(
                text: appLocalizations
                    .edit_product_form_item_nutrition_facts_explanation_info3_content,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
