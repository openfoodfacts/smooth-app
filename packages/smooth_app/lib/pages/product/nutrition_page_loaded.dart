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
  late final RegExp _decimalRegExp;
  late final NumberFormat _numberFormat;
  late final NutritionContainer _nutritionContainer;

  bool _unspecified = false; // TODO(monsieurtanuki): fetch that data from API?
  // If true then serving, if false then 100g.
  bool _servingOr100g = false;

  static const double _columnSize1 = 250; // TODO(monsieurtanuki): proper size
  static const double _columnSize2 =
      100; // TODO(monsieurtanuki): anyway, should fit the largest text, probably 'mcg/µg'

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
    _decimalRegExp = _numberFormat.format(1.2).contains('.')
        ? RegExp(r'[0-9\.]') // TODO(monsieurtanuki): check if . or \.
        : RegExp(r'[0-9,]');
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<Widget> children = <Widget>[];
    children.add(_switchNoNutrition(appLocalizations));
    if (!_unspecified) {
      children.add(_getServingField(appLocalizations));
      children.add(_getServingSwitch(appLocalizations));
      for (final OrderedNutrient orderedNutrient
          in _nutritionContainer.getDisplayableNutrients()) {
        children.add(
          _getNutrientRow(
            appLocalizations,
            orderedNutrient,
          ),
        );
      }
      children.add(_addNutrientButton(appLocalizations));
    }
    children.add(_addCancelSaveButtons(
      appLocalizations,
      localDatabase,
    ));

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.nutrition_page_title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(children: children),
        ),
      ),
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
            width: _columnSize1,
            child: _getNutrientCell(
              appLocalizations,
              orderedNutrient,
              _servingOr100g,
            ),
          ),
          SizedBox(
            width: _columnSize2,
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
        mainAxisAlignment: MainAxisAlignment.start,
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

  Widget _switchNoNutrition(final AppLocalizations appLocalizations) =>
      Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: _unspecified,
              onChanged: (final bool value) =>
                  setState(() => _unspecified = !_unspecified),
            ),
            SizedBox(
              width: 300, // TODO(monsieurtanuki): proper size
              child: Text(
                appLocalizations.nutrition_page_unspecified,
                style: const TextStyle(color: Colors.white),
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
          final OrderedNutrient? selected = await showDialog<OrderedNutrient>(
              context: context,
              builder: (BuildContext context) {
                final List<Widget> children = <Widget>[];
                for (final OrderedNutrient nutrient in leftovers) {
                  children.add(
                    ListTile(
                      title: Text(nutrient.name!),
                      onTap: () => Navigator.pop(context, nutrient),
                    ),
                  );
                }
                return AlertDialog(
                  title: Text(appLocalizations.nutrition_page_add_nutrient),
                  content: SizedBox(
                    // TODO(monsieurtanuki): proper sizes
                    width: 300,
                    height: 400,
                    child: ListView(children: children),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(appLocalizations.cancel),
                    ),
                  ],
                );
              });
          if (selected != null) {
            setState(() => _nutritionContainer.add(selected));
          }
        },
        icon: const Icon(Icons.add),
        label: Text(appLocalizations.nutrition_page_add_nutrient),
      );

  Widget _addCancelSaveButtons(
    final AppLocalizations appLocalizations,
    final LocalDatabase localDatabase,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              await _save(localDatabase);
            },
            child: Text(appLocalizations.save),
          ),
        ],
      );

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
}
