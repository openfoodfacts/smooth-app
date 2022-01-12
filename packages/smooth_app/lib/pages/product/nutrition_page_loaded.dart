import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/interface/JsonObject.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:smooth_app/database/product_query.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(this.product, this.orderedNutrients);

  final Product product;
  final OrderedNutrients orderedNutrients;

  @override
  State<NutritionPageLoaded> createState() => _NutritionPageLoadedState();
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded> {
  final List<OrderedNutrient> _displayableList = <OrderedNutrient>[];
  late Map<String, dynamic> _values;
  late RegExp _decimalRegExp;
  late NumberFormat _numberFormat;

  bool _perServing = false;
  bool _unspecified = false;

  static const double _columnSize1 =
      50; // TODO(monsieurtanuki): possible values: < > =
  static const double _columnSize2 = 150; // TODO(monsieurtanuki): proper size
  static const double _columnSize3 =
      100; // TODO(monsieurtanuki): anyway, should fit the largest text, probably 'mcg/µg'

  static const String _fakeNutrientIdServingSize = '_servingSize';

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  static const Map<Unit, Unit> _nextWeightUnits = <Unit, Unit>{
    Unit.G: Unit.MILLI_G,
    Unit.MILLI_G: Unit.MICRO_G,
    Unit.MICRO_G: Unit.G,
  };
  static const Map<Unit, String> _unitLabels = <Unit, String>{
    Unit.G: 'g',
    Unit.MILLI_G: 'mg',
    Unit.MICRO_G: 'mcg/µg',
    Unit.KJ: 'kJ',
    Unit.KCAL: 'kcal',
    Unit.PERCENT: '%',
  };

  @override
  void initState() {
    super.initState();
    _populateOrderedNutrientList(widget.orderedNutrients.nutrients);
    _values = widget.product.nutriments!.toJson();
    _numberFormat = NumberFormat('####0.#####', ProductQuery.getLocaleString());
    _decimalRegExp = _numberFormat.format(1.2).contains('.')
        ? RegExp(r'[0-9\.]') // TODO(monsieurtanuki): check if . or \.
        : RegExp(r'[0-9,]');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<Widget> children = <Widget>[];
    children.add(_switchNoNutrition(appLocalizations));
    if (!_unspecified) {
      children.add(_switch100gServing(appLocalizations));
      children.add(_getServingWidget(appLocalizations));
      for (final OrderedNutrient orderedNutrient in _displayableList) {
        final Widget? item = _getNutrientWidget(orderedNutrient);
        if (item != null) {
          children.add(item);
        }
      }
      children.add(_addNutrientButton(appLocalizations));
    }
    children.add(_addCancelSaveButtons(appLocalizations));

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.nutrition_page_title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: children),
      ),
    );
  }

  void _populateOrderedNutrientList(final List<OrderedNutrient>? list) {
    if (list == null) {
      return;
    }
    for (final OrderedNutrient nutrient in list) {
      _displayableList.add(nutrient);
      _populateOrderedNutrientList(nutrient.subNutrients);
    }
  }

  Widget? _getNutrientWidget(final OrderedNutrient orderedNutrient) {
    const String energyId = 'energy';
    const String energyKJId = 'energy-kj';
    const String energyKCalId = 'energy-kcal';
    final String id = orderedNutrient.id;
    if (id == energyId) {
      // we keep only kj and kcal
      return null;
    }
    double? value = _getValue(id);
    if (value == null && !orderedNutrient.important) {
      return null;
    }
    final TextEditingController controller = TextEditingController();
    final Unit? defaultNotWeightUnit = _getDefaultNotWeightUnit(id);
    final bool isWeight = defaultNotWeightUnit == null;
    final Unit unit = _getUnit(id) ?? defaultNotWeightUnit ?? Unit.G;
    if (value == null) {
      if (id == energyKJId || id == energyKCalId) {
        final double? valueEnergy = _getValue(energyId);
        final Unit? unitEnergy = _getUnit(energyId);
        if (id == energyKJId) {
          if (unitEnergy == Unit.KJ) {
            value = valueEnergy;
          }
        } else if (id == energyKCalId) {
          if (unitEnergy == Unit.KCAL) {
            value = valueEnergy;
          }
        }
      }
    }
    value = _convertValue(value, unit);
    controller.text = value == null ? '' : _numberFormat.format(value);
    _controllers[id] = controller;
    final List<Widget> rowItems = <Widget>[];
    rowItems.add(
      SizedBox(
        width: _columnSize1,
        child: id == energyKCalId || id == energyKJId
            ? null
            : const ElevatedButton(
                onPressed: null, // TODO(monsieurtanuki): put different values?
                child: Text('='),
              ),
      ),
    );
    rowItems.add(
      SizedBox(
        width: _columnSize2,
        child: TextFormField(
          controller: _controllers[id],
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
          validator: (String? value) => null,
        ),
      ),
    );
    rowItems.add(
      SizedBox(
        width: _columnSize3,
        child: ElevatedButton(
          onPressed: isWeight
              ? () => setState(
                    () => _setUnit(id, _nextWeightUnits[unit]!),
                  )
              : null,
          child: Text(
            _getUnitLabel(unit),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowItems,
    );
  }

  Widget _getServingWidget(final AppLocalizations appLocalizations) {
    const String id = _fakeNutrientIdServingSize;
    final TextEditingController controller = TextEditingController();
    controller.text = widget.product.servingSize ?? '';
    _controllers[id] = controller;
    final List<Widget> rowItems = <Widget>[];
    rowItems.add(const SizedBox(width: _columnSize1));
    rowItems.add(
      SizedBox(
        width: _columnSize2,
        child: TextFormField(
          controller: _controllers[id],
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: appLocalizations.nutrition_page_serving_size,
          ),
          textInputAction: TextInputAction.next,
          validator: (String? value) => null,
        ),
      ),
    );
    rowItems.add(const SizedBox(width: _columnSize3));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowItems,
    );
  }

  Unit? _getUnit(final String nutrientId) => UnitHelper.stringToUnit(
        _values[_getUnitValueTag(nutrientId)] as String?,
      );

  double? _getValue(final String nutrientId) =>
      JsonObject.parseDouble(_values[_getUnitServingTag(nutrientId)]);

  void _initValue(final String nutrientId) =>
      _values[_getUnitServingTag(nutrientId)] = 0;

  void _setUnit(final String nutrientId, final Unit unit) =>
      _values[_getUnitValueTag(nutrientId)] = UnitHelper.unitToString(unit);

  String _getUnitValueTag(final String nutrientId) => '${nutrientId}_unit';

  String _getUnitServingTag(final String nutrientId) =>
      '$nutrientId${_perServing ? '_serving' : '_100g'}';

  String _getUnitLabel(final Unit unit) =>
      _unitLabels[unit] ?? UnitHelper.unitToString(unit)!;

  // For the moment we only care about "weight or not weight?"
  static const Map<String, Unit> _defaultNotWeightUnits = <String, Unit>{
    'energy-kj': Unit.KJ,
    'energy-kcal': Unit.KCAL,
    'alcohol': Unit.PERCENT,
    'cocoa': Unit.PERCENT,
    'collagen-meat-protein-ratio': Unit.PERCENT,
    'fruits-vegetables-nuts': Unit.PERCENT,
    'fruits-vegetables-nuts-dried': Unit.PERCENT,
    'fruits-vegetables-nuts-estimate': Unit.PERCENT,
  };

  // TODO(monsieurtanuki): could be refined with values taken from https://static.openfoodfacts.org/data/taxonomies/nutrients.json
  Unit? _getDefaultNotWeightUnit(final String nutrientId) =>
      _defaultNotWeightUnits[nutrientId];

  double? _convertValue(final double? value, final Unit unit) {
    if (value == null) {
      return null;
    }
    if (unit == Unit.MILLI_G) {
      return 1E3 * value;
    }
    if (unit == Unit.MICRO_G) {
      return 1E6 * value;
    }
    return value;
  }

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

  Widget _switch100gServing(final AppLocalizations appLocalizations) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(appLocalizations.nutrition_page_per_100g),
          Switch(
            value: _perServing,
            onChanged: (final bool value) =>
                setState(() => _perServing = !_perServing),
          ),
          Text(appLocalizations.nutrition_page_per_serving),
        ],
      );

  Widget _addNutrientButton(final AppLocalizations appLocalizations) =>
      ElevatedButton.icon(
        onPressed: () async {
          final List<OrderedNutrient> availables = <OrderedNutrient>[];
          for (final OrderedNutrient orderedNutrient in _displayableList) {
            final String id = orderedNutrient.id;
            final double? value = _getValue(id);
            final bool addAble = value == null && !orderedNutrient.important;
            if (addAble) {
              availables.add(orderedNutrient);
            }
          }
          availables.sort((final OrderedNutrient a, final OrderedNutrient b) =>
              a.name!.compareTo(b.name!));
          final OrderedNutrient? selected = await showDialog<OrderedNutrient>(
              context: context,
              builder: (BuildContext context) {
                final List<Widget> children = <Widget>[];
                for (final OrderedNutrient nutrient in availables) {
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
            setState(() => _initValue(selected.id));
          }
        },
        icon: const Icon(Icons.add),
        label: Text(appLocalizations.nutrition_page_add_nutrient),
      );

  Widget _addCancelSaveButtons(final AppLocalizations appLocalizations) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {}, // TODO(monsieurtanuki): actually save
            child: Text(appLocalizations.save),
          ),
        ],
      );
}
