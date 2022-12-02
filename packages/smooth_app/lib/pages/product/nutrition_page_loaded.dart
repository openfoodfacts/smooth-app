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
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_add_nutrient_button.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(
    this.product,
    this.orderedNutrients, {
    required this.isLoggedInMandatory,
  });

  final Product product;
  final OrderedNutrients orderedNutrients;
  final bool isLoggedInMandatory;

  @override
  State<NutritionPageLoaded> createState() => _NutritionPageLoadedState();

  /// Shows the nutrition page after loading the ordered nutrient list.
  static Future<void> showNutritionPage({
    required final Product product,
    required final bool isLoggedInMandatory,
    required final State<StatefulWidget> widget,
  }) async {
    if (!widget.mounted) {
      return;
    }
    if (isLoggedInMandatory) {
      if (!await ProductRefresher().checkIfLoggedIn(widget.context)) {
        return;
      }
    }
    if (!widget.mounted) {
      return;
    }
    final OrderedNutrientsCache? cache =
        await OrderedNutrientsCache.getCache(widget.context);
    if (!widget.mounted) {
      return;
    }
    if (cache == null) {
      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(widget.context).nutrition_cache_loading_error,
          ),
        ),
      );
      return;
    }
    await Navigator.push<void>(
      widget.context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NutritionPageLoaded(
          product,
          cache.orderedNutrients,
          isLoggedInMandatory: isLoggedInMandatory,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded> {
  // we admit both decimal points
  // anyway, the keyboard will only show one
  static final RegExp _decimalRegExp = RegExp(r'[\d,.]');

  late final NumberFormat _numberFormat;
  late final NutritionContainer _nutritionContainer;

  double getColumnSizeFromContext(
    BuildContext context,
    double adjustmentFactor,
  ) {
    final double columnSize = MediaQuery.of(context).size.width;
    return columnSize * adjustmentFactor;
  }

  final Map<Nutrient, TextEditingControllerWithInitialValue> _controllers =
      <Nutrient, TextEditingControllerWithInitialValue>{};
  TextEditingControllerWithInitialValue? _servingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _nutritionContainer = NutritionContainer(
      orderedNutrients: widget.orderedNutrients,
      product: _product,
    );
    _numberFormat = NumberFormat('####0.#####', ProductQuery.getLocaleString());
  }

  @override
  void dispose() {
    for (final TextEditingControllerWithInitialValue controller
        in _controllers.values) {
      controller.dispose();
    }
    _servingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];

    // List of focus nodes for all text fields except the serving one.
    final List<FocusNode> focusNodes;

    children.add(_switchNoNutrition(appLocalizations));

    if (!_nutritionContainer.noNutritionData) {
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
      children.add(
        NutritionAddNutrientButton(
          nutritionContainer: _nutritionContainer,
          refreshParent: () => setState(() {}),
        ),
      );
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
    final int position,
  ) {
    final Nutrient nutrient = _getNutrient(orderedNutrient);

    if (_controllers[nutrient] == null) {
      final double? value = _nutritionContainer.getValue(nutrient);
      _controllers[nutrient] = TextEditingControllerWithInitialValue(
        text: value == null ? '' : _numberFormat.format(value),
      );
    }
    final TextEditingControllerWithInitialValue controller =
        _controllers[nutrient]!;

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
    final Unit unit =
        _nutritionContainer.getUnit(_getNutrient(orderedNutrient));
    return ElevatedButton(
      onPressed: _nutritionContainer.isEditableWeight(unit)
          ? () => setState(
              () => _nutritionContainer.setNextWeightUnit(orderedNutrient))
          : null,
      child: Text(
        _getUnitLabel(unit),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _getServingField(final AppLocalizations appLocalizations) {
    final String value = _nutritionContainer.servingSize;

    if (_servingController != null) {
      _servingController!.text = value;
    } else {
      _servingController = TextEditingControllerWithInitialValue(text: value);
    }

    final TextEditingControllerWithInitialValue controller =
        _servingController!;

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
              child: Text(
                appLocalizations.nutrition_page_per_100g,
                style: _nutritionContainer.perSize == PerSize.oneHundredGrams
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : null,
              ),
            ),
          ),
          Switch(
            value: _nutritionContainer.perSize == PerSize.serving,
            onChanged: (final bool value) => setState(
              () => _nutritionContainer.perSize =
                  value ? PerSize.serving : PerSize.oneHundredGrams,
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                appLocalizations.nutrition_page_per_serving,
                style: _nutritionContainer.perSize == PerSize.serving
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : null,
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
              value: _nutritionContainer.noNutritionData,
              onChanged: (final bool value) =>
                  setState(() => _nutritionContainer.noNutritionData = value),
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

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() {
    if (_servingController != null && _servingController!.valueHasChanged) {
      return true;
    }
    for (final TextEditingControllerWithInitialValue controller
        in _controllers.values) {
      if (controller.valueHasChanged) {
        return true;
      }
    }
    return _nutritionContainer.isEdited();
  }

  Product? _getChangedProduct(Product product) {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    for (final Nutrient nutrient in _controllers.keys) {
      final TextEditingControllerWithInitialValue controller =
          _controllers[nutrient]!;
      _nutritionContainer.setNutrientValueText(
        nutrient,
        controller.text,
        _numberFormat,
      );
    }
    if (_servingController != null) {
      _nutritionContainer.setServingText(_servingController?.text);
    }
    return _nutritionContainer.getChangedProduct(product);
  }

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
    if (!mounted) {
      return false;
    }

    final Product? changedProduct =
        _getChangedProduct(Product(barcode: widget.product.barcode));
    if (changedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // here I cheat and I reuse the only invalid case.
          content: Text(appLocalizations.nutrition_page_invalid_number),
        ),
      );
      return false;
    }
    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
    );
    return true;
  }

  // cf. https://github.com/openfoodfacts/smooth-app/issues/3387
  Nutrient _getNutrient(final OrderedNutrient orderedNutrient) {
    if (orderedNutrient.nutrient != null) {
      return orderedNutrient.nutrient!;
    }
    if (orderedNutrient.id == 'energy') {
      return Nutrient.energyKJ;
    }
    throw Exception('unknown nutrient for "${orderedNutrient.id}"');
  }
}
