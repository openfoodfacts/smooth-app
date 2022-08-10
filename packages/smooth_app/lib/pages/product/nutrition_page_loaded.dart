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
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(
    this.product,
    this.orderedNutrients,
  );

  final Product product;
  final OrderedNutrients orderedNutrients;

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

  // If true then serving, if false then 100g.
  bool _servingOr100g = false;

  double getColumnSizeFromContext(
    BuildContext context,
    double adjustmentFactor,
  ) {
    final double columnSize = MediaQuery.of(context).size.width;
    return columnSize * adjustmentFactor;
  }

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _nutritionContainer = _getFreshContainer();
    _numberFormat = NumberFormat('####0.#####', ProductQuery.getLocaleString());
    _noNutritionData = _product.noNutritionData ?? false;
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
        appBar: AppBar(
          title: AutoSizeText(
            appLocalizations.nutrition_page_title,
            maxLines: 2,
          ),
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
              _servingOr100g,
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
    final bool perServing,
    final int position,
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
    final TextEditingController controller = TextEditingController();
    controller.text = _nutritionContainer.servingSize ?? '';
    _controllers[NutritionContainer.fakeNutrientIdServingSize] = controller;
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
                      close: true,
                      title: appLocalizations.nutrition_page_add_nutrient,
                      body: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              enabledBorder: const UnderlineInputBorder(),
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
                          ...List<ListTile>.generate(
                            filteredList.length,
                            (int index) {
                              final OrderedNutrient nutrient =
                                  filteredList[index];
                              return ListTile(
                                title: Text(nutrient.name!),
                                onTap: () =>
                                    Navigator.of(context).pop(nutrient),
                              );
                            },
                          ),
                        ],
                      ),
                      negativeAction: SmoothActionButton(
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
      );

  Product? _getChangedProduct() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    // We use a separate fresh container here.
    // If something breaks while saving, we won't get a half written object.
    final NutritionContainer output = _getFreshContainer();
    // we copy the values
    for (final String key in _controllers.keys) {
      final TextEditingController controller = _controllers[key]!;
      output.setControllerText(key, controller.text);
    }
    // we copy the "with nutrition data true/false"
    output.noNutritionData = _noNutritionData;
    // we copy the units
    output.copyUnitsFrom(_nutritionContainer);
    return output.getProduct();
  }

  NutritionContainer _getFreshContainer() => NutritionContainer(
        orderedNutrients: widget.orderedNutrients,
        product: _product,
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
    final Product? changedProduct = _getChangedProduct();
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
    return ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: changedProduct,
    );
  }
}
