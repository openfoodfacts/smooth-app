import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_dropdown.dart';

class NutrientRow extends StatelessWidget {
  const NutrientRow(
    this.nutritionContainer,
    this.decimalNumberFormat,
    this.orderedNutrient,
    this.position,
    this.isLast,
  );

  final NutritionContainerHelper nutritionContainer;
  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final String key = orderedNutrient.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: KeyedSubtree(
            key: Key('$key-value'),
            child: _NutrientValueCell(
              decimalNumberFormat,
              orderedNutrient,
              position,
              isLast,
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
                      nutritionContainer,
                      orderedNutrient,
                    ),
                  ),
                  const _NutrientUnitVisibility()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientValueCell extends StatelessWidget {
  const _NutrientValueCell(
    this.decimalNumberFormat,
    this.orderedNutrient,
    this.position,
    this.isLast,
  );

  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Map<OrderedNutrient, FocusNode> focusNodes =
        context.watch<Map<OrderedNutrient, FocusNode>>();
    final TextEditingControllerWithHistory controller =
        context.watch<TextEditingControllerWithHistory>();

    final Product product = context.watch<Product>();
    final bool isLast = position == focusNodes.length - 1;
    final Nutrient? nutrient = orderedNutrient.nutrient;

    return Semantics(
      label: orderedNutrient.name,
      value: controller.text,
      textField: true,
      excludeSemantics: true,
      child: TextFormField(
        controller: controller,
        enabled: controller.isSet,
        focusNode: focusNodes[orderedNutrient],
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(),
          labelText: orderedNutrient.name,
          suffixIcon: nutrient == null ||
                  product.getOwnerFieldTimestamp(
                          OwnerField.nutrient(nutrient)) ==
                      null
              ? null
              : IconButton(
                  onPressed: () => showOwnerFieldInfoInModalSheet(context),
                  icon: const OwnerFieldIcon(),
                ),
        ),
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: true,
        ),
        textInputAction: isLast ? null : TextInputAction.next,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            SimpleInputNumberField.getNumberRegExp(decimal: true),
          ),
          DecimalSeparatorRewriter(decimalNumberFormat),
        ],
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return null;
          }
          try {
            decimalNumberFormat.parse(value);
            return null;
          } catch (e) {
            return appLocalizations.nutrition_page_invalid_number;
          }
        },
      ),
    );
  }
}

class _NutrientUnitCell extends StatefulWidget {
  const _NutrientUnitCell(
    this.nutritionContainer,
    this.orderedNutrient,
  );

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
          child: Ink(
            decoration: ShapeDecoration(
              color: isValueSet
                  ? context
                      .extension<SmoothColorsThemeExtension>()
                      .primarySemiDark
                  : Theme.of(context).disabledColor,
              shape: const CircleBorder(),
            ),
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
