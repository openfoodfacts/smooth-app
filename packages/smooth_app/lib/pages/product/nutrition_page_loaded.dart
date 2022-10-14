import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/model/Nutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/model/PerSize.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(
    this.product,
    this.orderedNutrients, {
    this.isLoggedInMandatory = true,
  });

  final Product product;
  final OrderedNutrients orderedNutrients;
  final bool isLoggedInMandatory;

  @override
  State<NutritionPageLoaded> createState() => _NutritionPageLoadedState();
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded> {
  // we admit both decimal points
  // anyway, the keyboard will only show one
  static final RegExp _decimalRegExp = RegExp(r'[\d,.]');

  late final NumberFormat _numberFormat;
  late final NutritionContainer _nutritionContainer;

  late bool _noNutritionData;
  final TextEditingControllerWithInitialValue _nutritionTextController =
      TextEditingControllerWithInitialValue();

  late NutritionUnit _nutritionUnit;
  late NutritionUnit _initialNutritionUnit;

  double getColumnSizeFromContext(
    BuildContext context,
    double adjustmentFactor,
  ) {
    final double columnSize = MediaQuery.of(context).size.width;
    return columnSize * adjustmentFactor;
  }

  final Map<String, TextEditingControllerWithInitialValue> _controllers =
      <String, TextEditingControllerWithInitialValue>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _nutritionContainer = _getFreshContainer(widget.product);
    _numberFormat = NumberFormat('####0.#####', ProductQuery.getLocaleString());
    _noNutritionData = _product.noNutritionData ?? false;
    _nutritionUnit = _initialNutritionUnit = _detectUnit(_product);
  }

  @override
  void dispose() {
    for (final TextEditingControllerWithInitialValue controller
        in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];

    // List of focus nodes for all text fields except the serving one.
    final List<FocusNode> focusNodes;

    children.add(_switchNoNutrition(appLocalizations));

    if (!_noNutritionData) {
      children.add(_getServingField(appLocalizations));
      children.add(_getServingSwitch(appLocalizations));

      final Iterable<OrderedNutrient> displayableNutrients =
          _nutritionContainer.getDisplayableNutrients();

      focusNodes = List<FocusNode>.generate(
        displayableNutrients.length,
        (_) => FocusNode(),
        growable: false,
      );

      for (int i = 0; i != displayableNutrients.length; i++) {
        children.add(
          _getNutrientRow(
              appLocalizations, displayableNutrients.elementAt(i), i),
        );
      }
      children.add(_addNutrientButton(appLocalizations));
    } else {
      focusNodes = <FocusNode>[];
    }

    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: AutoSizeText(
            appLocalizations.nutrition_page_title,
            maxLines: widget.product.productName?.isNotEmpty == true ? 1 : 2,
          ),
          subTitle: widget.product.productName != null
              ? Text(
                  widget.product.productName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Form(
                  key: _formKey,
                  child: Provider<List<FocusNode>>.value(
                    value: focusNodes,
                    child: ListView(children: children),
                  ),
                ),
              ),
              SmoothActionButtonsBar(
                axis: Axis.horizontal,
                positiveAction: SmoothActionButton(
                  text: appLocalizations.save,
                  onPressed: () async => _exitPage(
                    await _mayExitPage(saving: true),
                  ),
                ),
                negativeAction: SmoothActionButton(
                  text: appLocalizations.cancel,
                  onPressed: () async => _exitPage(
                    await _mayExitPage(saving: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNutrientRow(
    final AppLocalizations appLocalizations,
    final OrderedNutrient orderedNutrient,
    int position,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: getColumnSizeFromContext(context, 0.6),
            child: _getNutrientCell(
              appLocalizations,
              orderedNutrient,
              _nutritionUnit,
              position,
            ),
          ),
          SizedBox(
            width: getColumnSizeFromContext(context, 0.3),
            child: _getUnitCell(orderedNutrient),
          ),
        ],
      );

  Widget _getNutrientCell(
    final AppLocalizations appLocalizations,
    final OrderedNutrient orderedNutrient,
    final NutritionUnit nutritionUnit,
    final int position,
  ) {
    final String valueKey = NutritionContainer.getValueKey(
      orderedNutrient.id,
      nutritionUnit,
    );

    final TextEditingControllerWithInitialValue controller;
    if (_controllers[valueKey] != null) {
      controller = _controllers[valueKey]!;
    } else {
      // If a value is available for the other unit, let's switch the values
      String? otherUnitKey;
      if (_nutritionUnit == NutritionUnit.perServing &&
          valueKey.endsWith('_serving')) {
        otherUnitKey =
            '${valueKey.substring(0, valueKey.lastIndexOf('_serving'))}_100g';
      } else if (_nutritionUnit == NutritionUnit.per100g) {
        // Only case, where "_serving" is missing at the end
        if (valueKey == 'energy-kcal_100g') {
          otherUnitKey = 'energy-kcal';
        } else if (valueKey.endsWith('_100g')) {
          otherUnitKey =
              '${valueKey.substring(0, valueKey.lastIndexOf('_100g'))}_serving';
        }
      }

      if (otherUnitKey != null && _controllers[otherUnitKey] != null) {
        _controllers[valueKey] = _controllers[otherUnitKey]!;
        _controllers.remove(otherUnitKey);
      } else {
        final double? value = _nutritionContainer.getValue(valueKey);
        _controllers[valueKey] = TextEditingControllerWithInitialValue(
          text: value == null ? '' : _numberFormat.format(value),
        );
      }

      controller = _controllers[valueKey]!;
    }

    return Builder(
      builder: (BuildContext context) {
        final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
          context,
          listen: false,
        );

        final bool isLast = position == focusNodes.length - 1;

        return TextFormField(
          controller: controller,
          focusNode: focusNodes[position],
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(),
            labelText: orderedNutrient.name,
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          textInputAction: isLast ? TextInputAction.send : TextInputAction.next,
          onFieldSubmitted: (_) async {
            if (!isLast) {
              // Move to next field
              focusNodes[position + 1].requestFocus();
            } else {
              // Save page content
              _exitPage(
                await _mayExitPage(saving: true),
              );
            }
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(_decimalRegExp),
            DecimalSeparatorRewriter(_numberFormat),
          ],
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return null;
            }
            try {
              _numberFormat.parse(value);
              return null;
            } catch (e) {
              return appLocalizations.nutrition_page_invalid_number;
            }
          },
        );
      },
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

  Widget _getUnitCell(final OrderedNutrient orderedNutrient) {
    final Unit unit = _nutritionContainer.getUnit(orderedNutrient.id);
    return ElevatedButton(
      onPressed: NutritionContainer.isEditableWeight(orderedNutrient)
          ? () => setState(
                () => _nutritionContainer.setNextWeightUnit(orderedNutrient),
              )
          : null,
      child: Text(
        _getUnitLabel(unit),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _getServingField(final AppLocalizations appLocalizations) {
    final String value = _nutritionContainer.servingSize ?? '';

    if (_controllers[NutritionContainer.fakeNutrientIdServingSize] != null) {
      _controllers[NutritionContainer.fakeNutrientIdServingSize]!.text = value;
    } else {
      _controllers[NutritionContainer.fakeNutrientIdServingSize] =
          TextEditingControllerWithInitialValue(text: value);
    }

    final TextEditingControllerWithInitialValue controller =
        _controllers[NutritionContainer.fakeNutrientIdServingSize]!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: VERY_LARGE_SPACE),
      child: Builder(
        builder: (BuildContext context) {
          return TextFormField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(),
              labelText: appLocalizations.nutrition_page_serving_size,
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              // Move to the first TextField
              final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
                context,
                listen: false,
              );

              if (focusNodes.isNotEmpty) {
                focusNodes[0].requestFocus();
              }
            },
            validator: (String? value) => null, // free text
          );
        },
      ),
    );
  }

  Widget _getServingSwitch(final AppLocalizations appLocalizations) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: _nutritionUnit == NutritionUnit.per100g
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : const TextStyle(),
                child: Text(
                  appLocalizations.nutrition_page_per_100g,
                ),
              ),
            ),
          ),
          Switch(
            value: _nutritionUnit == NutritionUnit.perServing,
            onChanged: (final bool value) => setState(
              () => _nutritionUnit =
                  value ? NutritionUnit.perServing : NutritionUnit.per100g,
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: _nutritionUnit == NutritionUnit.perServing
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : const TextStyle(),
                child: Text(
                  appLocalizations.nutrition_page_per_serving,
                ),
              ),
            ),
          )
        ],
      );

  Widget _switchNoNutrition(final AppLocalizations localizations) => SmoothCard(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: SMALL_SPACE,
        ),
        margin: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: _noNutritionData,
              onChanged: (final bool value) =>
                  setState(() => _noNutritionData = !_noNutritionData),
              trackColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(
              width: getColumnSizeFromContext(context, 0.6),
              child: AutoSizeText(
                localizations.nutrition_page_unspecified,
                style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _addNutrientButton(final AppLocalizations appLocalizations) =>
      ElevatedButton.icon(
        onPressed: () async {
          final List<OrderedNutrient> leftovers = List<OrderedNutrient>.from(
            _nutritionContainer.getLeftoverNutrients(),
          );
          leftovers.sort((final OrderedNutrient a, final OrderedNutrient b) =>
              a.name!.compareTo(b.name!));
          List<OrderedNutrient> filteredList =
              List<OrderedNutrient>.from(leftovers);
          final OrderedNutrient? selected = await showDialog<OrderedNutrient>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(VoidCallback fn) setState) {
                    return SmoothAlertDialog(
                      body: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            SmoothTextFormField(
                              prefixIcon: const Icon(Icons.search),
                              hintText: appLocalizations.search,
                              type: TextFieldTypes.PLAIN_TEXT,
                              controller: _nutritionTextController,
                              onChanged: (String? query) {
                                setState(
                                  () {
                                    filteredList = leftovers
                                        .where((OrderedNutrient item) => item
                                            .name!
                                            .toLowerCase()
                                            .contains(query!.toLowerCase()))
                                        .toList();
                                  },
                                );
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  final OrderedNutrient nutrient =
                                      filteredList[index];
                                  return ListTile(
                                    title: Text(nutrient.name!),
                                    onTap: () =>
                                        Navigator.of(context).pop(nutrient),
                                  );
                                },
                                itemCount: filteredList.length,
                                shrinkWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      positiveAction: SmoothActionButton(
                        onPressed: () => Navigator.pop(context),
                        text: appLocalizations.cancel,
                      ),
                    );
                  },
                );
              });
          if (selected != null) {
            setState(() => _nutritionContainer.add(selected));
          }
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
              side: BorderSide.none,
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(appLocalizations.nutrition_page_add_nutrient),
      );

  /// Returns `true` if any value differs between form and container.
  bool _isEdited() => _nutritionContainer.isEdited(
        _controllers,
        _numberFormat,
        _noNutritionData,
        _unitAsChanged,
      );

  Product? _getChangedProduct(Product product) {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    // We use a separate fresh container here.
    // If something breaks while saving, we won't get a half written object.
    final NutritionContainer output = _getFreshContainer(product);
    // we copy the values
    for (final String key in _controllers.keys) {
      final TextEditingControllerWithInitialValue controller =
          _controllers[key]!;
      output.setControllerText(key, controller.text);
    }

    // we copy the "with nutrition data true/false"
    output.noNutritionData = _noNutritionData;

    // we copy the units
    output.copyUnitsFrom(_nutritionContainer);

    return output.getProduct(product);
  }

  NutritionContainer _getFreshContainer(Product product) => NutritionContainer(
        orderedNutrients: widget.orderedNutrients,
        product: product,
      );

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (!_isEdited()) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final UpToDateProductProvider provider =
        context.read<UpToDateProductProvider>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    if (!saving) {
      final bool? pleaseSave = await showDialog<bool>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          close: true,
          body: Text(appLocalizations.edit_product_form_item_exit_confirmation),
          title: appLocalizations.nutrition_page_title,
          negativeAction: SmoothActionButton(
            text: appLocalizations.ignore,
            onPressed: () => Navigator.pop(context, false),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations.save,
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
      );
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
    }

    final Product? changedProduct =
        _getChangedProduct(Product(barcode: widget.product.barcode));
    Product? cachedProduct = await daoProduct.get(
      _product.barcode!,
    );
    if (cachedProduct != null) {
      cachedProduct = _getChangedProduct(_product);
    }

    if (changedProduct == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // here I cheat and I reuse the only invalid case.
            content: Text(appLocalizations.nutrition_page_invalid_number),
          ),
        );
      }
      return false;
    }
    // if it fails, we stay on the same page
    await BackgroundTaskDetails.addTask(
      changedProduct,
      productEditTask: ProductEditTask.nutrition,
    );
    final Product upToDateProduct = cachedProduct ?? changedProduct;
    await daoProduct.put(upToDateProduct);
    provider.set(upToDateProduct);
    localDatabase.notifyListeners();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_task_background_schedule),
        ),
      );
    }
    return true;
  }

  NutritionUnit _detectUnit(Product product) {
    if (product.nutriments == null) {
      return NutritionUnit.per100g;
    } else if (_hasNutrientsInServingSize(product)) {
      return NutritionUnit.perServing;
    } else {
      return NutritionUnit.per100g;
    }
  }

  bool _hasNutrientsInServingSize(Product product) {
    if (product.nutriments == null) {
      return false;
    }

    for (final Nutrient e in Nutrient.values) {
      final double? value = product.nutriments!.getValue(e, PerSize.serving);
      if (value != null) {
        return true;
      }
    }
    return false;
  }

  bool get _unitAsChanged => _nutritionUnit != _initialNutritionUnit;
}
