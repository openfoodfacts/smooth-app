import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(this.product, this.orderedNutrients);

  final Product product;
  final OrderedNutrients orderedNutrients;

  @override
  State<NutritionPageLoaded> createState() => _NutritionPageLoadedState();
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded> {
  // we admit both decimal points
  // anyway, the keyboard will only show one
  static final RegExp _decimalRegExp = RegExp(r'[0-9,.]');

  late final NumberFormat _numberFormat;
  late final NutritionContainer _nutritionContainer;

  bool _unspecified = false; // TODO(monsieurtanuki): fetch that data from API?
  // If true then serving, if false then 100g.
  bool _servingOr100g = false;

  double getColumnSizeFromContext(
    BuildContext context,
    double adjustmentFactor,
  ) {
    final double _columnSize = MediaQuery.of(context).size.width;
    return _columnSize * adjustmentFactor;
  }

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nutritionContainer = NutritionContainer(
      orderedNutrients: widget.orderedNutrients,
      product: widget.product,
    );
    _numberFormat = NumberFormat('####0.#####', ProductQuery.getLocaleString());
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<Widget> children = <Widget>[];
    children.add(_switchNoNutrition(localizations));
    if (!_unspecified) {
      children.add(_getServingField(localizations));
      children.add(_getServingSwitch(localizations));
      for (final OrderedNutrient orderedNutrient
          in _nutritionContainer.getDisplayableNutrients()) {
        children.add(
          _getNutrientRow(localizations, orderedNutrient),
        );
      }
      children.add(_addNutrientButton(localizations));
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            localizations.nutrition_page_title,
            maxLines: 2,
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => _validateAndSave(localizations, localDatabase),
              icon: const Icon(Icons.check),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Form(
            key: _formKey,
            child: ListView(children: children),
          ),
        ),
      ),
      //return a boolean to decide whether to return to previous page or not
      onWillPop: () => _showCancelPopup(localizations),
    );
  }

  Widget _getNutrientRow(
    final AppLocalizations appLocalizations,
    final OrderedNutrient orderedNutrient,
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
              _servingOr100g,
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
    final bool perServing,
  ) {
    final String valueKey = NutritionContainer.getValueKey(
      orderedNutrient.id,
      perServing,
    );
    final TextEditingController controller;
    if (_controllers[valueKey] != null) {
      controller = _controllers[valueKey]!;
    } else {
      final double? value = _nutritionContainer.getValue(valueKey);
      controller = TextEditingController();
      controller.text = value == null ? '' : _numberFormat.format(value);
      _controllers[valueKey] = controller;
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: orderedNutrient.name,
      ),
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: true,
      ),
      textInputAction: TextInputAction.next,
      autofillHints: const <String>[AutofillHints.transactionAmount],
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(_decimalRegExp),
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
    final TextEditingController controller = TextEditingController();
    controller.text = _nutritionContainer.servingSize ?? '';
    _controllers[NutritionContainer.fakeNutrientIdServingSize] = controller;
    return Padding(
      padding: const EdgeInsets.only(bottom: VERY_LARGE_SPACE),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: appLocalizations.nutrition_page_serving_size,
        ),
        textInputAction: TextInputAction.next,
        validator: (String? value) => null, // free text
      ),
    );
  }

  Widget _getServingSwitch(final AppLocalizations appLocalizations) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(appLocalizations.nutrition_page_per_100g),
          Switch(
            value: _servingOr100g,
            onChanged: (final bool value) =>
                setState(() => _servingOr100g = !_servingOr100g),
          ),
          Text(appLocalizations.nutrition_page_per_serving)
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
              value: _unspecified,
              onChanged: (final bool value) =>
                  setState(() => _unspecified = !_unspecified),
            ),
            SizedBox(
              width: getColumnSizeFromContext(context, 0.6),
              child: AutoSizeText(
                localizations.nutrition_page_unspecified,
                style: Theme.of(context).primaryTextTheme.bodyText1,
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
                    return AlertDialog(
                      title: Text(appLocalizations.nutrition_page_add_nutrient),
                      content: SizedBox(
                        // TODO(monsieurtanuki): proper sizes
                        width: 300,
                        height: 400,
                        child: Column(
                          children: <Widget>[
                            TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                border: const UnderlineInputBorder(),
                                labelText: appLocalizations.search,
                              ),
                              onChanged: (String query) {
                                setState(
                                  () {
                                    filteredList = leftovers
                                        .where((OrderedNutrient item) => item
                                            .name!
                                            .toLowerCase()
                                            .contains(query.toLowerCase()))
                                        .toList();
                                  },
                                );
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final OrderedNutrient nutrient =
                                        filteredList[index];
                                    return ListTile(
                                      title: Text(nutrient.name!),
                                      onTap: () =>
                                          Navigator.of(context).pop(nutrient),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLocalizations.cancel),
                        ),
                      ],
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

  Future<bool> _showCancelPopup(AppLocalizations localizations) async {
    //if no changes made then returns true to the onWillPop
    // allowing it to let the user return back to previous screen
    if (!_isEdited()) {
      return true;
    }
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            title: Text(localizations.general_confirmation),
            content: Text(localizations.nutrition_page_close_confirmation),
            actions: <TextButton>[
              TextButton(
                child: Text(localizations.cancel.toUpperCase()),
                // returns false to onWillPop after the alert dialog is closed with cancel button
                //blocking return to the previous screen
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text(localizations.okay.toUpperCase()),
                // returns true to onWillPop after the alert dialog is closed with close button
                //letting return to the previous screen
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        // in case alert dialog is closed, a false is return
        // blocking the return to the previous screen
        false;
  }

  Future<void> _validateAndSave(final AppLocalizations localizations,
      final LocalDatabase localDatabase) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _showSavePopup(localizations, localDatabase);
  }

  Future<void> _showSavePopup(
      AppLocalizations localizations, LocalDatabase localDatabase) async {
    final bool shouldSave = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text(localizations.general_confirmation),
                  content: Text(localizations.save_confirmation),
                  shape: const RoundedRectangleBorder(
                    borderRadius: ROUNDED_BORDER_RADIUS,
                  ),
                  actions: <TextButton>[
                    TextButton(
                      child: Text(localizations.cancel.toUpperCase()),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text(localizations.save.toUpperCase()),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                )) ??
        false;

    if (shouldSave) {
      _save(localDatabase);
    }
  }

  Future<void> _save(final LocalDatabase localDatabase) async {
    for (final String key in _controllers.keys) {
      final TextEditingController controller = _controllers[key]!;
      _nutritionContainer.setControllerText(key, controller.text);
    }
    // minimal product: we only want to save the nutrients
    final Product inputProduct = _nutritionContainer.getProduct();

    final bool savedAndRefreshed = await ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: inputProduct,
    );
    if (savedAndRefreshed) {
      Navigator.of(context).pop(true);
    }
  }

  bool _isEdited() {
    for (final String key in _controllers.keys) {
      final TextEditingController controller = _controllers[key]!;
      if (_nutritionContainer.getValue(key) != null) {
        if (_numberFormat.format(_nutritionContainer.getValue(key)) !=
            controller.value.text) {
          //if any controller is not equal to the value in the container
          // then the form is edited, return true
          return true;
        }
      }
    }
    //else form is not edited just return false
    return false;
  }
}
