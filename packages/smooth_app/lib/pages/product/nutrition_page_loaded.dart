import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/interface/JsonObject.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

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

  bool _unspecified = false; // TODO(monsieurtanuki): fetch that data from API?
  bool _servingOr100g = false;

  static const double _columnSize1 = 250; // TODO(monsieurtanuki): proper size
  static const double _columnSize2 =
      100; // TODO(monsieurtanuki): anyway, should fit the largest text, probably 'mcg/µg'

  static const String _fakeNutrientIdServingSize = '_servingSize';
  static const String _energyId = 'energy';
  static const String _energyKJId = 'energy-kj';
  static const String _energyKCalId = 'energy-kcal';

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, Unit> _units = <String, Unit>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<Widget> children = <Widget>[];
    children.add(_switchNoNutrition(appLocalizations));
    if (!_unspecified) {
      children.add(_getServingField(appLocalizations));
      children.add(_getServingSwitch(appLocalizations));
      for (final OrderedNutrient orderedNutrient in _displayableList) {
        final Widget? item = _getNutrientWidget(
          appLocalizations,
          orderedNutrient,
        );
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
        child: Form(
          key: _formKey,
          child: ListView(children: children),
        ),
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

  Widget? _getNutrientWidget(
    final AppLocalizations appLocalizations,
    final OrderedNutrient orderedNutrient,
  ) {
    final String id = orderedNutrient.id;
    if (id == _energyId) {
      // we keep only kj and kcal
      return null;
    }
    final double? value100g = _getValue(id, false);
    final double? valueServing = _getValue(id, true);
    if (value100g == null &&
        valueServing == null &&
        !orderedNutrient.important) {
      return null;
    }
    return Row(
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
          child: _getUnitCell(id),
        ),
      ],
    );
  }

  Widget _getNutrientCell(
    final AppLocalizations appLocalizations,
    final OrderedNutrient orderedNutrient,
    final bool perServing,
  ) {
    final String id = orderedNutrient.id;
    final String tag = _getNutrientServingTag(id, perServing);
    final TextEditingController controller;
    if (_controllers[tag] != null) {
      controller = _controllers[tag]!;
    } else {
      double? value = _getValue(id, perServing);
      final Unit? defaultNotWeightUnit = _getDefaultNotWeightUnit(id);
      final Unit unit = _getUnit(id) ?? defaultNotWeightUnit ?? Unit.G;
      if (value == null) {
        if (id == _energyKJId || id == _energyKCalId) {
          final double? valueEnergy = _getValue(_energyId, perServing);
          final Unit? unitEnergy = _getUnit(_energyId);
          if (id == _energyKJId) {
            if (unitEnergy == Unit.KJ) {
              value = valueEnergy;
            }
          } else if (id == _energyKCalId) {
            if (unitEnergy == Unit.KCAL) {
              value = valueEnergy;
            }
          }
        }
      }
      value = _convertValueFromG(value, unit);
      controller = TextEditingController();
      controller.text = value == null ? '' : _numberFormat.format(value);
      _controllers[tag] = controller;
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

  Widget _getUnitCell(final String nutrientId) {
    final Unit? defaultNotWeightUnit = _getDefaultNotWeightUnit(nutrientId);
    final bool isWeight = defaultNotWeightUnit == null;
    final Unit unit;
    final String tag = _getNutrientIdFromServingTag(nutrientId);
    if (_units[tag] != null) {
      unit = _units[tag]!;
    } else {
      unit = _getUnit(nutrientId) ?? defaultNotWeightUnit ?? Unit.G;
      _units[tag] = unit;
    }
    return ElevatedButton(
      onPressed: isWeight
          ? () => setState(
                () => _setUnit(
                  nutrientId,
                  _units[nutrientId] = _nextWeightUnits[unit]!,
                ),
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
    controller.text = widget.product.servingSize ?? '';
    _controllers[_fakeNutrientIdServingSize] = controller;
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

  Unit? _getUnit(final String nutrientId) => UnitHelper.stringToUnit(
        _values[_getUnitValueTag(nutrientId)] as String?,
      );

  double? _getValue(final String nutrientId, final bool perServing) =>
      JsonObject.parseDouble(
          _values[_getNutrientServingTag(nutrientId, perServing)]);

  void _initValues(final String nutrientId) =>
      _values[_getNutrientServingTag(nutrientId, true)] =
          _values[_getNutrientServingTag(nutrientId, false)] = 0;

  void _setUnit(final String nutrientId, final Unit unit) =>
      _values[_getUnitValueTag(nutrientId)] = UnitHelper.unitToString(unit);

  String _getUnitValueTag(final String nutrientId) => '${nutrientId}_unit';

  // note: 'energy-kcal' is directly for serving (no 'energy-kcal_serving')
  String _getNutrientServingTag(
    final String nutrientId,
    final bool perServing,
  ) =>
      nutrientId == _energyKCalId && perServing
          ? _energyKCalId
          : '$nutrientId${perServing ? '_serving' : '_100g'}';

  String _getNutrientIdFromServingTag(final String key) =>
      key.replaceAll('_100g', '').replaceAll('_serving', '');

  String _getUnitLabel(final Unit unit) =>
      _unitLabels[unit] ?? UnitHelper.unitToString(unit)!;

  // For the moment we only care about "weight or not weight?"
  static const Map<String, Unit> _defaultNotWeightUnits = <String, Unit>{
    _energyKJId: Unit.KJ,
    _energyKCalId: Unit.KCAL,
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

  double? _convertValueFromG(final double? value, final Unit unit) {
    if (value == null) {
      return null;
    }
    if (unit == Unit.MILLI_G) {
      return value * 1E3;
    }
    if (unit == Unit.MICRO_G) {
      return value * 1E6;
    }
    return value;
  }

  double? _convertValueToG(final double? value, final Unit unit) {
    if (value == null) {
      return null;
    }
    if (unit == Unit.MILLI_G) {
      return value / 1E3;
    }
    if (unit == Unit.MICRO_G) {
      return value / 1E6;
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

  Widget _addNutrientButton(final AppLocalizations appLocalizations) =>
      ElevatedButton.icon(
        onPressed: () async {
          final List<OrderedNutrient> availables = <OrderedNutrient>[];
          for (final OrderedNutrient orderedNutrient in _displayableList) {
            final String id = orderedNutrient.id;
            final double? value100g = _getValue(id, false);
            final double? valueServing = _getValue(id, true);
            final bool addAble = value100g == null &&
                valueServing == null &&
                !orderedNutrient.important;
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
            setState(() => _initValues(selected.id));
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
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              await _save();
            },
            child: Text(appLocalizations.save),
          ),
        ],
      );

  Future<void> _save() async {
    final Map<String, dynamic> map = <String, dynamic>{};
    String? servingSize;
    for (final String key in _controllers.keys) {
      final TextEditingController controller = _controllers[key]!;
      final String text = controller.text;
      if (key == _fakeNutrientIdServingSize) {
        servingSize = text;
      } else {
        if (text.isNotEmpty) {
          final String nutrientId = _getNutrientIdFromServingTag(key);
          final Unit unit = _units[nutrientId]!;
          map[_getUnitValueTag(nutrientId)] = UnitHelper.unitToString(unit);
          map[key] = _convertValueToG(
              _numberFormat.parse(text).toDouble(), unit); // careful with comma
        }
      }
    }
    final Nutriments nutriments = Nutriments.fromJson(map);
    widget.product.nutriments =
        nutriments; // TODO(monsieurtanuki): here we impact directly the product share with the previous screen, not nice!
    widget.product.servingSize = servingSize;

    _popEd = false;
    final Status? status = await _openUpdateDialog();
    if (status == null) {
      // probably the end user stopped the dialog
      return;
    }
    if (status.error != null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: ListTile(
            leading: const Icon(Icons.error),
            title: Text(status.error!),
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context)!.okay,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(AppLocalizations.of(context)!.nutrition_page_update_done),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
              text: AppLocalizations.of(context)!.okay,
              onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  late bool _popEd;

  Future<Status?> _openUpdateDialog() async => showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          Future<Status?>.delayed(const Duration(seconds: 2), () => Status()
              /* TODO(monsieurtanuki): put back the actual call
          OpenFoodAPIClient.saveProduct(
            ProductQuery.getUser(),
            widget.product,
           */
              ).then<void>(
            (final Status? status) => _popUpdatingDialog(status),
          );
          return _getUpdatingDialog();
        },
      );

  void _popUpdatingDialog(final Status? status) {
    // TODO(monsieurtanuki): make a class of that process (Future, open dialog, close, error, result)
    if (_popEd) {
      return;
    }
    _popEd = true;
    // Here we use the root navigator so that we can pop dialog while using multiple navigators.
    Navigator.of(context, rootNavigator: true).pop(status);
  }

  Widget _getUpdatingDialog() => SmoothAlertDialog(
        close: false,
        body: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(
              '${AppLocalizations.of(context)!.nutrition_page_update_running}'
              ' (in fact just waiting 2 seconds)'),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context)!.stop,
            onPressed: () => _popUpdatingDialog(null),
          ),
        ],
      );
}
