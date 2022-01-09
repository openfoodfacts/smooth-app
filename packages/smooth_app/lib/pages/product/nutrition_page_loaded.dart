import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  static const Map<Unit, Unit> _nextWeightUnits = <Unit, Unit>{
    Unit.G: Unit.MILLI_G,
    Unit.MILLI_G: Unit.MICRO_G,
    Unit.MICRO_G: Unit.G,
  };
  static const Map<Unit, String> _weightUnitLabels = <Unit, String>{
    Unit.G: 'g',
    Unit.MILLI_G: 'mg',
    Unit.MICRO_G: 'mcg/µg',
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
    children.add(
      Container(
        color: Colors.blue, // TODO(monsieurtanuki): change it to app color
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
      ),
    );
    if (!_unspecified) {
      children.add(
        Row(
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
        ),
      );
      for (final OrderedNutrient orderedNutrient in _displayableList) {
        final Widget? item = _getNutrientWidget(orderedNutrient);
        if (item != null) {
          children.add(item);
        }
      }
      children.add(
        ElevatedButton.icon(
          onPressed: () async {
            final List<OrderedNutrient> availables = <OrderedNutrient>[];
            for (final OrderedNutrient orderedNutrient in _displayableList) {
              final String id = orderedNutrient.id;
              final dynamic value = _getValue(id);
              final bool addAble = value == null && !orderedNutrient.important;
              if (addAble) {
                availables.add(orderedNutrient);
              }
            }
            availables.sort(
                (final OrderedNutrient a, final OrderedNutrient b) =>
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
        ),
      );
    }

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
    final String id = orderedNutrient.id;
    final dynamic value = _getValue(id);
    if (value == null && !orderedNutrient.important) {
      return null;
    }
    final TextEditingController controller = TextEditingController();
    controller.text = value == null ? '' : _numberFormat.format(value);
    _controllers[id] = controller;
    final List<Widget> rowItems = <Widget>[];
    rowItems.add(
      const ElevatedButton(
        onPressed: null, // TODO(monsieurtanuki): put different values?
        child: Text('='),
      ),
    );
    rowItems.add(
      SizedBox(
        width: 150, // TODO(monsieurtanuki): proper size
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
    bool isWeight = true;
    Unit? unit = _getUnit(id);
    if (id == 'energy-kcal') {
      unit = Unit.KCAL;
      isWeight = false;
    }
    if (id == 'energy-kj') {
      unit = Unit.KJ;
      isWeight = false;
    }
    if (id == 'energy') {
      if (unit == Unit.UNKNOWN || unit == null) {
        unit = Unit.KJ; // TODO(monsieurtanuki): is that a fact?
      }
      isWeight = false;
    }
    unit ??= Unit.G;
    rowItems.add(
      SizedBox(
        width:
            100, // TODO(monsieurtanuki): anyway, should fit the largest text, probably 'mcg/µg'
        child: ElevatedButton(
          onPressed: isWeight
              ? () => setState(
                    () => _setUnit(id, _nextWeightUnits[unit]!),
                  )
              : null,
          child: Text(_getUnitLabel(unit)),
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowItems,
    );
  }

  Unit? _getUnit(final String nutrientId) => UnitHelper.stringToUnit(
        _values[_getUnitValueTag(nutrientId)] as String?,
      );

  dynamic _getValue(final String nutrientId) =>
      _values[_getUnitServingTag(nutrientId)];

  void _initValue(final String nutrientId) =>
      _values[_getUnitServingTag(nutrientId)] = 0;

  void _setUnit(final String nutrientId, final Unit unit) =>
      _values[_getUnitValueTag(nutrientId)] = UnitHelper.unitToString(unit);

  String _getUnitValueTag(final String nutrientId) => '${nutrientId}_unit';

  String _getUnitServingTag(final String nutrientId) =>
      '$nutrientId${_perServing ? '_serving' : '_100g'}';

  String _getUnitLabel(final Unit unit) =>
      _weightUnitLabels[unit] ?? UnitHelper.unitToString(unit)!;
}
